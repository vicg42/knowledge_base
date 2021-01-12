rem ----------------------------------------------------------------
rem Make covert .sof file to .rbf file
rem ----------------------------------------------------------------
%ALTERA_QUARTUS%\quartus\bin64\quartus_cpf --convert --configuration_mode=PS --sfl_device=10CL010YM164 ./output_files/falcon.sof ../fpga-firmware/fpga_firmware_falcon.rbf
