/*
    NEO_fnc_supportFocusMap

    Pans the Combat Support tablet map to a support unit when it is picked from a
    unit list, so the player can see where it is before choosing a target. The
    zoom the player set is kept.

    Params:
        0: _unit <OBJECT> - the vehicle, battery gun or helicopter picked

    Returns: nothing

    Author: Jman
*/

params [["_unit", objNull]];
if (isNull _unit) exitWith {};
private _map = (findDisplay 655555) displayCtrl 655560;
if (isNull _map) exitWith {};
_map ctrlMapAnimAdd [0.4, ctrlMapScale _map, getPosATL _unit];
ctrlMapAnimCommit _map;
