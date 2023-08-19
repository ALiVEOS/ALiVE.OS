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

if(count _types > 0) then {
    for "_i" from 1 to _count do {
        while {
        	_unittype = selectRandom _types; 
        	
        	_unittypeStr = [_unittype] call ALiVE_fnc_toString;
        	_isGMUnit = ["gm_", _unittypeStr] call BIS_fnc_inString;
        	_isWinUnit = ["_win", _unittypeStr] call BIS_fnc_inString;
        	_isSfUnit = ["_sf_", _unittypeStr] call BIS_fnc_inString;
        	_isBlkUnit = ["_blk", _unittypeStr] call BIS_fnc_inString;
        	_isCrewUnit = ["crew", _unittypeStr] call BIS_fnc_inString;
        	_isPilotUnit = ["pilot", _unittypeStr] call BIS_fnc_inString;
        	_isOfficerUnit = ["officer", _unittypeStr] call BIS_fnc_inString;
        	_isPoliceUnit = ["police", _unittypeStr] call BIS_fnc_inString;
        	_isFlkUnit = ["_90_", _unittypeStr] call BIS_fnc_inString;
        	
        	// dynamically add to blacklist if it's a wintermap & it's a GM unit and this is not a winter unit
        	if (_isWinterTerrain && _isGMUnit && !_isWinUnit) then {
        		_blacklist pushback _unittype;
        	};
        	// dynamically add to blacklist if it's not a wintermap & it's a GM unit and this is a winter unit
        	if (!_isWinterTerrain && _isGMUnit && _isWinUnit) then {
        		_blacklist pushback _unittype;
        	};
					// dynamically add to blacklist if it's a GM unit and this is a SF unit
        	if (_isGMUnit && _isSfUnit) then {
        		_blacklist pushback _unittype;
        	};
					// dynamically add to blacklist if it's a GM unit and this is a Blk unit
        	if (_isGMUnit && _isBlkUnit) then {
        		_blacklist pushback _unittype;
        	};
					// dynamically add to blacklist if it's a GM unit and this is an FLK unit
        	if (_isGMUnit && _isFlkUnit) then {
        		_blacklist pushback _unittype;
        	};
					// dynamically add to blacklist if it's a crew unit
        	if (_isCrewUnit) then {
        		_blacklist pushback _unittype;
        	};
					// dynamically add to blacklist if it's a pilot unit
        	if (_isPilotUnit) then {
        		_blacklist pushback _unittype;
        	};
					// dynamically add to blacklist if it's an officer unit
        	if (_isOfficerUnit) then {
        		_blacklist pushback _unittype;
        	};
					// dynamically add to blacklist if it's a police unit
        	if (_isPoliceUnit) then {
        		_blacklist pushback _unittype;
        	};

        	(_unittype in _blacklist)

        } do {true}; 
        if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
        	["ALiVE_fnc_chooseRandomUnits - _unittype: %1", _unittype] call ALiVE_fnc_Dump;
        };
        _unittypes pushback _unittype;
    };
};

_unittypes;
