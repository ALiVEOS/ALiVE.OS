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
