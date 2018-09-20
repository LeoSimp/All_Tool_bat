@echo off & setlocal enabledelayedexpansion

@mode con cols=160 lines=200
echo Logfile name like CT40PCBARF101004022104086610F_10H24M49S_P.txt
echo.
set /p Logfile=Please input the Logfile name:
:KewordInput
cls
echo Keword can contains blank for example:". WIFI_"
echo.
set /p "Keyword=Please input keyword:"
cls
echo diff is the difference between the value line number and the keyword line number
echo For example, the keyword is in line 66, but the value you want is in the next 3 line, then the diff is 3
echo If the keyword line number equal the value line number, the diff is 0
echo.
set /p "diff=Please input the diff:"
cls
echo According your input, the follwing will show you 3 line output, 
if exist Result.temp del Result.temp
find /i /n  "%Keyword%" %Logfile% > Result.temp
set /a n=0
for /f  "skip=2 delims=[] tokens=1,2" %%i in (Result.temp) do (
	set Line=%%i
	set "String=%%j"
	set /a Line=!Line!+%diff%
	set /a n=!n!+1
	for /f "tokens=1,2,3,4,5,6,7,8" %%a in ('find /i /n  "." %Logfile% ^| find /i "[!Line!]"') do set want_value=%%a,%%b,%%c,%%d,%%e,%%f,%%g,%%h
	echo !String!,!want_value! 
	if !n! geq 3 goto ExitLoop
	
)

:ExitLoop
echo if this is not your expect output, please select No, then will jump to Keword Input to re-input 
echo 1=OK, Continue; 2=No, Goto Keword re-input
echo.
set /p select=Please input the 1 or 2:
if "%select%"=="1" (goto next) else ( goto KewordInput )

:next
set outputfile=%Logfile%.out
if exist %outputfile% del %outputfile%
for /f  "skip=2 delims=[] tokens=1,2" %%i in (Result.temp) do (
	set Line=%%i
	set "String=%%j"
	set /a Line=!Line!+%diff%
	for /f "tokens=1,2,3,4,5,6,7,8" %%a in ('find /i /n  "." %Logfile% ^| find /i "[!Line!]"') do set want_value=%%a,%%b,%%c,%%d,%%e,%%f,%%g,%%h
	echo !String!,!want_value! >> %outputfile%
	
)
del Result.temp	
cls
type %outputfile%	
pause>nul
	