#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(placeDebugMarker);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_placeDebugMarker

Description:
Place a debug marker on the map. Optional text label, colour override, and
emitter id let callers tag what each marker represents (e.g. "BLUFOR - HQ
Building") so the debug map view is self-explanatory rather than a sea of
unlabelled flags.

When the optional emitter id is set, the marker position runs through
ALiVE_fnc_debugMarkerOffset so its label fans out to a reserved compass
slot around the anchor - prevents text-vs-text overlap when multiple
modules drop markers at the same cluster centre. In that case a small
no-text anchor mil_dot is also placed at the actual position in the same
colour so users can read both the label (separated from any cluster
anchor marker) AND see precisely where the spawn landed.

Parameters:
0: ARRAY  - position
1: SCALAR - icon type index (0 waypoint, 1 mil_dot, 2 mil_box, 3 mil_triangle, 4 mil_flag) - optional, default 0
2: STRING - text label drawn next to the marker - optional, default ""
3: STRING - marker colour name (e.g. "ColorBlue", "ColorRed", "ColorGreen") - optional, default "ColorGreen"
4: STRING - emitter id for ALiVE_fnc_debugMarkerOffset compass-slot lookup - optional, default ""
5: STRING - explicit marker name override - optional, default "" (auto-generated `<time>_debug`).
            Pass a deterministic name when the caller needs to look up + delete the marker
            later (e.g. queue markers that should disappear once the actual spawn lands).
            The companion `_anchor` marker (placed when the emitter id offsets the label
            position) uses the same name with `_anchor` appended.

Returns:
STRING - marker name

Examples:
(begin example)
// minimal (legacy): green flag, no label
_marker = [getPos player, 4] call ALIVE_fnc_placeDebugMarker;

// labelled: blue flag tagged as the HQ Building
_marker = [_pos, 4, "BLUFOR - HQ Building", "ColorBlue"] call ALIVE_fnc_placeDebugMarker;

// labelled + offset to compass slot so text doesn't collide with strategic
// cluster marker at the same anchor
_marker = [_pos, 4, "WEST - Random Camp #1", "ColorBlue", "placement.mp"] call ALIVE_fnc_placeDebugMarker;
(end)

See Also:
- ALiVE_fnc_debugMarkerOffset

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

private ["_indicators","_position","_type","_text","_color","_emitterId","_nameOverride","_markerPos","_err","_m","_markerName"];

_indicators = ["waypoint","mil_dot","mil_box","mil_triangle","mil_flag"];

_position     = _this select 0;
_type         = if (count _this > 1) then {_this select 1} else {0};
_text         = if (count _this > 2) then {_this select 2} else {""};
_color        = if (count _this > 3) then {_this select 3} else {"ColorGreen"};
_emitterId    = if (count _this > 4) then {_this select 4} else {""};
_nameOverride = if (count _this > 5) then {_this select 5} else {""};

_err = format["spawn debug marker position not valid - %1",_position];
ASSERT_TRUE(typeName _position == "ARRAY",_err);

_markerPos = if (_emitterId isEqualType "" && {_emitterId != ""} && {!isNil "ALiVE_fnc_debugMarkerOffset"}) then {
    [_emitterId, _position] call ALiVE_fnc_debugMarkerOffset
} else {
    _position
};

_markerName = if (_nameOverride isEqualType "" && {_nameOverride != ""}) then {
    _nameOverride
} else {
    format["%1_debug",(time + random 10000)]
};
_m = createMarker [_markerName, _markerPos];
_m setMarkerShape "ICON";
_m setMarkerSize [.65, .65];
_m setMarkerType (_indicators select _type);
_m setMarkerColor _color;
_m setMarkerAlpha 1;
if (_text isEqualType "" && {_text != ""}) then {
    _m setMarkerText _text;
};

// When the label was offset to a compass slot, drop a small anchor dot
// at the actual position so users can read both the label (separated
// from any cluster anchor marker) AND see precisely where the spawn
// landed.
if (!(_markerPos isEqualTo _position)) then {
    private _anchor = createMarker [format ["%1_anchor", _m], _position];
    _anchor setMarkerShape "ICON";
    _anchor setMarkerSize [0.4, 0.4];
    _anchor setMarkerType "mil_dot";
    _anchor setMarkerColor _color;
    _anchor setMarkerAlpha 1;
};
_m
