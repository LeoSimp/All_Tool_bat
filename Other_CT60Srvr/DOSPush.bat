@echo off
set Org_File=%1
rem set Det_Path=%2
set Det_Path=/storage/emulated/0/Download/

adb root
adb shell "ls /storage/emulated/0/" | find "Download"
if errorlevel 1 adb shell "mkdir %Det_Path%"

echo The following command is excuting without output, and may need several minutes to complete, please wait...
echo [adb push %Org_File% %Det_Path% ]
adb push %Org_File% %Det_Path% > nul
if not errorlevel 1 (echo TEST_PASS) else (echo TEST_FAIL)  