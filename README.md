# gen-wireguard

Simple hub-and-spoke wireguard configuration generator. Quickly generate the required keys and configuration files for one or more clients in a traditional server-client VPN setup.

# Requirements

Required dependencies:

- wireguard-tools

# Usage

`gen-wireguard.sh` needs a number of positional arguments:

```
    Usage: ./gen-wireguard.sh [output directory] [server ip] [clients (1-253, optional)]

    > ./gen-wireguard.sh example 172.16.192.1
    > ls example

    client1.conf  server.conf
```

Environment variables can be set to modify default behavior:

```
    NET         IPv4 range assigned to wireguard interfaces, (str) IPv4 net/24, default "10.9.0"
    PORT        Server port, (int) UDP port, default 5182
    KEEPALIVE   PersistentKeepalive, (int) seconds, default 0
```

A configuration with three clients, a `PersistentKeepalive` of 25 seconds, in IPv4 range 10.192.0.0/24, for example:

```
    > KEEPALIVE=25 NET="10.192.0" ./gen-wireguard.sh example 172.16.192.1 3
```