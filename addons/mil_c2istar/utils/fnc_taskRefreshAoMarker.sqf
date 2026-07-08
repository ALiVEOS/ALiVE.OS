#include "\x\alive\addons\mil_c2istar\script_component.hpp"
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
    if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
        ["DIAG-STRIP taskRefreshAoMarker: currentTask is null - hiding AO"] call ALiVE_fnc_dump;
    };
    deleteMarkerLocal _markerName;
    deleteMarkerLocal _textMarkerName;
};

if (toUpper (taskState _ct) != "ASSIGNED") exitWith {
    if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
        ["DIAG-STRIP taskRefreshAoMarker: state='%1' (not ASSIGNED) - hiding AO", taskState _ct] call ALiVE_fnc_dump;
    };
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
    if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
        ["DIAG-STRIP taskRefreshAoMarker: ct=%1 typeName=%2 strCt=%3", _ct, typeName _ct, str _ct] call ALiVE_fnc_dump;
    };
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
            if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
                ["DIAG-STRIP taskRefreshAoMarker: task[%1]=%2 stored at idx10 = %3 (typeName=%4) - isEqualTo ct = %5", _forEachIndex, _x, _stored, typeName _stored, _stored isEqualTo _ct] call ALiVE_fnc_dump;
            };
            if (_stored isEqualTo _ct) exitWith {
                _isC2istarTask = true;
                _matchedTaskID = _x;
                private _titleSlot = _taskData select 4;
                if (typeName _titleSlot == "STRING") then { _matchedTitle = _titleSlot };
            };
        } else {
            if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
                ["DIAG-STRIP taskRefreshAoMarker: task[%1]=%2 unexpected shape - typeName=%3 count=%4", _forEachIndex, _x, typeName _taskData, if (typeName _taskData == "ARRAY") then { count _taskData } else { -1 }] call ALiVE_fnc_dump;
            };
        };
    } forEach _keys;
};
if (!_isC2istarTask) exitWith {
    if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
        ["DIAG-STRIP taskRefreshAoMarker: currentTask not in c2istar tasks hash (hash count=%1) - hiding AO", if (typeName _tasks == "ARRAY" && {count _tasks > 1}) then { count (_tasks select 1) } else { -1 }] call ALiVE_fnc_dump;
    };
    deleteMarkerLocal _markerName;
    deleteMarkerLocal _textMarkerName;
};

// Mission-maker controls the radius via the C2ISTAR module's
// "Task AO Radius" attribute; 0 disables the feature. This call
// goes through the c2istar OO dispatch (case "taskAoRadius") rather
// than hashGet, so the logic object is the right input type here.
private _radius = [ALIVE_MIL_C2ISTAR, "taskAoRadius"] call ALIVE_fnc_C2ISTAR;
if (typeName _radius != "SCALAR" || {_radius <= 0}) exitWith {
    if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
        ["DIAG-STRIP taskRefreshAoMarker: radius=%1 (typeName=%2) - hiding AO", _radius, typeName _radius] call ALiVE_fnc_dump;
    };
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
// EmptyIcon ICON marker at the offset position, with the title as
// its text label. Title comes from the c2istar task hash entry
// captured during the is-c2istar-task scan above (index 4). The
// engine `taskTitle` command isn't recognised in this build, hence
// the indirection.
//
// Suppress the AO sibling text when any task's primary sibling text
// marker would land at the same spot. fnc_taskCreateMarker places its
// sibling 30m east of the task position; we place the AO sibling 30m
// east of the AO centre. So if any task's `_taskPosition` is within
// roughly the AO centre, the two sibling labels overlap at the same
// screen coordinate (different titles, same pixels). Multi-task
// families like Secure Community Event (Parent / Setup / Secure all
// share _taskPosition) trigger this even though the CURRENT task's
// own taskID may not have a primary marker yet - the sibling sub-task
// does, and its sibling text lands on top of ours. Walking all
// entries in ALIVE_taskMarkers covers that case in one shot.
//
// Threshold: 50m around the AO sibling text position. Tight enough
// that genuinely separate tasks don't suppress each other, loose
// enough that same-family / co-located tasks do.
//
// MilDefence DefenceWave and any other task type that doesn't call
// taskCreateMarkersForPlayers still leaves ALIVE_taskMarkers empty
// for its family, so the AO sibling remains the only label and shows.
private _aoTextPos = [(_pos select 0) + 30, _pos select 1, _pos param [2, 0]];
private _hasNearbyPrimaryText = false;
if (!isNil "ALIVE_taskMarkers" && {typeName ALIVE_taskMarkers == "ARRAY" && {count ALIVE_taskMarkers > 1}}) then {
    private _allTaskIDs = ALIVE_taskMarkers select 1;
    {
        private _markerNames = [ALIVE_taskMarkers, _x, []] call ALIVE_fnc_hashGet;
        if (typeName _markerNames == "ARRAY") then {
            {
                if (typeName _x == "STRING" && {(_x find "_text") > 0}) then {
                    private _mPos = getMarkerPos _x;
                    // getMarkerPos returns [0,0,0] for missing markers; skip
                    // those by requiring a non-zero position match.
                    if (count _mPos > 1 && {!(_mPos isEqualTo [0,0,0]) && {_mPos distance2D _aoTextPos < 50}}) exitWith {
                        _hasNearbyPrimaryText = true;
                    };
                };
            } forEach _markerNames;
        };
        if (_hasNearbyPrimaryText) exitWith {};
    } forEach _allTaskIDs;
};

if (_matchedTitle != "" && {!_hasNearbyPrimaryText}) then {
    // Offset the sibling text marker 30m east of the AO centre so the
    // title renders clear of BI's engine current-task waypoint icon
    // (which is rendered automatically at taskDestination and carries
    // its own small label). Mirrors the +30m east offset that
    // fnc_taskCreateMarker.sqf applies to its sibling text markers.
    // Without the offset, the title sits right on top of the BI
    // indicator and reads as cramped against the icon.
    private _mText = createMarkerLocal [_textMarkerName, _aoTextPos];
    _mText setMarkerShapeLocal "ICON";
    // EmptyIcon (invisible) rather than hd_dot — same fix as
    // fnc_taskCreateMarker.sqf (ebe78ad0). hd_dot rendered as a
    // leading "bullet" next to the task title; EmptyIcon has no
    // visual at any size while still keeping the marker text
    // visible. Size 0.5 retained because Arma still culls markers
    // below ~0.0001 even when the icon is invisible.
    _mText setMarkerTypeLocal "EmptyIcon";
    _mText setMarkerColorLocal "ColorBlack";
    _mText setMarkerSizeLocal [0.5, 0.5];
    _mText setMarkerAlphaLocal 1;
    _mText setMarkerTextLocal _matchedTitle;
};

if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
    ["DIAG-STRIP taskRefreshAoMarker: SHOWING AO marker=%1 pos=%2 radius=%3 title='%4' nearbyPrimary=%5 textMarker=%6", _markerName, _pos, _radius, _matchedTitle, _hasNearbyPrimaryText, if (_matchedTitle != "" && {!_hasNearbyPrimaryText}) then { _textMarkerName } else { "(none)" }] call ALiVE_fnc_dump;
};
