@echo off

:start
cls
set USISN=
set /p USISN=Please input the USI SN(20):
if not defined USISN call :fail "Not defined USISN"
call stringlen.bat %USISN% | find "StringLenth=20" 
if errorlevel 1 call :fail "USISN not equal 20"

set HC=%USISN:~8,3%
if "%HC%"=="860" set type=SDA && goto next
if "%HC%"=="740" set type=SDA && goto next
if "%HC%"=="870" set type=SDM && goto next
if "%HC%"=="750" set type=SDM && goto next
call :fail "USISN not contain HC info" 
:next
set COMPort=8
set imagepath=D:\USIPROJECT\IMAGE\CT60\HON660-N-00.00.00D(0073)_QFIL_G2H\emmc
if not exist %imagepath%\prog_emmc_ufs_firehose_Sdm660_ddr.elf call :fail "Not exist %imagepath%\prog_emmc_ufs_firehose_Sdm660_ddr.elf"
COMList.exe | find /i "COM8 "
if errorlevel 1 call :fail "not exit COM8 "
call QFIL_Flash.bat %COMPort% %imagepath% %type%
if errorlevel 1 call :fail "Image download fail"
:PowerOn
cls
echo Please hold press the power key to power on the DUT
pause>nul
COMList.exe | find /i "COM8 "
if not errorlevel 1 echo Still find the COM8 && pause>nul && goto PowerOn
echo Wait 2min... && ping 127.0.0.1 -n 121 >nul  
adb wait-for-device
echo Wait 40s... && ping 127.0.0.1 -n 41 >nul  

adb devices | find /v "devices" | find "device"
if errorlevel 1 call :fail "Not find the DUT ADB device" 

call TP_FW_FrcUp.bat endexit
goto end

:fail
echo %1
pause>nul
cls
goto fail

:end
echo Please check the Touch whether is OK now
pause>nul
goto start


