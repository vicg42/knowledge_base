#!/bin/bash

USR_MAC_ADDRES_FILE=/etc/wsl.mac
if [[ ! -f $USR_MAC_ADDRES_FILE ]]; then
    echo "Error: can't find $USR_MAC_ADDRES_FILE"
    exit 1
fi

# mac addres format:  xx:xx:xx:xx:xx:xx
mac=$(cat $USR_MAC_ADDRES_FILE)
if ! ip link show | grep $mac; then
    winip=$(ip route | awk '/default via /{print $3; exit}' 2>/dev/null)
    locnetip=$(ip address show dev eth0 | awk '/inet /{print $2; exit}' 2>/dev/null)

    echo 1 | sudo tee -a /proc/sys/net/ipv4/ip_forward

    sudo ip link add veth1a type veth peer name veth1b
    sudo ip netns add ns0
    sudo ip link set veth1b netns ns0
    sudo ip link set eth0 netns ns0

    sudo ip netns exec ns0 ip link set dev veth1b up
    sudo ip netns exec ns0 ip link set dev eth0 up
    sudo ip netns exec ns0 ip link set lo up
    sudo ip netns exec ns0 ip addr add $locnetip dev eth0
    sudo ip netns exec ns0 ip route add default via $winip dev eth0 proto kernel
    sudo ip netns exec ns0 ip addr add 10.10.10.2/24 dev veth1b

    sudo ip link set dev veth1a name eth0
    sudo ip link set eth0 addr $mac
    sudo ip link set dev eth0 up
    sudo ip addr add 10.10.10.1/24 dev eth0
    sudo ip route add default via 10.10.10.2 dev eth0

    sudo ip netns exec ns0 iptables -A FORWARD -o eth0 -i veth1b -j ACCEPT
    sudo ip netns exec ns0 iptables -A FORWARD -i eth0 -o veth1b -j ACCEPT
    sudo ip netns exec ns0 iptables -t nat -A POSTROUTING -s 10.10.10.1/24 -o eth0 -j MASQUERADE
fi

exit 0
