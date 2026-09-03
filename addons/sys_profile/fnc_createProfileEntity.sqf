#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(createProfileEntity);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createProfileEntity

Description:
Create profiles based on vehicle type including vehicle crew

Parameters:
Array - array of man classnames
String - Side name
String - Faction
Array - position
Scalar - direction
String - optional profile-ID prefix (defaults to no prefix; kept separate from
    the legacy _prefix argument so existing callers retain their IDs)
Boolean - optional spawn-good-position flag (defaults to false, preserving the
    existing behavior of recording despawnPosition)
String - optional uniform rank for every unit (defaults to random ranks)
Array - optional per-unit positions
Boolean - optional isSPE flag
String - optional AI behaviour

Returns:
Array of created profiles

Examples:
(begin example)
// create profiles for vehicle class
_result = [["B_Heli_Light_01_F"],"WEST","BLU_F",getPosATL player] call ALIVE_fnc_createProfileEntity;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params [
    "_entityClasses",
    "_side",
    "_faction",
    "_position",
    ["_direction", 0],
    ["_prefix", ""],
    ["_busy", false],
    ["_profileIDPrefix", ""],
    ["_spawnGoodPosition", false],
    ["_rank", "", [""]],
    ["_positions", []],
    ["_isSPE", false],
    ["_aiBehaviour", "SAFE"]
];

ASSERT_DEBUG(_positions isnotequalto [] || {count _positions == count _entityClasses}, "fnc_createProfileEntity | count _positions must equal count _unitClasses")

private _unitRanks = ["PRIVATE","CORPORAL","SERGEANT","LIEUTENANT","CAPTAIN","MAJOR","COLONEL"];

private _ranks = [];
private _damages = [];

{
    _ranks pushback (if (_rank isEqualTo "") then { selectRandom _unitRanks } else { _rank });
    _damages pushback 0;
} foreach _entityClasses;

private _entityID = [ALIVE_profileHandler,"getNextInsertEntityID"] call ALIVE_fnc_profileHandler;

private _profileEntity = [nil,"create"] call ALIVE_fnc_profileEntity;
[_profileEntity,"init"] call ALIVE_fnc_profileEntity;

private _profileData = [
    ["profileID", if (_profileIDPrefix isEqualTo "") then { _entityID } else { format ["%1-%2", _profileIDPrefix, _entityID] }],
    ["position", _position],
    ["unitClasses", _entityClasses],
    ["unitCount", count _entityClasses],
    ["damages", _damages],
    ["ranks", _ranks],
    ["side", _side],
    ["faction", _faction],
    ["isPlayer", false],
    ["busy", _busy],
    ["isSPE", _isSPE],
    ["aiBehaviour", _aiBehaviour]
];

if !(_positions isEqualTo []) then {
    _profileData pushBack ["positions", _positions];
};

[_profileEntity, _profileData] call ALiVE_fnc_hashSetMany;

if (!_spawnGoodPosition) then {
    [_profileEntity,"despawnPosition", _position] call ALIVE_fnc_profileEntity;
};

[ALIVE_profileHandler,"registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;

_profileEntity
