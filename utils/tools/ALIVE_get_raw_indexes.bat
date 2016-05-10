@echo off
set exe=DeWrp.exe -O

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

set arma=%_ARMA3PATH%

set target=P:\x\alive\addons\fnc_strategic\indexes

rem ----------------------------- A3 --------------------------------------
rem %exe% "%arma%\Addons\map_altis.pbo" > %target%\objects.altis.sqf
rem %exe% "%arma%\Addons\map_stratis.pbo" > %target%\objects.stratis.sqf

rem %exe% "%arma%\@nam\Addons\pandora.pbo" > %target%\objects.pandora.sqf

rem %exe% "%arma%\@lingor_a3\Addons\lingor3.pbo" > %target%\objects.lingor3.sqf
rem %exe% "%arma%\@panthera_a3\Addons\panthera3.pbo" > %target%\objects.panthera3.sqf
rem %exe% "%arma%\@mske-a3\Addons\hotze_mske.pbo" > %target%\objects.mske.sqf

rem %exe% "%arma%\@imrali\addons\imrali.pbo" > %target%\objects.imrali.sqf

rem %exe% "%arma%\@everon2013\addons\everon2014.pbo" > %target%\objects.everon2014.sqf

rem %exe% "%arma%\@esseker\Addons\esseker.pbo" > %target%\objects.esseker.sqf

rem %exe% "%arma%\@mog\Addons\mog.pbo" > %target%\objects.mog.sqf

rem %exe% "%arma%\@gunkizli\Addons\projeta3008.pbo" > %target%\objects.pja308.sqf

rem %exe% "%arma%\@Bornholm\Addons\Bornholm.pbo" > %target%\objects.bornholm.sqf
rem %exe% "%arma%\@panthera_a3\addons\panthera3.pbo" > %target%\objects.panthera3.sqf

rem %exe% "%arma%\@wake\addons\wake.pbo" > %target%\objects.wake.sqf

rem %exe% "%arma%\@sfp_islands\addons\sfp_sturko.pbo" > %target%\objects.sturko.sqf
rem %exe% "%arma%\@sfp_islands\addons\sfp_wamako.pbo" > %target%\objects.wamako.sqf

rem %exe% "%arma%\@dariyah\addons\projeta3-07.pbo" > %target%\objects.dariyah.sqf
rem %exe% "%arma%\@kalukhan\addons\projeta3-06.pbo" > %target%\objects.kalukhan.sqf

rem %exe% "%arma%\@allinarmaterrainpack\addons\sara.pbo" > %target%\objects.sara.sqf
rem %exe% "%arma%\@allinarmaterrainpack\addons\sara_dbe1.pbo" > %target%\objects.sara_dbe1.sqf
rem %exe% "%arma%\@allinarmaterrainpack\addons\saralite.pbo" > %target%\objects.saralite.sqf

rem ----------------------------- A2 --------------------------------------
rem %exe% "%arma%\@a2\chernarus.pbo" > %target%\objects.chernarus.sqf
rem %exe% "%arma%\@a2\utes.pbo" > %target%\objects.utes.sqf
rem %exe% "%arma%\@a2co\Expansion\Addons\desert_e.pbo" > %target%\objects.desert_e.sqf
rem %exe% "%arma%\@a2co\Expansion\Addons\takistan.pbo" > %target%\objects.takistan.sqf
rem %exe% "%arma%\@a2co\Expansion\Addons\zargabad.pbo" > %target%\objects.zargabad.sqf
rem %exe% "%arma%\@a2co\Common\provinggrounds_pmc.pbo" > %target%\objects.provinggrounds_pmc.sqf
rem %exe% "%arma%\@a2co\Common\shapur_baf.pbo" > %target%\objects.shapur_baf.sqf

rem ----------------------------- A1 --------------------------------------
rem %exe% "D:\SteamLibrary\SteamApps\common\ARMA Gold\AddOns\desert.pbo" > %target%\objects.desert.sqf
rem %exe% "D:\SteamLibrary\SteamApps\common\ARMA Gold\AddOns\Desert2.pbo" > %target%\objects.desert2.sqf
rem %exe% "D:\SteamLibrary\SteamApps\common\ARMA Gold\AddOns\sara.pbo" > %target%\objects.sara.sqf
rem %exe% "D:\SteamLibrary\SteamApps\common\ARMA Gold\AddOns\saralite.pbo" > %target%\objects.saralite.sqf
rem %exe% "%arma%\@dbe1\AddOns\Sara_DBE1.pbo" > %target%\objects.sara_dbe1.sqf

rem ----------------------------- CWR2 ------------------------------------
rem %exe% "%arma%\@a2co\@CWR2\Addons\cwr2_abel.pbo" > %target%\objects.abel.sqf
rem %exe% "%arma%\@a2co\@CWR2\Addons\cwr2_cain.pbo" > %target%\objects.cain.sqf
rem %exe% "%arma%\@a2co\@CWR2\Addons\cwr2_eden.pbo" > %target%\objects.eden.sqf
rem %exe% "%arma%\@a2co\@CWR2\Addons\cwr2_noe.pbo" > %target%\objects.noe.sqf

