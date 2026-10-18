#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(giveTargetPapers);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_giveTargetPapers

Description:
Gives a unit that something is about (a task's target, the Insurgency commander's recruiter, a
high value target) a Wallet (ID) and the identity it stands for. A player who takes the wallet,
from his body or from him as a prisoner, is told who he was (the Take handler in main's
XEH_postInit). Once per unit object: a profile that despawns and spawns again is a new object,
so callers that see him spawn again call this again.

Run on the server. The wallet is added where the unit is local.

Parameters:
Object - The unit
String - Stringtable key for his role, e.g. "STR_ALIVE_TARGETID_HVT"
String - (optional) What the role's %1 is, e.g. a town's name
String - (optional) His name, when it was set by remoteExec and isn't on him here yet

Returns:
Nothing

Examples:
(begin example)
[_hvt, "STR_ALIVE_TARGETID_HVT"] call ALiVE_fnc_giveTargetPapers;
[_unit, "STR_ALIVE_TARGETID_RECRUITER", "Zaros"] call ALiVE_fnc_giveTargetPapers;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]], ["_role", "", [""]], ["_arg", "", [""]], ["_name", "", [""]]];

if (!alive _unit || {_unit getVariable ["ALiVE_targetPapers", false]}) exitWith {};
_unit setVariable ["ALiVE_targetPapers", true];

if (_name == "") then { _name = name _unit };
_unit setVariable ["ALiVE_targetIdentity", [_name, _role, _arg], true];

if (local _unit) then {
    _unit addItem "Wallet_ID";
} else {
    [_unit, "Wallet_ID"] remoteExec ["addItem", _unit];
};
