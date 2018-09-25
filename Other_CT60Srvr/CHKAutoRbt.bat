@echo off && setlocal enabledelayedexpansion
adb logcat -c

set /a n=0
:Loop
echo wait 0.5S... && ping 127.0.0.1 -n 1 >nul
adb logcat -v raw -d | find /i "rebooting" >nul
if errorlevel 1 ( if !n! leq 35 ( 
	set /a n=n+1 
	goto Loop ) else (
		echo can not find the reboot process
		goto next
		) 
	) else (
	echo find the reboot process
	goto fail
	)
:next
echo SUCCESSFULLY TEST
goto end

:fail
echo UUT-FAIL
goto end

:end

	
