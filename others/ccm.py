#
# author: Golovachenko Viktor
#
import cv2
import numpy as np
import getopt
import sys
import os

usrfile_I = ""

def print_file( val, f ):
    #uncomment for python2
    #print >> f, val
    #uncomment for python3
    print(val, file=f)


try:
    options, remainder = getopt.gnu_getopt(
        sys.argv[1:],
        "hi:",
        ["help",
        "input=",
         ])
except getopt.GetoptError as err:
    print('ERROR:', err)
    sys.exit(1)

def help() :
    print('Mandatory option: ')
    print('\t-h  --help')
    print('\t-i  --input    path to input file (BMP)')
    print("usage:")
    print("\t1. %s -i <path to input file>" % (os.path.basename(__file__)))
    print("\t2. mouse click on image select 24 regions for calculation CCM coef")
    print("\t\tAttantion: The choice of regions should be made from the upper")
    print("\t\t           left corner region by region and line by line")
    print("\t3. after select each region press key 't'")
    print("\t4. for cancel press 'r'")
    print("\t5. after select all 24 regions press key 'c'")
    print("\t6. result coe for ccm save into ccm.txt")
    sys.exit()

for opt, arg in options:
    if opt in ('-i', '--input'):
        usrfile_I = arg
    elif opt in ('-h', '--help'):
        help()

if (not usrfile_I):
    print("error: set path to file raw data.")
    help()

print ("file: " + usrfile_I)
img_debayer = cv2.imread(usrfile_I, cv2.IMREAD_COLOR)
frame_h, frame_w, c = img_debayer.shape
print ("frame: " + str(frame_w) + " x " + str(frame_h))

img_debayer_save = img_debayer.copy()

# initialize the list of reference points and boolean indicating
# whether cropping is being performed or not
refPt = []

def click_and_crop(event, x, y, flags, param):
    # grab references to the global variables
    global refPt, cropping

    # if the left mouse button was clicked, record the starting
    # (x, y) coordinates and indicate that cropping is being
    # performed
    if event == cv2.EVENT_LBUTTONDOWN:
        refPt = [(x, y)]

    # check to see if the left mouse button was released
    elif event == cv2.EVENT_LBUTTONUP:
        # record the ending (x, y) coordinates and indicate that
        # the cropping operation is finished
        refPt.append((x, y))

        # draw a rectangle around the region of interest
        cv2.rectangle(img_debayer, refPt[0], refPt[1], (0, 255, 0), 2)
        cv2.imshow("image", img_debayer)


clone = img_debayer.copy()
cv2.namedWindow("image")
cv2.setMouseCallback("image", click_and_crop)
count = 0
ROI = []

# keep looping until the 'q' key is pressed
while True:
    # display the image and wait for a keypress
    cv2.imshow("image", img_debayer)
    key = cv2.waitKey(1) & 0xFF

    # if the 'r' key is pressed, reset the cropping region
    if key == ord("r"):
        img_debayer = clone.copy()
        count = 0
        print(count)

    # if the 'c' key is pressed, break from the loop
    elif key == ord("c"):
        break

    elif key ==  ord("t"):
        if len(refPt) == 2:
            ROI.append(clone[refPt[0][1]:refPt[1][1], refPt[0][0]:refPt[1][0]])
        print(count)
        count = count + 1
        # img_debayer = clone.copy()

CamImg_RGB = np.matrix(' \
                0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 ; \
                0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 ; \
                0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   \
            ')
#Etalon array
#ColorChart24_RGB [3x24] =
#                 A1    A2    A3    A4    A5    A6    B1    B2    B3    B4    B5    B6    C1    C2    C3    C4    C5    C6    D1    D2    D3    D4    D5    D6
#R  Mtarget = [  120   196    97    89   135    92   221    79   196    98   157   226    43    63   180   237   194     0   247   199   160   123    89    51 ;
#G                84   147   124   109   130   188   124    94    82    57   190   162    64   149    50   200    86   139   247   202   163   123    89    50 ;
#B                70   128   155    66   177   170    47   170    98   105    64    45   148    75    58    11   152   170   245   202   162   122    89    52

                # A1    A2    A3    A4    A5    A6    B1    B2    B3    B4    B5    B6    C1    C2    C3    C4    C5    C6    D1    D2    D3    D4    D5    D6
