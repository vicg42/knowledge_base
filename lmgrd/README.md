# Info


## Files

* ./lmgrd/bin/ -- utils
* ./lmgrd/lmgrd.service -- systemd service
* ./lmgrd/lmgrd_xx.sh -- user control of lmgrd


## License file

* ./lmgrd/license.dat -- license file. For multiple licenses you need to keep the contents of both the license files in a single one.


## Autorun app with systemd

1. `cd ./lmgrd`
1. `./lmgrd_install.sh`
1. `copy to /opt/lmgrd/bin all need demons`
1. `copy license file to /opt/lmgrd/. Name of license file must be license.dat`
1. `sudo systemctl daemon-reload`
1. `sudo systemctl start lmgrd.service`
1. `sudo systemctl enable lmgrd.service`


# Systemd user control

sudo systemctl start lmgrd.service
sudo systemctl stop lmgrd.service
sudo systemctl status lmgrd.service
sudo systemctl is-active lmgrd.service
sudo systemctl is-enable lmgrd.service
sudo systemctl enable lmgrd.service   -- If you want the service to start automatically when the system boots up


# License server(lmgrd) command

/opt/lmgrd/bin/lmgrd -c /opt/lmgrd/license.dat -l /opt/lmgrd/log.txt
/opt/lmgrd/bin/lmutil lmstat -c /opt/lmgrd/license.dat
/opt/lmgrd/bin/lmutil lmdown -q -c /opt/lmgrd/license.dat
