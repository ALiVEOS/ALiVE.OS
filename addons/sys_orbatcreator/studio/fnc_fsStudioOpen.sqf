#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioOpen);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioOpen

Description:
Creates the studio display (idd 14000) on an existing session and restores the
tab and the selection from the session (the tab's refresh reads the selection).
Repaints the last status line and the faction name.

Controls whose handler function is not loaded yet are switched off, so a click
on them does nothing instead of throwing a script error:
    - the preview mouse area is hidden without ALiVE_fnc_fsStudioCamera;
    - every control of a tab is disabled without that tab's function;
    - Edit loadout and Undo last Arsenal are disabled without ALiVE_fnc_fsStudioArsenal.

Never suspends. Leaves when there is no session; returns the live display when
the studio is already open.

Parameters:
    None

Returns:
    DISPLAY - the studio display, or displayNull

Examples:
    (begin example)
    [] call ALiVE_fnc_fsStudioOpen;
    (end)

See Also:
    ALiVE_fnc_fsStudioReopen, ALiVE_fnc_fsStudioTab, ALiVE_fnc_fsStudioStatus

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

if (!hasInterface) exitWith { displayNull };

disableSerialization;

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith { displayNull };

private _live = findDisplay FS_IDD_STUDIO;
if (!isNull _live) exitWith { _live };

createDialog "ALiVE_FS_Studio";
private _display = findDisplay FS_IDD_STUDIO;
if (isNull _display) exitWith {
    ["ORBAT Creator studio: the display ALiVE_FS_Studio did not open"] call ALiVE_fnc_dump;
    displayNull
};
_session set ["display", _display];

// true when _ctrl sits anywhere inside the controls group _group
private _inside = {
    params ["_ctrl", "_group"];
    private _parent = ctrlParentControlsGroup _ctrl;
    private _found = false;
    while { !isNull _parent && {!_found} } do {
        if (_parent isEqualTo _group) then { _found = true } else { _parent = ctrlParentControlsGroup _parent };
    };
    _found
};

if (isNil "ALiVE_fnc_fsStudioCamera") then { (_display displayCtrl FS_IDC_MOUSE) ctrlShow false };

private _all = allControls _display;
{
    _x params ["_idc", "_function"];
    if (isNil _function) then {
        private _group = _display displayCtrl _idc;
        { if ([_x, _group] call _inside) then { _x ctrlEnable false } } forEach _all;
    };
} forEach [
    [FS_IDC_GRP_FACTION,  "ALiVE_fnc_fsStudioTabFaction"],
    [FS_IDC_GRP_UNITS,    "ALiVE_fnc_fsStudioTabUnits"],
    [FS_IDC_GRP_VEHICLES, "ALiVE_fnc_fsStudioTabVehicles"],
    [FS_IDC_GRP_GROUPS,   "ALiVE_fnc_fsStudioTabGroups"],
    [FS_IDC_GRP_EXPORT,   "ALiVE_fnc_fsStudioTabExport"]
];

if (isNil "ALiVE_fnc_fsStudioArsenal") then {
    { (_display displayCtrl _x) ctrlEnable false } forEach [FS_IDC_U_LOADOUT, FS_IDC_U_UNDO];
};

[_session getOrDefault ["tab", "faction"]] call ALiVE_fnc_fsStudioTab;
[-1] call ALiVE_fnc_fsStudioStatus;

_display
