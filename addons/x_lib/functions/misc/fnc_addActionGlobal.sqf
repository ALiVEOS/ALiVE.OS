#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(addActionGlobal);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_addActionGlobal

Description:
Adds an action globally to the given object

Parameters:
object - unit/object
string - name of action command
string - visible name of action

Returns:
number - id of action

Examples:
(begin example)
_id = [_object,_action,_actionName] call ALiVE_fnc_addActionGlobal;
(end)

See Also:
- nil

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

params [
    ["_object", objNull, [objNull]],
    ["_action", "", [""]],
    ["_name", "", [""]]
];
_target = _this param [3, _object, [objNull]];

_object addAction [_name, {_target = _this select 3 select 0; _action = _this select 3 select 1; (_this select 1) action [_action, _target]}, [_target,_action]];