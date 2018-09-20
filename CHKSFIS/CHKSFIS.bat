
@echo off
@chcp 437 >nul

set SFIS_NetWrk=10.5.10.104
for /f "delims=. tokens=1,2" %%i in ('echo %SFIS_NetWrk%') do set IP_PRE=%%i.%%j

ECHO Check the SFIS network...
ping %SFIS_NetWrk% -n 1
if errorlevel 1 goto Next
ping %SFIS_NetWrk% -n 2 | find /i "unreachable"
if errorlevel 1 goto pass
:Next
ECHO Reset the SFIS network route set...
for /f "delims=: tokens=2" %%i in ('ipconfig ^| find "Default Gateway" ^| find "%IP_PRE%"') do set Gateway=%%i
if not defined Gateway (set ErrorMsg="Please check the network Gateway if contain %IP_PRE%" && goto fail)
echo Delete all the 0.0.0.0 route which include the new add wifi AP(192.168.1.1) and orignal one(%Gateway%)
route delete 0.0.0.0
if errorlevel 1 (set ErrorMsg="May need run as admin to retry" && goto fail)
echo Add the 0.0.0.0 route which only include the orignal one(%Gateway%)
route ADD 0.0.0.0 MASK 0.0.0.0 %Gateway% METRIC 3
if errorlevel 1 (set ErrorMsg="May need run as admin to retry" && goto fail)
echo wait 1S...
ping 127.0.0.1 -n 2 >nul
ping %SFIS_NetWrk% -n 1 
if errorlevel 1 (set ErrorMsg="Check SFIS network fail" && goto fail)
ping %SFIS_NetWrk% -n 2 | find /i "unreachable"
if not errorlevel 1 (set ErrorMsg="Check SFIS network fail" && goto fail)
goto pass

:fail
echo ErrorMsg:%ErrorMsg%
echo FAILED TEST
goto end

:pass
echo SUCCESSFUL TEST
goto end

:end

