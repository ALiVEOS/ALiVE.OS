#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(mapPins);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_mapPins

Description:
The map label layer. A feature hands ALiVE the markers it makes on the player's own machine
("adopt"), and the layer draws their names itself on every map the player has open (main map,
GPS, tablets, Zeus), each name moved to a free spot round its marker so names don't print over
each other or over other markers' icons and names. Arma keeps drawing the marker icons; an
adopted marker's own text is emptied on this machine only while the layer is on, and given back
when the player turns it off (Addon Options > ALiVE > Game > Tidy map labels).

Only local markers belong here: a global marker command from the server resends every property
and would bring the marker's own text back.

Placement, per map, recomputed a few times a second and whenever the zoom changes:
  - names are placed in priority order (FOB 90, rally 70, task 60 by default)
  - each tries 8 spots touching its icon (E, W, N, S, NE, SE, NW, SW), then the same 8 one and a
    half label heights further out, drawn with a short leader line back to the marker
  - a spot is free when it overlaps no marker icon on the map, no other marker's own name and no
    name already placed
  - a name with no free spot is left off, except priority 80 and above, which takes E anyway
The War Room's map (mb_app.js) mirrors this order and these numbers: change both together.

Parameters:
    STRING - operation
    ARRAY  - its arguments

    "adopt"    [marker, text, priority, colour, toggle, toggleArgs] - colour is a CfgMarkerColors
               name or RGBA; toggle (optional) is code run as [marker, layerOn, toggleArgs] when the
               player turns the layer on or off, for a marker that shows its name its own way
               without the layer (otherwise its own text is given back)
    "text"     [marker, text]                   - a new name for an adopted marker
    "release"  [marker]                         - stop managing it and give its text back
    "refresh"  []                               - the option changed: strip or give back every text
    "enabled"  []                               - true while the layer is on for this player
    "get"      [marker]                         - its entry [text, priority, RGBA] or []

Returns:
    per operation; nothing useful on a machine with no interface

Examples:
    ["adopt", ["ALiVE_FOB_3", "FOB Alpha", 90, "ColorWEST"]] call ALiVE_fnc_mapPins;

Author:
Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]], ["_args", []]];

if (!hasInterface) exitWith {
    if (_op == "enabled") exitWith {false};
    if (_op == "get") exitWith {[]};
};

if (isNil "ALiVE_mapPins_reg") then {
    ALiVE_mapPins_reg = createHashMap;
    ALiVE_mapPins_version = 0;
};

private _on = { missionNamespace getVariable ["ALiVE_prefMapLayer", true] };

// a CfgMarkerColors name to RGBA; side colours there are profile expressions
private _rgba = {
    params ["_c"];
    if (_c isEqualType []) exitWith {_c};
    private _arr = getArray (configFile >> "CfgMarkerColors" >> _c >> "color");
    if (count _arr < 4) exitWith {[0, 0, 0, 1]};
    _arr apply { if (_x isEqualType "") then { call compile _x } else {_x} }
};

// the watch, four times a second, that hangs the draw handler on every map control as it opens
private _watch = {
    if (!isNil "ALiVE_mapPins_watch") exitWith {};
    ALiVE_mapPins_watch = [{
        if (count ALiVE_mapPins_reg == 0) exitWith {};
        private _disps = allDisplays + [uiNamespace getVariable ["RscCustomInfoMiniMap", displayNull]];
        {
            private _d = _x;
            if (!isNull _d) then {
                {
                    if (ctrlType _x in [100, 101] && {isNil {_x getVariable "ALiVE_mapPins_eh"}}) then {
                        _x setVariable ["ALiVE_mapPins_eh", _x ctrlAddEventHandler ["Draw", { _this call ALiVE_fnc_mapPinsDraw }]];
                    };
                } forEach (allControls _d);
            };
        } forEach _disps;
    }, 0.25] call CBA_fnc_addPerFrameHandler;
};

switch (_op) do {
    case "adopt": {
        _args params [["_m", "", [""]], ["_text", "", [""]], ["_prio", 50, [0]], ["_colour", "ColorBlack", ["", []]], ["_toggle", {}, [{}]], ["_toggleArgs", []]];
        if (_m == "") exitWith {};
        private _new = [_text, _prio, [_colour] call _rgba, _toggle, _toggleArgs];
        // the same again (FOBs are re-adopted on every FOB list update): no new layout
        if ((ALiVE_mapPins_reg getOrDefault [_m, []]) isNotEqualTo _new) then {
            ALiVE_mapPins_reg set [_m, _new];
            ALiVE_mapPins_version = ALiVE_mapPins_version + 1;
        };
        _m setMarkerTextLocal ([_text, ""] select (call _on));
        call _watch;
    };
    case "text": {
        _args params [["_m", "", [""]], ["_text", "", [""]]];
        private _e = ALiVE_mapPins_reg get _m;
        if (isNil "_e") exitWith {};
        if ((_e select 0) isEqualTo _text) exitWith {};
        _e set [0, _text];
        ALiVE_mapPins_version = ALiVE_mapPins_version + 1;
        _m setMarkerTextLocal ([_text, ""] select (call _on));
    };
    case "release": {
        _args params [["_m", "", [""]]];
        private _e = ALiVE_mapPins_reg get _m;
        if (isNil "_e") exitWith {};
        ALiVE_mapPins_reg deleteAt _m;
        ALiVE_mapPins_version = ALiVE_mapPins_version + 1;
        if (markerType _m != "") then { _m setMarkerTextLocal (_e select 0) };
    };
    case "refresh": {
        private _strip = call _on;
        // a marker that shows its name its own way with the layer off (a task's black name beside its
        // pin) passed that in as code at "adopt": [marker, layer on, its arguments]
        {
            if (markerType _x != "") then {
                _y params ["_text", "", "", ["_toggle", {}], ["_toggleArgs", []]];
                if (_toggle isEqualTo {}) then {
                    _x setMarkerTextLocal ([_text, ""] select _strip);
                } else {
                    [_x, _strip, _toggleArgs] call _toggle;
                };
            };
        } forEach ALiVE_mapPins_reg;
        ALiVE_mapPins_version = ALiVE_mapPins_version + 1;
        // FOBs and rally points use ALiVE's pins only with the layer on, so they redraw now
        if (!isNil "ALiVE_fnc_fobMarkers") then { [] call ALiVE_fnc_fobMarkers };
        ALiVE_rallyMarkerRedraw = true;
    };
    case "enabled": { call _on };
    case "get": {
        _args params [["_m", "", [""]]];
        ALiVE_mapPins_reg getOrDefault [_m, []]
    };
};
