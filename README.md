# gen-wireguard

Simple hub-and-spoke wireguard key and configuration generator. Quickly generate the required config files for one or more clients.

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

A number of environment variables can be set to modify default behavior:

```
    NET         IPv4 range assigned to wireguard interfaces, (str) IPv4 net/24, default "10.9.0"
    PORT        Server port, (int) UDP port, default 5182
    KEEPALIVE   PersistentKeepAlive, (int) seconds, default 0
```

To generate a configuration with three clients, a `PersistentKeepAlive` of 25 seconds, in IPv4 range 10.192.0.x, for example:

```
    > KEEPALIVE=25 NET="10.192.0" ./gen-wireguard.sh example 172.16.192.1 3
```