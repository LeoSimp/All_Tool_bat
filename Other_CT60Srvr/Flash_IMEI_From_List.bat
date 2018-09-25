@echo off
rem Purpose:Get the IMEI from IT query list file, and flash the IMEI and MEID into DUT
rem Usage: Flash_IMEI_From_List %SN% %List_File%
rem Histroy:20180518 V1.0.0 Leo Frist Release

set SN=%1
set List_File=%2
if not exist %List_File% (set ErrorMsg="Not exist the File: %List_File%" && goto fail )
find "%SN%" %List_File% >nul
if errorlevel 1 (set ErrorMsg="Not exist the %SN% in the File:%List_File%" && goto fail )
set IMEI=
for /f "tokens=3" %%i in ('find "%SN%" %List_File%') do set IMEI=%%i
if not defined IMEI (set ErrorMsg="Can not find the IMEI in the File:%List_File% " && goto fail )

echo The IMEI of %SN% is :%IMEI%
echo VARSTRING SFIS_IMEI = '%IMEI%'
adb devices | find /v "devices" | find "device"
if errorlevel 1 (set ErrorMsg="Not exist adb device" && goto fail )
adb root
adb shell mfg-tool -u IMEI_NUMBER=%IMEI%
if errorlevel 1 (set ErrorMsg="IMEI_NUMBER flash error" && goto fail )
adb shell mfg-tool -u MEID_NUMBER=%IMEI:~0,14%
if errorlevel 1 (set ErrorMsg="MEID_NUMBER flash error" && goto fail )

echo SUCCESSFUL TEST
goto end

:fail
echo ErrorMsg:%ErrorMsg%
echo UUT-FAIL
goto end

:end