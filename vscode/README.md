# VSCode

## Clang
1. Ubuntu
    1. `sudo apt install clang-format`
    1. get path to program
        `whereis clang-format`
1. VSCode
    1. Install package [Clang-Format](https://marketplace.visualstudio.com/items?itemName=xaver.clang-format)
    1. `CTRL + ,`
        1. Type clang in Search setting
        1. Remove [WSL]
        1. Clang-format Exicutable: <path to program>
    1. Shift + Alt + F
        1. configure & select Clang-Format

## Code navigator
1. Ubuntu
    1. `touch c_cpp_properties.json`
    1. edit c_cpp_properties.json
        ``` json
        {
            "configurations": [
                {
                    "name": "Linux",
                    "includePath": [
                        "${workspaceFolder}/**",
                        "/home/program/Vitis_HLS/2023.2/include",
                        "/home/program/Vitis_HLS/2023.2/include/etc",
                        "/home/program/Vitis_HLS/2023.2/lnx64/tools/auto_cc/include",
                        "/home/program/Vitis_HLS/2023.2/tps/lnx64/gcc-8.3.0/include",
                        "/home/program/Vitis_HLS/2023.2/tps/lnx64/gcc-8.3.0/include/c++/8.3.0",
                        "/home/program/Vitis_HLS/2023.2/tps/lnx64/gcc-8.3.0/include/c++/8.3.0/backward",
                        "/home/program/Vitis_HLS/2023.2/tps/lnx64/gcc-8.3.0/include/c++/8.3.0/x86_64-pc-linux-gnu",
                        "/home/program/Vitis_HLS/2023.2/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/include",
                        "/home/program/Vitis_HLS/2023.2/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/include-fixed"
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
