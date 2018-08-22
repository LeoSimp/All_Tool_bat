@echo off
adb root
echo.
echo %time%: First get WIFIAP details
adb shell "wpa_cli -iwlan0 scan_res"

echo %time%: Start to close the shelding box, then press any key to continue
pause>nul

:Loop
echo.
echo %time%: Loop get WIFIAP details
adb shell "wpa_cli -iwlan0 scan_res"
if exist count.temp del count.temp
adb shell "wpa_cli -iwlan0 scan_res" | find /c "ESS" > count.temp
set /p count= < count.temp
if %count% gtr 2 goto Loop

:end
echo.
echo %time%: END WIFIAP details
adb shell "wpa_cli -iwlan0 scan_res"