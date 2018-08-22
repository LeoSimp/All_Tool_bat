@echo off
adb devices
adb devices | find /v /i "List" | find /i "device"
if errorlevel 1 ( set errorMsg="can not find DUT" && goto fail )
for /f "tokens=1" %%i in ('adb devices ^| find /v /i "List" ^| find /i "device"')  do set SSN=%%i
echo SSN:%SSN%
echo VARSTRING SSN = '%SSN%'
echo SUCCESSFUL TEST
goto end


:fail
echo errorMsg:%errorMsg%
echo UUT-FAIL
goto end

:end

