#!/bin/bash

WSL_CONF_FILE=wsl.conf
WSL_MAC_FILE=wsl.mac.sh
DST_PATH=/etc

if [[ ! -f $DST_PATH/$WSL_CONF_FILE ]]; then
    if [[ ! -f $WSL_CONF_FILE ]]; then
        echo "Error: can't find $$WSL_CONF_FILE"
        exit 1
    fi
    sudo cp -v $WSL_CONF_FILE $DST_PATH/$WSL_CONF_FILE
else
    echo "Error: $DST_PATH/$WSL_CONF_FILE has alrady exited"
fi

if [[ ! -f $DST_PATH/$WSL_MAC_FILE ]]; then
    if [[ ! -f $WSL_MAC_FILE ]]; then
        echo "Error: can't find $$WSL_MAC_FILE"
        exit 1
    fi
    sudo cp -v $WSL_MAC_FILE $DST_PATH/$WSL_MAC_FILE
else
    echo "Error: $DST_PATH/$WSL_MAC_FILE has alrady exited"
fi