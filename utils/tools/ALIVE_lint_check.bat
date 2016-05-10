@echo off
rem set exe=echo
set exe=Rapify.exe -A -E -L -K -N
rem -N
set source=P:\x\alive\addons

FOR /F "tokens=1* delims=," %%A in ('dir %source% /ad /b') do (
	%exe% "%source%\%%A\config.cpp"
	if ERRORLEVEL 1 goto err
)

goto end

:err
pause

:end