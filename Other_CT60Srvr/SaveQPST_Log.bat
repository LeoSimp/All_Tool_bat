@echo off

set Model=%1
set SN=%2
set BKDIR=SYS_Fuse_QPST
set SaveDIR=SYS_RF2_Saved

call :Mapstart Q: \\10.5.42.30\QCN administrator usi_2010
set QPST_LogPath=Q:\%Model%_Log\
rem set QPST_LogPath=E:\%Model%_Log\
if not exist %QPST_LogPath% (set errorMsg="not exist %QPST_LogPath%" && goto fail)
if not defined SN (set errorMsg="not defined SN" && goto fail)
if not exist %QPST_LogPath%%SaveDIR%\ md %QPST_LogPath%%SaveDIR%\

echo copy  %QPST_LogPath%%BKDIR%\%SN%_Dload_COM*.dbg  to  %QPST_LogPath%%SaveDIR%\
copy /y %QPST_LogPath%%BKDIR%\%SN%_Dload_COM*.dbg %QPST_LogPath%%SaveDIR%\
if errorlevel 1 (set errorMsg="Dload_COM*.dbg copy fail" && goto fail)
echo copy %QPST_LogPath%%BKDIR%\%SN%_PortTrace_COM*.dbg  to  %QPST_LogPath%%SaveDIR%\
copy /y %QPST_LogPath%%BKDIR%\%SN%_PortTrace_COM*.dbg %QPST_LogPath%%SaveDIR%\
if errorlevel 1 (set errorMsg="PortTrace_COM*.dbg copy fail" && goto fail)

echo SUCCESSFUL TEST

goto end
:fail
echo errorMsg:%errorMsg%
echo FAILED TEST
goto end

:Mapstart
set Driver=%1
set ServerPath=%2
set User=%3
set PW=%4
for /f "tokens=1 delims=\" %%i in ('echo %ServerPath%') do set server=%%i
if exist %Driver%\ net use /d %Driver% /y
ping %server% -n 2 >nul
if errorlevel 1 (
	echo %server% ping error, Pls check the network
	goto :eof
)
net use %Driver% %ServerPath% /USER:%user% %PW% 
echo test >%Driver%\test.flag
if not exist %Driver%\test.flag (
	echo Map %Driver% ServerPath error 
	goto :eof
)
echo Successful to MAP server
del %Driver%\test.flag /f
goto :eof

:end