ColorChart24_RGB = np.matrix(' \
                 120   196    97    89   135    92   221    79   196    98   157   226    43    63   180   237   194     0   247   199   160   123    89    51 ; \
                  84   147   124   109   130   188   124    94    82    57   190   162    64   149    50   200    86   139   247   202   163   123    89    50 ; \
                  70   128   155    66   177   170    47   170    98   105    64    45   148    75    58    11   152   170   245   202   162   122    89    52'  \
                  )
colorsToPick = 24

if count != colorsToPick:
    print('ERROR: count != 24')
    sys.exit(0)

for i in range(colorsToPick):
    roi_b, roi_g, roi_r = cv2.split(ROI[i])
    mean_red = np.mean(roi_r)
    mean_green = np.mean(roi_g)
    mean_blue = np.mean(roi_b)
    CamImg_RGB[0,i]=mean_red
    CamImg_RGB[1,i]=mean_green
    CamImg_RGB[2,i]=mean_blue
    # make source pixes as bright as target, saving the color
    srcBrightness = mean_red*0.299 + mean_green*0.587 + mean_blue*0.114
    tgtBrightness = ColorChart24_RGB[0,i]*0.299 + ColorChart24_RGB [1,i]*0.587 + ColorChart24_RGB [2,i]*0.114
    tgtSrcBrightRatio = tgtBrightness / srcBrightness
    ColorChart24_RGB[0,i] /= tgtSrcBrightRatio
    ColorChart24_RGB[1,i] /= tgtSrcBrightRatio
    ColorChart24_RGB[2,i] /= tgtSrcBrightRatio


print(CamImg_RGB)


CCM = ColorChart24_RGB * CamImg_RGB.transpose() * np.linalg.inv(CamImg_RGB * CamImg_RGB.transpose())
with open('ccm.txt', 'w') as f:
   print("CCM ---:")
   print(CCM)

   CCM_cc = np.zeros((3,3))
   CCM_ccr = np.zeros((3,3))
   CCM_ccr2 = np.zeros((3,3), int)
   for y in range(3):
       for x in range(3):
               CCM_cc[y,x] = CCM[y,x] * 1024
               CCM_ccr[y,x] = round(CCM_cc[y,x])
               CCM_ccr2[y,x] = CCM_ccr[y,x]

   print("CCM * 1024---:")
   print(CCM_cc)

   print("(round(CCM * 1024) ---:")
   print(CCM_ccr)

   for y in range(3):
       for x in range(3):
           print("CCM_cc[%d,%d]: %s" % (y, x, hex(CCM_ccr2[y,x] & 0xFFFF) ))
           vvv = str(hex(CCM_ccr2[y,x] & 0xFFFF))
           print_file( vvv, f )

print("calc...........................")
# def Discrete(pix,coe):
#     pixnew = int(round(pix*coe))
#     if pixnew > 255:
#         return 255
#     else:
#         return pixnew

#Save result image with color correction martix
img_debayer_ccm_r = np.zeros((frame_h, frame_w))
img_debayer_ccm_g = np.zeros((frame_h, frame_w))
img_debayer_ccm_b = np.zeros((frame_h, frame_w))
img_debayer_b, img_debayer_g, img_debayer_r = cv2.split(img_debayer_save)
for y in range(frame_h):
   for x in range(frame_w):
        img_debayer_ccm_r[y,x] = (img_debayer_r[y,x]*CCM[0,0]) + (img_debayer_g[y,x]*CCM[0,1]) + (img_debayer_b[y,x]*CCM[0,2])
        img_debayer_ccm_g[y,x] = (img_debayer_r[y,x]*CCM[1,0]) + (img_debayer_g[y,x]*CCM[1,1]) + (img_debayer_b[y,x]*CCM[1,2])
        img_debayer_ccm_b[y,x] = (img_debayer_r[y,x]*CCM[2,0]) + (img_debayer_g[y,x]*CCM[2,1]) + (img_debayer_b[y,x]*CCM[2,2])

img_debayer_ccm_rgb = cv2.merge((img_debayer_ccm_b, img_debayer_ccm_g, img_debayer_ccm_r))
cv2.imwrite(usrfile_I + '_ccm.bmp', img_debayer_ccm_rgb)
cv2.imwrite(usrfile_I + '_ccm.png', img_debayer_ccm_rgb)

print("Save coe correction martix: " + usrfile_I + '_ccm_coe.txt')
print("Save result image with color correction martix: " + usrfile_I + '_ccm.bmp')
print("Save result image with color correction martix: " + usrfile_I + '_ccm.png')
