#include <\x\alive\addons\sys_profile\script_component.hpp>
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

private ["_entityClasses","_side","_faction","_direction","_prefix","_busy","_position","_entityID",
"_profileEntity","_unitRanks","_positions","_ranks","_damages"];

_entityClasses = _this select 0;
_side = _this select 1;
_faction = _this select 2;
_position = _this select 3;
_direction = if(count _this > 4) then {_this select 4} else {0};
_prefix = if(count _this > 5) then {_this select 5} else {""};
_busy = if(count _this > 6) then {_this select 6} else {false};

// get counts of current profiles

_entityID = [ALIVE_profileHandler, "getNextInsertEntityID"] call ALIVE_fnc_profileHandler;

// create the profile for the entity

_unitRanks = ["PRIVATE","CORPORAL","SERGEANT","LIEUTENANT","CAPTAIN","MAJOR","COLONEL"];

_positions = [];
_ranks = [];
_damages = [];

{
    _positions pushback _position;
    _ranks pushback (selectRandom _unitRanks);
    _damages pushback 0;
} foreach _entityClasses;

_profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity, "profileID", _entityID] call ALIVE_fnc_profileEntity;
[_profileEntity, "unitClasses", _entityClasses] call ALIVE_fnc_profileEntity;
[_profileEntity, "position", _position] call ALIVE_fnc_profileEntity;
[_profileEntity, "despawnPosition", _position] call ALIVE_fnc_profileEntity;
[_profileEntity, "positions", _positions] call ALIVE_fnc_profileEntity;
[_profileEntity, "damages", _damages] call ALIVE_fnc_profileEntity;
[_profileEntity, "ranks", _ranks] call ALIVE_fnc_profileEntity;
[_profileEntity, "side", _side] call ALIVE_fnc_profileEntity;
[_profileEntity, "faction", _faction] call ALIVE_fnc_profileEntity;
[_profileEntity, "isPlayer", false] call ALIVE_fnc_profileEntity;
[_profileEntity, "busy", _busy] call ALIVE_fnc_profileEntity;

[ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;

_profileEntity