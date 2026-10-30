#include "\x\alive\addons\sys_zeus\script_component.hpp"
SCRIPT(zeusModule);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_zeusModule

Description:
Entry point of the ALiVE Zeus modules. Runs on the Zeus's machine, reads which module was
placed from its ALiVE_zeusAction config entry and hands over to ALiVE_fnc_zeusClient with the
position, the unit it was dropped on, if any, and whether Zeus Enhanced's option dialogs can be
used.

Parameters:
Object - the module logic
Array - synced units (not used)
Bool - activated

Returns:
Bool - true when a request went ahead

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_logic", objNull, [objNull]],
    ["_synced", [], [[]]],
    ["_activated", true, [true]]
];

if (isNull _logic || {!_activated}) exitWith {false};
// The module runs on every machine (isGlobal 1); only the placing Zeus's machine, where the logic
// is local, acts on it. It used to run on the server alone, which on a dedicated server has no
// interface, so nothing happened there.
if (!local _logic) exitWith {false};
if (!hasInterface) exitWith {
    deleteVehicle _logic;
    false
};

private _action = getText (configOf _logic >> "ALiVE_zeusAction");
private _position = getPosATL _logic;

// The unit the module was dropped on: the engine's curator attach sets this variable, and the
// logic is also attached to it
private _attached = _logic getVariable ["bis_fnc_curatorAttachObject_object", objNull];
if (isNull _attached) then { _attached = attachedTo _logic };

deleteVehicle _logic;

if (_action == "") exitWith {false};

[_action, _position, _attached, !isNil "zen_dialog_fnc_create"] call ALiVE_fnc_zeusClient
