#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(ProfileNameSpaceLoad);

/* ----------------------------------------------------------------------------
Function: AliVE_fnc_ProfileNameSpaceLoad

Description:
Loads a Hash with given ID from to ProfileNameSpace

Parameters:
String: ID (f.e. "ALiVE_SYS_LOGISTICS")

Returns:
stored data for mission and ID, false (BOOL) if no data available

Examples:
(begin example)
_state = "ALiVE_SYS_LOGISTICS" call ALiVE_fnc_ProfileNameSpaceLoad
(end)

See Also:
ALiVE_fnc_ProfileNameSpaceSave

Author:
Highhead
---------------------------------------------------------------------------- */

if !(isServer) exitwith {};

private _id = _this;
private _result = false;
private _mission = format["ALiVE_%1",missionName];

_data = profileNamespace getVariable _mission;

_result = if (isnil "_data") then {false} else {[_data,_id] call ALiVE_fnc_HashGet};

_result