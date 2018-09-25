@echo off && setlocal enabledelayedexpansion
echo Andriod reboot, first 4s can also find device, after about 26s, the device can be find again.
echo So during total 30S if continuously find 8+ can not find the DUT and 2+ can find the DUT , that may turns out the DUT is under reboot
rem adb kill-server
rem adb start-server

set /a n=0
set /a m=0
set /a t=0
set /a CMAX=0
set /a C=0
:Loop
adb devices | find /v "devices" | find "device"
if not errorlevel 1 (set /a n=!n!+1 && set /a a!t!=1 ) else (set /a m=!m!+1 && set /a a!t!=0)
rem echo at:!a%t%!
if !t! geq 1 (
	if !a%t%! equ !a%t-1%! if !a%t-1%! equ 0 (
		set /a C=!C!+1
		if !C! geq !CMAX! set /a CMAX=!C!
	)
	if !a%t-1%! equ 0 if !a%t1%! equ 1 (
		if !C! geq !CMAX! set /a CMAX=!C!
		set /a C=0
	)
	echo C:!C!
)
set /a t=!t!+1
echo !t!S... && ping 127.0.0.1 -n 2 >nul
if "!t!"=="30" echo 30S is used, exit loop && goto next
goto :Loop

:next
echo !t!s got device times is:!n!
echo !t!s not got device times is:!m!
echo In the total !m! times, the max continuously not got device times is !CMAX!
if !n! lss 2 (echo this can not judge if can find reboot process, DUT may off-line && goto end)
if !n! geq 2 if !CMAX! geq 8 (echo reboot process find) else (echo reboot process not find)

:end
