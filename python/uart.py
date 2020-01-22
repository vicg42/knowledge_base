import serial
import struct
import os


uart = serial.Serial()
uart.port = 'COM12'
# uart.baudrate = 115200
# uart.baudrate = 230400
# uart.baudrate = 460800
uart.baudrate = 921600
uart.parity = serial.PARITY_NONE
uart.stopbits = serial.STOPBITS_ONE
uart.bytesize = serial.EIGHTBITS
uart.xonxoff = False
uart.rtscts = False
uart.dsrdtr = False
uart.timeout = 3

#atomic write (Write data over USB2UART convertor to dsp board)
def RegWrite(value):
    # if __debug__:  #If this prints, you're not running python -O
        bs = struct.pack("B"*1,
            value
        )
        uart.write(bs)
    # else:
    #     print "~~~~ Write to adr(", hex(address), ") - ", hex(value)

uart.open()
uart.flushInput() #flush input buffer, discarding all its contents
uart.flushOutput() #flush input buffer, discarding all its contents

while(True):
    os.system('cls')
    print ("exit   - 0 ")
    print ("status - 1 ")
    print ("ctrl   - 2 ")
    print ("get fr - 3 ")
    key = input("Enter key: ")
    if key == "0":
        break;

    elif key == "1":
        os.system('cls')
        RegWrite(0x40)
        val=hex(ord(uart.read()))
        print ("status: " + str(val))
        input("press any key: ")

    elif key == "2":
        wval = 0x00
        while(True):
            os.system('cls')
            print ("wdata: " + str(hex(wval)))
            print ("exit       - 0 ")
            print ("set data   - 1 ")
            print ("write data - 2 ")
            key = input("Enter key: ")
            if key == "0":
                break;
            elif key == "1":
                wval = int(input("Enter data(hex): "), base=16)
            elif key == "2":
                RegWrite(wval)

    elif key == "3":
        os.system('cls')

        # for pix=8b: 1280*1=1280
        # for pix=10b: 1280*2=2560
        datasize=2560
        binFile=open("uartImage.bin","wb+")

        #deassert FIFO_NRST
        RegWrite(0x20)

        for y in range(10):
            for x in range(720):
                #deassert FIFO_NRST + EN READ LINE
                RegWrite(0x30)
                RegWrite(0x20)
                #deassert READ DATA from FIFO
                RegWrite(0xE0)

                chunk=uart.read(datasize)
                print ("fr(%2d),line(%3d)" % (y, x))

                binFile.write(chunk)

        binFile.close()

        RegWrite(0x00)
        input("press any key: ")

uart.close()
