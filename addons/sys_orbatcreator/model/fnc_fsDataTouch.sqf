#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataTouch);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataTouch

Description:
Marks the working faction changed and saves it when a save is due. Keeps its own
state in missionNamespace and needs no studio session, so it behaves the same on
a dedicated server.

    - sets ALiVE_FS_dirty and stamps meta.modified;
    - saves now (ALiVE_fnc_fsDataStore "saveCurrent", which clears ALiVE_FS_dirty
      and sets ALiVE_FS_lastSave) when _force is true or the last save is older
      than FS_AUTOSAVE_GAP seconds of diag_tickTime;
    - while the load state is "refused" it marks dirty and saves nothing, so a
      working copy that would not load is never written over.

Forced after one deliberate action (Arsenal closed, studio closed, export, library
save, load and delete, any replace of the working faction); throttled for every
other edit, so a run of edits costs at most one profile write per gap.

Parameters:
    _reason - STRING - why, for logs
    _force  - BOOL - save now

Returns:
    BOOL - true when it saved

Examples:
    (begin example)
    ["arsenal", true] call ALiVE_fnc_fsDataTouch;
    (end)

See Also:
    ALiVE_fnc_fsDataStore

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_reason", "", [""]], ["_force", false, [false]]];

missionNamespace setVariable ["ALiVE_FS_dirty", true];

private _faction = missionNamespace getVariable "ALiVE_FS_faction";
if (!isNil "_faction" && {_faction isEqualType createHashMap}) then {
    private _meta = _faction getOrDefault ["meta", createHashMap];
    if !("meta" in _faction) then { _faction set ["meta", _meta] };
    _meta set ["modified", systemTime select [0, 5]];
};

if ((missionNamespace getVariable ["ALiVE_FS_loadState", "none"]) isEqualTo "refused") exitWith { false };

private _last = missionNamespace getVariable ["ALiVE_FS_lastSave", -1e9];
if (!_force && {(diag_tickTime - _last) < FS_AUTOSAVE_GAP}) exitWith { false };

(["saveCurrent"] call ALiVE_fnc_fsDataStore) select 0
