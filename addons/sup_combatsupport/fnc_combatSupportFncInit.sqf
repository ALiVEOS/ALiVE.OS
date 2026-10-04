//----------------------
//Misc
//----------------------
NEO_fnc_smokeColor = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_smokeColor.sqf";
NEO_fnc_messageBroadcast = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_messageBroadcast.sqf";
NEO_fnc_callsignFix = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_callsignFix.sqf";
NEO_fnc_artyUnitAvailableRounds = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_artyUnitAvailableRounds.sqf";
NEO_fnc_artyUnitFiringDistance = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_artyUnitFiringDistance.sqf";
NEO_fnc_supportDrawRing = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportDrawRing.sqf";
NEO_fnc_supportSetTargetPos = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportSetTargetPos.sqf";
NEO_fnc_radioGridToPos = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_radioGridToPos.sqf";
NEO_fnc_radioPosToGrid = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_radioPosToGrid.sqf";
NEO_fnc_transportGunnerDefend = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_transportGunnerDefend.sqf";
NEO_fnc_transportInsertionHold = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_transportInsertionHold.sqf";
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
// A two-seat jet's back seat can own pylons, the S.O.G. F-4C's bombs among them, and the CAS menu and the
// attack only use the pilot's weapons: hand every pylon to the pilot, with the rounds it carries. Planes only:
// an attack helicopter's gunner owns its missile pylons and fires them.
NEO_fnc_casPylonsToPilot = {
    params ["_veh"];
    if !(_veh isKindOf "Plane") exitWith {};
    {
        _x params ["_index", "", "_turret", "_magazine", "_rounds"];
        if (_turret isNotEqualTo [-1] && {_magazine != ""}) then {
            _veh setPylonLoadout [_index, _magazine, true, [-1]];
            _veh setAmmoOnPylon [_index, _rounds];
        };
    } forEach getAllPylonsInfo _veh;
};
// A CAS plane parked where the game's own AI treats it as lined up for take-off (the start of a runway, facing down it)
// starts up and takes off by itself before it has been given anything to do: two F-100Ds parked at the start of the
// Khe Sanh SF strip were airborne 15 s into the mission, and side by side they met on the runway. Combat Support had not
// tasked them, so it showed them waiting at home and offered no RTB. This watches a plane while it has no task: the
// moment it starts its engine or rolls on the ground, it is put back on its stand and held there with an empty tank, the
// one thing that keeps a crewed jet still (the air commander holds its parked jets the same way). What was in the tank is
// kept on the plane (NEO_casHeldFuel) and the next task gives it back (cas.fsm, state "_"); the crew stays aboard.
NEO_fnc_casHoldWhenParked = {
    params ["_veh", "_callsign", "_dir"];
    if (!(_veh isKindOf "Plane") || {unitIsUAV _veh}) exitWith {};
    private _said = false;
    while { alive _veh } do {
        sleep 1;
        if ((_veh getVariable ["NEO_radioCurrentTask", []]) isEqualTo []) then {
            private _kept = _veh getVariable ["NEO_casHeldFuel", -1];
            if (_kept >= 0) then {
                // refuelled while held (a resupply truck): keep the larger figure and empty it again
                if (fuel _veh > 0) then {
                    _veh setVariable ["NEO_casHeldFuel", _kept max (fuel _veh), true];
                    _veh setFuel 0;
                };
            } else {
                if (isTouchingGround _veh && {((getPosATL _veh) select 2) < 2} && {isEngineOn _veh || {(abs speed _veh) > 2}}) then {
                    _veh setVariable ["NEO_casHeldFuel", fuel _veh, true];
                    _veh allowCrewInImmobile true;
                    _veh setFuel 0;
                    _veh engineOn false;
                    _veh setVelocity [0, 0, 0];
                    private _stand = _veh getVariable ["ALIVE_CombatSupport_Base", []];
                    if (_stand isEqualType [] && {count _stand >= 2} && {(_veh distance2D _stand) > 3}) then {
                        _veh allowDamage false;
                        _veh setPosATL [_stand select 0, _stand select 1, 0];
                        _veh setDir _dir;
                        _veh setVectorUp [0, 0, 1];
                        _veh setVelocity [0, 0, 0];
                        [_veh] spawn { sleep 3; (_this select 0) allowDamage true; };
                    };
                    if (!_said) then {
                        _said = true;
                        ["COMBAT SUPPORT - %1 (%2) started up by itself where it is parked, most likely at the start of a runway, where the game treats it as lined up for take-off. It is held on its stand until it is given a task. Parking it away from the start of the runway avoids this.",
                            _callsign, typeOf _veh] call ALiVE_fnc_dump;
                    };
                };
            };
        };
    };
};

//----------------------
//UI
//----------------------
NEO_fnc_radioOnLoad = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioOnLoad.sqf";
NEO_fnc_radioOnUnload = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioOnUnload.sqf";
NEO_fnc_radioLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioLbSelChanged.sqf";
NEO_fnc_radioMapEvent = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioMapEvent.sqf";
NEO_fnc_radioGridSetButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioGridSetButton.sqf";
NEO_fnc_radioRefreshUi = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioRefreshUi.sqf";
NEO_fnc_mapRestoreView = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_mapRestoreView.sqf";
NEO_fnc_mapControlSwap = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_mapControlSwap.sqf";
NEO_fnc_radioSetTerrainMode = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioSetTerrainMode.sqf";

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
NEO_fnc_casScriptedAttack = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casScriptedAttack.sqf";
NEO_fnc_casRearmService = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casRearmService.sqf";
NEO_fnc_disableOtherWeapons = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_disableOtherWeapons.sqf";
NEO_fnc_reenableWeapons = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_reenableWeapons.sqf";
NEO_fnc_casWeaponFamily = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casWeaponFamily.sqf";
NEO_fnc_casUsableWeapons = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casUsableWeapons.sqf";
NEO_fnc_casNextWeapon = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casNextWeapon.sqf";
NEO_fnc_casPrepareWeapons = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casPrepareWeapons.sqf";

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
