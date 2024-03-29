# Info


## vscode setting workspace for new project

1. `cd <directory new project>`
1. create ./.vscode
1. cp `<path>`/knowlage_base/vscode/setting.json ./.vscode
1. cp `<path>`/knowlage_base/vscode/.clang-format ./
1. cp `<path>`/knowlage_base/vscode/.markdownlint.json ./
1. cp `<path>`/knowlage_base/vscode/.verilog_format ./


## [my packages and settings](./vscode.md)


## Windows (setting vscode)

* C:\Users\User\AppData\Roaming\Code\User


## Code navigator

1. Ubuntu
    1. `touch c_cpp_properties.json`
    1. edit c_cpp_properties.json

    ``` json
    {
        "configurations": [
            {
                "name": "SHLS",
                "includePath": [
                    "${workspaceFolder}/**",
                    "/opt/microchip/SmartHLS/smarthls-library"
                ],
                "defines": [],
                "compilerPath": "/opt/rh/devtoolset-9/root/usr/bin/g++",
                "cStandard": "c17",
                "cppStandard": "c++11",
                "intelliSenseMode": "linux-gcc-x64",
                "configurationProvider": "ms-vscode.makefile-tools"
            },
            {
                "name": "HLS-Xilinx",
                "includePath": [
                    "${workspaceFolder}/**",
                    "/opt/xilinx/Vitis_HLS/2023.2/include",
                    "/opt/xilinx/Vitis_HLS/2023.2/include/etc",
                    "/opt/xilinx/Vitis_HLS/2023.2/lnx64/tools/auto_cc/include",
                    "/opt/xilinx/Vitis_HLS/2023.2/tps/lnx64/gcc-8.3.0/include",
                    "/opt/xilinx/Vitis_HLS/2023.2/tps/lnx64/gcc-8.3.0/include/c++/8.3.0",
                    "/opt/xilinx/Vitis_HLS/2023.2/tps/lnx64/gcc-8.3.0/include/c++/8.3.0/backward",
                    "/opt/xilinx/Vitis_HLS/2023.2/tps/lnx64/gcc-8.3.0/include/c++/8.3.0/x86_64-pc-linux-gnu",
                    "/opt/xilinx/Vitis_HLS/2023.2/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/include",
                    "/opt/xilinx/Vitis_HLS/2023.2/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/include-fixed"
                ],
                "defines": [],
                "compilerPath": "/opt/rh/devtoolset-9/root/usr/bin/g++",
                "cStandard": "c17",
                "cppStandard": "c++11",
                "intelliSenseMode": "linux-gcc-x64",
                "configurationProvider": "ms-vscode.makefile-tools"
            }
        ],
        "version": 4
    }
    ```

    1. mv c_cpp_properties.json ./.vscode

1. VSCode
    1. Install package [cpptools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)


## Debug Code

1. `sudo apt-get install -y gdb`
1. edit or create ./.vscode/launch.json

``` json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: <https://go.microsoft.com/fwlink/?linkid=830387>
    "version": "0.2.0",
    "configurations": [
        {
            "name": "SHLS (gdb)",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/fpga/src/thp/hls_output/.hls/thp.sw_binary",
            "environment": [
                {
                    "name": "LD_LIBRARY_PATH",
                    "value": "/opt/microchip/SmartHLS/smarthls-library/hls;/opt/microchip/SmartHLS/dependencies/gcc/lib64"
                }
            ],
            "args": [
                "-i${workspaceRoot}/fpga/samples/random_frames/random_frames.raw",
                "-o${workspaceRoot}/fpga//src/hls/build/hls-output.raw",
                "-p${workspaceRoot}/fpga//src/hls/config_pl.toml",
                "-v1",
                "-s0",
                "-e2",
                // "-c0",
                //"-l10",
                // "-f3",
            ],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description":  "Set Disassembly Flavor to Intel",
                    "text": "-gdb-set disassembly-flavor intel",
                    "ignoreFailures": true
                }
            ]
        },
        {
            "name": "HLS-Xilinx (gdb)",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/src/hls/build/hls/csim/build/csim.exe",
            "environment": [],
            "args": [
                "-i${workspaceRoot}/samples/random_frames/random_frames.raw",
                "-o${workspaceRoot}/src/hls/build/hls-output.raw",
                "-p${workspaceRoot}/src/hls/config_pl.toml",
                "-v1",
                "-s0",
                "-e2",
                // "-c0",
                //"-l10",
                // "-f3",
            ],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description":  "Set Disassembly Flavor to Intel",
                    "text": "-gdb-set disassembly-flavor intel",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
```
