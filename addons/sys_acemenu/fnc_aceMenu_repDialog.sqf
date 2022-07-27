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

Peer reviewed:
nil
---------------------------------------------------------------------------- */

params [
    "_repType"
];

private _dialog = "";
private _ctrl = "";

// Get dialog from report type //
switch (toLower(_repType)) do {
    case "situation": {
        _dialog = "RscDisplayALIVESITREP";
        _ctrl = {((findDisplay 90001) displayCtrl 90002)};
    };

    case "patrol": {
        _dialog = "RscDisplayALIVEPATROLREP";
        _ctrl = {((findDisplay 90002) displayCtrl 90003)};
    };

    default {
        _dialog = "RscDisplayALIVESITREP";
        _ctrl = {((findDisplay 90001) displayCtrl 90002)};
    };
};

// Display dialog based on tablet model //
switch (MOD(TABLET_MODEL)) do {
    case "Tablet01": {
        createDialog _dialog;
    };

    case "Mapbag01": {
        createDialog _dialog;

        private _ctrlBackground = call _ctrl;
        _ctrlBackground ctrlsettext "x\alive\addons\main\data\ui\ALiVE_mapbag.paa";
        _ctrlBackground ctrlSetPosition [
            0.15 * safezoneW + safezoneX,
            -0.242 * safezoneH + safezoneY,
            0.72 * safezoneW,
            1.372 * safezoneH
        ];
        _ctrlBackground ctrlCommit 0;
    };

    default {
        createDialog _dialog;
    };
};
