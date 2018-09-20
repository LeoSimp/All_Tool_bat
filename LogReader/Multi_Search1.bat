@echo off & setlocal enabledelayedexpansion

if not exist %~dp0OutputDir md %~dp0OutputDir
if not exist %~dp0SN_list.txt ( set errorMsg="not exist %~dp0SN_list.txt" && goto fail )
for /f "" %%a in (%~dp0SN_list.txt) do (
	set SN=%%a
	for /f "" %%i in ('dir /ad /b ^| find /v "OutputDir" ^| find /v "Log"') do (
		set DateDir=%%i
		if exist %~dp0!DateDir!\*!SN!*.txt copy /y %~dp0!DateDir!\*!SN!*.txt %~dp0OutputDir\ >nul
	)
)

goto end
:fail
echo errorMsg:%errorMsg%
echo UUT-FAIL
goto end

:end
