#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobClient);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobClient

Description:
The player's machine's side of the FOBs: a read-only copy of the list the server sends
(ALiVE_FOB_registryMirror, one row per FOB: id, side, name, position, status, tier, supply,
supply limit, build range, the player ID of who deployed it). It arrives with every change and to players who join later, as a
public variable; each arrival redraws the side's FOB markers. The player's actions read only
this copy.

Parameters:
String - "init" to start, "mine" for the rows of the player's own side, "notify" to show a
message from the server, "radio" for a radio message from HQ
Array - for "notify" and "radio": [stringtable key, format arguments]

Returns:
Nothing, or the rows

Author:
Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]], ["_args", [], [[]]]];

switch (_op) do {
    case "init": {
        if (!hasInterface) exitWith {};
        if (isNil "ALiVE_FOB_registryMirror") then { ALiVE_FOB_registryMirror = [] };
        if (isNil "ALiVE_FOB_clientReady") then {
            ALiVE_FOB_clientReady = true;
            "ALiVE_FOB_registryMirror" addPublicVariableEventHandler {
                ALiVE_FOB_registryMirror = _this select 1;
                [] call ALiVE_fnc_fobMarkers;
                ["manageRefresh"] call ALiVE_fnc_fobActions;
            };
            // The player object may not be there yet on a joining machine
            [] spawn {
                waitUntil { sleep 0.5; !isNull player };
                [] call ALiVE_fnc_fobMarkers;
                ["init"] call ALiVE_fnc_fobActions;
            };
        };
    };
    case "mine": {
        private _side = str (side group player);   // WEST, EAST or GUER, as the registry stores it
        ALiVE_FOB_registryMirror select { (_x select 1) == _side }
    };
    // A radio message from HQ to this player, sent by the server as a stringtable key and its
    // values so each player reads it in their own language
    case "radio": {
        if (!hasInterface) exitWith {};
        _args params [["_key", "", [""]], ["_fmt", [], [[]]]];
        if !(isLocalized _key) exitWith {};
        ALiVE_FOB_lastRadio = format ([localize _key] + _fmt);   // read by tests
        [player, ALiVE_FOB_lastRadio, "side", side group player, false, true, false, true, "HQ"] call ALIVE_fnc_radioBroadcast;
    };
    // The server let this player into a FOB Arsenal: stock the box on this machine only, with the
    // gear list and whatever the player already carries (so the arsenal strips nothing from them),
    // and open it. The box is bare again as soon as it closes.
    case "arsenalOpen": {
        if (!hasInterface) exitWith {};
        _args params [["_box", objNull, [objNull]], ["_list", [], [[]]]];
        if (_list isNotEqualTo []) then { ALiVE_FOB_gearList = _list };
        // nothing to stock it with: hand the visit straight back
        if (isNull _box || {isNil "ALiVE_FOB_gearList"}) exitWith { ["arsenalClose", [getUnitLoadout player]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] };
        ALiVE_FOB_gearList params ["_w", "_m", "_i", "_b"];
        _w = +_w; _m = +_m; _i = +_i; _b = +_b;
        {
            if (_x isEqualType "" && {_x != ""}) then {
                switch (true) do {
                    case (isClass (configFile >> "CfgMagazines" >> _x)): { _m pushBackUnique _x };
                    case (isClass (configFile >> "CfgVehicles" >> _x)): { _b pushBackUnique _x };
                    case (isClass (configFile >> "CfgWeapons" >> _x) && {getNumber (configFile >> "CfgWeapons" >> _x >> "type") in [1, 2, 4, 4096]}): { _w pushBackUnique _x };
                    case (isClass (configFile >> "CfgWeapons" >> _x) || {isClass (configFile >> "CfgGlasses" >> _x)}): { _i pushBackUnique _x };
                };
            };
        } forEach (flatten getUnitLoadout player);
        ALiVE_FOB_arsenalBox = _box;
        // what the arsenal screens say when they close, set up once
        if (isNil "ALiVE_FOB_arsenalEH") then {
            ALiVE_FOB_arsenalEH = true;
            [missionNamespace, "arsenalClosed", { ["arsenalClosed"] call ALiVE_fnc_fobClient }] call BIS_fnc_addScriptedEventHandler;
            if (isClass (configFile >> "CfgPatches" >> "ace_arsenal")) then {
                ["ace_arsenal_displayClosed", { ["arsenalClosed"] call ALiVE_fnc_fobClient }] call CBA_fnc_addEventHandler;
            };
        };
        if (isClass (configFile >> "CfgPatches" >> "ace_arsenal")) then {
            [_box, _w + _m + _i + _b, false] call ace_arsenal_fnc_initBox;
            [_box, player] call ace_arsenal_fnc_openBox;
        } else {
            if (isNil "ALiVE_FOB_arsenalPreloaded") then { ALiVE_FOB_arsenalPreloaded = true; ["Preload"] call BIS_fnc_arsenal };
            [_box, _w, false] call BIS_fnc_addVirtualWeaponCargo;
            [_box, _m, false] call BIS_fnc_addVirtualMagazineCargo;
            [_box, _i, false] call BIS_fnc_addVirtualItemCargo;
            [_box, _b, false] call BIS_fnc_addVirtualBackpackCargo;
            ["Open", [false, _box, player]] call BIS_fnc_arsenal;
        };
    };
    // The server settled the visit first (the player moved, the FOB went, a long visit): shut
    // the arsenal and bare the box without asking to be charged again
    case "arsenalShut": {
        if (!hasInterface) exitWith {};
        ALiVE_FOB_arsenalSilent = true;
        { if (!isNull _x) then { _x closeDisplay 2 } } forEach [uiNamespace getVariable ["ace_arsenal_display", displayNull], uiNamespace getVariable ["RscDisplayArsenal", displayNull]];
        ["arsenalClosed"] call ALiVE_fnc_fobClient;
        ALiVE_FOB_arsenalSilent = false;
    };
    // An arsenal screen closed: if it was a FOB Arsenal, bare the box and tell the server
    case "arsenalClosed": {
        private _box = missionNamespace getVariable ["ALiVE_FOB_arsenalBox", objNull];
        if (isNull _box) exitWith {};
        ALiVE_FOB_arsenalBox = objNull;
        if (isClass (configFile >> "CfgPatches" >> "ace_arsenal")) then { [_box, false] call ace_arsenal_fnc_removeBox } else {
            [_box, _box call BIS_fnc_getVirtualWeaponCargo, false] call BIS_fnc_removeVirtualWeaponCargo;
            [_box, _box call BIS_fnc_getVirtualMagazineCargo, false] call BIS_fnc_removeVirtualMagazineCargo;
            [_box, _box call BIS_fnc_getVirtualItemCargo, false] call BIS_fnc_removeVirtualItemCargo;
            [_box, _box call BIS_fnc_getVirtualBackpackCargo, false] call BIS_fnc_removeVirtualBackpackCargo;
        };
        if !(missionNamespace getVariable ["ALiVE_FOB_arsenalSilent", false]) then {
            ["arsenalClose", [getUnitLoadout player]] remoteExecCall ["ALiVE_fnc_fobRequest", 2];
        };
    };
    // The FOB couldn't pay, or the player came away with something the arsenal doesn't offer:
    // the kit they had when they opened it
    case "arsenalRevert": {
        _args params [["_unit", objNull, [objNull]], ["_loadout", [], [[]]]];
        if (!isNull _unit && {local _unit} && {_loadout isNotEqualTo []}) then { _unit setUnitLoadout _loadout };
    };
    case "notify": {
        if (!hasInterface) exitWith {};
        _args params [["_key", "", [""]], ["_fmt", [], [[]]]];
        if !(isLocalized _key) exitWith {};
        // the message box reads structured text: an item name with & or < in it is made safe first
        private _safe = _fmt apply { if (_x isEqualType "") then { ((_x regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"] } else { _x } };
        private _text = format ([localize _key] + _fmt);
        [localize "STR_ALIVE_FOB", format ([localize _key] + _safe)] call ALIVE_fnc_sendHint;
        // and on the FOB window's last line when it is open
        private _fw = findDisplay 9283;
        if (!isNull _fw) then { (_fw displayCtrl 92848) ctrlSetStructuredText parseText format ([localize _key] + _safe) };
        systemChat _text;
    };
};
