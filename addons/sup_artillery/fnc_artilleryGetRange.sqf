#include <\x\alive\addons\sup_artillery\script_component.hpp>
SCRIPT(ArtilleryGetRange);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_artilleryGetRange
Description:
Gets the range for artillery assets

Parameters:
Object - The artillery asset
String - The round type

Returns:
Number - The range

Examples:

See Also:

Author:
marceldev89
---------------------------------------------------------------------------- */
private _vehicle = param [0, objNull, [objNull]];
private _roundType = param [1, "", [""]];

private _range = 0;
private _inRange = true;
private _eta = 0;
private _target = position _vehicle;

// Figure out range by incrementing distance from asset. Configs seem unreliable.
while {_range == 0 || (_inRange && _eta != -1)} do {
    _inRange = _target inRangeOfArtillery [[_vehicle], _roundType];
    _eta = _vehicle getArtilleryETA [_target, _roundType];

    if (_inRange && _eta != -1) then {
        _range = (position _vehicle) distance2D _target;
    };

    _target = [_target, 1, 0] call BIS_fnc_relPos;
};

_range;
