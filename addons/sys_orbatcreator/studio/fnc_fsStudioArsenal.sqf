#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioArsenal);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioArsenal

Description:
The Arsenal round trip for the selected unit. No Arsenal control is read or
changed: everything is read from the preview body once the Arsenal has closed.

    - "available": BOOL, ACE Arsenal can be used;
    - "open": puts the unit's body on the stage, keeps what it wears for "undo",
      hides the studio (["suspend"] fsStudioClose) and opens the Virtual Arsenal
      or ACE Arsenal on the body. If no opened event arrives within 8 s it is
      "failed";
    - "opened": the Arsenal is up (stops the 8 s watchdog);
    - "closed": the body's loadout, face, voice, pitch and insignia go into the
      unit, saved at once, and the studio comes back with the same unit;
    - "failed": nothing changed, the studio comes back;
    - "undo": the loadout and identity from before the last Arsenal go back.
Refused while an export runs (S_BUSY_EXPORT), for a vehicle (S_ARSENAL_NOT_MAN)
and for a unit whose base is not loaded (S_BASE_MISSING).

Parameters:
    _op - STRING - as above

Returns:
    BOOL for "available", else nothing

Examples:
    (begin example)
    ["open"] call ALiVE_fnc_fsStudioArsenal;
    (end)

See Also:
    ALiVE_fnc_fsStudioTabUnits, ALiVE_fnc_fsStudioClose, ALiVE_fnc_fsStudioReopen

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]]];

if (_op == "available") exitWith {
    isClass (configFile >> "CfgPatches" >> "ace_arsenal") && {!isNil "ace_arsenal_fnc_openBox"}
};

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith {};

private _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
private _units = _faction getOrDefault ["units", createHashMap];

// the handlers of one round trip come off together
private _unhook = {
    {
        _x params ["_kind", "_a", "_b"];
        switch (_kind) do {
            case "bis": { [missionNamespace, _a, _b] call BIS_fnc_removeScriptedEventHandler };
            case "cba": { [_a, _b] call CBA_fnc_removeEventHandler };
        };
    } forEach (_session getOrDefault ["arsenalHandlers", []]);
    _session set ["arsenalHandlers", []];
    // the body leaves its anchor and stands still again where it was
    private _anchor = _session getOrDefault ["arsenalAnchor", objNull];
    if (!isNull _anchor) then {
        private _b = _session getOrDefault ["body", objNull];
        if (!isNull _b) then { detach _b; _b enableSimulation false; _b setPosASL (getPosASL _anchor); _b setDir (getDir _anchor) };
        deleteVehicle _anchor;
    };
    _session set ["arsenalAnchor", objNull];
};

// back to the studio once the Arsenal display is gone (ACE: at most 3 s). ACE Arsenal puts the player's
// own view and HUD back as it closes, some of it on the frames after, so after ACE the studio comes back
// five frames later (frames, not seconds: a slow machine has fewer of them) and, for three seconds, makes
// its camera the view again whenever the view is anywhere else
private _back = {
    private _reopen = {
        private _s = missionNamespace getVariable ["ALiVE_FS_session", createHashMap];
        _s set ["bodyRef", ""];
        if ((_s getOrDefault ["arsenal", "BIS"]) == "ACE") then {
            [{
                [] call ALiVE_fnc_fsStudioReopen;
                [{
                    params ["_end", "_pfh"];
                    private _s = missionNamespace getVariable ["ALiVE_FS_session", createHashMap];
                    private _cam = _s getOrDefault ["camera", objNull];
                    if (time > _end || {isNull _cam} || {isNil "ALiVE_fnc_fsStudioCamera"}) exitWith { [_pfh] call CBA_fnc_removePerFrameHandler };
                    if (((positionCameraToWorld [0, 0, 0]) distance (getPosVisual _cam)) > 1) then { ["view"] call ALiVE_fnc_fsStudioCamera };
                }, 0.1, time + 3] call CBA_fnc_addPerFrameHandler;
            }, [], 5] call CBA_fnc_execAfterNFrames;
        } else {
            [] call ALiVE_fnc_fsStudioReopen;
        };
    };
    [{
        isNull (uiNamespace getVariable ["ace_arsenal_display", displayNull]) && {isNull (uiNamespace getVariable ["RscDisplayArsenal", displayNull])}
    }, _reopen, [], 3, _reopen] call CBA_fnc_waitUntilAndExecute;
};

