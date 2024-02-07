# HLS
## Vitis Unified Software Platform
### Command line
#### compile
1. Help

``` txt
v++ -c --mode hls -h
usage: v++ [options] <input file...>

Generic options:
  -D [ --define ] arg     <name=definition> Predefine name as a macro with
                          definition. This option is passed to the openCL
                          preprocessor.
  -I [ --include ] arg    Add the directory to the list of directories to be
                          searched for header files. This option is passed to
                          the openCL preprocessor
  -c [ --compile ]        Run a compile mode
  -h [ --help ]           Print usage message
  -o [ --output ] arg     Set output file name. Default: a.xclbin (link,
                          build), a.xo (compile)
  -v [ --version ]        Print version information
  --config arg            Config file
  --input_files arg       Specify input file(s). Input file(s) can also be
                          specified positionally without using the
                          --input_files option.
  --log_dir arg           Specify a directory to copy internally generated log
                          files to
  --report_dir arg        Specify a directory to copy report files to
  --work_dir arg          Specify a working directory for output files and
                          directories

Options allowed in a config file:

  --part arg              Specify a part

[hls] section:
  --hls.* arg             Specify hls options
```
1. Example
    1. run vitis
    ``` bash
    source /home/program/Vitis/2023.2/settings64.sh
    export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LIBRARY_PATH
    ```
    1. run compile
    ``` bash
    v++ -c --mode hls --config ./hls_config.cfg --work_dir ./
    ```

#### simulation
1. Help

``` txt
vitis-run --mode hls -h
usage: vitis-run [options] <input file...>

Generic options:
  -h [ --help ]           Print usage message
  -v [ --version ]        Print version information
  --config arg            Config file
  --cosim                 Specify hls run option cosim
  --csim                  Specify hls run option csim
  --impl                  Specify hls run option impl for vivado ooc
  --input_file arg        Specify an input file as positional argument with
                          --tcl.
  --mode arg              [hls] Specify a mode.
  --package               Specify hls run option package
  --tcl                   Option to support Tcl script flow
  --work_dir arg          Specify a working directory for output files and
                          directories

Options allowed in a config file:

  --part arg              Specify a part
  --platform		    Specify a platform to define the part

[hls] section:
  --hls.* arg             Specify hls options
```
1. Example
    1. run vitis
    ``` bash
    source /home/program/Vitis/2023.2/settings64.sh
    export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LIBRARY_PATH
    ```
    1. run compile
    ``` bash
    vitis-run --mode hls --csim --config ./hls_config.cfg --work_dir ./
    ```

1. Example
    1. run vitis
    ``` bash
    source /home/program/Vitis/2023.2/settings64.sh
    export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LIBRARY_PATH
    vitis_hls -f ./run_hls.tcl
    ```
