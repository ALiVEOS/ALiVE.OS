@echo off
rem ***************************************************
rem ********** YOU MUST HAVE P: set *******************
rem ***************************************************

rem WARNING*WARNING*WARNING*WARNING*WARNING*WARNING*WARNING*WARNING*
rem WARNING: this bat obviously overwrites everything in p:\a3
rem WARNING*WARNING*WARNING*WARNING*WARNING*WARNING*WARNING*WARNING

rem version 1.13
rem added registry check

rem todo, remove dubbing_f from extraction

SETLOCAL ENABLEEXTENSIONS


:ask
set /P INPUT=This will alter some content on the P drive. Are you sure? (y/n): %=%
If /I "%INPUT%"=="y" goto yes
If /I "%INPUT%"=="n" goto no
goto ask
:no
@exit /B 1
:yes


if exist p:\ (goto pfound)
echo P: drive must be set
pause
@exit /B 1

:pfound
for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKLM\SOFTWARE\Mikero\depbo" /v "path" 2^>nul') do (set _MIKEDLL=%%B)
if defined _MIKEDLL goto mikefound
for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKCU\SOFTWARE\Mikero\depbo" /v "path" 2^>nul') do (set _MIKEDLL=%%B)
if defined _MIKEDLL goto mikefound
echo mikero tools is not set in registry

set _MIKEDLL=C:\Program Files (x86)\Mikero\DePboTools\bin

:mikefound
set _MIKEDLL=%_MIKEDLL%\bin
echo %_MIKEDLL%
rem if not exist "%_MIKEDLL%\depbo.dll" (goto nofind)
if exist "%_MIKEDLL%\extractpbo.exe" goto foundextract
echo extractpbo is not installed
pause
exit /b 1

:foundextract
if exist "%_MIKEDLL%\derap.exe" goto foundDeRap
echo derap.exe is not installed
pause
exit /b 1

:foundDeRap



rem ********************
echo searching registry for the arma3 path
rem ********************


for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKLM\SOFTWARE\Wow6432Node\Bohemia Interactive Studio\ArmA 3" /v "MAIN" 2^>nul') do (set _ARMA3PATH=%%B)
if defined _ARMA3PATH goto found_A3
 
for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKLM\SOFTWARE\Bohemia Interactive Studio\ArmA 3" /v "MAIN" 2^>nul') do (set _ARMA3PATH=%%B)
if defined _ARMA3PATH goto found_A3
 
for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKLM\SOFTWARE\Wow6432Node\Bohemia Interactive\ArmA 3" /v "MAIN" 2^>nul') do (set _ARMA3PATH=%%B)
if defined _ARMA3PATH goto found_A3
 
for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKLM\SOFTWARE\Bohemia Interactive\ArmA 3" /v "MAIN" 2^>nul') do (set _ARMA3PATH=%%B)
if defined _ARMA3PATH goto found_A3
 
rem no regkeys are found so use steams generic folder if present

for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKLM\SOFTWARE\Wow6432Node\Valve\Steam" /v "InstallPath" 2^>nul') do (set _ARMA3PATH=%%B\steamapps\common\Arma 3)
if defined _ARMA3PATH goto found_A3
for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKLM\SOFTWARE\Valve\Steam" /v "InstallPath" 2^>nul') do (set _ARMA3PATH=%%B\steamapps\common\Arma 3)
if defined _ARMA3PATH goto found_A3

echo arma3 does not exist in the registry
goto err


:found_A3
echo %_ARMA3PATH%
rem goto skip
echo removing folders. Expect this to take some time......

echo removing a3...
if exist "%_ARMA3PATH%\addons\dubbing_radio_f_data.pbo" (ren "%_ARMA3PATH%\addons\dubbing_radio_f_data.pbo" dubbing_radio_f_data.pbo1)

if exist p:\a3 (rmdir /s/q p:\a3)
if ERRORLEVEL 1 goto err

echo extracting the addons folder....
extractpbo -p "%_ARMA3PATH%\Addons" p:\
if ERRORLEVEL 1 goto err

echo removing deprecated a3_dta if it exists...
if exist p:\a3_dta (rmdir /s/q p:\a3_dta)
if ERRORLEVEL 1 goto err

echo removing bin...
if exist p:\bin (rmdir /s/q p:\bin)
if ERRORLEVEL 1 goto err

echo removing core...
if exist p:\core (rmdir /s/q p:\core)
if ERRORLEVEL 1 goto err

echo removing languages...
if exist p:\languagecore (rmdir /s/q p:\languagecore)
if ERRORLEVEL 1 goto err
if exist p:\languagecore_f (rmdir /s/q p:\languagecore_f)
if ERRORLEVEL 1 goto err
if exist p:\languagecore_h (rmdir /s/q p:\languagecore_h)
if ERRORLEVEL 1 goto err



echo extracting dta....

extractpbo -p "%_ARMA3PATH%\Dta" p:\
if ERRORLEVEL 1 goto err
:skip
echo unrapping bins....
rem arma3 has a collection of rapified bins : product, languagelist and blah
rem one exception is texheaders.bin
if exist p:\dta (rmdir /s/q p:\dta)
if ERRORLEVEL 1 goto err
rem remove wrong locations from a previous install if any
if exist p:\languagelist.* (del /q p:\languagelist.*)
if exist p:\product.* (del /q p:\product.*)
if exist p:\splashwindow.* (del /q p:\splashwindow.*)

mkdir p:\dta
if ERRORLEVEL 1 goto err
set binfiles="%_ARMA3PATH%\Dta\*.bin"

rem only grab from the dta folder, not p, because it may have other, user-installed .bins

dir /b/s %binfiles% >p:\a3.txt
if ERRORLEVEL 1 goto err
findstr  /vic:"texheaders.bin" "p:\a3.txt" >"p:\pipe.txt"
if ERRORLEVEL 1 goto err
del p:\a3.txt
if ERRORLEVEL 1 goto err


FOR /F "tokens=1* delims=," %%A in (p:\pipe.txt) do (
 derap -p "%%A" p:\dta
 if ERRORLEVEL 1 goto err
 xcopy /Q/y "%%A" p:\dta
 if ERRORLEVEL 1 goto err
)
del p:\pipe.txt
rem goto success
echo installing buldozer and it's dlls
xcopy /q/y "%_ARMA3PATH%\*.dll" p:\
if ERRORLEVEL 1 goto err

rem xcopy /q/y "%_ARMA3PATH%\arma3.exe" p:\buldozer.exe
rem why?
copy /b/y "%_ARMA3PATH%\arma3.exe" p:\buldozer.exe
if ERRORLEVEL 1 goto err

xcopy /q/y "%_ARMA3PATH%\steam_appid.txt" p:\
if ERRORLEVEL 1 goto err

:success
ren "%_ARMA3PATH%\addons\dubbing_radio_f_data.pbo1" dubbing_radio_f_data.pbo
echo success 
pause
@exit /B 0

:err
ren "%_ARMA3PATH%\addons\dubbing_radio_f_data.pbo1" dubbing_radio_f_data.pbo

echo fail
pause

@exit /B 1

