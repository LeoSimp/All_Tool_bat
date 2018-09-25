@echo off
set file=%1
set CHKSUM_File=%2
set path=%path%;D:\USIPROJECT\UUTAP\CT60\

if not exist %file% call :fail "not exist %file%"
if not exist %CHKSUM_File% call :fail "not exist %CHKSUM_File%"

set CHKSUM1=
for /f "skip=3 tokens=1" %%i in ('fciv.exe "%file%"') do set CHKSUM1=%%i
set CHKSUM2=
for /f "tokens=1" %%i in ('type "%CHKSUM_File%"') do set CHKSUM2=%%i
echo CHKSUM Local:%CHKSUM1% 
echo CHKSUM Server:%CHKSUM2%
if not defined CHKSUM1 call :fail "not defined CHKSUM1"
if not defined CHKSUM2 call :fail "not defined CHKSUM1"
if "%CHKSUM1%"=="%CHKSUM2%" (echo SUCCESSFULLY TEST) else (call :fail "%CHKSUM1% not equal %CHKSUM2%") 
goto end

:fail
echo UUT-FAIL
echo %1
goto end

:end
