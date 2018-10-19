@echo off

:Start
cls
set /p SN=Please input MB SN(16):

for /f "delims== tokens=2" %%i in ('stringlen.bat %SN%') do set StringLenth=%%i
if not %StringLenth% equ 16 (Echo The MB SN Length is not 16, please re-input && pause> nul && goto Start)

if exist resul.t del resul.t
call CHKQCN_Size_From_List.bat %SN% > resul.t
type resul.t
find "SUCCESSFUL TEST" resul.t >nul
if not errorlevel 1 (
	COLOR 2F
	echo %date% %time% %SN% Check QCN filesize pass
	echo %date% %time% %SN% Check QCN filesize pass >> %~n0_Log.txt
) else (
	COLOR 4F
	echo %date% %time% %SN% Check QCN filesize fail
	echo %date% %time% %SN% Check QCN filesize fail >> %~n0_Log.txt
)
Echo Press any key to continue...
Pause>nul
color 07
goto Start