switch (_op) do {
    case "open": {
        if (_session getOrDefault ["exportBusy", false]) exitWith { [1, "S_BUSY_EXPORT", []] call ALiVE_fnc_fsStudioStatus };
        if (_session getOrDefault ["arsenalBusy", false]) exitWith {};
        private _id = _session getOrDefault ["selUnit", ""];
        if (((_session getOrDefault ["tab", ""]) != "units") || {!(_id in _units)}) exitWith { [1, "S_ARSENAL_NOT_MAN", []] call ALiVE_fnc_fsStudioStatus };
        private _entry = _units get _id;
        private _base = _entry getOrDefault ["base", ""];
        if !(isClass (configFile >> "CfgVehicles" >> _base)) exitWith { [1, "S_BASE_MISSING", [_entry getOrDefault ["name", _id], _base]] call ALiVE_fnc_fsStudioStatus };

        private _body = _session getOrDefault ["body", objNull];
        if (isNull _body || {(_session getOrDefault ["bodyRef", ""]) != _id}) then { _body = ["unit", _id] call ALiVE_fnc_fsStudioPreview };
        if (isNull _body) exitWith { [1, "S_ARSENAL_FAILED", []] call ALiVE_fnc_fsStudioStatus };

        private _undo = _session getOrDefault ["arsenalUndo", createHashMap];
        if !(_undo isEqualType createHashMap) then { _undo = createHashMap };
        _undo set [_id, [+(_entry getOrDefault ["loadout", []]), +(_entry getOrDefault ["identity", createHashMap])]];
        _session set ["arsenalUndo", _undo];
        _session set ["arsenalUnit", _id];
        _session set ["arsenalBusy", true];
        _session set ["arsenalSeen", false];
        [0, "S_ARSENAL_OPEN", [_entry getOrDefault ["name", _id]]] call ALiVE_fnc_fsStudioStatus;

        // the body has to move and turn in the Arsenal. With simulation on it would fall: in module mode the
        // stage hangs 500 m up inside its backdrop with no floor. Held on an anchor at its spot, it can still
        // animate.
        private _anchor = "Logic" createVehicleLocal [0, 0, 0];
        _anchor setPosASL (getPosASL _body);
        _anchor setDir (getDir _body);
        _session set ["arsenalAnchor", _anchor];
        _body enableSimulation true;
        _body attachTo [_anchor, [0, 0, 0]];
        _body setDir 0;
        ["suspend"] call ALiVE_fnc_fsStudioClose;

        private _handlers = [];
        if ((_session getOrDefault ["arsenal", "BIS"]) == "ACE" && {["available"] call ALiVE_fnc_fsStudioArsenal}) then {
            private _h = ["ace_arsenal_displayOpened", {
                params ["_display"];
                ["opened"] call ALiVE_fnc_fsStudioArsenal;
                _display displayAddEventHandler ["Unload", { ["closed"] call ALiVE_fnc_fsStudioArsenal }];
            }] call CBA_fnc_addEventHandler;
            _handlers pushBack ["cba", "ace_arsenal_displayOpened", _h];
            _session set ["arsenalHandlers", _handlers];
            [_body, _body, true] call ace_arsenal_fnc_openBox;
        } else {
            _handlers pushBack ["bis", "arsenalOpened", [missionNamespace, "arsenalOpened", { ["opened"] call ALiVE_fnc_fsStudioArsenal }] call BIS_fnc_addScriptedEventHandler];
            _handlers pushBack ["bis", "arsenalClosed", [missionNamespace, "arsenalClosed", { ["closed"] call ALiVE_fnc_fsStudioArsenal }] call BIS_fnc_addScriptedEventHandler];
            _session set ["arsenalHandlers", _handlers];
            ["Open", [true, objNull, _body]] spawn BIS_fnc_arsenal;
        };

        // watchdog: no opened event in 8 s, and no Arsenal display still loading, means it did not open
        [{
            private _s = missionNamespace getVariable ["ALiVE_FS_session", createHashMap];
            private _loading = !isNull (uiNamespace getVariable ["RscDisplayArsenal", displayNull])
                || {!isNull (uiNamespace getVariable ["ace_arsenal_display", displayNull])};
            if ((_s getOrDefault ["arsenalBusy", false]) && {!(_s getOrDefault ["arsenalSeen", false])} && {!_loading}) then { ["failed"] call ALiVE_fnc_fsStudioArsenal };
        }, [], 8] call CBA_fnc_waitAndExecute;
    };

    case "opened": {
        _session set ["arsenalSeen", true];
    };

    case "closed": {
        call _unhook;
        if !(_session getOrDefault ["arsenalBusy", false]) exitWith {};
        _session set ["arsenalBusy", false];
        private _id = _session getOrDefault ["arsenalUnit", ""];
        private _body = _session getOrDefault ["body", objNull];
        if (isNull _body || {!(_id in _units)}) exitWith { call _back; [1, "S_ARSENAL_FAILED", []] call ALiVE_fnc_fsStudioStatus };
        private _why = ["set", [_id, "loadout", getUnitLoadout _body]] call ALiVE_fnc_fsDataUnit;
        // the face and voice are always kept, so the read-out is true; the export writes them only when fixed
        private _identity = +((_units get _id) getOrDefault ["identity", createHashMap]);
        _identity set ["face", face _body];
        _identity set ["speaker", speaker _body];
        _identity set ["pitch", pitch _body];
        _identity set ["insignia", [_body] call BIS_fnc_getUnitInsignia];
        ["set", [_id, "identity", _identity]] call ALiVE_fnc_fsDataUnit;
        ["arsenal", true] call ALiVE_fnc_fsDataTouch;
        _session set ["selUnit", _id];
        call _back;
        if (_why isEqualTo "") then {
            [0, "S_ARSENAL_SAVED", [(_units get _id) getOrDefault ["name", _id]]] call ALiVE_fnc_fsStudioStatus;
        } else {
            [1, _why, []] call ALiVE_fnc_fsStudioStatus;
        };
    };

    case "failed": {
        call _unhook;
        _session set ["arsenalBusy", false];
        call _back;
        [1, "S_ARSENAL_FAILED", []] call ALiVE_fnc_fsStudioStatus;
    };

    case "undo": {
        private _id = _session getOrDefault ["selUnit", ""];
        private _undo = _session getOrDefault ["arsenalUndo", createHashMap];
        if (!(_undo isEqualType createHashMap) || {!(_id in _undo)} || {!(_id in _units)}) exitWith {};
        (_undo get _id) params ["_loadout", "_identity"];
        _undo deleteAt _id;
        ["set", [_id, "loadout", _loadout]] call ALiVE_fnc_fsDataUnit;
        ["set", [_id, "identity", _identity]] call ALiVE_fnc_fsDataUnit;
        ["arsenal undo", true] call ALiVE_fnc_fsDataTouch;
        _session set ["bodyRef", ""];
        ["refresh", []] call ALiVE_fnc_fsStudioTabUnits;
        [0, "S_ARSENAL_UNDONE", [(_units get _id) getOrDefault ["name", _id]]] call ALiVE_fnc_fsStudioStatus;
    };

    default {};
};
