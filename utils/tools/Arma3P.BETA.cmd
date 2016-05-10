@echo off
if not exist p:\ (goto installP)
if exist extractpbo.exe (goto installok)
:install
echo extractpbo is required
pause
@exit /B 1
:installP
echo P: drive must be set
pause
@exit /B 1
:installok
rem Dta\bin.pbo
rem Dta\core.pbo
rem Dta\languagecore.pbo
rem Dta\languagecore_f.pbo
rem Dta\languagecore_h.pbo
rem Dta\product.bin

rem TODO: some sort of error with windows 7 and the slash in p:\ ???

rem unpacks all A2/OA/CO pbo's to the p: tree

rem ***************************************************
rem ********** YOU MUST HAVE P: set *******************
rem ***************************************************

rem run this cmd from same dir as extractpbo.exe
rem WARNING*WARNING*WARNING*WARNING*WARNING*WARNING*WARNING*WARNING*
rem WARNING: this bat obviously overwrites everything in p:\ca
rem WARNING*WARNING*WARNING*WARNING*WARNING*WARNING*WARNING*WARNING

SETLOCAL ENABLEEXTENSIONS

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
echo %_ARMA3PATH%

:run


rem :::::::::::::::::::::::::::::
rem :::::::: ProcessOA ::::::::::
rem :::::::::::::::::::::::::::::

if exist "%_ARMA3PATH%\Addons" (dir /b/s "%_ARMA3PATH%\Addons\*.pbo" >a3.txt) 
if exist "%_ARMA3PATH%\Dta" (dir /b/s "%_ARMA3PATH%\Dta\*.pbo" >>a3.txt)

goto process

findstr  /i "beta" "exp.txt" >betalist.txt
findstr  /iv "beta" "exp.txt" >pipe.txt
type betalist.txt >>pipe.txt
del /q betalist.txt
del /q exp.txt
ren pipe.txt exp.txt
rem ::::::::::::::::::::::::::::

:process

echo preserving roads and bin folders

rem ******* preserve personal edition shaders and hpp's
if not exist p:\bin (goto nobin)
rem if exist p:\pebin (rmdir /s/q p:\pebin)
rem ren p:\bin pebin
:nobin

echo removing folders. Expect this to take some time......
@echo off
if exist p:\a3 (rmdir /s/q p:\a3)
rem if exist p:\languagecore (rmdir /s/q p:\languagecore)
rem if exist p:\core (rmdir /s/q p:\core)
@echo off
echo done
 extractpbo -a "%_ARMA3PATH%\Addons" p:\
mkdir p:\a3\dta
extractpbo -a "%_ARMA3PATH%\Dta" p:\a3\dta
goto skip
echo extracting pbo's. expect THIS to take some time !!!.......
rem ******* standard co extraction ************
FOR /F "tokens=1* delims=," %%A in (a3.txt) do (
 extractpbo -a "%%A" p:\
 if ERRORLEVEL 1 goto err
)

goto skip

***** retrieve roads2 mlods ***********
echo retrieving mlod roads
if not exist p:\roads2 (goto noroads2)
rem copy only the base mlods. textures are fine as pbo entities
xcopy /y /q P:\roads2\*.p3d P:\ca\roads2
rmdir /s/q p:\roads2
:noroads2
if not exist p:\roads_pmc (goto noroadspmc)
xcopy /y /q P:\roads_pmc\*.p3d P:\ca\roads_pmc
rmdir /s/q p:\roads_pmc
:noroadspmc
if not exist p:\roads_e (goto noroadse)
xcopy /y /q /s P:\roads_e\*.p3d P:\ca\roads_e
rmdir /s/q p:\roads_e
:noroadse
echo replacing with engine's bin config
rem ******** retrieve pe's bin stuff (except cpp) eg overwrite it shaders are pe********
rem the engine's config is installed, the shaders et al are personal tools stuff, left for buldozer
echo retrieving bin
copy /y p:\bin\config.cpp pebin
rmdir /s/q p:\bin
ren p:\pebin bin

rem ******** fixup languagecore ***************
echo fixing stringtables
copy p:\languagecore\stringtable.xml p:\bin


rem ************* copy all ca configs to project folder ***************
:sklug
xcopy /s /y p:\ca\*.cpp "%WRP_PROJECTS%\ca\"
echo copy (or move) WRP_PROJECTS\ca to your projects folder
rem *********** convert all 49's to 48 **************** required for petools 2.0
convertp3d -50 p:\a3
if ERRORLEVEL 1 goto err
:skip


rem del co.txt record keeping
:success
echo success 
pause
@exit /B 0

:err
:ENDfailA2
echo fail
pause

@exit /B 1

:ENDfailA2OA
pause
@exit /B 2