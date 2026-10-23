#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobMarkers);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobMarkers

Description:
The map markers for the player's own side's FOBs, drawn on the player's machine from the FOB
list the server sends. Each machine draws only its own side's, so the other side never sees
where your FOBs are on its map. A marker is a flag in the side's colour named after the FOB;
a damaged FOB's is drawn faded.

Parameters:
None

Returns:
Number - the markers drawn

Author:
Jman
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {0};

private _side = str (side group player);
private _colour = switch (_side) do {
    case "WEST": {"ColorWEST"};
    case "EAST": {"ColorEAST"};
    case "GUER": {"ColorGUER"};
    default {"ColorCIV"};
};

private _usePin = (missionNamespace getVariable ["ALiVE_prefMapLayer", true])
    && {missionNamespace getVariable ["ALiVE_prefTaskPins", "alive"] == "alive"}
    && {isClass (configFile >> "CfgMarkers" >> "alive_pin_fob")};

private _rows = (missionNamespace getVariable ["ALiVE_FOB_registryMirror", []]) select { (_x select 1) == _side };
private _want = _rows apply { "ALiVE_FOB_" + (_x select 0) };

// Gone, or now another side's
{
    if !(_x in _want) then { deleteMarkerLocal _x };
} forEach (missionNamespace getVariable ["ALiVE_FOB_markers", []]);

{
    _x params ["_id", "", "_name", "_pos", "_status", "", "", "", "", "", ["_type", ""]];
    private _m = "ALiVE_FOB_" + _id;
    if (markerType _m == "") then { createMarkerLocal [_m, _pos] };
    // its FOB type's marker (FOB Types), a flag for a plain FOB
    private _icon = ([missionNamespace getVariable ["ALiVE_sup_fob", objNull], "typeSpec", [_type]] call ALiVE_fnc_FOB) param [3, "mil_flag"];
    // a plain FOB gets ALiVE's FOB pin, in its own colours, while the player has Task Pins and
    // Tidy map labels on (the layer writes its name in the side's colour instead)
    private _pin = _icon == "mil_flag" && {_usePin};
    if (_pin) then { _icon = "alive_pin_fob" };
    if (markerType _m != _icon) then { _m setMarkerTypeLocal _icon };
    _m setMarkerPosLocal _pos;
    _m setMarkerColorLocal ([_colour, "Default"] select _pin);
    // a FOB the Rally Points module lets this player travel to says so here rather than with a
    // second marker of its own on the same spot (ALiVE_rallyFOBIds, kept by ALiVE_fnc_rallyInit).
    // The map label layer writes the name, clear of other names (ALiVE_fnc_mapPins).
    ["adopt", [_m, [_name, format [localize "STR_ALIVE_FOB_MARKER_RALLY", _name]] select (_id in (missionNamespace getVariable ["ALiVE_rallyFOBIds", []])), 90, _colour]] call ALiVE_fnc_mapPins;
    _m setMarkerAlphaLocal ([1, 0.5] select (_status == "damaged"));
} forEach _rows;

ALiVE_FOB_markers = _want;
count _want
