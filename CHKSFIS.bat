@echo off
chcp 437
ping 10.5.10.104 -n 2 | find /i "unreachable"
if errorlevel 1 goto pass

set IP_PRE=10.5
for /f "delims=: tokens=2" %%i in ('ipconfig ^| find "Default Gateway" ^| find "%IP_PRE%"') do set Gateway=%%i
echo Delete all the 0.0.0.0 route which include the new add wifi AP(192.168.1.1) and orignal one(%Gateway%)
route delete 0.0.0.0
echo Add the 0.0.0.0 route which only include the orignal one(%Gateway%)
route ADD 0.0.0.0 MASK 0.0.0.0 %Gateway% METRIC 3

echo wait 1S...
ping 127.0.0.1 -n 2 >nul

ping 10.5.10.104 -n 2 | find /i "unreachable"
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

