# WSL

## Install Ubuntu, GUI xfce

1. Install WSL
    * Windows(Start) &rarr; Microsoft Store &rarr; Windows Subsystem for Linux
1. [install chocolatey](https://chocolatey.org/install#individual)
1. open PowerShell (Administration Mode)
    * `choco install chocolateygui`
1. Run Chocolatey GUI
    * Windows(Start) &rarr; Chocolatey GUI
        1. Select chocolatey
        1. Search: ubuntu
            * install ubunto 20.4.0.20220127
1. run Ubuntu
    * Windows(Start) &rarr; Ubuntu
        1. `mkdir -p ~/work/_install && cd ~/work`
        1. `sudo apt update && sudo apt -y upgrade`
        1. [download wsl-xfce-gui-install.sh](https://github.com/vicg42/knowledge_base/blob/master/wsl/wsl-xfce-gui-install.sh)
        1. `cp /mnt/<path to wsl-xfce-gui-install.sh> ~/work/_install/ && cd ~/work/_install`
        1. `./wsl-xfce-gui-install.sh`

## Run xfce GUI

1. Install Windows Terminal
    * Windows(Start) &rarr; Microsoft Store &rarr; Windows Terminal
1. Run Windows Terminal
    * Windows(Start) &rarr; Terminal
        1. `wsl`
        1. `sudo /etc/init.d/xrdp start`
        1. run Remote Desktop Connection\
            * Windows(Start) &rarr; Remote Desktop Connection (localhost:3390)

## Settings xfce GUI

1. Application &rarr; Settings &rarr; Light Locker Settings &rarr; Enable light-locker --- (OFF)
1. Application &rarr; Settings &rarr; Keyboard &rarr; Layout &rarr; Use system defaults --- (Uncheck)
1. Application &rarr; Settings &rarr; Keyboard &rarr; Layout &rarr; Keyboard layout &rarr; Add --- (Russian)
1. Application &rarr; Settings &rarr; Keyboard &rarr; Layout &rarr; Change layout option --- (Alt + Shift)
1. Application &rarr; Terminal Emulator &rarr; Edit &rarr; Preference &rarr; General &rarr; Enable the menu accelerator key (F10 by default) --- (Uncheck)
1. Application &rarr; Terminal Emulator &rarr; Edit &rarr; Preference &rarr; General &rarr; Theme variant --- (Dark)
1. Application &rarr; Desktop &rarr; Background  --- (choose what you like)
1. Move mouse to the task bar and push right button.
    * Panel &rarr; Add New Items &rarr; Keyboard Layouts

## Change mac address WSL

1. `cd ~/work`
1. [download wsl.conf](https://github.com/vicg42/knowledge_base/blob/master/wsl/wsl.conf)
1. [download wsl-run-script.sh](https://github.com/vicg42/knowledge_base/blob/master/wsl/wsl-run-script.sh)
1. [download wsl-run-script-install.sh](https://github.com/vicg42/knowledge_base/blob/master/wsl/wsl-run-script-install.sh)
1. `cp /mnt/<path to wsl-run-script.sh .. > ./`
1. `touch ./wsl.mac`
    * add mac address. (mac address format:  xx:xx:xx:xx:xx:xx)

## Backup/Restore

### Backup WSL

1. open PowerShell (Administration Mode)
1. `wsl -l -v`
1. `wsl --export <DISTRO-NAME> <PATH\FILE-NAME.tar>`

### Restore WSL

1. open PowerShell (Administration Mode)
1. `wsl --unregister DISTRO-NAME`
1. `wsl --import <DISTRO-NAME> <Path to path current ext4.vhdx> <Path to backup archive (*.tar)>`
1. open Windows Terminal
1. `wsl`
1. `su - user`

### [Send Clipboard (WSL GUI <> Windows)](https://github.com/microsoft/WSL/issues/4440#issuecomment-638956838)

1. Run xfce GUI WSL
1. curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
1. unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
1. chmod +x /tmp/win32yank.exe
1. sudo mv /tmp/win32yank.exe /bin/

### [Chrome install](https://askubuntu.com/questions/510056/how-to-install-google-chrome)

1. wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
1. echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
1. sudo apt-get update
1. sudo apt-get install google-chrome-stable

### Install Xilinx

1. start WSL GUI(XFCE)
1. `sudo mkdir /home/program`
1. `sudo chmod 777 /home/program`
1. `sudo mkdir /mnt/iso`
1. `sudo chmod 777 /mnt/iso`
1. `sudo mount <path to Xilinx install iso file> /mnt/iso`
1. `/mnt/iso/xsetup`
    * select Vitis for install
    * select Devices
    * Select the installation directory: /home/program
1. `source /home/program/Vitis/<release>/settings64.sh`
1. `vlm`
    * Load License &rarr; Copy License  --- (Path to License)
1. `sudo /home/program/Vitis/<release>/scripts/installLibs.sh`
<!-- 1. [Download Xilinx Runtime (XRT) and install](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-platforms.html)
    * `sudo dpkg -i <*.deb>` -->

### Run Xilinx Vitis

``` sh
source /home/program/Vitis/<release>/settings64.sh
#source /opt/xilinx/xrt/setup.sh
export LIBRARY=/usr/lib/x86_64-linux-gnu
vitis -w <>
```


### Info

* [To see all the distributions you have installed, go to PowerShell and run](https://askubuntu.com/questions/1380253/where-is-wsl-located-on-my-computer):

``` powershell
Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss" -Recurse
```
