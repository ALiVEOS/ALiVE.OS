#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskRefreshAoMarker);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskRefreshAoMarker

Description:
    Refreshes the AO ellipse marker for the player's current task.
    Self-contained - operates on `player` and `currentTask player`
    so it can be called from anywhere (CBA per-frame handler, BI
    mission events, c2istar task lifecycle hooks).

    Visibility rules:
      - Player's currentTask is non-null
      - AND task state is "ASSIGNED"
      - AND the task is a c2istar-routed task (in the c2istar tasks
        hashmap so we don't accidentally ring a mission-maker-
        scripted task that happens to be selected as current)
      - AND the c2istar singleton's "taskAoRadius" > 0
      - AND the task has a valid destination

    Single per-player local marker, always red (target / threat
    semantic). Replaces any previous AO marker on each call so
    radius / position changes are picked up.

Parameters:
    None - reads state from player and the c2istar singleton.

Returns:
    Nothing

Author:
    Jman
---------------------------------------------------------------------------- */

private _markerName = "ALiVE_C2ISTAR_currentTaskAO";
private _textMarkerName = "ALiVE_C2ISTAR_currentTaskAO_text";

private _ct = currentTask player;
if (isNull _ct) exitWith {
    diag_log "DIAG-STRIP taskRefreshAoMarker: currentTask is null - hiding AO";
    deleteMarkerLocal _markerName;
    deleteMarkerLocal _textMarkerName;
};

if (toUpper (taskState _ct) != "ASSIGNED") exitWith {
    diag_log format ["DIAG-STRIP taskRefreshAoMarker: state='%1' (not ASSIGNED) - hiding AO", taskState _ct];
    deleteMarkerLocal _markerName;
    deleteMarkerLocal _textMarkerName;
};

if (isNil "ALIVE_MIL_C2ISTAR") exitWith {
    deleteMarkerLocal _markerName;
    deleteMarkerLocal _textMarkerName;
};

// Confirm the current task is one of c2istar's tracked tasks. The
// client-side task hash lives in the global ALIVE_taskHandlerClient
// (NOT on the c2istar module logic - hashGet expects an array hash,
// not an object). The hash is built locally on each client by
// registerTask / updateTask in fnc_taskHandlerClient.sqf, so this
// works without a server round-trip.
if (isNil "ALIVE_taskHandlerClient") exitWith {
    deleteMarkerLocal _markerName;
    deleteMarkerLocal _textMarkerName;
};
private _tasks = [ALIVE_taskHandlerClient, "tasks"] call ALIVE_fnc_hashGet;
private _isC2istarTask = false;
private _matchedTitle = "";
private _matchedTaskID = "";
if (typeName _tasks == "ARRAY" && {count _tasks > 1}) then {
    diag_log format ["DIAG-STRIP taskRefreshAoMarker: ct=%1 typeName=%2 strCt=%3", _ct, typeName _ct, str _ct];
    // CBA hash structure: select 1 is the KEYS array (taskIDs). Walk
    // keys and hashGet each task data to access the task object at
    // index 10. Iterating select 1 directly would loop over strings,
    // not the task data arrays we need.
    // c2istar client task array layout (see fnc_taskHandlerClient
    // case "registerTask"): [_, taskID, requestingPlayer, position,
    // title, description, state, current, parent, source, taskObject]
    // - so title is at index 4 and the BI task object is at index 10.
    private _keys = _tasks select 1;
    {
        private _taskData = [_tasks, _x] call ALIVE_fnc_hashGet;
        if (typeName _taskData == "ARRAY" && {count _taskData > 10}) then {
            private _stored = _taskData select 10;
            diag_log format ["DIAG-STRIP taskRefreshAoMarker: task[%1]=%2 stored at idx10 = %3 (typeName=%4) - isEqualTo ct = %5", _forEachIndex, _x, _stored, typeName _stored, _stored isEqualTo _ct];
            if (_stored isEqualTo _ct) exitWith {
                _isC2istarTask = true;
                _matchedTaskID = _x;
                private _titleSlot = _taskData select 4;
                if (typeName _titleSlot == "STRING") then { _matchedTitle = _titleSlot };
            };
        } else {
            diag_log format ["DIAG-STRIP taskRefreshAoMarker: task[%1]=%2 unexpected shape - typeName=%3 count=%4", _forEachIndex, _x, typeName _taskData, if (typeName _taskData == "ARRAY") then { count _taskData } else { -1 }];
        };
    } forEach _keys;
};
if (!_isC2istarTask) exitWith {
    diag_log format ["DIAG-STRIP taskRefreshAoMarker: currentTask not in c2istar tasks hash (hash count=%1) - hiding AO", if (typeName _tasks == "ARRAY" && {count _tasks > 1}) then { count (_tasks select 1) } else { -1 }];
    deleteMarkerLocal _markerName;
    deleteMarkerLocal _textMarkerName;
};

