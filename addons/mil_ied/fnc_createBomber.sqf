#include "\x\alive\addons\mil_IED\script_component.hpp"
SCRIPT(createBomber);

// Suicide Bomber - create Suicide Bomber at location
private ["_location","_debug","_victim","_size","_faction","_bomber"];

if !(isServer) exitWith {diag_log "Suicide Bomber Not running on server!";};

_victim = objNull;

if (typeName (_this select 0) == "ARRAY") then {
    _location = (_this select 0) select 0;
    _size = (_this select 0) select 1;
    _faction = (_this select 0) select 2;
} else {
    _bomber = _this select 0;
};

_victim = (_this select 1) select 0;

_debug = ADDON getVariable ["debug", false];

if(isnil "_debug") then {_debug = false};

// Create suicide bomber
private ["_grp","_side","_pos","_time","_marker","_class","_btype"];

if (isNil "_bomber") then {
    _pos = [_location, 0, _size - 10, 3, 0, 0, 0] call BIS_fnc_findSafePos;
    _side = _faction call ALiVE_fnc_factionSide;
    _grp = createGroup _side;
    _btype = ADDON getVariable ["Bomber_Type", ""];
    if ( isNil "_btype" || _btype == "") then {
        _class = ([[_faction], 1, ALiVE_MIL_CQB_UNITBLACKLIST, false] call ALiVE_fnc_chooseRandomUnits) select 0;
        if (isNil "_class") then {
            _class = ([[_faction], 1, ALiVE_MIL_CQB_UNITBLACKLIST, true] call ALiVE_fnc_chooseRandomUnits) select 0;
        };
    } else {
        _class = (selectRandom (parseSimpleArray (ADDON getVariable "Bomber_Type")));
    };
    if (isNil "_class") exitWith {diag_log "No bomber class defined."};
    _bomber = _grp createUnit [_class, _pos, [], _size, "NONE"];

    // ["SURFACE %1, %2", surfaceIsWater (position _bomber), (position _bomber)] call ALiVE_fnc_dump;
    if (surfaceIsWater (position _bomber)) exitWith { deleteVehicle _bomber; diag_log "Bomber pos was in water, aborting";};
};

if (isNil "_bomber") exitWith {};

// Add radio, suicide vest and charge
_bomber addweapon (selectRandom ["ItemRadio","ItemALiVEPhoneOld"]);
removeVest _bomber;
_bomber addVest "V_ALiVE_Suicide_Vest";
_bomber addItemToVest "DemoCharge_Remote_Mag";

// Select victim
_victim = (selectRandom (units (group _victim)));
if (isNil "_victim") exitWith {    deletevehicle _bomber;};

// Add debug marker
if (_debug) then {
    diag_log format ["ALIVE-%1 Suicide Bomber: created at %2 going after %3", time, _pos, name _victim];
};

[ALiVE_fnc_bomberHuntForTarget, 1, [_victim,_bomber, _pos, _blowUpFunc]] call CBA_fnc_addPerFrameHandler;
