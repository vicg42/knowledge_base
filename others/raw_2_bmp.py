#
# author: Golovachenko Viktor
#
import cv2
import numpy as np
import getopt
import sys

usrfile = ""
frame_w = 2688
frame_h = 1520

try:
    options, remainder = getopt.gnu_getopt(
        sys.argv[1:],
        "hi:x:y:",
        ["help",
        "file=",
        "x=",
        "y=",
         ])
except getopt.GetoptError as err:
    print('ERROR:', err)
    sys.exit(1)

def help() :
    print('Mandatory option: ')
    print('\t-h   help')
    print('\t-i   path to file raw data')
    print('\t-x   width. default ' + str(frame_w))
    print('\t-y   hight. default ' + str(frame_h))
    sys.exit()

for opt, arg in options:
    if opt in ('-x', '--x'):
        frame_w = int(arg)
    elif opt in ('-y', '--y'):
        frame_h = int(arg)
    elif opt in ('-i', '--input'):
        usrfile = arg
    elif opt in ('-h', '--help'):
        help()

if not usrfile:
    print("error: set path to file raw data.")
    help()

print ("file: " + usrfile)
print ("frame: " + str(frame_w) + " x " + str(frame_h))

#parsing raw data
raw_data = np.fromfile(usrfile, dtype='uint8')
raw_images = np.reshape(raw_data, (-1, frame_h, frame_w))
raw_img0 = raw_images[0, :, :]
# raw_img1 = raw_images[1, :, :]
# raw_img2 = raw_images[2, :, :]

#set bayer channel
raw_img = raw_img0
cv2.imwrite(usrfile + '_bayer.bmp', raw_img)
