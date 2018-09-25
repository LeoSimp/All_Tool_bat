@echo off
adb root
adb shell "cat /sys/class/hwmon/hwmon*/name" | find "quiet_therm" >nul
if errorlevel 1 (set errorMsg="Can not find quiet_therm in /sys/class/hwmon/hwmon*/name" && goto fail)

set line_num=
for /f "delims=: tokens=1" %%i in ('adb shell "cat /sys/class/hwmon/hwmon*/name | grep -n "quiet_therm""') do set line_num=%%i
if not defined line_num (set errorMsg="Not defined line_num" && goto fail)
set hwmon_dir=
for /f "delims=/ tokens=5" %%i in ('adb shell "ls /sys/class/hwmon/hwmon*/name | grep -n "." | grep "%line_num%:/sys/class/hwmon/hwmon""') do set hwmon_dir=%%i
if not defined hwmon_dir (set errorMsg="Not defined hwmon_dir" && goto fail)
echo Find "quiet_therm" in /sys/class/hwmon/%hwmon_dir%/name 
echo And the Temperature record should locat in /sys/class/hwmon/%hwmon_dir%/temp1_input
set Temperature=
for /f "" %%i in ('adb shell "cat /sys/class/hwmon/%hwmon_dir%/temp1_input"') do set Temperature=%%i
if not defined Temperature (set errorMsg="Not defined Temperature" && goto fail)

if not %Temperature% leq 40 if %Temperature% geq 20 (set errorMsg="Temperature:%Temperature% is not in the spec 20-40" && goto fail)
echo Temperature:%Temperature% is in the spec 20-40
echo SUCCESSFULLY TEST 
goto end

:fail
echo errorMsg:%errorMsg%
echo UUT-Fail
goto end

:end
