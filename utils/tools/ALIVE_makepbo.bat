@echo off
rem set exe=echo
set exe=MakePBO -A -BD -L -P -U -X=thumbs.db,*.h,*.dep,*.bak,*.png,*.log,*.pew -Z=default 
set source=P:\x\alive\addons

set exeuncommpressed=MakePBO.exe -A -BD -L -P -X=thumbs.db,*.h,*.dep,*.bak,*.png,*.log,*.pew
set uncommpressedsource=P:\x\alive\addons\mil_OPCOM

rem ********************
rem find the arma3 path
rem ********************
:v64_path_a2
For /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKLM\SOFTWARE\Wow6432Node\Bohemia Interactive\ArmA 3" /v "MAIN"') Do (set _ARMA3PATH=%%B)

IF NOT DEFINED _ARMA3PATH (GOTO v32_path_a2) ELSE (GOTO v64_path_a2oa)

:v32_path_a2

For /F "Tokens=2* skip=2" %%C In ('REG QUERY "HKLM\SOFTWARE\Bohemia Interactive Studio\ArmA 3" /v "MAIN"') Do (set _ARMA3PATH=%%D)

IF NOT DEFINED _ARMA3PATH (GOTO uac_PATH_A2) ELSE (GOTO v64_path_a2oa)

:uac_PATH_A2

@FOR /F "tokens=2* delims=	 " %%I IN ('REG QUERY "HKLM\SOFTWARE\Wow6432Node\Bohemia Interactive\ArmA 3" /v "MAIN"') DO (SET _ARMA3PATH=%%J)

IF NOT DEFINED _ARMA3PATH (GOTO std_PATH_A2) ELSE (GOTO v64_path_a2oa)

rem arma2 not there

:std_PATH_A2
@FOR /F "tokens=2* delims=	 " %%K IN ('REG QUERY "HKLM\SOFTWARE\Bohemia Interactive\ArmA 3" /v "MAIN"') DO (SET _ARMA3PATH=%%L)

IF NOT DEFINED _ARMA3PATH (GOTO ENDfailA2) ELSE (GOTO v64_path_a2oa)

:v64_path_a2oa
echo PATH - %_ARMA3PATH%
echo EXE - %exe%
echo SOURCE - %source%

set target="%_ARMA3PATH%\@alive\addons"

FOR /F "tokens=1* delims=," %%A in ('dir %source% /ad /b') do (
	%exe% "%source%\%%A"
	if ERRORLEVEL 1 goto err
)

 echo %exeuncommpressed% %uncommpressedsource%
 %exeuncommpressed% "%uncommpressedsource%"

del /Y %target%\*.pbo
move /Y %source%\*.pbo %target%\

rem Optional PBOs
set source=P:\x\alive\optional
set target="%_ARMA3PATH%\@alive\optional"

IF NOT EXIST %target% (
	MD %target%
)

FOR /F "tokens=1* delims=," %%A in ('dir %source% /ad /b') do (
	%exe% "%source%\%%A"
	if ERRORLEVEL 1 goto err
)

 echo %exeuncommpressed% %uncommpressedsource%
 %exeuncommpressed% "%uncommpressedsource%"

del /Y %target%\*.pbo
move /Y %source%\*.pbo %target%\

goto end

:err
:ENDfailA2
pause

:end