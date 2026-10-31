#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(OPCOMIntelMarkers);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_OPCOMIntelMarkers

Description:
Intel Markers (Find Out Before Attacking): on a player's machine, draws what the AI Commander of the player's side knows of
an objective it is finding out about. One area round the objective, yellow while it isn't sure yet and red once it is, a
label with how many it has seen and how sure it is, and a dot for each enemy group seen. Sent by the commander's
"intelMarkers" on every report; nothing (an empty picture) takes them off the map. A mission that limits remoteExec
through CfgRemoteExec must allow this function.

Parameters:
String - the commander's and the objective's IDs
Array - [centre, radius, how sure 0 to 1, [[position, colour], ...], sure enough], or [] to clear

Author:
Jman
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {};
params [["_objectiveID", "", [""]], ["_picture", [], [[]]]];
if (_objectiveID == "") exitWith {};

private _base = "ALiVE_intel_" + _objectiveID;
private _drawn = missionNamespace getVariable ["ALiVE_intelMarkersDrawn", createHashMap];
{ deleteMarkerLocal _x } forEach (_drawn getOrDefault [_objectiveID, []]);
_drawn deleteAt _objectiveID;
missionNamespace setVariable ["ALiVE_intelMarkersDrawn", _drawn];
if (_picture isEqualTo []) exitWith {};

_picture params [["_centre", [0,0,0], [[]]], ["_radius", 200, [0]], ["_sure", 0, [0]], ["_contacts", [], [[]]], ["_enough", false, [false]]];
private _made = [];

private _area = createMarkerLocal [_base, _centre];
_area setMarkerShapeLocal "ELLIPSE";
_area setMarkerSizeLocal [_radius, _radius];
_area setMarkerBrushLocal "FDiagonal";
_area setMarkerColorLocal (["ColorYellow", "ColorRed"] select _enough);
_area setMarkerAlphaLocal 0.6;
_made pushBack _area;

private _label = createMarkerLocal [_base + "_label", _centre];
_label setMarkerTypeLocal "hd_unknown";
_label setMarkerColorLocal (["ColorYellow", "ColorRed"] select _enough);
_label setMarkerTextLocal format [localize "STR_ALIVE_OPCOM_INTEL_MARKER", count _contacts, round (_sure * 100)];
_made pushBack _label;

{
    _x params [["_pos", [], [[]]], ["_colour", "ColorRed", [""]]];
    if (count _pos > 1) then {
        private _m = createMarkerLocal [format ["%1_%2", _base, _forEachIndex], _pos];
        _m setMarkerTypeLocal "mil_dot";
        _m setMarkerColorLocal _colour;
        _made pushBack _m;
    };
} forEach _contacts;

_drawn set [_objectiveID, _made];
