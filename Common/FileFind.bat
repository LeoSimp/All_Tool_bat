@echo off
echo VARSTRING Result = ''
set keyword=%1
set file=%2
if not ^%keyword:~0,1%==^" (set ErrorMsg="1st parameter not include left quotation" && goto fail)
if not ^%keyword:~-1%==^" (set ErrorMsg="1st parameter not include right quotation" && goto fail)
if not exist %file% (set ErrorMsg="not exist %file% " && goto fail)

find /i %keyword% %file%
if errorlevel 1 (set ErrorMsg="can not find %keyword% in %file% " && echo VARSTRING Result = 'FALSE' && goto fail)
echo Can find %keyword% in %file%
goto pass
:fail
echo VARSTRING ErrorMsg = '%ErrorMsg%'
echo FAILED TEST
goto end

:pass
echo SUCCESSFUL TEST
echo VARSTRING Result = 'TRUE'
goto end

:end