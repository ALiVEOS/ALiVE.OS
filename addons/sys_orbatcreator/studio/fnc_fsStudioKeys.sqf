#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioKeys);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioKeys

Description:
KeyDown handler of the studio display.
    - Esc: in scene mode swallowed, with the status S_ESC (Exit is the way out);
      in module mode it closes the studio as usual;
    - Ctrl+S: saves the working faction to the saved factions under its name;
    - Ctrl+1 to Ctrl+5: Faction, Units, Vehicles, Groups, Export.

Parameters:
    _display - DISPLAY
    _key     - NUMBER - DIK code
    _shift   - BOOL
    _ctrl    - BOOL
    _alt     - BOOL

Returns:
    BOOL - true when the key was handled

Examples:
    (begin example)
    onKeyDown = "_this call ALiVE_fnc_fsStudioKeys";
    (end)

See Also:
    ALiVE_fnc_fsStudioTab, ALiVE_fnc_fsStudioClose

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

#define FS_DIK_ESCAPE   1
#define FS_DIK_1        2
#define FS_DIK_5        6
#define FS_DIK_S        31

if (!hasInterface) exitWith { false };

params ["_display", ["_key", -1, [0]], ["_shift", false, [false]], ["_ctrl", false, [false]], ["_alt", false, [false]]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith { false };

private _handled = false;

switch (true) do {

    case (_key == FS_DIK_ESCAPE): {
        if ((_session getOrDefault ["mode", "scene"]) == "scene") then {
            [0, "S_ESC", []] call ALiVE_fnc_fsStudioStatus;
            _handled = true;
        };
    };

    case (_ctrl && {!_alt} && {_key == FS_DIK_S}): {
        _handled = true;
        private _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
        private _name = if (_faction isEqualType createHashMap) then { _faction getOrDefault ["name", ""] } else { "" };
        (["librarySave", [_name]] call ALiVE_fnc_fsDataStore) params ["_ok", "_statusKey", "_statusArgs"];
        if (_ok) then {
            ["library", true] call ALiVE_fnc_fsDataTouch;
            [0, _statusKey, _statusArgs] call ALiVE_fnc_fsStudioStatus;
        } else {
            [1, _statusKey, _statusArgs] call ALiVE_fnc_fsStudioStatus;
        };
    };

    case (_ctrl && {!_alt} && {_key >= FS_DIK_1} && {_key <= FS_DIK_5}): {
        _handled = true;
        [["faction", "units", "vehicles", "groups", "export"] select (_key - FS_DIK_1)] call ALiVE_fnc_fsStudioTab;
    };
};

_handled
