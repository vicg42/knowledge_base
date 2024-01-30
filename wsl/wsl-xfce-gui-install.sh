#!/bin/bash
SCRIPT_NAME=`basename "$0"`

stty -echo
read -p "Enter password for root user: " PASS
stty echo
echo ""

#https://dev.to/darksmile92/linux-on-windows-wsl-with-desktop-environment-via-rdp-522g
for arg in xrdp xfce4 xfce4-goodies
do
    dpkg -s $arg &> /dev/null
    if [[ ! $? -eq 0 ]]; then
        echo "----- Install $arg -----"
        echo $PASS | sudo -S apt-get install -y $arg
    fi
done

if [[ ! -f /etc/xrdp/xrdp.ini.bak ]]; then
    if [[ -f /etc/xrdp/xrdp.ini ]]; then
        echo $PASS | sudo -S cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
        echo $PASS | sudo -S sed -i 's/3389/3390/g' /etc/xrdp/xrdp.ini
        echo $PASS | sudo -S sed -i 's/max_bpp=32/#max_bpp=32\nmax_bpp=128/g' /etc/xrdp/xrdp.ini
        echo $PASS | sudo -S sed -i 's/xserverbpp=24/#xserverbpp=24\nxserverbpp=128/g' /etc/xrdp/xrdp.ini
    fi
fi

if [[ ! -f ~/.xsession ]]; then
    echo xfce4-session > ~/.xsession
fi

if [[ ! -f /etc/xrdp/startwm.sh.bak ]]; then
    echo $PASS | sudo -S cp /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak

    if [[ -z $(find /etc/xrdp/startwm.sh -type f -print | xargs grep "#test -x /etc/X11/Xsession") ]]; then
        sudo sed -i 's/test -x \/etc\/X11\/Xsession/#test -x \/etc\/X11\/Xsession/g' /etc/xrdp/startwm.sh
    fi

    if [[ -z $(find /etc/xrdp/startwm.sh -type f -print | xargs grep "#exec /bin/sh /etc/X11/Xsession") ]]; then
        sudo sed -i 's/exec \/bin\/sh \/etc\/X11\/Xsession/#exec \/bin\/sh \/etc\/X11\/Xsession/g' /etc/xrdp/startwm.sh
    fi

    if [[ -z $(find /etc/xrdp/startwm.sh -type f -print | xargs grep "startxfce4") ]]; then
        echo "startxfce4" | sudo tee -a /etc/xrdp/startwm.sh
    fi
fi

exit 0
