#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioCamera);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioCamera

Description:
The orbit camera on the stage. Its state is cam = [yaw, pitch, dist, height] in
the session; it moves only when a value changes, never every frame.

    - "create": the camera, looking at the stage;
    - "destroy": ends the camera effect and deletes it (camera becomes objNull, so
      a reopen makes it again);
    - "focus": frames the body: distance from its size, height half its height
      (the Reset view, a double-click on the preview);
    - "save": before the body changes, keeps the view relative to it, for the tab
      the body was shown on (camRels, by tab): the angle as it is, the distance and
      height as shares of its framing, the move as a share of its bounding radius;
    - "restore": the current tab's view on the new body, scaled to its size, so a
      man and a tank frame the same way; each tab has its own view (a unit is seen
      much closer than a vehicle); a tab with no saved view frames it ("focus").
      "focus" (the double-click) resets the current tab's view only;
    - "apply": puts the camera where cam says. The target is moved to the camera's
      left by 0.17 of the distance, so the body stands in the free area right of
      the panel;
    - "view": makes the studio camera the view again, after something else took
      it (ACE Arsenal puts the player's view back as it closes);
    - "down" / "up" / "move" / "wheel": the preview mouse area (control 14008),
      as in Eden: left drag moves the view (sideways and up/down), right drag turns
      around the unit, the wheel moves in and out;
    - "popLayout": places the four areas of open view around a popup, where a view
      drag, the wheel and the double-click start; nothing else starts them, so an
      open combo list or a scrollbar past the popup's edge keeps its own mouse;
    - "popMove" / "popUp": a popup display's mouse events, which follow a drag
      that has started, and keep the four areas round a popup being dragged.
A drag ends when its button is found released, wherever the pointer was let go.
Limits: pitch -10..80; distance from just outside the unit (its size) to 60; the
sideways move stays within the unit's bounding radius, so it never leaves the view.

Parameters:
    _op   - STRING - as above
    _args - ARRAY - the event arguments for the mouse events

Returns:
    BOOL - false (mouse events are not taken from the display)

Examples:
    (begin example)
    ["create"] call ALiVE_fnc_fsStudioCamera;
    ["focus"] call ALiVE_fnc_fsStudioCamera;
    (end)

See Also:
    ALiVE_fnc_fsStudioStage, ALiVE_fnc_fsStudioPreview

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

params [["_op", "", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith { false };

// the four areas of open view round a popup: the box around its controls, read each time because it can be dragged
// by its title
private _layout = {
    params ["_popup"];
    private _areas = [FS_IDC_POPUP_TOP, FS_IDC_POPUP_BOTTOM, FS_IDC_POPUP_LEFT, FS_IDC_POPUP_RIGHT];
    private _left = 99;
    private _top = 99;
    private _right = -99;
    private _bottom = -99;
    {
        if (!(ctrlIDC _x in _areas) && {isNull (ctrlParentControlsGroup _x)}) then {
            (ctrlPosition _x) params ["_cx", "_cy", "_cw", "_ch"];
            _left = _left min _cx;
            _top = _top min _cy;
            _right = _right max (_cx + _cw);
            _bottom = _bottom max (_cy + _ch);
        };
    } forEach (allControls _popup);
    {
        _x params ["_idc", "_ax", "_ay", "_aw", "_ah"];
        private _area = _popup displayCtrl _idc;
        _area ctrlSetPosition [_ax, _ay, _aw max 0, _ah max 0];
        _area ctrlCommit 0;
    } forEach [
        [FS_IDC_POPUP_TOP, safezoneX, safezoneY, safezoneW, _top - safezoneY],
        [FS_IDC_POPUP_BOTTOM, safezoneX, _bottom, safezoneW, (safezoneY + safezoneH) - _bottom],
        [FS_IDC_POPUP_LEFT, safezoneX, _top, _left - safezoneX, _bottom - _top],
        [FS_IDC_POPUP_RIGHT, _right, _top, (safezoneX + safezoneW) - _right, _bottom - _top]
    ];
};

private _apply = {
    private _cam = _session getOrDefault ["camera", objNull];
    private _stage = _session getOrDefault ["stagePos", []];
    if (isNull _cam || {_stage isEqualTo []}) exitWith {};
    (_session getOrDefault ["cam", [200, 8, 4, 1]]) params ["_yaw", "_pitch", "_dist", "_height"];
    private _target = (_stage vectorAdd [0, 0, _height]) vectorAdd (_session getOrDefault ["camPan", [0, 0, 0]]);
    private _pos = _target vectorAdd [_dist * (sin _yaw) * (cos _pitch), _dist * (cos _yaw) * (cos _pitch), _dist * (sin _pitch)];
    private _dir = vectorNormalized (_target vectorDiff _pos);
    // right of the view, flat: the target moves the other way so the body sits right of the panel
    private _right = vectorNormalized (_dir vectorCrossProduct [0, 0, 1]);
    _target = _target vectorAdd (_right vectorMultiply (-0.17 * _dist));
    _dir = vectorNormalized (_target vectorDiff _pos);
    private _up = (_dir vectorCrossProduct [0, 0, 1]) vectorCrossProduct _dir;
    _cam setPosASL _pos;
    _cam setVectorDirAndUp [_dir, vectorNormalized _up];
};

// how far the view may move from the unit, and how near it may come: the unit's size
private _reach = {
    private _body = _session getOrDefault ["body", objNull];
    // the model's bounding radius: sizeOf gives a man about 7 m, which let the view leave him
    if (isNull _body) then { 1.5 } else { ((boundingBoxReal _body) select 2) max 0.8 }
};

// the body's own framing: [distance, height, bounding radius], or [] with no body
// measured once per class and kept (frames): the bounding box changes as parts show or hide, and the view
// must not move when a part is ticked
private _frame = {
    private _body = _session getOrDefault ["body", objNull];
    if (isNull _body) exitWith { [] };
    private _frames = _session getOrDefault ["frames", createHashMap];
    _session set ["frames", _frames];
    private _type = typeOf _body;
    if (_type in _frames) exitWith { _frames get _type };
    private _bb = boundingBoxReal _body;
    private _h = (((_bb select 1) select 2) - ((_bb select 0) select 2)) max 0.5;
    private _bottom = ((getPosASL _body) select 2) - ((_session getOrDefault ["stagePos", [0, 0, 0]]) select 2);
    private _f = [(((sizeOf _type) * 1.1) max 2.2) min 60, (_bottom + _h / 2) max 0.3, (_bb select 2) max 0.8];
    _frames set [_type, _f];
    _f
};

// how far the view may move for a distance: the unit's size, and never so far for the zoom that it leaves the
// view (a vehicle's radius is wider than a close view). Pulls the move and the height back inside it
private _hold = {
    params ["_dist", "_height", "_r"];
    private _limit = _r min ((_dist * 0.35) max 0.5);
    private _pan = _session getOrDefault ["camPan", [0, 0, 0]];
    if (vectorMagnitude _pan > _limit) then { _session set ["camPan", (vectorNormalized _pan) vectorMultiply _limit] };
    [_limit, ((_height max 0) min ((_limit * 2) max 3))]
};

switch (_op) do {
    case "create": {
        private _old = _session getOrDefault ["camera", objNull];
        if (!isNull _old) then { _old cameraEffect ["Terminate", "Back"]; camDestroy _old };
        private _stage = _session getOrDefault ["stagePos", []];
        private _cam = "camera" camCreate (if (_stage isEqualTo []) then { getPosATL player } else { ASLToATL _stage });
        _cam cameraEffect ["Internal", "Back"];
        showCinemaBorder false;
        _cam camSetFov 0.45;
        _session set ["camera", _cam];
        if ((_session getOrDefault ["cam", []]) isEqualTo []) then { _session set ["cam", [200, 8, 4, 1]] };
        call _apply;
    };
    case "destroy": {
        private _cam = _session getOrDefault ["camera", objNull];
        if (!isNull _cam) then { _cam cameraEffect ["Terminate", "Back"]; camDestroy _cam };
        _session set ["camera", objNull];
        _session set ["drag", []];
    };
    case "focus": {
        _session set ["bodyTab", _session getOrDefault ["tab", "faction"]];
        private _f = call _frame;
        if (_f isEqualTo []) exitWith {};
        _f params ["_dist", "_height"];
        _session set ["cam", [200, 8, _dist, _height]];
        _session set ["camPan", [0, 0, 0]];
        call _apply;
    };
    case "save": {
        private _f = call _frame;
        if (_f isEqualTo [] || {isNull (_session getOrDefault ["camera", objNull])}) exitWith {};
        _f params ["_d0", "_h0", "_r"];
        (_session getOrDefault ["cam", [200, 8, _d0, _h0]]) params ["_yaw", "_pitch", "_dist", "_height"];
        private _rels = _session getOrDefault ["camRels", createHashMap];
        _session set ["camRels", _rels];
        _rels set [_session getOrDefault ["bodyTab", "faction"], [_yaw, _pitch, _dist / _d0, (_height - _h0) / _r, (_session getOrDefault ["camPan", [0, 0, 0]]) vectorMultiply (1 / _r)]];
    };
    case "restore": {
        private _tab = _session getOrDefault ["tab", "faction"];
        _session set ["bodyTab", _tab];
        private _rel = (_session getOrDefault ["camRels", createHashMap]) getOrDefault [_tab, []];
        if (_rel isEqualTo []) exitWith { ["focus"] call ALiVE_fnc_fsStudioCamera };
        private _f = call _frame;
        if (_f isEqualTo []) exitWith {};
        _f params ["_d0", "_h0", "_r"];
        _rel params ["_yaw", "_pitch", "_k", "_up", "_pan"];
        private _near = (_r * 0.9) max 0.8;
        private _dist = ((_d0 * _k) max _near) min 60;
        // held to a left drag's limit: a move kept from a small unit can be wider than a close view of a big one
        _session set ["camPan", _pan vectorMultiply _r];
        private _height = ([_dist, _h0 + _up * _r, _r] call _hold) select 1;
        _session set ["cam", [_yaw, _pitch, _dist, _height]];
        call _apply;
    };
    case "apply": { call _apply };
    // the studio camera made the view again (after something else took it, such as ACE Arsenal closing)
    case "view": {
        private _cam = _session getOrDefault ["camera", objNull];
        if (isNull _cam) exitWith {};
        _cam cameraEffect ["Internal", "Back"];
        showCinemaBorder false;
        call _apply;
    };
    case "down": {
        _args params ["", "_button", "_mx", "_my"];
        _session set ["drag", [_button, _mx, _my, diag_tickTime]];
    };
    case "popLayout": { [_args select 0] call _layout };
    case "popUp": {
        _session set ["drag", []];
        [_args select 0] call _layout;
    };
    // a display's own move event does not carry the pointer's place
    case "popMove": {
        getMousePosition params ["_mx", "_my"];
        ["move", [_args select 0, _mx, _my]] call ALiVE_fnc_fsStudioCamera;
        // the left button held with no view drag going: the popup may be moving by its title
        if ((inputMouse 0) != 0 && {(_session getOrDefault ["drag", []]) isEqualTo []}) then { [_args select 0] call _layout };
    };
    case "up": { _session set ["drag", []] };
    case "move": {
        _args params ["", "_mx", "_my"];
        private _drag = _session getOrDefault ["drag", []];
        if (_drag isEqualTo []) exitWith {};
        _drag params ["_button", "_x0", "_y0", ["_t0", 0]];
        // let go over a popup, where this area hears no release: the drag is over
        if ((inputMouse _button) == 0) exitWith { _session set ["drag", []] };
        _session set ["drag", [_button, _mx, _my, diag_tickTime]];
        // back from a pass over the popup: carry on from here, the view does not jump
        if (diag_tickTime - _t0 > 0.2) exitWith {};
        private _dx = (_mx - _x0) * (getResolution select 2);
        private _dy = (_my - _y0) * (getResolution select 3);
        (_session getOrDefault ["cam", [200, 8, 4, 1]]) params ["_yaw", "_pitch", "_dist", "_height"];
        private _limit = ([_dist, _height, call _reach] call _hold) select 0;
        if (_button == 1) then {
            _yaw = (_yaw - _dx * 0.4) mod 360;
            _pitch = ((_pitch + _dy * 0.4) max -10) min 80;
        } else {
            // left drag: the view follows the pointer, sideways along the screen and up and down,
            // further per pixel when the camera is further out
            private _step = _dist * 0.0015;
            // the camera's left, flat: dragging right moves the view's centre left, so the unit follows the pointer
            private _left = [cos _yaw, -(sin _yaw), 0];
            private _pan = (_session getOrDefault ["camPan", [0, 0, 0]]) vectorAdd (_left vectorMultiply (_dx * _step));
            if (vectorMagnitude _pan > _limit) then { _pan = (vectorNormalized _pan) vectorMultiply _limit };
            _session set ["camPan", _pan];
            _height = ((_height + _dy * _step) max 0) min ((_limit * 2) max 3);
        };
        _session set ["cam", [_yaw, _pitch, _dist, _height]];
        call _apply;
    };
    case "wheel": {
        _args params ["", "_z"];
        (_session getOrDefault ["cam", [200, 8, 4, 1]]) params ["_yaw", "_pitch", "_dist", "_height"];
        // never inside the unit: no nearer than its size from the target
        private _near = ((call _reach) * 0.9) max 0.8;
        _dist = ((_dist * ([1.1, 0.9] select (_z > 0))) max _near) min 60;
        // nearer, the move allowed is shorter
        _height = ([_dist, _height, call _reach] call _hold) select 1;
        _session set ["cam", [_yaw, _pitch, _dist, _height]];
        call _apply;
    };
};

false
