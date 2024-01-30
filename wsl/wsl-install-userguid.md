# User Guide
1. Windows(Start) &rarr; Microsoft Store &rarr; Windows Subsystem for Linux
1. [install chocolatey](https://chocolatey.org/install#individual)
1. open PowerShell (Administration Mode)
    * `choco install chocolateygui`
1. Windows(Start) &rarr; Chocolatey GUI
    1. Select chocolatey
    1. Search: ubuntu
        * install ubunto 20.4.0.20220127
1. Windows(Start) &rarr; Ubuntu
1. `sudo apt update && sudo apt -y upgrade`
1. `cp /mnt/<path to wsl-xfce-gui-install.sh> ./`
1. `sudo /etc/init.d/xrdp start`
1. Windows(Start) &rarr; Remote Desktop Connection (localhost:3390)
1. `./wsl-xfce-gui-settings.md`
