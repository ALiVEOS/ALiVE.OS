#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(isHouseEnterable);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isHouseEnterable

Description:
Returns true if the house is enterable and not blacklisted

Parameters:
Object - House

Returns:
Boolean - True if house has one building position

Examples:
(begin example)
if([_house] call ALIVE_fnc_isHouseEnterable) then{
    hint format["%1 is enterable", _house];
};
(end)

See Also:
- <ALIVE_fnc_getObjectsByType>
- <ALIVE_fnc_getAllEnterableHouses>
- <ALIVE_fnc_getEnterableHouses>

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private ["_house","_err","_enterable"];

PARAMS_1(_house);
_err = "house not valid";
ASSERT_DEFINED("_house",_err);
ASSERT_TRUE(typeName _house == "OBJECT",_err);

_enterable = !((_house buildingPos 0) isEqualTo [0,0,0]);
// Check if the house is blacklisted
// Set blacklist sometime near mission launch (eg in init.sqf)
if (_enterable && !(isNil "ALIVE_Building_Blacklist")) then {
    if ((typeOf _house) in ALIVE_Building_Blacklist) then {
        _enterable = false;
    };
};
// filter out SPE bocage objects 
if (_house isKindOf "spe_bocage_base") then {
	_enterable = false;
};

_enterable