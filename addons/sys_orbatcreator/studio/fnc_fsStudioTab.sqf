#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioTab);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioTab

Description:
Shows one tab of the studio and hides the rest, keeps the choice in the session
and the prefs, marks the tab's button, then calls the tab's "refresh" when its
handler function is loaded. An unknown tab name falls back to "faction".

Parameters:
    _tab - STRING - "faction", "units", "vehicles", "groups", "alive" or "export"

Returns:
    STRING - the tab shown

Examples:
    (begin example)
    ["units"] call ALiVE_fnc_fsStudioTab;
    (end)

See Also:
    ALiVE_fnc_fsStudioOpen, ALiVE_fnc_fsStudioKeys

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

if (!hasInterface) exitWith { "" };

disableSerialization;

params [["_tab", "faction", [""]]];

// [name, group IDC, button IDC, handler function]
private _tabs = [
    ["faction",  FS_IDC_GRP_FACTION,  FS_IDC_TAB_FACTION,  "ALiVE_fnc_fsStudioTabFaction"],
    ["units",    FS_IDC_GRP_UNITS,    FS_IDC_TAB_UNITS,    "ALiVE_fnc_fsStudioTabUnits"],
    ["vehicles", FS_IDC_GRP_VEHICLES, FS_IDC_TAB_VEHICLES, "ALiVE_fnc_fsStudioTabVehicles"],
    ["groups",   FS_IDC_GRP_GROUPS,   FS_IDC_TAB_GROUPS,   "ALiVE_fnc_fsStudioTabGroups"],
    ["alive",    FS_IDC_GRP_ALIVE,    FS_IDC_TAB_ALIVE,    "ALiVE_fnc_fsStudioTabAlive"],
    ["export",   FS_IDC_GRP_EXPORT,   FS_IDC_TAB_EXPORT,   "ALiVE_fnc_fsStudioTabExport"]
];

private _at = _tabs findIf { (_x select 0) == _tab };
if (_at < 0) then { _at = 0; _tab = "faction" };

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (!isNil "_session") then { _session set ["tab", _tab] };
["prefSet", ["tab", _tab]] call ALiVE_fnc_fsDataStore;

private _display = findDisplay FS_IDD_STUDIO;
if (isNull _display) exitWith { _tab };

{
    _x params ["_name", "_group", "_button"];
    private _on = (_forEachIndex == _at);
    (_display displayCtrl _group) ctrlShow _on;
    (_display displayCtrl _button) ctrlSetTextColor ([[1, 1, 1, 0.7], [0.576, 0.769, 0.49, 1]] select _on);
} forEach _tabs;

private _handler = missionNamespace getVariable ((_tabs select _at) select 3);
if (!isNil "_handler") then { ["refresh", []] call _handler };

// an open help window follows the tab, and a tab this player has not seen opens its help
["tabShown"] call ALiVE_fnc_fsStudioHelp;

_tab
