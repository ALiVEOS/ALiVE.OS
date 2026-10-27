#include "\x\alive\addons\sys_acemenu\script_component.hpp"

SCRIPT(aceMenu_repDialog);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_aceMenu_repDialog
Description:
Wrapper for SITREP and PATROLREP Dialogs

Parameters:
STRING _repType

Returns:

Examples:
(begin example)
["situation"] call ALiVE_fnc_aceMenu_repDialog;    // SitREP
["patrol"] call ALiVE_fnc_aceMenu_repDialog;       // PatrolREP
(end)

See Also:

Author:
Whigital
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

params [
    "_repType"
];

private _dialog = "";

// Get dialog from report type //
switch (toLower(_repType)) do {
    case "situation": {
        _dialog = "RscDisplayALIVESITREP";
    };

    case "patrol": {
        _dialog = "RscDisplayALIVEPATROLREP";
    };

    default {
        _dialog = "RscDisplayALIVESITREP";
    };
};

// Open it in the player's tablet style //
[_dialog] call ALiVE_fnc_tabletOpen;
