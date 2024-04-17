#!/bin/bash

/opt/lmgrd/bin/lmutil lmstat -c /opt/lmgrd/license.dat || exit 1

exit 0