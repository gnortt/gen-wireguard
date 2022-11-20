#!/usr/bin/env bash

set -e

if [ $# -le 1 ]; then
    echo "Usage: $0 [output directory] [server ip] [clients (1-253, optional)]"
    exit 1
fi

OUT_DIR=$1
SERVER_IP=$2
CLIENTS=${3:-1}

: "${NET:="10.9.0"}"
: "${PORT:=5182}"
: "${KEEPALIVE:=0}"

if [ "$CLIENTS" -gt 254 ] || [ "$CLIENTS" -lt 1 ]; then
    echo "Invalid number of clients: must be between 1 and 253"
    exit 1
fi

if [ $KEEPALIVE -gt 0 ]; then
    KEEPALIVE="PersistentKeepalive="$KEEPALIVE
else
    KEEPALIVE=""
fi

mkdir "$OUT_DIR"
OUT_DIR="$(pwd)/$OUT_DIR"

SERVER_KEY=$(wg genkey)
SERVER_PUB=$(echo -n "$SERVER_KEY" | wg pubkey)

echo -e "[Interface]
Address = ${NET}.1/24
PrivateKey = ${SERVER_KEY}
ListenPort = ${PORT}\n" > "$OUT_DIR"/server.conf

for (( C=1; C<=CLIENTS; C++ )); do
    CLIENT_IP=$((C + 1))
    CLIENT_KEY=$(wg genkey)
    CLIENT_PUB=$(echo -n "$CLIENT_KEY" | wg pubkey)
    CLIENT_PSK=$(wg genpsk)

    echo "[Interface]
Address = ${NET}.${CLIENT_IP}/32
PrivateKey = ${CLIENT_KEY}

[Peer]
PublicKey = ${SERVER_PUB}
Endpoint = ${SERVER_IP}:${PORT}
AllowedIPs = ${NET}.1/32
PresharedKey = ${CLIENT_PSK}
${KEEPALIVE}" > "$OUT_DIR"/client"$C".conf

    echo -e "[Peer]
PublicKey = ${CLIENT_PUB}
AllowedIPs = ${NET}.${CLIENT_IP}/32
PresharedKey = ${CLIENT_PSK}
${KEEPALIVE}" >> "$OUT_DIR"/server.conf
done
