@ECHO Off
adb root
set num=
for /f "" %%i in ('adb shell wpa_cli scan_res ^| find /i /c "ESS"') do set num=%%i
if %num% gtr %1 (echo SUCCESSFUL TEST) else (echo UUT_FAIL)