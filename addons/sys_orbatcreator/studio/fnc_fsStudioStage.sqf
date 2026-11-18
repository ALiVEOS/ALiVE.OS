#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioStage);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioStage

Description:
The spot the preview body stands on, kept in the session as stagePos (ASL).

    - "create": scene mode stands it 6 m in front of the player (the VR ground is
      the backdrop); module mode raises it 500 m above the module inside a local
      Sphere_3DEN, as the classic editor's background does, so the body is seen
      against a plain backdrop and nothing in the mission is in view;
    - "destroy": deletes the backdrop and clears stagePos, so a reopen makes it
      again.

Parameters:
    _op - STRING - "create" or "destroy"

Returns:
    ARRAY - stagePos after the call ([] after "destroy")

Examples:
    (begin example)
    ["create"] call ALiVE_fnc_fsStudioStage;
    (end)

See Also:
    ALiVE_fnc_fsStudioPreview, ALiVE_fnc_fsStudioCamera

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith { [] };

switch (_op) do {
    case "create": {
        { deleteVehicle _x } forEach (_session getOrDefault ["backdrop", []]);
        private _pos = [];
        private _backdrop = [];
        if ((_session getOrDefault ["mode", "scene"]) == "module" && {!isNull (_session getOrDefault ["logic", objNull])}) then {
            private _at = getPosASL (_session get "logic");
            _pos = [_at select 0, _at select 1, (_at select 2) + 500];
            private _sphere = "Sphere_3DEN" createVehicleLocal [0, 0, 0];
            _sphere setPosASL _pos;
            _sphere setDir 0;
            _backdrop pushBack _sphere;
        } else {
            _pos = (getPosASL player) vectorAdd [0, 6, 0];
        };
        _session set ["stagePos", _pos];
        _session set ["backdrop", _backdrop];
        _pos
    };
    case "destroy": {
        { deleteVehicle _x } forEach (_session getOrDefault ["backdrop", []]);
        _session set ["backdrop", []];
        _session set ["stagePos", []];
        []
    };
    default { _session getOrDefault ["stagePos", []] };
}
