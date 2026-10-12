#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobSaveData);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobSaveData

Description:
Saves the FOBs now, whatever has changed. Called by the autosave and by SERVER SAVE AND EXIT,
alongside the other modules' save functions.

Parameters:
None

Returns:
ARRAY - [saved, messages], the shape SERVER SAVE AND EXIT shows the admin

Author:
Jman
---------------------------------------------------------------------------- */

// No remote-call refusal here, as for Military Logistics' save: SERVER SAVE AND EXIT can reach
// this from an admin's machine, and a save changes nothing a player could gain from. The marker
// below lets the save itself through the remote-call guard on the persistence function.
private _ALiVE_fobCaller = objNull;
if (!isServer || {isNil "ALiVE_sup_fob"} || {isNull ALiVE_sup_fob}) exitWith {[false, []]};
if !([ALiVE_sup_fob, "attribute", ["fob_persistent"]] call ALiVE_fnc_FOB) exitWith {[false, []]};

private _count = count (ALiVE_FOB_registry select 1);
private _saved = ["save", [true]] call ALiVE_fnc_fobPersistence;

[_saved, [format ["ALiVE Player FOBs - Saved %1 FOBs: %2", _count, _saved]]]
