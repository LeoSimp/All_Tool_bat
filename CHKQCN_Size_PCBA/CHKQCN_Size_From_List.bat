@echo off & setlocal enabledelayedexpansion
rem Purpose:Get the IMEI from IT query list file, and Get the server latest QCN file if exist many and check its size
rem Usage: CHKQCN_Size_From_List %SN%
REM Notice: The local PC date format need set:YYYY/MM/DD or YYYY-MM-DD(YYYY*MM*DD)
REM			time format need remove tt for remove AM/PM(change H:mm:ss tt to H:mm:ss )

rem Histroy:20181015 V1.0.0 Leo Frist Release
chcp 437

set SN=%1
set List_File=SN_IMEI.txt

set Model=CT60
set /a Num=1
if not exist %List_File% (set ErrorMsg="Not exist the File: %List_File%" && goto fail )
find "%SN%" %List_File% >nul
if errorlevel 1 (set ErrorMsg="Not exist the %SN% in the File:%List_File%" && goto fail )
set IMEI=
for /f "tokens=2" %%i in ('find "%SN%" %List_File%') do set IMEI=%%i
if not defined IMEI (set ErrorMsg="Can not find the IMEI in the File:%List_File% " && goto fail )

echo The IMEI of %SN% is :%IMEI%

rem set NowMonth=%date:~0,4%%date:~5,2%
rem The follwing need have a blank before >
rem call :Get_MonthList %NowMonth% %Num% >tem.p
rem set /p MonthList=<tem.p

Set YYYYMM_List=201810 201809 END
echo YYYYMM_List:%YYYYMM_List%
rem server path
call :Mapstart Q: \\10.5.42.30\QCN administrator usi_2010
set QCNPath=Q:\%Model%
rem Local path
rem set QCNPath=E:\Model\QCN_BK\%Model%
if not exist %QCNPath%\ echo Not find the %QCNPath%\ && goto fail
set YYYYMM=
call :Loop %YYYYMM_List%
if not defined YYYYMM echo Not find the %IMEI% QCN file && goto fail
echo %QCNPath%\%YYYYMM%\%IMEI%_*.xqcn
for /f "skip=5 tokens=4,5" %%i in ('dir %QCNPath%\%YYYYMM%\%IMEI%_*.xqcn ^| find /v "bytes"') do (
	set filesize=%%i 
	set filename=%%j
)
echo filesize:!filesize!
for /f "delims=, tokens=1" %%i in ('echo !filesize!') do set filesize_K=%%i
if %filesize_K% lss 700 (set errorMsg="The filesize of !filename! is less than 700K" && goto fail)
goto pass

:Loop
if "%1"=="END" goto :eof
if exist %QCNPath%\%1\%IMEI%_*.xqcn set YYYYMM=%1&& goto :eof
shift
goto Loop

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

:Get_MonthList
set Month0=%1
for /l %%i in (1,1,%2) do (
	set  /a Month%%i=!Month0!-1
	if "!Month%%i:~4,2!"=="00" (
		set /a Month_1_4=!Month0:~0,4!-1
		set Month%%i=!Month_1_4!12
		rem set Month0=!Month%%i!
	) 
	set Month0=!Month%%i!
	set /p =!Month%%i! <NUL
	rem echo Month0:!Month0!
	rem pause>nul
)	
goto :eof

:fail
echo errorMsg:%errorMsg%
echo FAILED TEST
goto end

:pass
echo SUCCESSFUL TEST

:end
if exist tem.p del tem.p
