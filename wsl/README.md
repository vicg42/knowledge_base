# Install WSL, Ubuntu, GUI xfce
1. Windows(Start) &rarr; Microsoft Store &rarr; Windows Subsystem for Linux -- install
1. [install chocolatey](https://chocolatey.org/install#individual)
1. open PowerShell (Administration Mode)
    * `choco install chocolateygui`
1. Windows(Start) &rarr; Chocolatey GUI
    1. Select chocolatey
    1. Search: ubuntu
        * install ubunto 20.4.0.20220127
1. Windows(Start) &rarr; Ubuntu
1. `cd ~/`
1. `sudo apt update && sudo apt -y upgrade`
1. [download wsl-xfce-gui-install.sh](https://github.com/vicg42/knowledge_base/blob/master/wsl/wsl-xfce-gui-install.sh)
1. `cp /mnt/<path to wsl-xfce-gui-install.sh> ./`
1. `./wsl-xfce-gui-install.sh`

# Run xfce GUI
1. Windows(Start) &rarr; Microsoft Store &rarr; Windows Terminal -- install
1. Windows(Start) &rarr; Terminal
1. `wsl`
1. `sudo /etc/init.d/xrdp start`
1. Windows(Start) &rarr; Remote Desktop Connection (localhost:3390)

# Settings xfce GUI
1. Application &rarr; Settings &rarr; Light Locker Settings &rarr; Enable light-locker --- (OFF)
1. Application &rarr; Settings &rarr; Keyboard &rarr; Layout &rarr; Use system defaults --- (Uncheck)
1. Application &rarr; Settings &rarr; Keyboard &rarr; Layout &rarr; Keyboard layout &rarr; Add --- (Russian)
1. Application &rarr; Settings &rarr; Keyboard &rarr; Layout &rarr; Change layout option --- (Alt + Shift)
1. Application &rarr; Terminal Emulator &rarr; Edit &rarr; Preference &rarr; General &rarr; Enable the menu accelerator key (F10 by default) --- (Uncheck)
1. Application &rarr; Terminal Emulator &rarr; Edit &rarr; Preference &rarr; General &rarr; Theme variant --- (Dark)
1. Application &rarr; Desktop &rarr; Background  --- (choose what you like)
1. Move mouse to the task bar and push right button.
    * Panel &rarr; Add New Items &rarr; Keyboard Layouts

# Change mac address WSL
1. `cd ~/`
1. [download wsl.conf](https://github.com/vicg42/knowledge_base/blob/master/wsl/wsl.conf)
1. [download wsl-run-script.sh](https://github.com/vicg42/knowledge_base/blob/master/wsl/wsl-run-script.sh)
1. [download wsl-run-script-install.sh](https://github.com/vicg42/knowledge_base/blob/master/wsl/wsl-run-script-install.sh)
1. `cp /mnt/<path to wsl-run-script.sh .. > ./`
1. `touch ./wsl.mac`
    * add mac address. (mac address format:  xx:xx:xx:xx:xx:xx)
