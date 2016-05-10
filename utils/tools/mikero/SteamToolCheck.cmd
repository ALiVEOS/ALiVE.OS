@echo off
SETLOCAL ENABLEEXTENSIONS
set _ARMA3PATH=
for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKCU\SOFTWARE\bohemia interactive\arma 3 tools" /v "Path" 2^>nul') do (set _ARMA3PATH=%%B)

if  defined _ARMA3PATH goto oktools
echo A3 bis steam tools not in registry:
echo there is no "HKCU\SOFTWARE\bohemia interactive\arma 3 tools"
pause
exit/b 1
:oktools
echo registry says steam tools are installed in:
echo %_ARMA3PATH% 
set _ARMA3PATH=
for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKCU\SOFTWARE\bohemia interactive\binarize" /v "Path" 2^>nul') do (set _ARMA3PATH=%%B)
if  defined _ARMA3PATH goto okbinpath
echo there is no binarise path. missing registry key
echo "HKCU\SOFTWARE\bohemia interactive\binarize\path"
pause
exit/b 1

:okbinpath
set _BINEXE=
for /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKCU\SOFTWARE\bohemia interactive\binarize" /v "exe" 2^>nul') do (set _BINEXE=%%B)
if  defined _BINEXE goto okexe

echo there is no registry for binarise exe. missing key
echo "HKCU\SOFTWARE\bohemia interactive\binarize\exe"
pause
exit/b 1
:okexe
echo registry says bis binarise is in :
set fred=%_ARMA3PATH%\%_BINEXE% 
echo %fred%

if exist	 "%fred%" goto fileis

echo but the file does not exist
pause
exit/b 1
:fileis
echo and the file exists where it says it is
pause
exit/b 0

