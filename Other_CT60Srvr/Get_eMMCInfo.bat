@echo off
ECHO %~0 Modify Date 20180209
ECHO Usage:%~0 'COMPortNumber' 'ImagePath'
ECHO i.e: %~0 8 D:\usiproject\IMAGE\Model-X\HON660-X\emmc

cd /d "C:\Program Files (x86)\Qualcomm\QPST\bin"
set Comport=%1
set Comport=COM%Comport%
set imagepath=%2

echo.
echo Set the image path...
QSaharaServer.exe -p \\.\%Comport% -s 13:%imagepath%\prog_emmc_ufs_firehose_Sdm660_ddr.elf >nul
if not errorlevel 1 (echo set the image path pass) else (
	echo set the image path fail
	goto fail
)
echo.
echo Search the eMMCinfo...
if exist eMMCinfo.txt del eMMCinfo.txt
fh_loader.exe --port=\\.\%Comport% --zlpawarehost=1 --getstorageinfo=1 --noprompt | find /i "prod_name" >eMMCinfo.txt
if not errorlevel 1 (echo search the eMMCinfo pass) else (
	echo search the eMMCinfo fail
	goto fail
)
type eMMCinfo.txt

echo.
echo Get the eMMC Model...
set eMMCModel=
for /f "tokens=9 delims=," %%i in (eMMCinfo.txt) do set eMMCModel=%%i
set eMMCModel=%eMMCModel:"=%
set eMMCModel=%eMMCModel:}=%
set eMMCModel=%eMMCModel:'=%
for /f "tokens=2 delims=:" %%i in ('echo %eMMCModel%') do set eMMCModel=%%i

echo.
echo Reset the DUT to edl mode...
if exist D:\ResetToEDL.xml del D:\ResetToEDL.xml
echo ^<?xml version="1.0"?^>>D:\ResetToEDL.xml
echo ^<data^>>>D:\ResetToEDL.xml
echo ^  ^<power value="reset_to_edl" /^>>>D:\ResetToEDL.xml
echo ^</data^>>>D:\ResetToEDL.xml
fh_loader.exe --port=\\.\%Comport% --sendxml=D:\ResetToEDL.xml --search_path=%~dp0 --zlpawarehost=1 --noprompt >nul
if not errorlevel 1 (echo reset the DUT to edl mode pass) else (
	echo reset the DUT to edl mode fail
	goto fail
)

goto pass

:fail
cd /d %~dp0
Echo the program run error, pls check...
Echo UUT-FAIL
goto end

:pass
cd /d %~dp0
Echo SUCCESSFUL TEST
echo eMMCModel:%eMMCModel%

:end
if exist D:\ResetToEDL.xml del D:\ResetToEDL.xml
