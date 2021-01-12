rem ----------------------------------------------------------------
rem set params for Serial Configuration Devices
rem ----------------------------------------------------------------
rem %ALTERA_QUARTUS%\quartus\bin64\quartus_cpf.exe -w ./output_files/ulogic.opt

rem ----------------------------------------------------------------
rem Make covert .sof file to .jic file for next download it to Serial Configuration Devices (EPCQ)
rem ----------------------------------------------------------------
%ALTERA_QUARTUS%\quartus\bin64\quartus_cpf --convert --option=./output_files/ulogic.opt --configuration_mode=ASx1 --sfl_device=EP4CGX150 --device=EPCQ64 ./output_files/ulogic.sof ./output_files/ulogic_eth_fiber.jic
