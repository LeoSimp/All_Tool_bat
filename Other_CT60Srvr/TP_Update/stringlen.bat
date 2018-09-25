@echo off
setlocal enabledelayedexpansion
set str=%1
set /a x=0
call :StrLen
endlocal
goto :eof

:StrLen
if not "!str:~%x%,1!" == "" set /a x+=1 & goto StrLen
echo StringLenth=%x%
goto :eof

