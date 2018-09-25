@echo off
set file=%1
set path=%path%;D:\USIPROJECT\UUTAP\CT60\

for /f "skip=3 tokens=1,2" %%i in ('fciv.exe "%file%"') do echo %%i %%j >%file%.md5
type %file%.md5
ECHO File: %file%.md5 create complete!