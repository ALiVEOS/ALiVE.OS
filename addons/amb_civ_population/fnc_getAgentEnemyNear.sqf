#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(getAgentEnemyNear);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getAgentEnemyNear

Description:
Find an agent enemy nearby

Parameters:
Array - cluster hash
Array - position
Scalar - distance

Returns:
Array - empty if none found, 1 unit within if found

Examples:
(begin example)
//
_result = [getPos _agent, 300] call ALIVE_fnc_getAgentEnemyNear;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_cluster","_position","_distance","_result","_clusterHostility","_hostilitySettingsEAST","_hostilitySettingsWEST","_hostilitySettingsINDEP",
"_hostilitySides","_hostilityNumbers","_nearUnits","_highest","_highestIndex","_nearEAST","_nearWEST","_nearINDEP","_players","_mostHostileSide"];

_cluster = _this select 0;
_position = _this select 1;
_distance = _this select 2;

_result = [];

_clusterHostility = [_cluster, "hostility"] call ALIVE_fnc_hashGet;

_hostilitySettingsEAST = [_clusterHostility, "EAST"] call ALIVE_fnc_hashGet;
_hostilitySettingsWEST = [_clusterHostility, "WEST"] call ALIVE_fnc_hashGet;
_hostilitySettingsINDEP = [_clusterHostility, "GUER"] call ALIVE_fnc_hashGet;
//_hostilitySettingsGUER = [_clusterHostility, "GUER"] call ALIVE_fnc_hashGet;

_hostilitySides = ["EAST","WEST","GUER"];
_hostilityNumbers = [_hostilitySettingsEAST, _hostilitySettingsWEST, _hostilitySettingsINDEP];

_nearUnits = [] call ALIVE_fnc_hashCreate;
[_nearUnits, "EAST", []] call ALIVE_fnc_hashSet;
[_nearUnits, "WEST", []] call ALIVE_fnc_hashSet;
[_nearUnits, "GUER", []] call ALIVE_fnc_hashSet;

_nearEAST = [_nearUnits, "EAST"] call ALIVE_fnc_hashGet;
_nearWEST = [_nearUnits, "WEST"] call ALIVE_fnc_hashGet;
_nearINDEP = [_nearUnits, "GUER"] call ALIVE_fnc_hashGet;

{
    if(_position distance position _x < _distance) then {
        if(alive _x) then {
            switch(side (group _x)) do {
                case west:{
                    _nearWEST set [count _nearWEST, _x];
                };
                case east:{
                    _nearEAST set [count _nearEAST, _x];
                };
                case resistance:{
                    _nearINDEP set [count _nearINDEP, _x];
                };
            };
        };
    };
} forEach (_position nearEntities ["CAManBase", _distance]);


_players = [] call BIS_fnc_listPlayers;

{
    if(_position distance position _x < _distance) then {
        if(alive _x) then {
            switch(side (group _x)) do {
                case west:{
                    _nearWEST set [count _nearWEST, _x];
                };
                case east:{
                    _nearEAST set [count _nearEAST, _x];
                };
                case resistance:{
                    _nearINDEP set [count _nearINDEP, _x];
                };
            };
        };
    };
} forEach _players;

_nearEAST = [_nearUnits, "EAST"] call ALIVE_fnc_hashGet;
_nearWEST = [_nearUnits, "WEST"] call ALIVE_fnc_hashGet;
_nearINDEP = [_nearUnits, "GUER"] call ALIVE_fnc_hashGet;

/*
["HOST EAST %1",_hostilitySettingsEAST] call ALIVE_fnc_dump;
["HOST WEST %1",_hostilitySettingsWEST] call ALIVE_fnc_dump;
["HOST INDEP %1",_hostilitySettingsINDEP] call ALIVE_fnc_dump;
["NEAR EAST %1",_nearEAST] call ALIVE_fnc_dump;
["NEAR WEST %1",_nearWEST] call ALIVE_fnc_dump;
["NEAR INDEP %1",_nearINDEP] call ALIVE_fnc_dump;
*/

_highest = 0;
_highestIndex = 0;
{
    if(_x > _highest) then {
        _highest = _x;
        _highestIndex = _forEachIndex;
    };
} foreach _hostilityNumbers;

_mostHostileSide = _hostilitySides select _highestIndex;

/*
["hostile numbers: %1",_hostilityNumbers] call ALIVE_fnc_dump;
["hostile sides: %1",_hostilitySides] call ALIVE_fnc_dump;
["most hostile: %1",_mostHostileSide] call ALIVE_fnc_dump;
*/

private ["_units","_unit"];

if(count ([_nearUnits, _mostHostileSide] call ALIVE_fnc_hashGet) > 0) then {
    if(_highest > 0) then {
        _units = [_nearUnits, _mostHostileSide] call ALIVE_fnc_hashGet;
        _unit = _units call BIS_fnc_selectRandom;
        _result = [_unit];
    }
}else{
    _hostilityNumbers set [_highestIndex, -1];

    _highest = 0;
    _highestIndex = 0;
    {
        if(_x > _highest) then {
            _highest = _x;
            _highestIndex = _forEachIndex;
        };
    } foreach _hostilityNumbers;

    _mostHostileSide = _hostilitySides select _highestIndex;

    /*
    ["hostile numbers: %1",_hostilityNumbers] call ALIVE_fnc_dump;
    ["hostile sides: %1",_hostilitySides] call ALIVE_fnc_dump;
    ["next most hostile: %1",_mostHostileSide] call ALIVE_fnc_dump;
    */

    if(count ([_nearUnits, _mostHostileSide] call ALIVE_fnc_hashGet) > 0) then {
        if(_highest > 0) then {
            _units = [_nearUnits, _mostHostileSide] call ALIVE_fnc_hashGet;
            _unit = _units call BIS_fnc_selectRandom;
            _result = [_unit];
        }
    }else{
        _hostilityNumbers set [_highestIndex, -1];

        _highest = 0;
        _highestIndex = 0;
        {
            if(_x > _highest) then {
                _highest = _x;
                _highestIndex = _forEachIndex;
            };
        } foreach _hostilityNumbers;

        _mostHostileSide = _hostilitySides select _highestIndex;

        /*
        ["hostile numbers: %1",_hostilityNumbers] call ALIVE_fnc_dump;
        ["hostile sides: %1",_hostilitySides] call ALIVE_fnc_dump;
        ["least hostile: %1",_mostHostileSide] call ALIVE_fnc_dump;
        */

        if(count ([_nearUnits, _mostHostileSide] call ALIVE_fnc_hashGet) > 0) then {
            if(_highest > 0) then {
                _units = [_nearUnits, _mostHostileSide] call ALIVE_fnc_hashGet;
                _unit = _units call BIS_fnc_selectRandom;
                _result = [_unit];
            }
        };
    };

};

_result
