setMode -bs
setCable -p auto
identify
assignfile -p 1 -file ./prj/main.bit
program -p 1
quit
