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

    "adopt"    [marker, text, priority, colour, toggle, toggleArgs, icon] - colour is a CfgMarkerColors name, RGBA or "auto"
               toggle (optional) is code run as [marker, layerOn, toggleArgs] when the
               player turns the layer on or off, for a marker that shows its name its own way
               without the layer (otherwise its own text is given back); icon "auto" has the layer
               draw the marker's icon too (a NATO b_/o_/n_/c_ unit type as its side's NATO frame
               with Arma's drawing for that kind of unit in white, anything else as its own icon), so pins close
               together on screen group into one with a count; Arma's own is hidden on this machine
               by size 0 and given back when the layer is turned off
    "pinSide"  [key, frame]                     - the letter of the side whose frame the pin is drawn on
               ("w", "e", "i", "c"): the player's, or the enemy's for a pin marking the enemy
    "pinSet"   [key]                            - the pins' name suffix ("_w" and so on), or "off" for
               Arma's own markers
    "pinType"  [stockType, key]                 - "alive_pin_<key>_<side>" when the player has Tidy map
               labels on and ALiVE pins picked and the class exists, else the stock type
    "pin"      [marker, stockType, key, colour, frame] - give any marker on this machine ALiVE's pin for key in
               place of stockType (and colour, which the pin doesn't use), or put the stock look back,
               and keep it in step when the player changes either setting. stockType "" takes the
               marker's own type. Works on a global marker too: the server's next change to it resends
               its stock look, so the Draw handler puts the pin back before any map draws it. Returns
               the type used. frame (optional) is the side the marked thing belongs to, a side
               or "w"/"e"/"i"/"c", for a marker every side can see (an OPCOM installation, a group
               on the tablet): the pin goes on that side's frame instead of one guessed from the key
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
    if (_op == "pinType") exitWith { _args param [0, ""] };
    if (_op == "pin") exitWith { _args param [1, ""] };
};

if (isNil "ALiVE_mapPins_reg") then {
    ALiVE_mapPins_reg = createHashMap;
    ALiVE_mapPins_version = 0;
    // a CfgMarkerColors name (or a marker type's own colour for "Default") to RGBA, read once per
    // name; side colours there are profile expressions
    ALiVE_mapPins_rgbaCache = createHashMap;
    ALiVE_mapPins_rgba = {
        params ["_c", ["_type", ""]];
        if (_c isEqualType []) exitWith {_c};
        private _key = _c + "|" + _type;
        private _v = ALiVE_mapPins_rgbaCache get _key;
        if (!isNil "_v") exitWith {_v};
        private _arr = if (_c == "Default" && {_type != ""}) then {
            getArray (configFile >> "CfgMarkers" >> _type >> "color")
        } else {
            getArray (configFile >> "CfgMarkerColors" >> _c >> "color")
        };
        _v = if (count _arr < 4) then { [0, 0, 0, 1] } else { _arr apply { if (_x isEqualType "") then { call compile _x } else {_x} } };
        ALiVE_mapPins_rgbaCache set [_key, _v];
        _v
    };
};

private _on = { missionNamespace getVariable ["ALiVE_prefMapLayer", true] };

// the watch that hangs the draw handler on every map control as it opens:
// every display, the GPS panel and the in-game panels Arma lists in IGUI_displays (whether mod
// panels shown with cutRsc, such as cTab or the ACE microDAGR, are among them is not yet checked)
private _watch = {
    if (!isNil "ALiVE_mapPins_watch") exitWith {};
    // every frame it only counts the open displays; a new one (a map, the tablet, Zeus) is searched
    // straight away, and everything is searched again four times a second for the GPS panel
    ALiVE_mapPins_watch = [{
        if (count ALiVE_mapPins_reg == 0 && {count (missionNamespace getVariable ["ALiVE_mapPins_skins", createHashMap]) == 0}) exitWith {};
        private _n = count allDisplays;
        if (_n == (missionNamespace getVariable ["ALiVE_mapPins_dispCount", -1]) && {diag_tickTime < (missionNamespace getVariable ["ALiVE_mapPins_nextScan", 0])}) exitWith {};
        ALiVE_mapPins_dispCount = _n;
        ALiVE_mapPins_nextScan = diag_tickTime + 0.25;
        private _disps = allDisplays + [uiNamespace getVariable ["RscCustomInfoMiniMap", displayNull]] + (uiNamespace getVariable ["IGUI_displays", []]);
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
    }, 0] call CBA_fnc_addPerFrameHandler;
};

