#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioPreview);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioPreview

Description:
The body on the stage: the selected unit or vehicle, built locally, kept still and
unhurt, with the camera turned to it.

    - "clear": deletes the body;
    - "unit" / "vehicle": an entry id of the working faction (ALiVE_FS_faction);
      the body is the entry's base class with its loadout (men) or its paint and
      parts (vehicles, BIS_fnc_initVehicle);
    - "class": a config class as it is (the class browser's preview).
A man gets its loadout again five frames later, because the base class's own init
handlers can run after creation. bodyGen rises on every call, so a late callback
for an older body does nothing. A class that is not loaded shows no body and the
caption names it. The player's view is kept from body to body, scaled to its size
(ALiVE_fnc_fsStudioCamera "save" / "restore"); for the same vehicle the paint and
parts change on the body already there.

Parameters:
    _op  - STRING - "clear", "unit", "vehicle" or "class"
    _arg - STRING - the entry id or the class

Returns:
    OBJECT - the body, or objNull

Examples:
    (begin example)
    ["unit", "u3"] call ALiVE_fnc_fsStudioPreview;
    ["class", "B_Soldier_F"] call ALiVE_fnc_fsStudioPreview;
    (end)

See Also:
    ALiVE_fnc_fsStudioStage, ALiVE_fnc_fsStudioCamera

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

params [["_op", "", [""]], ["_arg", "", [""]]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith { objNull };

// the player's view, relative to the body on show, before that body changes (ALiVE_fnc_fsStudioCamera "save")
if (!isNil "ALiVE_fnc_fsStudioCamera") then { ["save"] call ALiVE_fnc_fsStudioCamera };
private _gen = (_session getOrDefault ["bodyGen", 0]) + 1;
_session set ["bodyGen", _gen];
private _old = _session getOrDefault ["body", objNull];
private _oldRef = _session getOrDefault ["bodyRef", ""];
// the same entry again (a part, the paint, the crew, the loadout, the name): the view stays exactly as it is
private _sameEntry = !isNull _old && {_oldRef isEqualTo _arg} && {(_session getOrDefault ["bodyOp", ""]) isEqualTo _op};
private _drop = {
    if (!isNull _old) then { deleteVehicle _old };
    _session set ["body", objNull];
    _session set ["bodyRef", ""];
};

private _caption = {
    private _d = _session getOrDefault ["display", displayNull];
    if (!isNull _d) then { (_d displayCtrl FS_IDC_CAPTION) ctrlSetText _this };
};

if (_op == "clear" || {_arg isEqualTo ""}) exitWith { call _drop; "" call _caption; objNull };

// what to build: class, loadout, identity, paint
private _class = _arg;
private _name = "";
private _loadout = [];
private _identity = createHashMap;
private _paint = "";
private _parts = [];
private _pylons = [];
private _marks = [];
if (_op in ["unit", "vehicle"]) then {
    private _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
    private _entry = (_faction getOrDefault [["units", "vehicles"] select (_op == "vehicle"), createHashMap]) getOrDefault [_arg, createHashMap];
    _class = _entry getOrDefault ["base", ""];
    if (_class isEqualTo "") then { _class = _entry getOrDefault ["src", ""] };
    _name = _entry getOrDefault ["name", ""];
    _loadout = _entry getOrDefault ["loadout", []];
    _identity = _entry getOrDefault ["identity", createHashMap];
    _paint = _entry getOrDefault ["texture", ""];
    { _parts append [_x getOrDefault ["source", ""], _x getOrDefault ["value", 0]] } forEach (_entry getOrDefault ["components", []]);
    _pylons = _entry getOrDefault ["pylons", []];
    _marks = _entry getOrDefault ["markingsOff", []];
};
// the markings taken off, as the base's hidden selection indices
private _markIdx = [];
if (_marks isNotEqualTo []) then {
    private _sels = (getArray (configFile >> "CfgVehicles" >> _class >> "hiddenSelections")) apply { if (_x isEqualType "") then { toLower _x } else { "" } };
    { private _k = _sels find (toLower _x); if (_k >= 0) then { _markIdx pushBack _k } } forEach _marks;
};

private _stage = _session getOrDefault ["stagePos", []];
if (_stage isEqualTo [] || {_class isEqualTo ""}) exitWith { call _drop; "" call _caption; objNull };
if !(isClass (configFile >> "CfgVehicles" >> _class)) exitWith {
    call _drop;
    format ["%1: not loaded", _class] call _caption;
    objNull
};

// the same vehicle again with new paint or parts (or crew, or a name): changed where it stands.
// Going back to no paint (the base's own) needs a new body.
if (_op == "vehicle" && {!isNull _old} && {_oldRef isEqualTo _arg} && {typeOf _old == _class} && {!(_paint isEqualTo "") || {(_session getOrDefault ["bodyPaint", ""]) isEqualTo ""}} && {(_session getOrDefault ["bodyPylons", []]) isEqualTo _pylons}) exitWith {
    // every Garage part, at its stored value or the base's start value, so an unticked part goes back too
    private _stored = createHashMap;
    for "_i" from 0 to (count _parts - 2) step 2 do { _stored set [_parts select _i, _parts select (_i + 1)] };
    private _all = [];
    {
        if (!(getText (_x >> "displayName") isEqualTo "") && {getNumber (_x >> "scope") > 1 || {!isNumber (_x >> "scope")}}) then {
            _all append [configName _x, _stored getOrDefault [configName _x, getNumber (_x >> "initPhase")]];
        };
    } forEach (configProperties [configFile >> "CfgVehicles" >> _class >> "animationSources", "isClass _x", true]);
    // a frozen vehicle keeps gathering speed, and all of it came out the moment its physics came back on, which
    // threw it off the stage: at rest and back in place first
    _old setVelocity [0, 0, 0];
    _old setDir 180;
    _old setPosASL _stage;
    _old enableSimulation true;
    _session set ["bodyPaint", _paint];
    // the class's own textures first, so a marking put back shows again when there is no paint to put it back
    { if (_x isEqualType "") then { _old setObjectTexture [_forEachIndex, _x] } } forEach (getArray (configFile >> "CfgVehicles" >> _class >> "hiddenSelectionsTextures"));
    [_old, [false, [_paint, 1]] select !(_paint isEqualTo ""), [false, _all] select !(_all isEqualTo [])] call BIS_fnc_initVehicle;
    { _old setObjectTexture [_x, ""] } forEach _markIdx;
    [{
        params ["_body", "_stage", "_gen"];
        private _s = missionNamespace getVariable ["ALiVE_FS_session", createHashMap];
        if (isNull _body || {(_s getOrDefault ["bodyGen", -1]) != _gen}) exitWith {};
        _body enableSimulation false;
        _body setDir 180;
        _body setPosASL _stage;
        _body setVelocity [0, 0, 0];
    }, [_old, _stage, _gen], 2] call CBA_fnc_execAfterNFrames;
    (if (_name isEqualTo "") then { _class } else { format ["%1  %2", _class, _name] }) call _caption;
    // shown again from another tab: that tab's own view
    if (!isNil "ALiVE_fnc_fsStudioCamera" && {(_session getOrDefault ["bodyTab", ""]) != (_session getOrDefault ["tab", ""])}) then { ["restore"] call ALiVE_fnc_fsStudioCamera };
    _old
};
call _drop;

private _body = objNull;
if (_class isKindOf "CAManBase") then {
    _body = createAgent [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _body setVariable ["BIS_enableRandomization", false];
    _body setPosASL _stage;
    _body enableSimulation false;
    _body allowDamage false;
    _body setDir 180;
    _body disableAI "ANIM";
    private _apply = {
        params ["_body", "_loadout", "_identity"];
        if (count _loadout == 10) then { _body setUnitLoadout _loadout };
        // a relaxed stand with the weapon lowered, whatever the player is doing
        _body switchMove (switch (true) do {
            case (primaryWeapon _body != ""): { "AmovPercMstpSlowWrflDnon" };
            case (handgunWeapon _body != ""): { "AmovPercMstpSlowWpstDnon" };
            default { "AmovPercMstpSnonWnonDnon" };
        });
        if (_identity getOrDefault ["fixed", false]) then {
            private _face = _identity getOrDefault ["face", ""];
            private _speaker = _identity getOrDefault ["speaker", ""];
            if !(_face isEqualTo "") then { _body setFace _face };
            if !(_speaker isEqualTo "") then { _body setSpeaker _speaker };
        };
        private _insignia = _identity getOrDefault ["insignia", ""];
        if !(_insignia isEqualTo "") then { [_body, _insignia] call BIS_fnc_setUnitInsignia };
    };
    [_body, _loadout, _identity] call _apply;
    // once more five frames on; a newer body by then means this one is gone
    [{
        params ["_body", "_loadout", "_identity", "_gen", "_apply"];
        private _s = missionNamespace getVariable ["ALiVE_FS_session", createHashMap];
        if (!isNull _body && {(_s getOrDefault ["bodyGen", -1]) == _gen}) then { [_body, _loadout, _identity] call _apply };
    }, [_body, _loadout, _identity, _gen, _apply], 5] call CBA_fnc_execAfterNFrames;
} else {
    // on this machine only: other players never see the preview, and no updates for it cross the network
    _body = _class createVehicleLocal [0, 0, 0];
    _body enableSimulation false;
    _body allowDamage false;
    _body setDir 180;
    // setPosASL puts a vehicle's land contact at the height given, so the stage height is its ground
    _body setPosASL _stage;
    // pylons: the magazine on each one set (the rest keep the base's)
    { if !(_x isEqualTo "") then { _body setPylonLoadout [_forEachIndex + 1, _x, true] } } forEach _pylons;
    _session set ["bodyPylons", +_pylons];
    // paint and parts; false leaves the paint or the parts as the base has them.
    // The parts move only while the body simulates, so it does for two frames and is put back on the stage.
    if (!(_paint isEqualTo "") || {!(_parts isEqualTo [])}) then {
        _body enableSimulation true;
        [_body, [false, [_paint, 1]] select !(_paint isEqualTo ""), [false, _parts] select !(_parts isEqualTo [])] call BIS_fnc_initVehicle;
        [{
            params ["_body", "_stage", "_gen"];
            private _s = missionNamespace getVariable ["ALiVE_FS_session", createHashMap];
            if (isNull _body || {(_s getOrDefault ["bodyGen", -1]) != _gen}) exitWith {};
            _body enableSimulation false;
            _body setDir 180;
            _body setPosASL _stage;
            _body setVelocity [0, 0, 0];
        }, [_body, _stage, _gen], 2] call CBA_fnc_execAfterNFrames;
    };
    { _body setObjectTexture [_x, ""] } forEach _markIdx;
};

_session set ["body", _body];
_session set ["bodyRef", _arg];
_session set ["bodyPaint", _paint];
_session set ["bodyOp", _op];
(if (_name isEqualTo "") then { _class } else { format ["%1  %2", _class, _name] }) call _caption;
// the player's view on any body, scaled to its size: only the Reset view (a double-click) frames it afresh
if (!isNil "ALiVE_fnc_fsStudioCamera") then { [["restore", "apply"] select (_sameEntry && {(_session getOrDefault ["bodyTab", ""]) == (_session getOrDefault ["tab", ""])}) ] call ALiVE_fnc_fsStudioCamera };
_body
