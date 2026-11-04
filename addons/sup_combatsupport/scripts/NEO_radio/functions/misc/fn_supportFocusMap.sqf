/*
    NEO_fnc_supportFocusMap

    Pans the Combat Support tablet map to a support unit when it is picked from a
    unit list, so the player can see where it is before choosing a target. The
    zoom the player set is kept.

    Params:
        0: _unit <OBJECT> - the vehicle, battery gun or helicopter picked
        1: _pos <ARRAY> (optional) - a position to show instead of the unit's own,
           such as where a battery last fired

    Returns: nothing

    Author: Jman
*/

params [["_unit", objNull], ["_pos", [], [[]]]];
if (isNull _unit && {_pos isEqualTo []}) exitWith {};
private _map = (findDisplay 655555) displayCtrl 655560;
if (isNull _map) exitWith {};
if (_pos isEqualTo []) then { _pos = getPosATL _unit };
_map ctrlMapAnimAdd [0.4, ctrlMapScale _map, _pos];
ctrlMapAnimCommit _map;
