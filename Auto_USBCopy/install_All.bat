:: File Name: install_All.bat
:: Purpose: to create Linux USB key for Thecus NAS Test
:: Note: change the drive letter on detect wrong drive letter section
::	 for local harddrive and backup harddrives if any
:: Release: Beta Build, 10/12/16, Leo
:: 12/21/16 Add show Udisk Driver Letter for OP to choose
::	       Change Udisk Label rev accordding to Models
::		   Add support install null udisk by format only
:: 04/17/17 Add N2350 and upgrade the message of Factory_Server=2.0.85K.17
:: 04/26/17 upgrade the message of Factory_Server=2.0.85K.18
::			if can not get Udisk list, pls run this batch file as administrator
cd /d %~dp0
@echo off
chcp 437
color 37
echo. 
echo			The supprot Model list:
echo [0]Common format only
dir * /ad /b | find /i /v /n "Utilities"
echo ------------------------------------------------------------------------------- 
echo. 
echo (Enter the numer 0 will format the USDISK only for common use)
set /p Mnum= Enter the Model name by number(1,2,3...): 

if "%Mnum%"=="0" (
	title Creating Thecus Null USB Key to test
	set folder=%~dp0
	set FS=FAT32
	set Factory_Server=All 
	set Label=UDISK_Null
	goto start
)
for /f "tokens=2 delims=[]" %%a in (' dir * /ad /b ^| find /i /v /n "Utilities" ^| find "[%Mnum%]"') do set Model=%%a
echo %Model%
title Creating Thecus USB Key to test %Model%


:: -------------------------------------------------
:: Change the parameters below for different product
:: -------------------------------------------------

set folder=%~dp0
set FS=FAT32
set Factory_Server=2.0.85K.18 
if "%Model%"=="N2310MB" set Label=%Model%_03
if "%Model%"=="N2310BP" set Label=%Model%_01
if "%Model%"=="N2350MB" set Label=%Model%_01



:start
cls
color 17
echo list vol >script.txt
echo. 
echo			Wait for Udisk list:
echo. 
diskpart /s script.txt | find /i "Removeable"
if not errorlevel 1 goto choose
diskpart /s script.txt | find /i "Removable"
if errorlevel 1 echo "Not exist the Udisk,pls insert Udisk and press any key to continue" && pause>nul & goto start

:choose
set DISK=none
echo.
echo 				    Thecus
echo			Create USB client program for Factory_Server: %Factory_Server%
echo ------------------------------------------------------------------------------- 
echo.
set /p DISK= Enter USB Driver Letter(E,F,G...): 
echo.
set Type=%Model%

if not "%Mnum%"=="0" set /p USB_ID= Enter Test USB ID Number(1-5): 
echo.

if not exist %~dp0%Type% goto wrongtype

::=====================================================
:: Detect the local drive & backup hard disk letter
::=====================================================

for %%d in (c,C,d,D) do if %DISK%==%%d goto wrongdrive 
if not exist %DISK%:\ goto wrongdrive
goto begin

:wrongdrive
color 47
echo.
echo %DISK% is Local drive or backup drive or not exist %DISK%
echo.
echo Press any key to re-enter USB drive letter
pause > nul
goto start

:wrongtype
color 47
echo.
echo %Type% is not exist
echo.
echo Press any key to re-enter Type
pause > nul
goto start

:begin


cls
color 67
echo.
echo ================================================================================
echo.
echo Warning! All files of the device %DISK%: will be overwritten.
echo.
echo If %DISK%: is a partition on the same disk drive like your Windows installation,
echo then your Windows will not boot anymore. Be careful!
echo.
echo Press any key to continue, or close this window [x] to abort...
echo.
echo ================================================================================
pause > nul

cls
color 17
echo.
echo Creating %DISK%:
start /WAIT .\Utilities\HPUSBF %DISK%: -FS:%FS% -V:%Label% -Q -y

if "%Mnum%"=="0" goto done
xcopy  %~dp0%Type%\*.* /e/y %DISK%:

echo %USB_ID% > %DISK%:\gofactory\USBID



:done
cls
color 2f
echo.
echo Disk %DISK%: should be OK now. Installation finished.
echo.
echo press any key to exit...
pause > nul



:end

