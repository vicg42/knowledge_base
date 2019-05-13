rem@echo off

set AXONIM_PRJ_PATH="d:\Work\Axonim\prj\Adani_BD\bcu"

git.exe clone git@git.axonim.by:Adani/bcu/fpga.git %AXONIM_PRJ_PATH%\_finish\_tmp\fpga
git.exe clone git@git.axonim.by:Adani/bcu/sw.git %AXONIM_PRJ_PATH%\_finish\_tmp\sw
git.exe clone git@git.axonim.by:Adani/bcu/tools.git %AXONIM_PRJ_PATH%\_finish\_tmp\tools

copy %AXONIM_PRJ_PATH%\bcu_doc.pdf %AXONIM_PRJ_PATH%\_finish\_tmp
