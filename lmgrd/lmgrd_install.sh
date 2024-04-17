#!/bin/bash

sudo mkdir -p /opt/lmgrd/bin
sudo cp -v ./bin/lmutil /opt/lmgrd/bin
sudo cp -v ./bin/lmgrd /opt/lmgrd/bin
sudo cp -v ./* /opt/lmgrd
sudo cp -v /opt/lmgrd/lmgrd.service /etc/systemd/system/
sudo chown -R ${USER}:${USER} /opt/lmgrd

exit 0