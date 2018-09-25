@echo off & setlocal enabledelayedexpansion
cd /d %~dp0
rem set SN=16110200200123456789
set SN=%1

set /a fail_flag=0
call :ChkLog_1 Barcode_Speaker_LED 5
call :ChkLog SysInfo
call :ChkLog BatteryInfo
call :ChkLog Display
call :ChkLog RTC_TEST
call :ChkLog Backlight
call :ChkLog Camera
call :ChkLog BurnInVibrate
call :ChkLog WLAN
call :ChkLog_1 BT 70
call :ChkLog FileSystem
if "%fail_flag%"=="1" (echo Fail found) else (echo SUCCESSFUL TEST)
goto end


:ChkLog
set BI_Item=%1
set Logpath=D:\CT60_BURNINLOG\Result\
for /f "delims== tokens=2" %%i in ('find /i "%BI_Item%" %Logpath%%SN%.txt') do set Result=%%i
if /i "%Result%"=="Pass" (
	echo Burnin_Item:%BI_Item% is Pass
) else (
	echo Burnin_Item:%BI_Item% is Fail
	set /a fail_flag=1
	)
)
goto :eof

:ChkLog_1
set BI_Item=%1
set LowSpec=%2
set Logpath=D:\CT60_BURNINLOG\Result\
for /f "delims== tokens=2" %%i in ('find /i "%BI_Item%" %Logpath%%SN%.txt') do set Result=%%i
if /i "%Result%"=="Pass" (
	echo Burnin_Item:%BI_Item% is Pass
) else (
	for /f "delims=, tokens=5" %%i in ('find /i "%BI_Item%" %Logpath%%SN%.txt') do set PassRate=%%i
	echo Burnin_Item:%BI_Item% PassRate is !PassRate!
	if !PassRate! geq %LowSpec% (
		echo Burnin_Item:%BI_Item% is Pass
	) else (
		echo Burnin_Item:%BI_Item% is Fail
		set /a fail_flag=1
	)
)
goto :eof

:end
