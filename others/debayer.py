#
# author: Golovachenko Viktor
#
import cv2
import numpy as np
import getopt
import sys
import os

usrfile_I = ""
usrfile_O = ""

cpath = os.getcwd()

try:
    options, remainder = getopt.gnu_getopt(
        sys.argv[1:],
        "hi:o:",
        ["help",
        "input=",
        "output=",
         ])
except getopt.GetoptError as err:
    print('ERROR:', err)
    sys.exit(1)

def help() :
    print('Mandatory option: ')
    print('\t-h  --help')
    print('\t-i  --input   path to input image file')
    print('\t-o  --output  path to output image file')
    print("usage:")
    print("\t %s -i <path to file> -o <path to file>" % (os.path.basename(__file__)))
    sys.exit()

for opt, arg in options:
    if opt in ('-i', '--input'):
        usrfile_I = arg
    elif opt in ('-o', '--output'):
        usrfile_O = arg
    elif opt in ('-h', '--help'):
        help()

if (not usrfile_I) or (not usrfile_O):
    print("error: set path to image file.")
    help()

print ("input image: " + usrfile_I)
# cv2.IMREAD_COLOR : Loads a color image. Any transparency of image will be neglected. It is the default flag.
# cv2.IMREAD_GRAYSCALE : Loads image in grayscale mode
# cv2.IMREAD_UNCHANGED : Loads image as such including alpha channel
img_in = cv2.imread(usrfile_I, cv2.IMREAD_GRAYSCALE)
frame_h, frame_w = img_in.shape
print ("frame: " + str(frame_w) + " x " + str(frame_h))


img_o = cv2.cvtColor(img_in, cv2.COLOR_BAYER_RG2BGR)
# img_o = cv2.cvtColor(img_in, cv2.COLOR_BAYER_GR2RGB)
# img_o = cv2.cvtColor(img_in, cv2.COLOR_BAYER_RG2RGB)
# img_o = cv2.cvtColor(img_in, cv2.COLOR_BAYER_GB2RGB)
# img_o = cv2.cvtColor(img_in, cv2.COLOR_BAYER_BG2RGB)
# img_o = cv2.cvtColor(img_in, cv2.COLOR_BAYER_BG2BGR)
cv2.imwrite(usrfile_O, img_o)
print ("output image: " + usrfile_O)

