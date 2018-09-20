@echo off & setlocal enabledelayedexpansion

set SubDIR=OutputDir_Total
set tstlst=Barcode_Speaker_LED SysInfo BatteryInfo Display RTC_TEST Backlight Camera BurnInVibrate WLAN BT FileSystem END

set Nowdir=%CD%\
echo The Data souce is in %Nowdir%%SubDIR%
echo The Item list is %tstlst%
echo.
echo Find BurnIn test item detail data start...

cd /d  %Nowdir%%SubDIR%\
call :Loop %tstlst%
goto end

:Loop
if "%1"=="END" goto :eof
Set Item=%1
if exist  %Nowdir%%Item%_Data.txt del  %Nowdir%%Item%_Data.txt
echo Writting data to %Item%_Data.txt, pls wait...
echo Item,TestCount,PassCount,FailCount,PassRate > %Nowdir%%Item%_Data.txt
for /f "" %%a in ('dir /b *.txt') do (
	set "Logfile=%%a"
	call :GetPassRate %Item% "!Logfile!"
)
shift
goto Loop
	
:GetPassRate
set BI_Item=%1
set "file=%2"
set filename=!file:~1,-5!
set PassRate=NA
for /f "delims=, tokens=2,3,4,5" %%i in ('find /i "%BI_Item%" %file%') do echo !filename!,%%i,%%j,%%k,%%l >> %Nowdir%%BI_Item%_Data.txt
rem pause
goto :eof

:end
cd /d %~dp0