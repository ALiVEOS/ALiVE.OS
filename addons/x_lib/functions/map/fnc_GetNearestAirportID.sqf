/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_GetNearestAirportID

Description:
	Creates an array of nearestAirportIDs
	
Parameters:
	None.

Returns:
	Array - List of Nearest Aiport IDs.

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	?
---------------------------------------------------------------------------- */

private ["_Airports","_pos","_i","_Primary","_Secondary","_ILS"];

_pos = _this select 0;

_Primary = getArray(configFile >> "cfgWorlds" >> WorldName >> "ilsPosition");
_Secondary = (configFile >> "cfgWorlds" >> WorldName >> "SecondaryAirports");
_Airports = [[_Primary,0]];

for "_i" from 0 to ((count _Secondary)-1) do {
	_ILS = getArray(((configFile >> "cfgWorlds" >> WorldName >> "SecondaryAirports") select _i) >> "ilsPosition");
	_Airports pushback [_ILS,_i+1];
};

_Airports = [_Airports,[],{_pos distance (_x select 0)},"ASCEND"] call ALiVE_fnc_SortBy;
_Airports select 0 select 1;