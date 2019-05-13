#!/bin/bash
#
# authors:    Victor Golovachenko
#

FILE1=./communication/communication
FILE2=./configuration/configuration

if [[ ! -f "$FILE1" || ! -f "$FILE2" ]]; then
echo "can't find need files: $FILE1 $FILE2"
fi

mkdir -p ./tmp
cp ./communication/communication ./tmp
cp ./configuration/configuration ./tmp
cp ./device_ctrl/tests/fpga_get_firmware.sh ./tmp
cp ./device_ctrl/tests/test_fpga_reg ./tmp
cp -R ./scritps/* ./tmp

cd ./tmp
tar -czf ./app.tar.gz ./*
cp ./app.tar.gz ../
cd ../

rm -Rf ./tmp