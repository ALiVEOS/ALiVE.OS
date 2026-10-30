#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(addToEnemyGroup);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addToEnemyGroup

Description:
Assigns a unit to an enemy group of a target

Parameters:
Object - unit
Object - target

Returns:

Examples:
(begin example)
//
_result = [_unit, _target] call ALIVE_fnc_addToEnemyGroup;
(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

private ["_unit","_target","_unitSide","_targetSide","_group","_currentGroup"];

_unit = _this select 0;
_target = _this select 1;

_unitSide = side group _unit;
_targetSide = side group _target;

if!((_unitSide) getFriend (_targetSide) < 0.6) then {
    // An insurgent commander's side comes first when it's hostile to the target, so a bomber or rogue
    // in an Independent insurgency joins the insurgents, not OPFOR (NeisAEL, 30 Oct). Otherwise the
    // side opposite the target, as before.
    private _insurgentSides = ((missionNamespace getVariable ["OPCOM_instances", []]) select {
        ([_x, "controltype", ""] call ALiVE_fnc_HashGet) == "asymmetric"
    }) apply { [[_x, "side", ""] call ALiVE_fnc_HashGet] call ALiVE_fnc_sideTextToObject };
    private _pick = _insurgentSides findIf { _x in [west, east, resistance] && {(_x getFriend _targetSide) < 0.6} };
    private _insurgentSide = [sideUnknown, _insurgentSides select (_pick max 0)] select (_pick > -1);
    if (_insurgentSide != sideUnknown) then {
        _group = createGroup _insurgentSide;
    } else {
    switch (_targetSide) do {
        case west:{
            _group = createGroup east;
        };
        case east:{
            _group = createGroup west;
        };
        case resistance:{
            if((west getFriend resistance) < 0.6) then {
                _group = createGroup west;
            }else{
                _group = createGroup east;
            };
        };
        case civilian:{
            if((west getFriend civilian) < 0.6) then {
                _group = createGroup west;
            }else{
                _group = createGroup east;
            };
        };
    };
    };

    _currentGroup = group _unit;
    [_unit] joinSilent _group;
    _currentGroup call ALiVE_fnc_DeleteGroupRemote;
};