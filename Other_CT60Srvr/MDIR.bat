@echo off
set Path1=%1

if not defined Path1  echo %0 run error, pls check

if not exist %Path1% md %Path1%