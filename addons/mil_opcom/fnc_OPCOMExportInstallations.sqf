#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(OPCOMExportInstallations);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_OPCOMExportInstallations
Description:
Writes out where an Asymmetric commander's installations and roadblocks are, as a
piece of SQF that puts a marker on each one. Pasted into the Eden debug console of
another mission it places them as Eden markers; run in a mission it creates map
markers. The point is to rebuild an insurgency's layout by hand somewhere else.

The SQF is returned, written to the RPT between two lines starting
"ALiVE installation export", copied to the clipboard where this machine has one,
and kept in ALiVE_OPCOM_installationExport (public), so on a dedicated server a
player can run copyToClipboard ALiVE_OPCOM_installationExport locally.
Needs to run serverside.

Parameters:
Any - Optional selector, as ALiVE_fnc_OPCOMAsymmetricState takes it: nil or objNull
      for every Asymmetric commander, a side, a faction, an OPCOM ID, the module or
      its handler

Returns:
String - the SQF ("" when there is nothing to export)
Nil - On non-server machines

Examples:
(begin example)
// in the debug console, server exec
[] call ALiVE_fnc_OPCOMExportInstallations;
// then, local exec on the player's machine
copyToClipboard ALiVE_OPCOM_installationExport;
(end)

See Also:
ALiVE_fnc_OPCOMAsymmetricState

Author:
Jman
---------------------------------------------------------------------------- */

private _target = if (count _this > 0 && {!isNil {_this select 0}}) then {_this select 0} else {objNull};

if !(isServer) exitWith {
    ["ALiVE_fnc_OPCOMExportInstallations needs to run serverside"] call ALIVE_fnc_dump;
    nil
};

private _handlers = [[_target] call ALIVE_fnc_OPCOMAsymmetricState, "handlers", []] call ALIVE_fnc_hashGet;

// objective key, what it's called on the marker, marker type
private _kinds = [
    ["HQ", "Insurgent HQ", "hd_flag"],
    ["depot", "Weapons depot", "hd_objective"],
    ["factory", "IED factory", "hd_objective"],
    ["ied", "IED", "hd_warning"],
    ["suicide", "Suicide bomber", "hd_warning"],
    ["sabotage", "Sabotage target", "hd_destroy"],
    ["ambush", "Ambush", "hd_ambush"]
];

private _entries = [];   // [position, text, marker type, colour]
private _seen = [];

{
    private _handler = _x;
    private _colour = switch ([_handler, "side", ""] call ALIVE_fnc_hashGet) do {
        case "WEST": {"ColorWEST"};
        case "GUER": {"ColorGUER"};
        case "CIV": {"ColorCIV"};
        default {"ColorEAST"};
    };
    // a removed objective keeps its old keys, as ALiVE_fnc_OPCOMAsymmetricState notes (#727)
    private _objectives = ([_handler, "objectives", []] call ALIVE_fnc_hashGet) select {
        !([_x, "deleted", false] call ALiVE_fnc_HashGet)
    };

    {
        private _objective = _x;
        private _center = [_objective, "center", []] call ALIVE_fnc_hashGet;
        private _size = [_objective, "size", 300] call ALIVE_fnc_hashGet;

        {
            _x params ["_key", "_label", "_type"];
            private _stored = [_objective, _key, []] call ALIVE_fnc_hashGet;
            // kept as [position, class] (the building), or as the object itself (the ambush road)
            private _object = if (_stored isEqualType objNull) then {_stored} else {
                if (_stored isEqualType [] && {count _stored == 2}) then {[_handler, "convertObject", _stored] call ALIVE_fnc_OPCOM} else {objNull}
            };
            if (!isNil "_object" && {_object isEqualType objNull} && {alive _object}) then {
                private _pos = getPosATL _object;
                private _text = if (_object isKindOf "Building" && {!(_object isKindOf "Road")}) then {
                    format ["%1 (%2)", _label, typeOf _object]
                } else {_label};
                _entries pushBack [[_pos select 0, _pos select 1], _text, _type, _colour];
            };
        } forEach _kinds;

        // Roadblocks sit in one list shared with the placement modules, so the ones inside this objective are taken
        if (_center isEqualType [] && {count _center >= 2}) then {
            {
                if (_x isEqualType [] && {count _x >= 2} && {_x distance2D _center < _size} && {!(_x in _seen)}) then {
                    _seen pushBack _x;
                    _entries pushBack [[_x select 0, _x select 1], "Roadblock", "hd_dot", _colour];
                };
            } forEach (missionNamespace getVariable ["ALiVE_CIV_PLACEMENT_ROADBLOCKS", []]);
        };
    } forEach _objectives;
} forEach _handlers;

if (_entries isEqualTo []) exitWith {
    ["ALiVE installation export: no installations or roadblocks found (%1 Asymmetric commander(s))", count _handlers] call ALIVE_fnc_dump;
    ""
};

// The SQF: Eden markers in the editor, map markers in a mission
private _lines = [
    // a string, not a comment: the debug console compiles without the preprocessor, which is what strips comments
    format ["""ALiVE: %1 insurgent installations and roadblocks from %2 on %3"";", count _entries, missionName, worldName],
    "{",
    "    _x params [""_p"", ""_t"", ""_y"", ""_c""];",
    "    if (is3DEN) then {",
    "        private _m = create3DENEntity [""Marker"", _y, _p];",
    "        _m set3DENAttribute [""text"", _t]; _m set3DENAttribute [""baseColor"", _c];",
    "    } else {",
    "        private _m = createMarker [format [""ALiVE_installation_%1"", _forEachIndex], _p];",
    "        _m setMarkerType _y; _m setMarkerText _t; _m setMarkerColor _c;",
    "    };",
    "} forEach ["
];
{
    _x params ["_p", "_t", "_y", "_c"];
    _lines pushBack format ["    [[%1,%2],%3,%4,%5]%6", round (_p select 0), round (_p select 1), str _t, str _y, str _c, ["", ","] select (_forEachIndex < count _entries - 1)];
} forEach _entries;
_lines pushBack "];";

private _sqf = _lines joinString toString [13, 10];

["ALiVE installation export: begin (%1 markers)", count _entries] call ALIVE_fnc_dump;
{ diag_log text _x } forEach _lines;
["ALiVE installation export: end"] call ALIVE_fnc_dump;

ALiVE_OPCOM_installationExport = _sqf;
publicVariable "ALiVE_OPCOM_installationExport";
if (hasInterface) then { copyToClipboard _sqf };

_sqf
