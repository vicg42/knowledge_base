#!/bin/bash

USR_MAC_ADDRES_FILE=/etc/wsl.mac.txt
if [[ ! -f /etc/wsl.mac.txt ]]; then
    echo "Error: can't find $USR_MAC_ADDRES_FILE"
    exit 1
fi

# mac addres format:  xx:xx:xx:xx:xx:xx
USR_MAC_ADDRES=$(cat /etc/wsl.mac.txt)

if ! ifconfig -a | grep bond0; then
    #https://github.com/microsoft/WSL/issues/9989#issuecomment-1513961916
    ip link add name bond0 type bond mode active-backup
fi

#https://github.com/microsoft/WSL/issues/5352#issuecomment-1076336583
gateway=$(ip route | awk '/default via /{print $3; exit}' 2>/dev/null)
if ! ip link show | grep $USER_MAC_ADDRESS; then
    sudo ip link set dev eth0 down || exit 1
    sudo ip link set dev eth0 name eth1 || exit 1
    sudo ip link set dev eth1 up || exit 1
    sudo ip route add default via $gateway dev eth1 || exit 1
    sudo ip link set dev bond0 down || exit 1
    sudo ip link set dev bond0 address $USER_MAC_ADDRESS || exit 1
    sudo ip link set dev bond0 name eth0 || exit 1
    sudo ip link set dev eth0 up || exit 1
fi

exit 0
