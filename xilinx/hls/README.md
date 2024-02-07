# HLS
## Vitis Unified Software Platform
### WSL (Ubuntu)
1. run vitis
```
source /home/program/Vitis/2023.2/settings64.sh
export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LIBRARY_PATH
```
1. run compile
```
v++ -c --mode hls --config ./hls_config.cfg
```