// Mission-maker controls the radius via the C2ISTAR module's
// "Task AO Radius" attribute; 0 disables the feature. This call
// goes through the c2istar OO dispatch (case "taskAoRadius") rather
// than hashGet, so the logic object is the right input type here.
private _radius = [ALIVE_MIL_C2ISTAR, "taskAoRadius"] call ALIVE_fnc_C2ISTAR;
if (typeName _radius != "SCALAR" || {_radius <= 0}) exitWith {
    diag_log format ["DIAG-STRIP taskRefreshAoMarker: radius=%1 (typeName=%2) - hiding AO", _radius, typeName _radius];
    deleteMarkerLocal _markerName;
    deleteMarkerLocal _textMarkerName;
};

private _pos = taskDestination _ct;
if (typeName _pos != "ARRAY" || {count _pos < 2}) exitWith {
    deleteMarkerLocal _markerName;
    deleteMarkerLocal _textMarkerName;
};

// Replace any previous markers so radius / position changes propagate.
deleteMarkerLocal _markerName;
deleteMarkerLocal _textMarkerName;

private _m = createMarkerLocal [_markerName, _pos];
_m setMarkerShapeLocal "ELLIPSE";
_m setMarkerSizeLocal [_radius, _radius];
// Always red - "target / threat area" semantic. Side-independent
// because the player is approaching a hostile or contested objective.
_m setMarkerColorLocal "ColorRed";
_m setMarkerAlphaLocal 0.5;
_m setMarkerBrushLocal "SolidBorder";
// Surface the current task title via a SIBLING ICON marker rather
// than setMarkerTextLocal on the ellipse. ELLIPSE shape text labels
// don't render reliably (text is anchored at marker centre, can be
// occluded by SolidBorder fill / overlapping markers, and engine
// behaviour varies). The sibling-overlay pattern is the same one
// fnc_taskCreateMarker.sqf uses for ICON markers with text: a tiny
// hd_dot ICON marker at the same position, with the title as its
// text label. Title comes from the c2istar task hash entry captured
// during the is-c2istar-task scan above (index 4). The engine
// `taskTitle` command isn't recognised in this build, hence the
// indirection.
//
// Suppress the AO sibling text when the task already has a primary
// marker on the map (fnc_taskCreateMarker registers them in
// ALIVE_taskMarkers keyed by taskID). The primary marker drops its
// own black hd_dot sibling 30m east of the icon, so without this
// gate the title would render twice - once from the primary's
// sibling, once from the AO's. MilDefence DefenceWave and any other
// task type that doesn't call taskCreateMarkersForPlayers leaves
// ALIVE_taskMarkers empty for its taskID, so the AO sibling remains
// the only label and still shows.
private _hasPrimaryMarkers = false;
if (_matchedTaskID != "" && {!isNil "ALIVE_taskMarkers"}) then {
    private _existingMarkers = [ALIVE_taskMarkers, _matchedTaskID, []] call ALIVE_fnc_hashGet;
    if (typeName _existingMarkers == "ARRAY" && {count _existingMarkers > 0}) then {
        _hasPrimaryMarkers = true;
    };
};

if (_matchedTitle != "" && {!_hasPrimaryMarkers}) then {
    // Offset the sibling text marker 30m east of the AO centre so the
    // title renders clear of BI's engine current-task waypoint icon
    // (which is rendered automatically at taskDestination and carries
    // its own small label). Mirrors the +30m east offset that
    // fnc_taskCreateMarker.sqf applies to its sibling text markers.
    // Without the offset, the title sits right on top of the BI
    // indicator and reads as cramped against the icon.
    private _textPos = [(_pos select 0) + 30, _pos select 1, _pos param [2, 0]];
    private _mText = createMarkerLocal [_textMarkerName, _textPos];
    _mText setMarkerShapeLocal "ICON";
    _mText setMarkerTypeLocal "hd_dot";
    _mText setMarkerColorLocal "ColorBlack";
    _mText setMarkerSizeLocal [0.5, 0.5];
    _mText setMarkerAlphaLocal 1;
    _mText setMarkerTextLocal _matchedTitle;
};

diag_log format ["DIAG-STRIP taskRefreshAoMarker: SHOWING AO marker=%1 pos=%2 radius=%3 title='%4' hasPrimary=%5 textMarker=%6", _markerName, _pos, _radius, _matchedTitle, _hasPrimaryMarkers, if (_matchedTitle != "" && {!_hasPrimaryMarkers}) then { _textMarkerName } else { "(none)" }];
