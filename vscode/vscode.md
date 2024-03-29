# VSCode settings


## Code navigation settings for HLS

1. edit or create ./.vscode/c_cpp_properties.json

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
        }
    ],
    "version": 4
}
```


## Debug settings for HLS

1. `sudo apt-get install -y gdb`
1. edit or create ./.vscode/launch.json

```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(gdb) SHLS",
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
        }
    ]
}
```


## Install packages & settings

* vscode &rarr;File&rarr;Preferences &rarr; settings &rarr; Enter the string:"Files: Trim Trailing  Whitespace" and set check
* vscode &rarr;File&rarr;Preferences &rarr; settings &rarr; Enter the string:"Render Whitespace" and set all
* [git Graph](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph)
* [git History](https://marketplace.visualstudio.com/items?itemName=donjayamanne.githistory)
* [cpptools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
    1. select cpp file
    1. Shift + Alt + F
        1. configure & select the required formatter
* [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
    1. select markdown file
    1. Shift + Alt + F
        1. configure & select the required formatter
* [markdown-navigation](https://marketplace.visualstudio.com/items?itemName=AlanWalk.markdown-navigation)
* [markdown-preview-enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced)
* [TOML Language Support](https://marketplace.visualstudio.com/items?itemName=be5invis.toml)
* [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
* [SystemRDL](https://marketplace.visualstudio.com/items?itemName=amykyta3.systemrdl)
* [hightlight do file (modelsim)](https://marketplace.visualstudio.com/items?itemName=Jiang-Percy.Verilog-Hdl-Format)
* [Verilog Formatter](https://marketplace.visualstudio.com/items?itemName=kukdh1.verible-formatter)
    - [download tools linux-static-x86_64.tar.gz](https://github.com/chipsalliance/verible/releases)
    - `tar -xvzf <path to arch> -C ~/Downloads`
    - `sudo cp -rv ~/Downloads/verible-v0.0-3584-g8d7ea9b4/bin /usr/local/bin`
* [Tcl](https://marketplace.visualstudio.com/items?itemName=bitwisecook.tcl)
    1. select cpp file
    1. Shift + Alt + F
        1. configure & select the required formatter
* [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
* [C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
* [C++ Lint](https://marketplace.visualstudio.com/items?itemName=jbenden.c-cpp-flylint)
    1. [install CppCheck](https://cppcheck.sourceforge.io/)
* [Remove empty lines](https://marketplace.visualstudio.com/items?itemName=usernamehw.remove-empty-lines)
* [Cpplint](https://marketplace.visualstudio.com/items?itemName=mine.cpplint)
