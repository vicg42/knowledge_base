#
# author: Golovachenko Viktor
#
import cv2
import numpy as np
import getopt
import sys

usrfile = ""
frame_w = 1280
frame_h = 720

try:
    options, remainder = getopt.gnu_getopt(
        sys.argv[1:],
        "hf:x:y:",
        ["help",
        "file="
        "x=",
        "y=",
         ])
except getopt.GetoptError as err:
    print('ERROR:', err)
    sys.exit(1)

def help() :
    print('Mandatory option: ')
    print('\t-h   help')
    print('\t-f   path to file raw data')
    print('\t-x   width. default ' + str(frame_w))
    print('\t-y   hight. default ' + str(frame_h))
    print("using:")
    print("\t1. run appication: ./ccm.py -f <path to raw data file>")
    print("\t2. mouse click on image select 24 regions for calculation CCM coef")
    print("\t\tAttantion: The choice of regions should be made from the upper")
    print("\t\t           left corner region by region and line by line")
    print("\t3. after select eche region press key 't'")
    print("\t4. for cancel press 'r'")
    print("\t5. after select all 24 regions press key 'c'")
    sys.exit()

for opt, arg in options:
    if opt in ('-x', '--x'):
        frame_w = arg
    elif opt in ('-y', '--y'):
        frame_h = arg
    elif opt in ('-f', '--file'):
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
raw_img1 = raw_images[1, :, :]
raw_img2 = raw_images[2, :, :]

#set bayer channel
raw_img = raw_img2
cv2.imwrite(usrfile + '_bayer.bmp', raw_img)

img_debayer = cv2.cvtColor(raw_img, cv2.COLOR_BAYER_BG2RGB)
cv2.imwrite(usrfile + '_debayer.bmp', img_debayer)

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

print(CamImg_RGB)


# # #test for test_fr_color_target10_wb_on.raw
# # Sample0_RGB = np.matrix(' \
# #                 69    167     73     53    105    104    192     60    158     54    141    225     40     61    129    250    166     59    255    211    129     86     60     38 ; \
# #                 66    149    109     74    117    190    137     79     97     48    198    190     51    116     65    255    110    116    255    247    170    106     67     34 ; \
# #                 64    119    111     56    132    173     71    109     71     48    107     96     87     83     41    107    112    141    255    231    143     89     60     41   \
# #             ')
# # Sample1_RGB = np.matrix(' \
# #                 70    174     71     52    105    107    194     63    156     54    147    223     36     59    129    255    167     59    255    204    135     92     60     34 ; \
# #                 67    156    103     73    129    201    124     80     91     48    206    190     48    118     67    251    116    128    255    246    161     95     71     47 ; \
# #                 46    117    106     54    151    168     65    112     55     60    111     98     79     82     44    117    114    143    255    223    136     94     52     37   \
# #             ')
# # Sample2_RGB = np.matrix(' \
# #                 73    181     74     51    109    106    190     60    163     55    150    228     37     54    129    255    165     59    255    214    142     85     52     42 ; \
# #                 69    166     95     70    129    203    131     77     93     50    205    205     55    115     72    252    115    121    255    252    168    103     62     44 ; \
# #                 57    122    112     55    139    172     60    117     66     62    117     99     91     79     45    119    118    138    255    219    144     86     57     36   \
# #             ')
# # Sample3_RGB = np.matrix(' \
# #                 71    174     76     49    101     99    187     57    154     55    137    228     40     57    134    250    171     58    255    208    151     84     53     32 ; \
# #                 68    152    106     75    126    189    129     73     94     47    197    194     57    124     72    248    120    114    255    255    173    108     61     39 ; \
# #                 52    130    124     49    131    174     64    106     66     48    112     98     91     81     42    101     99    146    255    223    150     86     56     34   \
# #             ')
# # for y in range(3):
# #     for x in range(24):
# #             SUM = Sample0_RGB[y,x] + Sample1_RGB[y,x] + Sample2_RGB[y,x] + Sample3_RGB[y,x]
# #             CamImg_RGB[y,x] = int(round(float(SUM)/4) )


#Etalon array
#ColorChart24_RGB [3x24] =
#                A1    A2    A3    A4    A5    A6    B1    B2    B3    B4    B5    B6    D1    D2    D3    D4    D5    D6    C1    C2    C3    C4    C5    C6
#R  Mtarget = [ 120   196    97    89   135    92   221    79   196    98   157   226    43    63   180   237   194     0   247   199   160   123    89    51 ;
#G               84   147   124   109   130   188   124    94    82    57   190   162    64   149    50   200    86   139   247   202   163   123    89    50 ;
#B               70   128   155    66   177   170    47   170    98   105    64    45   148    75    58    11   152   170   245   202   162   122    89    52  ]
ColorChart24_RGB = np.matrix(' \
                     120   196    97    89   135    92   221    79   196    98   157   226    43    63   180   237   194     0   247   199   160   123    89    51 ; \
                      84   147   124   109   130   188   124    94    82    57   190   162    64   149    50   200    86   139   247   202   163   123    89    50 ; \
                      70   128   155    66   177   170    47   170    98   105    64    45   148    75    58    11   152   170   245   202   162   122    89    52'  \
                      )
CCM = ColorChart24_RGB * CamImg_RGB.transpose() * np.linalg.inv(CamImg_RGB * CamImg_RGB.transpose())
with open('ccm_coe.txt', 'w') as f:
    if sys.version_info < (3, 0):
        print >> f, CCM
    else:
        print(CCM, file=f)

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
cv2.imwrite(usrfile + '_ccm.bmp', img_debayer_ccm_rgb)

print("Save result image with color correction martix: " + usrfile + '_ccm.bmp')