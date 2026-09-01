#include "\x\alive\addons\sys_classpicker\script_component.hpp"
#include "\a3\editor_f\Data\Scripts\dikCodes.h"

SCRIPT(classPickerMenuDef);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_classPickerMenuDef

Description:
Class picker entries for the ALiVE menu, so that every operation except the two
picking keys can be reached without the debug console.

Collecting stays on Home and End as well as being here. The menu takes the mouse
to choose an entry with, so picking five positions in one building through it is
five menu openings against five key presses. What the menu is for is being able
to find the thing at all, and the operations that happen once the aiming is done.

Parameters:
Object - The object to attach the menu too
Array - The menu parameters

Returns:
Array - Returns the menu definitions for FlexiMenu

Examples:
(begin example)
[
    "player",
    [221,[false,false,false]],
    -9500,
    ["call ALIVE_fnc_classPickerMenuDef","main"]
] call CBA_fnc_flexiMenu_Add;
(end)

See Also:
- <ALIVE_fnc_classPicker>
- CBA_fnc_flexiMenu_Add

Author:
Jman
---------------------------------------------------------------------------- */

private ["_menuDef", "_target", "_params", "_menuName", "_menuRsc", "_menus"];

PARAMS_2(_target,_params);

_menuName = "";
_menuRsc = "popup";

if (typeName _params == typeName []) then {
    if (count _params < 1) exitWith {["Error: Invalid params: %1, %2", _this, __FILE__] call ALiVE_fnc_dump;};
    _menuName = _params select 0;
    _menuRsc = if (count _params > 1) then {_params select 1} else {_menuRsc};
} else {
    _menuName = _params;
};

private _opts = missionNamespace getVariable ["ALIVE_classPicker_moduleOpts", ["buildings", 75, true]];
private _running = !isNil "ALIVE_classPicker_EH_Draw3D";
private _held = count (missionNamespace getVariable ["ALIVE_classPicker_classes", []]);

// What the module is synced to decides which settings are worth offering. A
// picker wired only to military placement has no business offering to fill in a
// civilian garrison list nobody is going to read. Wired to nothing, everything
// is offered, because then there is no way to know what is wanted.
(missionNamespace getVariable ["ALIVE_classPicker_syncedTo", [0,0]]) params ["_syncedMil", "_syncedCiv"];

// What is under the crosshair right now and whether it is already held, so the
// two toggles can say which way they would toggle. A menu entry reading "take"
// when pressing it would give the thing back is worse than no label at all.
// Read at menu open, while the crosshair still resolves.
private _hoverHeld = false;
private _hoverIndex = -1;
private _hoverIndexHeld = false;
private _hoverAllHeld = false;
if (_running) then {
    (["hoverInfo"] call ALIVE_fnc_classPicker) params ["_hClass", "_hHeld", "_hIndex", "_hIndexHeld", "_hAllHeld"];
    _hoverHeld = _hHeld;
    _hoverIndex = _hIndex;
    _hoverIndexHeld = _hIndexHeld;
    _hoverAllHeld = _hAllHeld;
};
private _showMil = (_syncedMil > 0) || {_syncedMil + _syncedCiv == 0};
private _showCiv = (_syncedCiv > 0) || {_syncedMil + _syncedCiv == 0};

_menus =
[
    [
        ["main", "ALiVE", _menuRsc],
        [
            [localize "STR_ALIVE_CLASSPICKER",
                {},
                "",
                localize "STR_ALIVE_CLASSPICKER_COMMENT",
                ["call ALIVE_fnc_classPickerMenuDef", "classpicker", 1],
                -1, 1, true
            ]
        ]
    ]
];

