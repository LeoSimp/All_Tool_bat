@echo off
set endexit=%1

adb devices | find /v "devices" | find "device"
if errorlevel 1 call :fail "Not find the DUT ADB device" 

adb root
adb remount
adb shell svc power stayon true

set cfg_version=
set fw_version=
for /f "" %%i in ('adb shell "cat /sys/bus/i2c/drivers/atmel_maxtouch_ts/4-004a/cfg_version"') do set cfg_version=%%i
for /f "" %%i in ('adb shell "cat /sys/bus/i2c/drivers/atmel_maxtouch_ts/4-004a/fw_version"') do set fw_version=%%i
if not defined fw_version call :fail "not defined fw_version"
echo cfg_version:%cfg_version%
echo fw_version:%fw_version%
rem if not defined cfg_version call :fail "not defined cfg_version" 
rem no need check cfg_version because cfg_version not control by MFG.Test but by shipping image 
if "%fw_version%"=="2.0.03" echo fw_version is %fw_version%, skip to push && goto pass

adb push D:\usiproject\UUTAP\CT60\TP_Update\ct60_maxtouch_v2.0.03.fw /vendor/firmware/ct60_maxtouch_v2.0.03.fw
if errorlevel 1 call :fail "adb push file into DUT error" 
adb push D:\usiproject\UUTAP\CT60\TP_Update\Honeywell_CT60_GP_640U_FW2.0.03_NormalMode_AE000_20180314.raw /vendor/firmware/ct60_mxt640u.raw
if errorlevel 1 call :fail "adb push file into DUT error"  
adb push D:\usiproject\UUTAP\CT60\TP_Update\Honeywell_CT60_GP_640U_FW2.0.03_AE001_StylusMode_20180313.raw /vendor/firmware/ct60_mxt640u_stylus.raw
if errorlevel 1 call :fail "adb push file into DUT error" 
adb push D:\usiproject\UUTAP\CT60\TP_Update\Honeywell_CT60_GP_640U_FW2.0.03_AE002_GloveMode_20180322.raw /vendor/firmware/ct60_mxt640u_glove.raw
if errorlevel 1 call :fail "adb push file into DUT error"  
adb push D:\usiproject\UUTAP\CT60\TP_Update\Honeywell_CT60_GP_640U_FW2.0.03_AE003_FingerMode_20180322.raw /vendor/firmware/ct60_mxt640u_finger.raw
if errorlevel 1 call :fail "adb push file into DUT error"  

adb shell "echo ct60_mxt640u.raw > /sys/bus/i2c/drivers/atmel_maxtouch_ts/4-004a/cfg_name"
if errorlevel 1 call :fail "adb write file error" 
adb shell "echo ct60_maxtouch_v2.0.03.fw > /sys/bus/i2c/drivers/atmel_maxtouch_ts/4-004a/update_fw"
if errorlevel 1 call :fail "adb write file error"
goto pass

:pass
Echo SUCCESSFULLY TEST
goto end

:fail
echo %1
echo UUT-FAIL
goto end

:end
if /i "%endexit%"=="endexit" (exit) else (pause>nul && exit)
