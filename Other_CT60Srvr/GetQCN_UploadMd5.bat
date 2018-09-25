@echo off & setlocal enabledelayedexpansion
rem Purpose:Get the server latest QCN file if exist many and upload QCN md5 file for rework use
rem Usage: GetQCN.bat %Model% %IMEI% %Num%
rem The NowMonth is the latst year and month, and the %Num% defines how many months need Query
rem the %YYYYMM_List%=NowMonth NowMonth-1 NowMonth-2 ... NowMonth-num-1 end
REM Notice: The local PC time format need set:YYYY/MM/DD or YYYY-MM-DD(YYYY*MM*DD)

rem Histroy:20180521 V1.0.0 Leo Frist Release

set path=%path%;D:\USIPROJECT\UUTAP\CT60\

set Model=%1
set IMEI=%2
set /a Num=%3-1

set NowMonth=%date:~0,4%%date:~5,2%
rem The follwing need have a blank before >
call :Get_MonthList %NowMonth% %Num% >tem.p
set /p MonthList=<tem.p

Set YYYYMM_List=%NowMonth% %MonthList%END
echo YYYYMM_List:%YYYYMM_List%
rem server path
call :Mapstart Q: \\10.5.22.30\QCN administrator usi_2010
set QCNPath=Q:\%Model%
rem Local path
rem set QCNPath=E:\Model\QCN_BK\%Model%
if not exist %QCNPath%\ echo Not find the %QCNPath%\ && goto fail
set YYYYMM=
call :Loop %YYYYMM_List%
if not defined YYYYMM echo Not find the %IMEI% QCN file && goto fail
for /f "" %%i in ('dir /b %QCNPath%\%YYYYMM%\%IMEI%_*.xqcn') do set filename=%%i
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
echo UUT-FAIL
goto end

:pass

echo Latest IMEI QCN path, %QCNPath%\%YYYYMM%\%filename%
echo VARSTRING QcnFile = '%filename%'

set QCNPool=D:\USIPROJECT\IMAGE\CT60\QCN
if not exist %QCNPool% mkdir %QCNPool%
if exist %QCNPool%\*.xqcn del %QCNPool%\*.xqcn
if exist %QCNPool%\*.md5 del %QCNPool%\*.md5
copy %QCNPath%\%YYYYMM%\%filename% %QCNPool%\%filename% /y
if errorlevel 1 goto  fail
set file=%QCNPool%\%filename%
for /f "skip=3 tokens=1,2" %%i in ('fciv.exe "%file%"') do echo %%i %%j >%QCNPool%\%filename%.md5
type %file%.md5
if not exist %QCNPool%\%filename%.md5 goto fail
ECHO File: %file%.md5 create complete!
copy %QCNPool%\%filename%.md5 %QCNPath%\%YYYYMM%\%filename%.md5 /y
if errorlevel 1 goto  fail
echo VARSTRING QCNCT60 = '%QCNPool%\%filename%'
echo SUCCESSFUL TEST

:end
if exist tem.p del tem.p