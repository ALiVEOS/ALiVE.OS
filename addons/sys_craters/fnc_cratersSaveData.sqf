#include "\x\alive\addons\sys_craters\script_component.hpp"
SCRIPT(cratersSaveData);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_cratersSaveData

Description:
Saves the craters now, whatever has changed. Called by the autosave and by SERVER SAVE AND
EXIT, alongside the other modules' save functions.

Parameters:
None

Returns:
ARRAY - [saved, messages], the shape SERVER SAVE AND EXIT shows the admin

Author:
Jman
---------------------------------------------------------------------------- */

// SERVER SAVE AND EXIT can reach this from an admin's machine; a save changes nothing a player
// could gain from. The marker lets the save through the persistence function's remote-call guard.
private _ALiVE_cratersCaller = objNull;
if (!isServer || {isNil "ALiVE_sys_craters"} || {isNull ALiVE_sys_craters}) exitWith {[false, []]};
if !([ALiVE_sys_craters, "attribute", ["craters_persistent"]] call ALiVE_fnc_craters) exitWith {[false, []]};
if !(ALiVE_sys_craters getVariable ["startupComplete", false]) exitWith {[false, ["ALiVE Persistent Craters - Not saved, the saved craters are still loading"]]};
// from another machine, one save in ten seconds
if (isRemoteExecuted && {remoteExecutedOwner != 2} && {time - (missionNamespace getVariable ["ALiVE_craters_lastSave", -1e9]) < 10}) exitWith {[false, ["ALiVE Persistent Craters - Not saved, saved under ten seconds ago"]]};

private _count = count ALiVE_craters_order;
private _saved = ["save", [true]] call ALiVE_fnc_cratersPersistence;

[_saved, [format ["ALiVE Persistent Craters - Saved %1 craters: %2", _count, _saved]]]
