@echo off
REM Version2.0 20171208: Optimize for usbflags reg, because it only support serial number less than 8

rem for DUT COM4 FW:C07 BOOTSTRAP
call :SetCOM 05E017010003
rem for DUT COM4 FW:other BOOTSTRAP
call :SetCOM 05E017010002

rem for Scanner COM6 
call :SetCOM 05E017010002

rem for DUT COM4 all poweron 
call :SetCOM 05E017010000
goto end

:SetCOM
set VIDPIDSID=%1
echo clear COM database
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\COM Name Arbiter"  /v ComDB /t REG_BINARY /d 00000000000000000000000000000000000000000000000 /f 
if errorlevel 1 echo fail find && Pause >Nul
echo Ignore add port number for HW SerNum start from %VIDPIDSID:~0,8%
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\usbflags" /v IgnoreHWSerNum%VIDPIDSID:~0,8% /t REG_BINARY /d 01 /f
if errorlevel 1 echo fail find && Pause >Nul

echo Ignore add port number for HW SerNum start from %VIDPIDSID% for SID IdQuery
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\usbflags\%VIDPIDSID%" /v osvc /t REG_BINARY /d 0101 /f
if errorlevel 1 echo fail find && Pause >Nul
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\usbflags\%VIDPIDSID%" /v SkipContainerIdQuery /t REG_BINARY /d 01000000 /f
if errorlevel 1 echo fail find && Pause >Nul
goto :eof

:end