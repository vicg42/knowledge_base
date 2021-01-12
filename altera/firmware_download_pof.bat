rem ----------------------------------------------------------------
rem update memory content from the Memory Initialization File (.mif)
rem ----------------------------------------------------------------
%ALTERA_QUARTUS%\quartus\bin64\quartus_cdb.exe ./ulogic -c ulogic --update_mif

rem ----------------------------------------------------------------
rem generates a device programming image
rem ----------------------------------------------------------------
%ALTERA_QUARTUS%\quartus\bin64\quartus_asm.exe ./ulogic

rem ----------------------------------------------------------------
rem set params for Serial Configuration Devices
rem ----------------------------------------------------------------
rem %ALTERA_QUARTUS%\quartus\bin64\quartus_cpf.exe -w ./output_files/ulogic.opt

rem ----------------------------------------------------------------
rem Make covert .sof file to .jic file for next download it to Serial Configuration Devices (EPCQ)
rem ----------------------------------------------------------------
%ALTERA_QUARTUS%\quartus\bin64\quartus_cpf --convert --option=./output_files/ulogic.opt --configuration_mode=ASx1 --sfl_device=EP4CGX150 --device=EPCQ64 ./output_files/ulogic.sof ./output_files/ulogic.jic

rem ----------------------------------------------------------------
rem detect and display all the devices in the device chain
rem ----------------------------------------------------------------
rem %ALTERA_QUARTUS%\quartus\bin64\quartus_pgm.exe --auto

rem ----------------------------------------------------------------
rem Make download .jic file to Serial Configuration Devices (EPCQ)
rem ----------------------------------------------------------------
%ALTERA_QUARTUS%\quartus\bin64\quartus_pgm.exe --cable=USB-Blaster --mode=JTAG --operation=pvbi;./output_files/ulogic.jic