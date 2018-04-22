@echo off
title Yaddle Minify fusion tool
setlocal
:_core
set /p input="Write filename.extension of the script you want to minify : "
set /p output="Write filename.extension of the final minified script : "
IF EXIST %output%.tmp (
    luasrcdiet .\%output%.tmp -o %output% --maximum --opt-experimental --opt-entropy --noopt-srcequiv
    DEL %output%.tmp
    PAUSE
)
IF NOT EXIST %output%.tmp (
    luamin -f %input% > %output%.tmp
    timeout /t 1 /nobreak
    luasrcdiet .\%output%.tmp -o %output% --maximum --opt-experimental --opt-entropy --noopt-srcequiv
    DEL %output%.tmp
    PAUSE
)

:_exit
ECHO Closing Yaddle Minify fusion tool ...
exit

