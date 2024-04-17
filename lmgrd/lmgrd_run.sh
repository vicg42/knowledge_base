#!/bin/bash

/opt/lmgrd/bin/lmgrd -c /opt/lmgrd/license.dat -l /opt/lmgrd/log.txt  || exit 1

exit 0