switch (_op) do {
    case "adopt": {
        _args params [["_m", "", [""]], ["_text", "", [""]], ["_prio", 50, [0]], ["_colour", "ColorBlack", ["", []]], ["_toggle", {}, [{}]], ["_toggleArgs", []], ["_icon", "", [""]]];
        if (_m == "") exitWith {};
        private _old = ALiVE_mapPins_reg getOrDefault [_m, []];
        // the marker's size the first time it is seen at full size: a marker the layer already hid
        // reads [0,0], so the size kept from before stands
        private _size = markerSize _m;
        if (_size isEqualTo [0, 0]) then { _size = _old param [5, [1, 1]] };
        // colour "auto": the marker's own (a NATO unit type's side colour when it is "Default")
        private _rgbaV = if (_colour isEqualTo "auto") then { [markerColor _m, markerType _m] call ALiVE_mapPins_rgba } else { [_colour] call ALiVE_mapPins_rgba };
        private _new = [_text, _prio, _rgbaV, _toggle, _toggleArgs, _size, _icon];
        // the same again (FOBs are re-adopted on every FOB list update): no new layout
        if (_old isNotEqualTo _new) then {
            ALiVE_mapPins_reg set [_m, _new];
            ALiVE_mapPins_version = ALiVE_mapPins_version + 1;
        };
        _m setMarkerTextLocal ([_text, ""] select (call _on));
        // the layer draws this one's icon itself (so it can group with others): Arma's is hidden here only
        if (_icon != "" && {call _on}) then { _m setMarkerSizeLocal [0, 0] };
        call _watch;
    };
    case "pin": {
        _args params [["_m", "", [""]], ["_stock", "", [""]], ["_key", "", [""]], ["_colour", "Default", [""]], ["_frame", ""]];
        if (_m == "" || {markerShape _m == ""}) exitWith {_stock};
        if (_stock == "") then { _stock = markerType _m };
        if (isNil "ALiVE_mapPins_skins") then { ALiVE_mapPins_skins = createHashMap };
        // a marker made again under the same name may already show its pin here: keep the stock type known
        if ((_stock select [0, 10]) == "alive_pin_") then { _stock = (ALiVE_mapPins_skins getOrDefault [_m, [_stock]]) select 0 };
        private _type = ["pinType", [_stock, _key, _frame]] call ALiVE_fnc_mapPins;
        private _col = [_colour, "Default"] select (_type != _stock);
        // [stock type, key, stock colour, type shown, colour shown, frame]
        ALiVE_mapPins_skins set [_m, [_stock, _key, _colour, _type, _col, _frame]];
        _m setMarkerTypeLocal _type;
        _m setMarkerColorLocal _col;
        call _watch;
        _type
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
        if (markerType _m != "") then {
            if ((_e param [6, ""]) != "") then { _m setMarkerSizeLocal (_e param [5, [1, 1]]) };
            _m setMarkerTextLocal (_e select 0);
        };
    };
    case "refresh": {
        private _strip = call _on;
        // a marker that shows its name its own way with the layer off (a task's black name beside its
        // pin) passed that in as code at "adopt": [marker, layer on, its arguments]
        {
            if (markerType _x != "") then {
                _y params ["_text", "", "", ["_toggle", {}], ["_toggleArgs", []], ["_size", [1, 1]], ["_icon", ""]];
                if (_icon != "") then { _x setMarkerSizeLocal ([_size, [0, 0]] select _strip) };
                if (_toggle isEqualTo {}) then {
                    _x setMarkerTextLocal ([_text, ""] select _strip);
                } else {
                    [_x, _strip, _toggleArgs] call _toggle;
                };
            };
        } forEach ALiVE_mapPins_reg;
        ALiVE_mapPins_version = ALiVE_mapPins_version + 1;
        // markers given a pin by "pin" follow the settings too; one that has since been deleted is dropped
        if (!isNil "ALiVE_mapPins_skins") then {
            {
                if (markerShape _x == "") then {
                    ALiVE_mapPins_skins deleteAt _x;
                } else {
                    _y params ["_stock", "_key", "_colour", "", "", ["_frame", ""]];
                    private _type = ["pinType", [_stock, _key, _frame]] call ALiVE_fnc_mapPins;
                    private _col = [_colour, "Default"] select (_type != _stock);
                    ALiVE_mapPins_skins set [_x, [_stock, _key, _colour, _type, _col, _frame]];
                    _x setMarkerTypeLocal _type;
                    _x setMarkerColorLocal _col;
                };
            } forEach +ALiVE_mapPins_skins;
        };
        // FOBs and rally points use ALiVE's pins only with the layer on, so they redraw now
        if (!isNil "ALiVE_fnc_fobMarkers") then { [] call ALiVE_fnc_fobMarkers };
        ALiVE_rallyMarkerRedraw = true;
    };
    case "pinSide": {
        // the side whose NATO frame a pin is drawn on, as the letter on the end of its class name: the
        // player's own side ("w" BLUFOR, "e" OPFOR, "i" Independent, "c" Civilian); a pin that marks the
        // enemy (a threat, an ambush, an unknown contact, an enemy installation, a strike target or an HVT) is
        // drawn on the enemy's frame instead, OPFOR's, or BLUFOR's for an OPFOR player; civilians' on the
        // civilian frame
        _args params [["_key", "", [""]], ["_frame", "", ["", sideUnknown]]];
        if (_frame isEqualType sideUnknown) then {
            _frame = switch (_frame) do { case west: {"w"}; case east: {"e"}; case resistance: {"i"}; case civilian: {"c"}; default {""} };
        };
        if (_frame in ["w", "e", "i", "c"]) exitWith {_frame};
        private _own = switch (playerSide) do {
            case west: {"w"};
            case east: {"e"};
            case resistance: {"i"};
            default {"c"};
        };
        if (toLower _key == "civilian") exitWith {"c"};
        if (toLower _key in ["threat", "ambush", "unknowncontact", "installation", "striketarget", "hvt"]) exitWith { ["e", "w"] select (_own == "e") };
        _own
    };
    case "pinSet": {
        // "off" for Arma's own markers, otherwise the side suffix on the player's pins' names ("_w" and so
        // on); a save from before carrying an older pin set ("alive_b" and so on) counts as on
        if !((missionNamespace getVariable ["ALiVE_prefTaskPins", "alive"]) select [0, 5] == "alive") exitWith {"off"};
        "_" + (["pinSide", [_args param [0, ""], _args param [1, ""]]] call ALiVE_fnc_mapPins)
    };
    case "pinType": {
        // ALiVE's pin for a kind of place, on the right side's frame, when Tidy map labels are on and ALiVE
        // pins are picked; otherwise the stock marker type the feature always used
        _args params [["_stock", "", [""]], ["_key", "", [""]], ["_frame", ""]];
        private _set = ["pinSet", [_key, _frame]] call ALiVE_fnc_mapPins;
        private _pin = "alive_pin_" + toLower _key + _set;
        [_stock, _pin] select ((call _on) && {_set != "off"} && {isClass (configFile >> "CfgMarkers" >> _pin)})
    };
    case "enabled": { call _on };
    case "get": {
        _args params [["_m", "", [""]]];
        ALiVE_mapPins_reg getOrDefault [_m, []]
    };
};
