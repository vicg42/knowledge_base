#!/bin/bash

USER_MAC_ADDRESS=00:15:5d:2a:fc:a4
# USR_MAC_ADDRES=/etc/wsl.mac.txt
# if [[ ! -s $USR_MAC_ADDRES ]]; then
#     #echo "save mac addres.This addres will be user mac address"
#     touch $USR_MAC_ADDRES
#     ifconfig | grep ether | awk '{print $2}' >> $USR_MAC_ADDRES
# fi

if ! ifconfig -a | grep bond0; then
    #echo "add bond0"
    #https://github.com/microsoft/WSL/issues/9989#issuecomment-1513961916
    ip link add name bond0 type bond mode active-backup
fi

# #https://github.com/microsoft/WSL/issues/5352#issuecomment-1076336583
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