rem ----------------------------- Iron Front ----------------------------------
rem %exe% "%arma%\@IF\addons\baranow_wrp.pbo" > %target%\objects.baranow.sqf
rem %exe% "%arma%\@IF\addons\ivachev_wrp.pbo" > %target%\objects.ivachev.sqf
rem %exe% "%arma%\@IF\addons\panovo_wrp.pbo" > %target%\objects.panovo.sqf
rem %exe% "%arma%\@IF\addons\staszow_wrp.pbo" > %target%\objects.staszow.sqf
rem %exe% "%arma%\@LIB_DLC_1\addons\france_wrp.pbo" > %target%\objects.colleville.sqf

rem ----------------------------- User ------------------------------------

rem %exe% "%arma%\@a2co\@Nziwasogo_V03\addons\projeta3-05.pbo" > %target%\objects.nziwasogo.sqf
rem %exe% "%arma%\@a2co\@Lingor\Addons\lingor.pbo" > %target%\objects.lingor.sqf
rem %exe% "%arma%\@a2co\@isla_duala\Addons\isladuala.pbo" > %target%\objects.isladuala.sqf
rem %exe% "%arma%\@a2co\@Tavi\Addons\tavi.pbo" > %target%\objects.taviana.sqf
rem %exe% "%arma%\@a2co\@napf\Addons\napf.pbo" > %target%\objects.napf.sqf
rem %exe% "%arma%\@a2co\@caribou\AddOns\caribou_summer_conf.pbo" > %target%\objects.caribou.sqf
rem %exe% "%arma%\@a2co\@smd_sahrani_a2\addons\smd_sahrani_a2.pbo" > %target%\objects.smd_sahrani_a2.sqf
rem %exe% "%arma%\@a2co\@MBG_Celle2\addons\mbg_celle2.pbo" > %target%\objects.mbg_celle2.sqf
rem %exe% "%arma%\@a2co\@fata\addons\fata.pbo" > %target%\objects.fata.sqf
rem %exe% "%arma%\@koplic\addons\projeta3-01.pbo" > %target%\objects.koplic.sqf
rem %exe% "%arma%\@a2co\@Sangin\Addons\hellskitchen.pbo" > %target%\objects.hellskitchen.sqf
rem %exe% "%arma%\@a2co\@Sangin\Addons\hellskitchens.pbo" > %target%\objects.hellskitchens.sqf
rem %exe% "%arma%\@a2co\@carraigdubh\Addons\carraigdubh.pbo" > %target%\objects.carraigdubh.sqf
rem %exe% "%arma%\@a2co\@CLAfghan\Addons\clafghan.pbo" > %target%\objects.clafghan.sqf
rem %exe% "%arma%\@a2co\@fallujah\Addons\fallujah1_2.pbo" > %target%\objects.fallujah.sqf
rem %exe% "%arma%\@a2co\@FDF_Podagorsk\Addons\fdf_isle1_a.pbo" > %target%\objects.fdf_isle1_a.sqf
rem %exe% "%arma%\@a2co\@isla_duala\Addons\isladuala.pbo" > %target%\objects.isladuala.sqf
rem %exe% "%arma%\@a2co\@MBG_Celle\Addons\celle.pbo" > %target%\objects.celle.sqf
rem %exe% "%arma%\@a2co\@NGS_CAPRAIA\Addons\isoladicapraia.pbo" > %target%\objects.isoladicapraia.sqf
rem %exe% "%arma%\@a2co\@Lingor\Addons\lingor.pbo" > %target%\objects.lingor.sqf
rem %exe% "%arma%\@a2co\@mcn_hazarkot\Addons\mcn_hazarkot.pbo" > %target%\objects.mcn_hazarkot.sqf
rem %exe% "%arma%\@a2co\@namalsk\Addons\namalsk.pbo" > %target%\objects.namalsk.sqf
rem %exe% "%arma%\@a2co\@panthera\Addons\panthera2.pbo" > %target%\objects.panthera.sqf
rem %exe% "%arma%\@a2co\@Thirsk\Addons\thirsk2.pbo" > %target%\objects.thirsk.sqf
rem %exe% "%arma%\@a2co\@Thirsk\Addons\thirsk4.pbo" > %target%\objects.thirskw.sqf
rem %exe% "%arma%\@a2co\@tigeria\Addons\tigeria.pbo" > %target%\objects.tigeria.sqf
rem %exe% "%arma%\@a2co\@ToraBora\Addons\torabora.pbo" > %target%\objects.torabora.sqf
rem %exe% "%arma%\@a2co\@TUP\Addons\tup_qom.pbo" > %target%\objects.tup_qom.sqf

rem ----------------------------- Not Completed------------------------------------



rem ----------------------------- Broken - No Index Produced -----------------------

rem %exe% "%arma%\@a2co\@vostok\Addons\vostok.pbo" > %target%\objects.vostok.sqf
rem %exe% "%arma%\@a2co\@vostok\Addons\vostok_w.pbo" > %target%\objects.vostok_w.sqf

:err
:ENDfailA2
pause