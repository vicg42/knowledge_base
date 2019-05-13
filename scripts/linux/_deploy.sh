#!/bin/bash
#
# authors:    Victor Golovachenko
#

#sshpass -p "root" scp -q ./configuration/configuration root@10.0.0.1:/home/root || exit 1
#sshpass -p "root" scp -q ./communication/communication root@10.0.0.1:/home/root || exit 1
sshpass -p "root" scp -q ./configuration/configuration root@192.168.1.69:/home/root || exit 1
sshpass -p "root" scp -q ./communication/communication root@192.168.1.69:/home/root || exit 1
sshpass -p "root" scp -q ./device_ctrl/tests/test_fpga_reg root@192.168.1.69:/home/root || exit 1
sshpass -p "root" scp -q ./device_ctrl/tests/fpga_get_firmware.sh root@192.168.1.69:/home/root || exit 1
#sshpass -p "root" scp -q ./device_ctrl/tests/hello_world root@192.168.1.69:/home/root || exit 1
