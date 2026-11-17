#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioReopen);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioReopen

Description:
Brings the studio back on an existing session. Never suspends, so the ALiVE
menu action, the scene's next-frame reopen and the Arsenal's return can call it.
    1. No session: spawns ALiVE_fnc_fsStudioStart, in module mode when
       MOD(orbatCreator) is a logic, else in scene mode, and leaves.
    2. Leaves while the session is starting, an Arsenal or an export is busy,
       or the display is already open.
    3. Clears exiting and suspended, makes the stage and the camera again when
       they are gone (only when those functions are loaded), then opens.
Reads nothing from the profile: ALiVE_FS_faction is still in memory, and the
display's unload saved it.

Parameters:
    None

Returns:
    BOOL - true when it opened the display

Examples:
    (begin example)
    [] call ALiVE_fnc_fsStudioReopen;
    (end)

See Also:
    ALiVE_fnc_fsStudioStart, ALiVE_fnc_fsStudioOpen, ALiVE_fnc_fsStudioClose

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

if (!hasInterface) exitWith { false };

private _session = missionNamespace getVariable "ALiVE_FS_session";

if (isNil "_session") exitWith {
    private _logic = missionNamespace getVariable [QMOD(orbatCreator), objNull];
    if !(_logic isEqualType objNull) then { _logic = objNull };
    [["scene", "module"] select (!isNull _logic), _logic] spawn ALiVE_fnc_fsStudioStart;
    false
};

if (
    (_session getOrDefault ["starting", false])
    || {_session getOrDefault ["arsenalBusy", false]}
    || {_session getOrDefault ["exportBusy", false]}
    || {!isNull (findDisplay FS_IDD_STUDIO)}
) exitWith { false };

_session set ["exiting", false];
_session set ["suspended", false];

// the stage clears stagePos and the camera clears camera when they are destroyed
if (!isNil "ALiVE_fnc_fsStudioStage" && {(_session getOrDefault ["stagePos", []]) isEqualTo []}) then {
    ["create"] call ALiVE_fnc_fsStudioStage;
};
if (!isNil "ALiVE_fnc_fsStudioCamera" && {isNull (_session getOrDefault ["camera", objNull])}) then {
    ["create"] call ALiVE_fnc_fsStudioCamera;
};

!isNull ([] call ALiVE_fnc_fsStudioOpen)
