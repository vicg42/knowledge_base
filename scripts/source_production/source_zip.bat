rem@echo off


set prj_name="bcu"
set source="d:\Work\Axonim\prj\Adani_BD\bcu\_finish\_tmp\"
set destination="d:\Work\Axonim\prj\Adani_BD\bcu\_finish"
set dd=%DATE:~0,2%
set mm=%DATE:~3,2%
set yyyy=%DATE:~6,4%
set curdate=%yyyy%.%mm%.%dd%

7z.exe a -tzip -ssw -mx0 -r0 %destination%\%prj_name%_%curdate%.zip %source%\*
