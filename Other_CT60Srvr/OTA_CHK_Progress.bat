@echo off && setlocal enabledelayedexpansion

ECHO Wait for 99 of percent progress
set /a n=0
call :WaitUntill_99 
ECHO Wait for 100 of percent progress
set /a n=0
call :WaitUntill_Complete
goto pass

:WaitUntill_99 
if !n! gtr 10 goto fail
adb logcat -v raw -s OTAUpgradeActivity:D -d | find "MSG_UPDATE_PROGRESS_PERCENT" >nul
if not errorlevel 1 (
	echo Percent progress find, checking if 99 of percent can find
	adb logcat -v raw -s OTAUpgradeActivity:D -d | find "MSG_UPDATE_PROGRESS_PERCENT:99" 
	if errorlevel 1 ( 
		for /f "skip=20 tokens=1" %%i in ('adb logcat -v raw -s OTAUpgradeActivity:D -d ^| find "MSG_UPDATE_PROGRESS_PERCENT"') do echo %%i
		adb logcat -c
		ECHO WAIT 75 S ... && ping 127.0.0.1 -n 76 >nul
		set /a n=0
		goto WaitUntill_99
	) else ( 
	echo 99 of percent progress find 
	goto :eof
	)
) else ( 
	ECHO Progress no update,WAIT 5 S ... && ping 127.0.0.1 -n 6 >nul
	set /a n=!n!+1
	rem echo n:!n!
	goto WaitUntill_99
)

:WaitUntill_Complete
if !n! gtr 20 goto fail
if !n! equ 3 (
	 ECHO 30S already used, still no find 100 of percent, need wait 5min first
	 ECHO WAIT 5 min ... && ping 127.0.0.1 -n 301 >nul
)
if !n! equ 6 (
	 ECHO 6min already used, still no find 100 of percent, need wait 30S again
	 ECHO WAIT 30 s ... && ping 127.0.0.1 -n 31 >nul
)
adb logcat -v raw -s OTAUpgradeActivity:D -d | find "MSG_UPDATE_ENGINE_CALLBACK_STATUS_REBOOT"
if not errorlevel 1 (
	ECHO 100 of percent progress find 
	goto :eof
) else (
	ECHO WAIT 10 S ... && ping 127.0.0.1 -n 11 >nul
	set /a n=!n!+1
	goto WaitUntill_Complete
)

:fail
echo program error, please check!
echo UUT-FAIL
goto end

:pass
echo SUCCESSFULLY TEST

:end
rem pause
exit