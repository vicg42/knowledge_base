rem ----------------------------------------------------------------
rem display all the available programming hardware cables
rem ----------------------------------------------------------------
%ALTERA_QUARTUS%\quartus\bin64\quartus_pgm.exe --list

rem ----------------------------------------------------------------
rem detect and display all the devices in the device chain
rem ----------------------------------------------------------------
rem %ALTERA_QUARTUS%\quartus\bin64\quartus_pgm.exe --auto

rem ----------------------------------------------------------------
rem Make download .sof file to FPGA
rem ----------------------------------------------------------------
%ALTERA_QUARTUS%\quartus\bin64\quartus_pgm.exe --cable=USB-Blaster --mode=JTAG --operation=p;./output_files/ulogic.sof