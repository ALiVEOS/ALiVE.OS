//»»»»»»»»»»»»»»»»»»»»»»
//Misc
//»»»»»»»»»»»»»»»»»»»»»»
NEO_fnc_smokeColor = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_smokeColor.sqf";
NEO_fnc_messageBroadcast = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_messageBroadcast.sqf";
NEO_fnc_callsignFix = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_callsignFix.sqf";
NEO_fnc_artyUnitAvailableRounds = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_artyUnitAvailableRounds.sqf";
NEO_fnc_artyUnitFiringDistance = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_artyUnitFiringDistance.sqf";
NEO_fnc_radioCreateMarker = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_createMarker.sqf";
NEO_fnc_radioHint = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_radioHint.sqf";
NEO_fnc_radioSupportAdd = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportAdd.sqf";
NEO_fnc_radioSupportRemove = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportRemove.sqf";
fnc_setGroupID = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_setGroupID.sqf";
fnc_addAction = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_addAction.sqf";
fnc_setFlyInHeight = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_setFlyInHeight.sqf";
fnc_setSpeed = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_setSpeed.sqf";
fnc_setROE = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_setROE.sqf";
fnc_getSitrep = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_getSitrep.sqf";
ALIVE_fnc_RespawnArtyAsset = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_RespawnArtyAsset.sqf";
ALIVE_fnc_RespawnTransportAsset = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_RespawnTransportAsset.sqf";

ALIVE_fnc_RespawnCASAsset = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_RespawnCASAsset.sqf";

//»»»»»»»»»»»»»»»»»»»»»»
//UI
//»»»»»»»»»»»»»»»»»»»»»»
NEO_fnc_radioOnLoad = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioOnLoad.sqf";
NEO_fnc_radioOnUnload = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioOnUnload.sqf";
NEO_fnc_radioLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioLbSelChanged.sqf";
NEO_fnc_radioMapEvent = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioMapEvent.sqf";
NEO_fnc_radioRefreshUi = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioRefreshUi.sqf";

//Transport
NEO_fnc_transportUnitLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportUnitLbSelChanged.sqf";
NEO_fnc_transportTaskLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportTaskLbSelChanged.sqf";
NEO_fnc_transportConfirmButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportConfirmButton.sqf";
NEO_fnc_transportConfirmButtonEnable = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportConfirmButtonEnable.sqf";
NEO_fnc_transportBaseButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportBaseButton.sqf";
NEO_fnc_transportSmokeFoundButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportSmokeFoundButton.sqf";
NEO_fnc_transportSmokeNotFoundButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportSmokeNotFoundButton.sqf";
NEO_fnc_radioTransportOnComboCurSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportOnComboCurSelChanged.sqf";

//CAS
NEO_fnc_casUnitLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\cas\fn_casUnitLbSelChanged.sqf";
NEO_fnc_casTaskLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\cas\fn_casTaskLbSelChanged.sqf";
NEO_fnc_casConfirmButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\cas\fn_casConfirmButton.sqf";
NEO_fnc_casBaseButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\cas\fn_casBaseButton.sqf";
NEO_fnc_casConfirmButtonEnable = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\cas\fn_casConfirmButtonEnable.sqf";
NEO_fnc_pickCasTarget = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_pickCasTarget.sqf";
NEO_fnc_disableOtherWeapons = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_disableOtherWeapons.sqf";
NEO_fnc_reenableWeapons = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_reenableWeapons.sqf";

//ARTY
NEO_fnc_artyUnitLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyUnitLbSelChanged.sqf";
NEO_fnc_artyConfirmButtonEnable = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyConfirmButtonEnable.sqf";
NEO_fnc_artyConfirmButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyConfirmButton.sqf";
NEO_fnc_artyMoveButtons = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyMoveButtons.sqf";
NEO_fnc_artyBaseButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyBaseButton.sqf";
NEO_fnc_artyOrdLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyOrdLbSelChanged.sqf";
NEO_fnc_artyDispersionOnSliderPosChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyDispersionOnSliderPosChanged.sqf";
NEO_fnc_artyRateDelayOnSliderPosChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyRateDelayOnSliderPosChanged.sqf";
NEO_fnc_artyRateOfFireLbOnSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyRateOfFireLbOnSelChanged.sqf";
ALIVE_fnc_ExecuteMission = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_ExecuteMission.sqf";
ALIVE_fnc_GetMagazineType = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_GetMagazineType.sqf";
