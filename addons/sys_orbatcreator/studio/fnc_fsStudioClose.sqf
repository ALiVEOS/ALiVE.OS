#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioClose);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioClose

Description:
Closing the studio display, three ways.
    "unload"  - the display's onUnload. Forced save; stops a running export.
                Suspended (an Arsenal is opening): nothing more. Exiting: tears
                down the camera, the body and the stage, and in module mode gives
                the player his own view back. Scene mode, neither flag: opens again
                on the next frame. Module mode, neither flag: treated as exiting
                (the ALiVE menu row opens it again).
    "exit"    - the Exit button. Refused while an export is being written. Else
                closes for good; in scene mode it then ends the mission.
    "suspend" - closes the display and the camera but keeps the stage, so the
                Arsenal can open on the body. Used by ALiVE_fnc_fsStudioArsenal.
Stage, preview and camera are only called when those functions are loaded.

Parameters:
    _op   - STRING - "unload", "exit" or "suspend"
    _args - ANY - the display event arguments for "unload"

Returns:
    BOOL - false when "exit" was refused, else true

Examples:
    (begin example)
    ["exit"] call ALiVE_fnc_fsStudioClose;
    (end)

See Also:
    ALiVE_fnc_fsStudioReopen, ALiVE_fnc_fsDataTouch

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

if (!hasInterface) exitWith { false };

disableSerialization;

params [["_op", "", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith { false };

// camera, body and stage away; module mode gives the player his own view back
// (the view is only handed back when the studio camera exists to take it)
private _teardown = {
    if (!isNil "ALiVE_fnc_fsStudioCamera") then {
        ["destroy"] call ALiVE_fnc_fsStudioCamera;
        if ((_session getOrDefault ["mode", "scene"]) == "module") then {
            [player, "FIRST_PERSON"] call ALIVE_fnc_switchCamera;
        };
    };
    if (!isNil "ALiVE_fnc_fsStudioPreview") then { ["clear"] call ALiVE_fnc_fsStudioPreview };
    if (!isNil "ALiVE_fnc_fsStudioStage") then { ["destroy"] call ALiVE_fnc_fsStudioStage };
};

private _result = true;

switch (_op) do {

    case "unload": {
        ["unload", true] call ALiVE_fnc_fsDataTouch;
        if (_session getOrDefault ["exportBusy", false]) then { _session set ["exportAbort", true] };
        _session set ["display", displayNull];

        switch (true) do {
            case (_session getOrDefault ["suspended", false]): {};
            case (_session getOrDefault ["exiting", false]): { call _teardown };
            case ((_session getOrDefault ["mode", "scene"]) == "scene"): {
                // the scene has nothing behind the studio: open it again
                [{ [] call ALiVE_fnc_fsStudioReopen }] call CBA_fnc_execNextFrame;
            };
            default {
                _session set ["exiting", true];
                call _teardown;
            };
        };
    };

    case "exit": {
        if (_session getOrDefault ["exportBusy", false]) then {
            [1, "S_BUSY_EXPORT", []] call ALiVE_fnc_fsStudioStatus;
            _result = false;
        } else {
            _session set ["exiting", true];
            private _display = findDisplay FS_IDD_STUDIO;
            if (!isNull _display) then { _display closeDisplay 2 };
            if ((_session getOrDefault ["mode", "scene"]) == "scene") then { endMission "END1" };
        };
    };

    case "suspend": {
        _session set ["suspended", true];
        if (!isNil "ALiVE_fnc_fsStudioCamera") then { ["destroy"] call ALiVE_fnc_fsStudioCamera };
        private _display = findDisplay FS_IDD_STUDIO;
        if (!isNull _display) then { _display closeDisplay 2 };
    };

    default {
        _result = false;
    };
};

_result
