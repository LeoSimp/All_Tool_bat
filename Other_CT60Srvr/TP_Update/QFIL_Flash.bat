@echo off
cd /d "C:\Program Files (x86)\Qualcomm\QPST\bin"
set Comport=%1
set Comport=COM%Comport%
set imagepath=%2
set type=%3

QSaharaServer.exe -p \\.\%Comport% -s 13:%imagepath%\prog_emmc_ufs_firehose_Sdm660_ddr.elf 
if errorlevel 1 goto fail

fh_loader.exe --port=\\.\%Comport% --sendxml=rawprogram_unsparse_%type%660.xml --search_path=%imagepath% --noprompt --zlpawarehost=1 --memoryname=emmc 
if errorlevel 1 goto fail

fh_loader.exe --port=\\.\%Comport% --sendxml=patch0.xml --search_path=%imagepath% --noprompt --zlpawarehost=1 --memoryname=emmc 
if errorlevel 1 goto fail

fh_loader.exe --port=\\.\%Comport% --setactivepartition=0 --noprompt --zlpawarehost=1 --memoryname=emmc 
if errorlevel 1 goto fail

goto end

:fail
ping 127.0.0.1 -n 2>nul
echo.
echo QFIL Flash error,need to reset the DUT to edl mode...
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
cd /d %~dp0
Echo the program run error, pls check...
pause>nul
goto fail

:end
cd /d %~dp0