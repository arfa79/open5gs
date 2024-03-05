#!/bin/bash
meson build --prefix=/home/infra/open5gs/install
ninja -C build install
sudo systemctl start mongod
sudo ip tuntap add name ogstun mode tun
sudo ip addr add 10.45.0.1/16 dev ogstun
sudo ip addr add 2001:db8:cafe::1/48 dev ogstun
sudo ip link set ogstun up
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
sudo ip6tables -t nat -A POSTROUTING -s 2001:db8:cafe::/48 ! -o ogstun -j MASQUERADE
sudo iptables -I INPUT -i ogstun -j ACCEPT
sudo iptables -I INPUT -s 10.45.0.0/16 -j DROP
./build/tests/attach/attach
./build/tests/registration/registration
meson test -v
ninja -C build test
ps -ef | grep open5gs
echo all executed