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

echo -e "[Interface]\n" \
"Address = ${NET}.1/24\n" \
"PrivateKey = ${SERVER_KEY}\n" \
"ListenPort = ${PORT}\n" > "$OUT_DIR"/server.conf

for (( C=1; C<=CLIENTS; C++ )); do
    CLIENT_IP=$((C + 1))
    CLIENT_KEY=$(wg genkey)
    CLIENT_PUB=$(echo -n "$CLIENT_KEY" | wg pubkey)
    CLIENT_PSK=$(wg genpsk)

    echo -e "[Interface]\n" \
"Address = ${NET}.${CLIENT_IP}/32\n" \
"PrivateKey = ${CLIENT_KEY}\n\n" \
"[Peer]\n" \
"PublicKey = ${SERVER_PUB}\n" \
"Endpoint = ${SERVER_IP}:${PORT}\n" \
"AllowedIPs = ${NET}.1/32\n" \
"PresharedKey = ${CLIENT_PSK}\n" \
"${KEEPALIVE}" > "$OUT_DIR"/client"$C".conf

    echo -e "[Peer]\n" \
"PublicKey = ${CLIENT_PUB}\n" \
"AllowedIPs = ${NET}.${CLIENT_IP}/32\n" \
"PresharedKey = ${CLIENT_PSK}\n" \
"${KEEPALIVE}\n" >> "$OUT_DIR"/server.conf
done
