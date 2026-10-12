#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobClient);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobClient

Description:
The player's machine's side of the FOBs: a read-only copy of the list the server sends
(ALiVE_FOB_registryMirror, one row per FOB: id, side, name, position, status, tier, supply,
supply limit, build range). It arrives with every change and to players who join later, as a
public variable. Menus and markers come in later parts of the module and read only this.

Parameters:
String - "init" to start, "mine" for the rows of the player's own side

Returns:
Nothing, or the rows

Author:
Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]]];

switch (_op) do {
    case "init": {
        if (isNil "ALiVE_FOB_registryMirror") then { ALiVE_FOB_registryMirror = [] };
        if (isNil "ALiVE_FOB_clientReady") then {
            ALiVE_FOB_clientReady = true;
            "ALiVE_FOB_registryMirror" addPublicVariableEventHandler {
                ALiVE_FOB_registryMirror = _this select 1;
            };
        };
    };
    case "mine": {
        private _side = str (side group player);   // WEST, EAST or GUER, as the registry stores it
        ALiVE_FOB_registryMirror select { (_x select 1) == _side }
    };
};
