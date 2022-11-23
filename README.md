# gen-wireguard

Simple hub-and-spoke wireguard configuration generator. Quickly generate the required keys and configuration files for one or more clients in a traditional server-client VPN setup.

# Requirements

Required dependencies:

- wireguard-tools

# Usage

`gen-wireguard.sh` needs a number of positional arguments:

```
    Usage: ./gen-wireguard.sh [options] <output_directory> <server_ip>

        Options:
          -c    number of clients, 1 (default) to 253
          -k    keepalive timeout, default 0 (disabled) seconds
          -n    ip range, default 10.9.0
          -p    server udp port, default 5182

    > ./gen-wireguard.sh example 172.16.192.1
    > ls example

    client1.conf  server.conf
```
