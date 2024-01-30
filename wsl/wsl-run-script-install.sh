#!/bin/bash

WSL_CONF_FILE=wsl.conf
WSL_RUN_SCRIPT=wsl-run-script.sh
WSL_MAC_FILE=wsl.mac

stty -echo
read -p "Enter password for root user: " PASS
stty echo
echo ""

if [[ ! -f ./$WSL_CONF_FILE ]]; then
    echo "Error: can't find ./$WSL_CONF_FILE"
    exit 1
fi

if [[ ! -f ./$WSL_RUN_SCRIPT ]]; then
    echo "Error: can't find ./$WSL_RUN_SCRIPT"
    exit 1
fi

if [[ ! -f ./$WSL_MAC_FILE ]]; then
    echo "Error: can't find ./$WSL_MAC_FILE"
    exit 1
fi

for arg in mc tmux net-tools
do
    dpkg -s $arg &> /dev/null
    if [[ ! $? -eq 0 ]]; then
        echo "----- Install $arg -----"
        echo $PASS | sudo -S apt-get install -y $arg
    fi
done

if [[ ! -f /etc/$WSL_CONF_FILE ]]; then
    echo $PASS | sudo -S cp -v ./$WSL_CONF_FILE /etc/
else
    echo "Error: /etc/$WSL_CONF_FILE has alrady exited"
fi

if [[ ! -f /etc/$WSL_RUN_SCRIPT ]]; then
    echo $PASS | sudo -S cp -v ./$WSL_RUN_SCRIPT /etc/
else
    echo "Error: /etc/$WSL_RUN_SCRIPT has alrady exited"
fi

if [[ ! -f /etc/$WSL_MAC_FILE ]]; then
    echo $PASS | sudo -S cp -v ./$WSL_MAC_FILE /etc/
else
    echo "Error: /etc/$WSL_MAC_FILE has alrady exited"
fi

exit 0
