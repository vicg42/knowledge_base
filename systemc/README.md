# SystemC
## instalation (Windows10)
1. install and config Msys2
    1. open Chocolaty GUI, install Msys2, Gnu Make
    1. open console Msys2 (press WinStart and type Msys2)
        1. update main package of Msys2 (https://librebay.blogspot.com/2018/12/install-msys2-for-windows.html?m=1)
            * pacman -Syu
        1. install packege:
            1. pacman -S mingw-w64-x86_64-gcc
            1. pacman -S mingw-w64-x86_64-gdb
            1. pacman -S mingw-w64-x86_64-make
            1. pacman -S mingw-w64-x86_64-binutils
            1. pacman -S mingw-w64-x86_64-gcc-libs
    1. Add the path to your Mingw-w64 bin folder to the Windows PATH environment variable by using the following steps: (https://code.visualstudio.com/docs/cpp/config-mingw)
        1. In the Windows search bar, type 'settings' to open your Windows Settings.
        1. Search for Edit environment variables for your account.
        1. Choose the Path variable in your User variables and then select Edit.
        1. Select New and add the Mingw-w64 destination folder path to the system path. The exact path depends on which version of Mingw-w64 you have installed and where you installed it. If you used the settings above to install Mingw-w64, then add this to the path: C:\msys64\mingw64\bin.
        1. Select OK to save the updated PATH. You will need to reopen any console windows for the new PATH location to be available
    1. open windows cmd.exe
        1. g++ -v
        1. gcc -v
        1. gdb -v
        1. make -v
1. https://www.accellera.org/downloads/standards/systemc   download systemc-2.3.3.zip
1. unzip systemc-2.3.3.zip to d:/Setup/SoftWork
1. create dir d:/Setup/SoftWork/sysc
1. open console mingw64 Msys2:
    * in WindowsSatrt type MSYS2 MinGW x64  or  C:\msys64\mingw64.exe
1. ../configure --preefix=/d/Setup/SoftWork/sysc
1. make
1. make install

## build app
1. open console mingw64 Msys2 [* in WindowsSatrt type MSYS2 MinGW x64  or  C:\msys64\mingw64.exe]
1. cd /d/Work/test/systemc/hello
1. make
1. ./teset/exe

## Miscellaneous
# [Msys2 packages](https://packages.msys2.org/queue)