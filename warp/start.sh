#!/bin/bash
set -x

# 1. Create and configure the TUN device
ip tuntap add mode tun dev tun0
ip addr add 192.168.200.1/24 dev tun0
ip link set dev tun0 up

# 2. Get the IP address of the 'tor' container and the default gateway
# This is crucial to ensure tun2socks can reach Tor without going through the tunnel itself.
TOR_IP=$(getent hosts tor | awk '{ print $1 }')
DEFAULT_GW=$(ip route | grep default | awk '{print $3}')

# 3. Add a specific route for the Tor SOCKS proxy to go through the original gateway (use ifconfig to find it).
# This prevents a routing loop.
ip route add $TOR_IP/32 via $DEFAULT_GW dev enp5s0

# 4. Make the TUN device the new default route for all other traffic
ip route add default dev tun0

# 5. Start tun2socks in the background.
# It captures all traffic from tun0 and forwards it to the Tor SOCKS proxy.
nohup tun2socks -device tun://tun0 -proxy socks5://tor:9050 &

# 6. Start the warp-plus application.
# Its traffic will be captured by tun0, processed by tun2socks, and sent to Tor.
# It binds to 0.0.0.0:8086 to be accessible from the host machine.
./warp-plus --bind 0.0.0.0:8086 --verbose