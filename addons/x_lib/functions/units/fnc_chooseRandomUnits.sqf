#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(chooseRandomUnits);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_chooseRandomUnits

Description:
Provides up to 4 random infantry unit types

Parameters:
Array - A list of factions
Number - Number of unit types to return
(Optional) Array - Blacklist of given units
(Optional) Boolean - unit is armed

Returns:
Array - A list of random unit types

Examples:
(begin example)
[["RU","INS"], ceil(random 5),["RU_Pilot","RU_SoldierAT],true] call ALiVE_fnc_chooseRandomUnits;
(end)

See Also:
- <ALiVE_fnc_findVehicleType>
- <ALiVE_fnc_getBuildingPositions>

Author:
Highhead
Jman
---------------------------------------------------------------------------- */

private ["_unittype","_types","_unittypes","_factions","_blacklist","_armed","_isWinterTerrain","_unittypeStr","_isWinUnit","_isSfUnit","_isGMUnit","_isBlkUnit"];

DEFAULT_PARAM(0,_factions,[]);
DEFAULT_PARAM(1,_count,1);
DEFAULT_PARAM(2,_blacklist,[]);
DEFAULT_PARAM(3,_armed,false);

if (!(typename _factions == "ARRAY") || !(typename _count == "SCALAR") || !(typename _blacklist == "ARRAY")) then {
    ["Main ALiVE_fnc_chooseRandomUnits probably failes due to wrong params given! Factions (Array): %1 | Max. units (Number): %2 | Blacklist (Array): %3", _factions, _count, _blacklist] call ALiVE_fnc_dump;
};

_types = [0, selectRandom _factions,"Man",_armed] call ALiVE_fnc_findVehicleType;
_unittypes = [];
_isWinterTerrain = ["winter", worldName] call BIS_fnc_inString;

// The classes that can be picked, filtered once. This used to draw at random until a class
// passed, which never ended for a faction where none can (one with only crew, pilots and
// officers, say: measured 11 Oct, an Assassination task stalled there for good). It also
// added every reject to the caller's own blacklist, which is often the shared CQB one.
private _fnc_unwanted = {
    params ["_type"];
    private _s = toLower ([_type] call ALiVE_fnc_toString);
    private _isGM = (_s find "gm_") >= 0;
    private _isWin = (_s find "_win") >= 0;
    (_type in _blacklist)
    || {_isGM && {_isWinterTerrain != _isWin}}
    || {_isGM && {(_s find "_sf_") >= 0 || {(_s find "_blk") >= 0} || {(_s find "_90_") >= 0}}}
    || {(["crew", "pilot", "officer", "police"] findIf { (_s find _x) >= 0 }) >= 0}
    // not soldiers at all, though they count as men: mods' spawner and invisible helpers,
    // base and uniform classes, and the UAV AI, none of which carries a weapon
    || {(["spawner", "invisible", "uav_ai"] findIf { (_s find _x) >= 0 }) >= 0}
    || {(_s select [count _s - 5]) == "_base" || {(_s find "_base_f") >= 0} || {(_s find "uniform") >= 0}}
    || {(getArray (configFile >> "CfgVehicles" >> _type >> "weapons")) isEqualTo []}
};
private _usable = _types select { !([_x] call _fnc_unwanted) };

if (_usable isNotEqualTo []) then {
    for "_i" from 1 to _count do {
        _unittype = selectRandom _usable;
        if (missionNamespace getVariable ["ALiVE_SYS_PROFILE_DEBUG_ON", false]) then {
            ["ALiVE_fnc_chooseRandomUnits - _unittype: %1", _unittype] call ALiVE_fnc_Dump;
        };
        _unittypes pushback _unittype;
    };
} else {
    if (_types isNotEqualTo []) then {
        ["ALiVE_fnc_chooseRandomUnits: none of the %1 soldier classes of %2 can be used (all crew, pilots, officers, police or blacklisted)", count _types, _factions] call ALiVE_fnc_dump;
    };
};

_unittypes;
