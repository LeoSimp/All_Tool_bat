@echo off
set S_Keyfile_name=%1
rem S_Keyfile_name=CT6018238D83A2_20180901_154048.txt
if "%S_Keyfile_name:~24,1%" == "0" (set /a HH_File=%S_Keyfile_name:~25,1%) else (set /a HH_File=%S_Keyfile_name:~24,1%%S_Keyfile_name:~25,1%)
set /a HH_PC="%time:~0,2%"
echo The Local PC time Hour is %HH_PC%, and the Server Keyfile time Hour is %HH_File%
set /a Diff=HH_PC-HH_File
echo Check if Diff:%Diff% is into the limit of [0,3]...
if Not %Diff%  geq 0 (
	set errorMsg="The PC time or the server file time error, call TE/TD for help" 
	goto fail
)
if Not %Diff%  leq 3 (
	echo The already exist Keyfile in server is more than 3 Hours time limit, 
	echo can not sure the DUT if something has changed, so need re-flash Debug G2H OS to clear kefile message inside
	set errorMsg="The DUT need offline re-flash Debug G2H OS,Call TE for help" 
	goto fail
)
echo Check if Diff:%Diff% is into the limit of [0,3]...Pass


goto end

:fail
echo errorMsg:%errorMsg%
echo FAILED TEST
goto end

:end