if (_menuName == "classpicker") then {
    _menus pushBack
    [
        ["classpicker", localize "STR_ALIVE_CLASSPICKER", _menuRsc],
        [
            [format [localize "STR_ALIVE_CLASSPICKER_MENU_START", _opts select 0],
                {["start", ALIVE_classPicker_moduleOpts] call ALIVE_fnc_classPicker},
                "", localize "STR_ALIVE_CLASSPICKER_MENU_START_COMMENT",
                "", -1, 1, !_running
            ],
            [localize "STR_ALIVE_CLASSPICKER_MENU_STOP",
                {["stop"] call ALIVE_fnc_classPicker},
                "", localize "STR_ALIVE_CLASSPICKER_MENU_STOP_COMMENT",
                "", -1, 1, _running
            ],
            [if (_hoverHeld) then { localize "STR_ALIVE_CLASSPICKER_MENU_DROP" } else { localize "STR_ALIVE_CLASSPICKER_MENU_TAKE" },
                {["toggleTarget"] call ALIVE_fnc_classPicker},
                "", localize "STR_ALIVE_CLASSPICKER_MENU_TAKE_COMMENT",
                "", -1, 1, _running
            ],
            [if (_hoverIndexHeld) then { format [localize "STR_ALIVE_CLASSPICKER_MENU_DROPPOS", _hoverIndex] } else { localize "STR_ALIVE_CLASSPICKER_MENU_TAKEPOS" },
                {["toggleIndex"] call ALIVE_fnc_classPicker},
                "", localize "STR_ALIVE_CLASSPICKER_MENU_TAKEPOS_COMMENT",
                "", -1, 1, _running
            ],
            [if (_hoverAllHeld) then { localize "STR_ALIVE_CLASSPICKER_MENU_DROPALLPOS" } else { localize "STR_ALIVE_CLASSPICKER_MENU_TAKEALLPOS" },
                {["takeAllIndices"] call ALIVE_fnc_classPicker},
                "", localize "STR_ALIVE_CLASSPICKER_MENU_TAKEALLPOS_COMMENT",
                "", -1, 1, _running
            ],
            [format [localize "STR_ALIVE_CLASSPICKER_MENU_COPYFOR", _held],
                {},
                "", localize "STR_ALIVE_CLASSPICKER_MENU_COPYFOR_COMMENT",
                ["call ALIVE_fnc_classPickerMenuDef", "classpickercopy", 1],
                -1, 1, true
            ],
            [localize "STR_ALIVE_CLASSPICKER_MENU_CLEAR",
                {["clear"] call ALIVE_fnc_classPicker},
                "", localize "STR_ALIVE_CLASSPICKER_MENU_CLEAR_COMMENT",
                "", -1, 1, true
            ]
        ]
    ];
};

// One entry per setting the list can go to, named for the setting rather than
// for the format, so nobody has to know which format a given setting wants.
if (_menuName == "classpickercopy") then {
    _menus pushBack
    [
        ["classpickercopy", localize "STR_ALIVE_CLASSPICKER_MENU_COPYFOR_TITLE", _menuRsc],
        [
            [if (_syncedMil > 0) then { format [localize "STR_ALIVE_CLASSPICKER_DEST_MILGARRISON_SYNCED", _syncedMil] } else { localize "STR_ALIVE_CLASSPICKER_DEST_MILGARRISON" },
                {["copyFor", "milGarrison"] call ALIVE_fnc_classPicker},
                "", localize "STR_ALIVE_CLASSPICKER_DEST_MILGARRISON_COMMENT",
                "", -1, 1, _showMil
            ],
            [if (_syncedCiv > 0) then { format [localize "STR_ALIVE_CLASSPICKER_DEST_CIVGARRISON_SYNCED", _syncedCiv] } else { localize "STR_ALIVE_CLASSPICKER_DEST_CIVGARRISON" },
                {["copyFor", "civGarrison"] call ALIVE_fnc_classPicker},
                "", localize "STR_ALIVE_CLASSPICKER_DEST_CIVGARRISON_COMMENT",
                "", -1, 1, _showCiv
            ],
            [localize "STR_ALIVE_CLASSPICKER_DEST_VEHICLEBLACKLIST",
                {["copyFor", "vehicleBlacklist"] call ALIVE_fnc_classPicker},
                "", localize "STR_ALIVE_CLASSPICKER_DEST_VEHICLEBLACKLIST_COMMENT",
                "", -1, 1, true
            ],
            [localize "STR_ALIVE_CLASSPICKER_DEST_UNITBLACKLIST",
                {["copyFor", "unitBlacklist"] call ALIVE_fnc_classPicker},
                "", localize "STR_ALIVE_CLASSPICKER_DEST_UNITBLACKLIST_COMMENT",
                "", -1, 1, true
            ],
            [localize "STR_ALIVE_CLASSPICKER_DEST_GROUPBLACKLIST",
                {["copyFor", "groupBlacklist"] call ALIVE_fnc_classPicker},
                "", localize "STR_ALIVE_CLASSPICKER_DEST_GROUPBLACKLIST_COMMENT",
                "", -1, 1, true
            ],
            [localize "STR_ALIVE_CLASSPICKER_MENU_COPYFLAT",
                {["copy", "flat"] call ALIVE_fnc_classPicker},
                "", localize "STR_ALIVE_CLASSPICKER_MENU_COPYFLAT_COMMENT",
                "", -1, 1, true
            ]
        ]
    ];
};

_menus call ALiVE_fnc_normalizeFlexiMenuActions;

_menuDef = [];
{
    if (_x select 0 select 0 == _menuName) exitWith {_menuDef = _x};
} forEach _menus;

if (count _menuDef == 0) then {
    ["Error: Menu not found: %1, %2, %3", str _menuName, _this, __FILE__] call ALiVE_fnc_dump;
};

_menuDef
