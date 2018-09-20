@echo off
rem The cmd.exe should be the last one to taskkill
rem The max support exe num is 9

set TaskList=%1 %2 %3 %4 %5 %6 %7 %8 %9 END

call :Loop %TaskList%
goto end

:LOOP
if /i "%1"=="END" goto :eof
rem Becuase this bat file will use C:\Windows\System32\cmd.exe to load, so we need skip this
tasklist /v /fo list | find /v "C:\Windows\System32\cmd.exe" | find /i "%1" >nul
if not errorlevel 1 ( taskkill /im %1 /f ) else ( echo The %1 is not in the tasklist )
shift
goto Loop

:END