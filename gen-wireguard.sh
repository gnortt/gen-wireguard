#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 [options] <output_directory> <server_ip>

    Options:
      -c    number of clients, 1 (default) to 253
      -k    keepalive timeout, default 0 (disabled) seconds
      -n    ip range, default 10.9.0
      -p    server udp port, default 5182"
    exit 1
}

while getopts "c:k:n:p:" flag; do
    case "$flag" in
        c)  CLIENTS=$OPTARG;;
        k)  KEEPALIVE=$OPTARG;;
        n)  NET=$OPTARG;;
        p)  PORT=$OPTARG;;
        \?) usage;;
    esac
done

shift $((OPTIND - 1))

if [ $# -le 1 ]; then
    usage
fi

OUT_DIR=$1
SERVER_IP=$2

: "${CLIENTS:=1}"
: "${NET:="10.9.0"}"
: "${PORT:=5182}"
: "${KEEPALIVE:=0}"

if [ "$CLIENTS" -gt 254 ] || [ "$CLIENTS" -lt 1 ]; then
    echo "Invalid number of clients: must be between 1 and 253"
    exit 1
fi

if [ $KEEPALIVE -gt 0 ]; then
    KEEPALIVE="PersistentKeepalive=${KEEPALIVE}\n"
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

    echo -e "[Interface]
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
