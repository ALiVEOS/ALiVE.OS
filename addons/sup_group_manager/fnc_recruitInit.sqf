#include "\x\alive\addons\sup_group_manager\script_component.hpp"
SCRIPT(recruitInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_recruitInit

Description:
Recruitment module (#977, #1075). Every object synced to the module offers recruits: by
default one "Recruitment" action opens a window listing the soldiers and vehicles on
offer; with Interface set to Actions each one gets its own "Recruit" action instead.

A soldier joins the player's own group, until the group reaches the module's size cap.
A vehicle comes empty, up to the module's vehicle allowance per player. Both appear at
one of the module's spawn points (marker names or object names; an object gives its own
height, so a ship's deck or a rooftop works, and a marker can be given a height), or
beside the recruiting object when there are none. The module's code runs on each one,
with _this the new soldier or vehicle.

Recruits belong to the player's group only: they are not ALiVE profiles. With a Force Pool
Cost set, each soldier or vehicle is paid for from the force pool of the player's faction
(kept by Military Logistics on the server); a faction with no force pool recruits free.
A player save keeps a player's own recruits. The player who recruited a soldier or vehicle
can Dismiss it, and what it cost goes back to the pool (#1078; Allow Dismiss turns this off).

Parameters:
_this select 0: OBJECT - the module

Returns:
Nil

Examples:
(begin example)
[_logic] call ALIVE_fnc_recruitInit;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_logic", objNull, [objNull]]];

if (isNull _logic) exitWith {};

// Force pool spending. The pool lives on the server, so a player's machine asks here and is
// told yes or no: [caller, faction, cost, ticket]. A cost of 0 only asks how much is left, a
// negative cost is a refund. A faction with no pool (no Military Logistics, or a faction it
// doesn't keep) is answered yes with -1 left, so recruiting stays free there.
if (isServer && {isNil "ALiVE_recruitSpendServer"}) then {
    ALiVE_recruitSpendServer = {
        params ["_caller", "_faction", "_cost", "_ticket"];
        private _ok = true;
        private _left = -1;
        if (!isNil "ALIVE_globalForcePool" && {_faction in (ALIVE_globalForcePool select 1)}) then {
            _left = [ALIVE_globalForcePool, _faction, 0] call ALIVE_fnc_hashGet;
            if (_left isEqualType "") then { _left = parseNumber _left };
            if (_cost > _left) then { _ok = false } else {
                _left = _left - _cost;
                [ALIVE_globalForcePool, _faction, _left] call ALIVE_fnc_hashSet;
            };
        };
        ALiVE_recruitSpendReply = [_ticket, _ok, _left];
        if (local _caller) then { ALiVE_recruitSpendLast = ALiVE_recruitSpendReply } else { (owner _caller) publicVariableClient "ALiVE_recruitSpendReply" };
    };
    "ALiVE_recruitSpendRequest" addPublicVariableEventHandler { (_this select 1) call ALiVE_recruitSpendServer };
};

if (!hasInterface) exitWith {};

if (isNil "ALiVE_fnc_recruitAsk") then {
    "ALiVE_recruitSpendReply" addPublicVariableEventHandler { ALiVE_recruitSpendLast = _this select 1 };
};

// Ask the server to spend _cost from the player's faction's force pool (scheduled callers
// only: it waits for the answer). Returns [allowed, left] (left -1 when there is no pool), or
// [] when no answer came. Remembers what is left for the window's status line.
ALiVE_fnc_recruitAsk = {
    params ["_cost"];
    private _ticket = format ["%1_%2", getPlayerUID player, diag_tickTime];
    ALiVE_recruitSpendLast = [];
    ALiVE_recruitSpendRequest = [player, faction player, _cost, _ticket];
    if (isServer) then { ALiVE_recruitSpendRequest call ALiVE_recruitSpendServer } else { publicVariableServer "ALiVE_recruitSpendRequest" };
    private _t = diag_tickTime;
    waitUntil { ((ALiVE_recruitSpendLast param [0, ""]) isEqualTo _ticket) || {diag_tickTime - _t > 10} };
    if !((ALiVE_recruitSpendLast param [0, ""]) isEqualTo _ticket) exitWith { [] };
    uiNamespace setVariable ["ALiVE_recruitPool", ALiVE_recruitSpendLast select 2];
    [ALiVE_recruitSpendLast select 1, ALiVE_recruitSpendLast select 2]
};

// Pay _cost before making something; true when it may be made. Says why when it may not.
ALiVE_fnc_recruitPay = {
    params ["_cost"];
    if (_cost <= 0) exitWith { true };
    private _answer = [_cost] call ALiVE_fnc_recruitAsk;
    if (_answer isEqualTo []) exitWith { [localize "STR_ALIVE_RECRUIT", localize "STR_ALIVE_RECRUIT_UI_NO_ANSWER"] call ALIVE_fnc_sendHint; false };
    _answer params ["_ok", "_left"];
    if (!_ok) exitWith { [localize "STR_ALIVE_RECRUIT", format [localize "STR_ALIVE_RECRUIT_UI_POOL_SHORT", _left, _cost]] call ALIVE_fnc_sendHint; false };
    true
};

// Made into one list of classes: the module's own, or failing that the infantry of the
// player's faction that the editor would offer.
ALiVE_fnc_recruitClasses = {
    params ["_logic"];
    private _raw = _logic getVariable ["unitClasses", ""];
    private _classes = if (_raw isEqualType "") then { (_raw splitString ", ") select { _x != "" } } else { [] };
    _classes = _classes select { isClass (configFile >> "CfgVehicles" >> _x) && {getNumber (configFile >> "CfgVehicles" >> _x >> "scope") >= 1} };
    if (_classes isEqualTo []) then {
        private _faction = faction player;
        _classes = ("getText (_x >> 'faction') == _faction && {getNumber (_x >> 'scope') == 2} && {configName _x isKindOf 'CAManBase'} && {getText (_x >> 'vehicleClass') != 'MenDiver'}" configClasses (configFile >> "CfgVehicles")) apply { configName _x };
        // The usual roles first, so the short list is the useful one.
        private _rank = {
            private _n = toLower _this;
            switch (true) do {
                case ("_soldier_f" in _n || {"rifleman" in _n}): { 0 };
                case ("_ar_" in _n || {"autorifle" in _n}): { 1 };
                case ("_medic_" in _n): { 2 };
                case ("_lat_" in _n || {"_at_" in _n}): { 3 };
                case ("_gl_" in _n || {"grenadier" in _n}): { 4 };
                case ("_m_" in _n || {"marksman" in _n}): { 5 };
                case ("engineer" in _n): { 6 };
                default { 10 };
            };
        };
        // The faction's regular soldiers where it files them apart from special forces and story
        // characters, and one of each role name, so the list reads like a roster.
        private _regular = _classes select { getText (configFile >> "CfgVehicles" >> _x >> "editorSubcategory") == "EdSubcat_Personnel" };
        if (count _regular >= 3) then { _classes = _regular };
        _classes = [_classes, [], { _x call _rank }, "ASCEND"] call ALiVE_fnc_SortBy;
        private _names = [];
        _classes = _classes select {
            private _n = getText (configFile >> "CfgVehicles" >> _x >> "displayName");
            if (_n in _names) then { false } else { _names pushBack _n; true }
        };
        _classes = _classes select [0, 8];
    };
    _classes
};

// Where a recruit appears: a random spawn point, or beside the recruiting object.
// Returns [position ASL, direction, exact] - exact when the point gives its own height.
ALiVE_fnc_recruitSpawnPos = {
    params ["_object", "_settings", "_isVehicle", "_class"];
    _settings params ["", "", "", "", "", "", "_points", "_height"];
    private _candidates = [];
    {
        // "name" or "name:height": a height given with the point beats the module's Marker Height
        (_x splitString ":") params [["_name", ""], ["_h", ""]];
        private _ptHeight = if (_h != "") then { parseNumber _h } else { _height };
        private _obj = missionNamespace getVariable [_name, objNull];
        if (_obj isEqualType objNull && {!isNull _obj}) then {
            _candidates pushBack [getPosASL _obj, getDir _obj, true];
        } else {
            if (getMarkerColor _name != "") then {
                private _p = getMarkerPos _name;
                if (_ptHeight > 0) then {
                    _candidates pushBack [[_p select 0, _p select 1, ((getTerrainHeightASL _p) max 0) + _ptHeight], markerDir _name, true];
                } else {
                    _candidates pushBack [AGLToASL [_p select 0, _p select 1, 0], markerDir _name, false];
                };
            };
        };
    } forEach _points;
    // An exact point (a deck, a roof) can't be shifted to find room, so one with a vehicle
    // already standing on it is passed over: a second would land on the first.
    if (_isVehicle) then {
        _candidates = _candidates select { !(_x select 2) || {((ASLToAGL (_x select 0)) nearEntities [["LandVehicle", "Air", "Ship"], 8]) isEqualTo []} };
        if (_candidates isEqualTo [] && {_points isNotEqualTo []}) then { _candidates = [[[], 0, true]] };
    };
    if (_candidates isNotEqualTo []) exitWith {
        (selectRandom _candidates) params ["_pos", "_dir", "_exact"];
        if (_pos isEqualTo []) exitWith { [[], 0, true] };
        if (_exact) exitWith { [_pos, _dir, true] };
        private _free = (ASLToAGL _pos) findEmptyPosition [0, [8, 40] select _isVehicle, [_class, "B_Soldier_F"] select !_isVehicle];
        if (_free isEqualTo []) then { _free = ASLToAGL _pos };
        [AGLToASL _free, _dir, false]
    };
    if (_isVehicle) exitWith {
        private _free = (getPosATL _object) findEmptyPosition [8, 50, _class];
        if (_free isEqualTo []) then { _free = (getPosATL _object) getPos [12, random 360] };
        [AGLToASL _free, random 360, false]
    };
    [AGLToASL ((getPosATL _object) getPos [3 + random 2, random 360]), random 360, false]
};

// Dismiss, on a recruit or a recruited vehicle, for the player who recruited it (#1078): it goes,
// and what it cost goes back to the force pool. A vehicle with a player aboard can't be dismissed.
// From the hold action below or from the Recruitment window's list of the player's recruits.
ALiVE_fnc_recruitDismiss = {
    params ["_thing"];
    if (isNull _thing || {!alive _thing}) exitWith { false };
    private _isVehicle = !(_thing isKindOf "CAManBase");
    if (_isVehicle && {((crew _thing) findIf { isPlayer _x }) >= 0}) exitWith { false };
    private _cost = _thing getVariable ["ALiVE_recruitCost", 0];
    private _name = getText (configFile >> "CfgVehicles" >> typeOf _thing >> "displayName");
    if (_isVehicle) then { { moveOut _x } forEach crew _thing };
    deleteVehicle _thing;
    [_cost, _name] spawn {
        params ["_cost", "_name"];
        private _back = (_cost > 0) && {([-_cost] call ALiVE_fnc_recruitAsk) isNotEqualTo []};
        [localize "STR_ALIVE_RECRUIT", format [localize (["STR_ALIVE_RECRUIT_UI_DISMISSED", "STR_ALIVE_RECRUIT_UI_DISMISSED_REFUND"] select _back), _name, _cost]] call ALIVE_fnc_sendHint;
    };
    true
};

// This player's recruits and recruited vehicles, alive, that can be dismissed now
ALiVE_fnc_recruitDismissable = {
    private _uid = getPlayerUID player;
    ((units group player) select { alive _x && {(_x getVariable ["ALiVE_recruitedBy", ""]) == _uid} })
        + ((call ALiVE_fnc_recruitVehiclesOwned) select { ((crew _x) findIf { isPlayer _x }) < 0 })
};

// The action: held for 2 seconds, so a stray scroll click in a firefight can't dismiss anyone
ALiVE_fnc_recruitDismissAction = {
    params ["_thing", "_cost", "_isVehicle"];
    _thing setVariable ["ALiVE_recruitCost", _cost];
    private _name = getText (configFile >> "CfgVehicles" >> typeOf _thing >> "displayName");
    [
        _thing,
        format [localize "STR_ALIVE_RECRUIT_UI_DISMISS", _name],
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_takeOff1_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_takeOff1_ca.paa",
        "alive _target && {_this isEqualTo player} && {_this distance _target < 6} && {(_target getVariable ['ALiVE_recruitedBy', _target getVariable ['ALiVE_recruitedVehicleBy', '']]) isEqualTo getPlayerUID _this} && {_target isKindOf 'CAManBase' || {((crew _target) findIf { isPlayer _x }) < 0}}",
        "alive _target",
        {}, {},
        { [_this select 0] call ALiVE_fnc_recruitDismiss },
        {},
        [], 2, 0.4, false, false
    ] call BIS_fnc_holdActionAdd;
};

ALiVE_fnc_recruitUnit = {
    params ["_object", "_class", "_settings"];
    _settings params ["", "", "", "_max", "_skill", "", "", "", "_code"];
    private _group = group player;
    private _size = { alive _x } count units _group;
    if (_size >= _max) exitWith { [localize "STR_ALIVE_RECRUIT", format [localize "STR_ALIVE_RECRUIT_UI_GROUP_FULL", _max]] call ALIVE_fnc_sendHint; false };
    if (time < (player getVariable ["ALiVE_recruitNext", 0])) exitWith { [localize "STR_ALIVE_RECRUIT", localize "STR_ALIVE_RECRUIT_UI_WAIT"] call ALIVE_fnc_sendHint; false };
    player setVariable ["ALiVE_recruitNext", time + 3];
    private _cost = _settings param [10, 0];
    if !([_cost] call ALiVE_fnc_recruitPay) exitWith { false };
    ([_object, _settings, false, _class] call ALiVE_fnc_recruitSpawnPos) params ["_pos", "_dir", "_exact"];
    private _unit = _group createUnit [_class, ASLToAGL _pos, [], [2, 0] select _exact, "NONE"];
    if (isNull _unit) exitWith {
        if (_cost > 0) then { [-_cost] call ALiVE_fnc_recruitAsk };
        [localize "STR_ALIVE_RECRUIT", localize "STR_ALIVE_RECRUIT_UI_NOBODY"] call ALIVE_fnc_sendHint; false
    };
    if (_exact) then { _unit setPosASL _pos };
    _unit setDir _dir;
    [_unit] joinSilent _group;
    _unit setVariable ["ALiVE_recruited", true, true];
    // whose recruit he is, so a player save keeps only that player's own
    _unit setVariable ["ALiVE_recruitedBy", getPlayerUID player, true];
    if (_skill > 0) then { _unit setSkill _skill };
    // the module's code, kept with him so a player save that brings him back runs it again
    _unit setVariable ["ALiVE_recruitCode", _settings param [9, ""], true];
    _unit call _code;
    if (_settings param [12, true]) then { [_unit, _cost, false] call ALiVE_fnc_recruitDismissAction };
    [localize "STR_ALIVE_RECRUIT", format [localize "STR_ALIVE_RECRUIT_UI_JOINED", getText (configFile >> "CfgVehicles" >> _class >> "displayName"), _size + 1, _max]] call ALIVE_fnc_sendHint;
    true
};

// This player's recruited vehicles that still run
ALiVE_fnc_recruitVehiclesOwned = {
    vehicles select { alive _x && {(_x getVariable ["ALiVE_recruitedVehicleBy", ""]) == getPlayerUID player} }
};

ALiVE_fnc_recruitVehicle = {
    params ["_object", "_class", "_settings"];
    _settings params ["", "", "", "", "", "_maxVeh", "", "", "_code"];
    private _have = count (call ALiVE_fnc_recruitVehiclesOwned);
    if (_have >= _maxVeh) exitWith { [localize "STR_ALIVE_RECRUIT", format [localize "STR_ALIVE_RECRUIT_UI_VEH_FULL", _have, _maxVeh]] call ALIVE_fnc_sendHint; false };
    if (time < (player getVariable ["ALiVE_recruitNext", 0])) exitWith { [localize "STR_ALIVE_RECRUIT", localize "STR_ALIVE_RECRUIT_UI_WAIT"] call ALIVE_fnc_sendHint; false };
    ([_object, _settings, true, _class] call ALiVE_fnc_recruitSpawnPos) params ["_pos", "_dir", "_exact"];
    if (_pos isEqualTo []) exitWith { [localize "STR_ALIVE_RECRUIT", localize "STR_ALIVE_RECRUIT_UI_SPAWN_TAKEN"] call ALIVE_fnc_sendHint; false };
    player setVariable ["ALiVE_recruitNext", time + 5];
    private _cost = _settings param [11, 0];
    if !([_cost] call ALiVE_fnc_recruitPay) exitWith { false };
    private _veh = createVehicle [_class, [0, 0, 1000 + random 500], [], 0, "CAN_COLLIDE"];
    if (isNull _veh) exitWith {
        if (_cost > 0) then { [-_cost] call ALiVE_fnc_recruitAsk };
        [localize "STR_ALIVE_RECRUIT", localize "STR_ALIVE_RECRUIT_UI_VEH_NONE"] call ALIVE_fnc_sendHint; false
    };
    _veh setDir _dir;
    _veh setPosASL _pos;
    _veh setVelocity [0, 0, 0];
    _veh setVariable ["ALiVE_recruitedVehicleBy", getPlayerUID player, true];
    // a player's own, so a Zeus virtualise doesn't hand it to an AI commander
    _veh setVariable ["ALIVE_profileIgnore", true, true];
    _veh call _code;
    if (_settings param [12, true]) then { [_veh, _cost, true] call ALiVE_fnc_recruitDismissAction };
    [localize "STR_ALIVE_RECRUIT", format [localize "STR_ALIVE_RECRUIT_UI_VEH_READY", getText (configFile >> "CfgVehicles" >> _class >> "displayName"), _have + 1, _maxVeh]] call ALIVE_fnc_sendHint;
    true
};

[_logic] spawn {
    params ["_logic"];
    waitUntil { sleep 1; !isNull player };
    private _num = { params ["_v", "_d"]; if (_v isEqualType "") then { _v = parseNumber _v }; if (_v isEqualType 0) then { _v } else { _d } };
    private _max = [_logic getVariable ["maxGroupSize", 8], 8] call _num;
    if (_max < 1) then { _max = 8 };
    private _skill = [_logic getVariable ["recruitSkill", 0], 0] call _num;
    private _maxVeh = [_logic getVariable ["maxVehicles", 2], 2] call _num;
    private _height = [_logic getVariable ["spawnHeight", 0], 0] call _num;
    private _classes = [_logic] call ALiVE_fnc_recruitClasses;
    private _rawV = _logic getVariable ["vehicleClasses", ""];
    private _vehicles = if (_rawV isEqualType "") then { (_rawV splitString ", ") select { _x != "" && {isClass (configFile >> "CfgVehicles" >> _x)} && {getNumber (configFile >> "CfgVehicles" >> _x >> "scope") >= 1} } } else { [] };
    if (_maxVeh < 1) then { _vehicles = [] };
    private _rawP = _logic getVariable ["spawnPoints", ""];
    private _points = if (_rawP isEqualType "") then { (_rawP splitString ", ") select { _x != "" } } else { [] };
    private _rawC = _logic getVariable ["recruitCode", ""];
    private _code = if (_rawC isEqualType "" && {_rawC != ""}) then { compile _rawC } else { {} };
    private _window = (_logic getVariable ["recruitInterface", "window"]) != "actions";
    // what one soldier and one vehicle cost from the force pool; 0 is free
    private _unitCost = ([_logic getVariable ["unitCost", 0], 0] call _num) max 0;
    private _vehicleCost = ([_logic getVariable ["vehicleCost", 0], 0] call _num) max 0;
    // players can dismiss their own recruits and recruited vehicles (#1078)
    private _rawD = _logic getVariable ["allowDismiss", true];
    private _dismiss = if (_rawD isEqualType "") then { toLower _rawD != "false" } else { _rawD isNotEqualTo false };
    private _settings = [_logic, _classes, _vehicles, _max, _skill, _maxVeh, _points, _height, _code, ["", _rawC] select (_rawC isEqualType "" && {_rawC != ""}), _unitCost, _vehicleCost, _dismiss];
    private _objects = (synchronizedObjects _logic) select { !(_x isKindOf "Logic") };
    if (_objects isEqualTo [] || {(_classes + _vehicles) isEqualTo []}) exitWith {
        ["ALiVE Recruitment: nothing to do (%1 synced objects, %2 unit classes, %3 vehicle classes)", count _objects, count _classes, count _vehicles] call ALiVE_fnc_dump;
    };
    {
        private _object = _x;
        if (_window) then {
            _object addAction [localize "STR_ALIVE_RECRUIT", { ["open", _this select 3] call ALiVE_fnc_recruitWindow },
                [_object, _settings], 1.5, true, true, "", "alive _target && {vehicle _this isEqualTo _this}", 5];
        } else {
            {
                _object addAction [
                    format [localize "STR_ALIVE_RECRUIT_UI_ACTION_RECRUIT", getText (configFile >> "CfgVehicles" >> _x >> "displayName")],
                    { (_this select 3) call ALiVE_fnc_recruitUnit },
                    [_object, _x, _settings], 1.5, false, true, "", "alive _target && {vehicle _this isEqualTo _this}", 5
                ];
            } forEach _classes;
            {
                _object addAction [
                    format [localize "STR_ALIVE_RECRUIT_UI_ACTION_TAKE", getText (configFile >> "CfgVehicles" >> _x >> "displayName")],
                    { (_this select 3) call ALiVE_fnc_recruitVehicle },
                    [_object, _x, _settings], 1.4, false, true, "", "alive _target && {vehicle _this isEqualTo _this}", 5
                ];
            } forEach _vehicles;
        };
    } forEach _objects;
    _logic setVariable ["ALiVE_recruitReady", [count _objects, _classes, _vehicles], false];
};
