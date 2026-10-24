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

With Offer Synced Units and Vehicles on, the men and vehicles synced to the module are the
offer instead of recruitment points: the server notes each one as placed (his loadout, its
paint), removes it, and publishes the list and the remaining recruitment points on the module.

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

// Offer Synced Units and Vehicles: off by default, when synced objects are only recruitment points
private _rawT = _logic getVariable ["syncedTemplates", "false"];
private _synced = if (_rawT isEqualType "") then { toLower _rawT == "true" } else { _rawT isEqualTo true };

// The synced men and vehicles become the offer, each kept as it was placed: a man as [class, name,
// loadout, rank, skill], a vehicle as [class, name, textures]. Done on the server, which removes the
// placed ones and publishes the offer and the remaining recruitment points on the module, because a
// player's machine can't see a deleted object through synchronizedObjects; a late joiner reads the
// module's variables. The profile system leaves these alone (fnc_createProfilesFromUnits), whichever
// module starts first.
if (isServer && {_synced}) then {
    private _playable = playableUnits + switchableUnits;
    // with Max Vehicles below 1 no vehicle is offered, so a synced vehicle stays a recruitment point
    private _maxV = _logic getVariable ["maxVehicles", 2];
    if (_maxV isEqualType "") then { _maxV = parseNumber _maxV };
    if !(_maxV isEqualType 0) then { _maxV = 2 };
    private _men = [];
    private _vehs = [];
    private _points = [];
    {
        switch (true) do {
            case (_x isKindOf "Logic"): {};
            case (_x isKindOf "CAManBase"): {
                if (alive _x && {!isPlayer _x} && {!(_x in _playable)}) then { _men pushBack _x };
            };
            case (_x isKindOf "LandVehicle" || {_x isKindOf "Air"} || {_x isKindOf "Ship"}): {
                // one with a player's slot aboard stays where it is
                if (alive _x && {((crew _x) findIf { isPlayer _x || {_x in _playable} }) < 0}) then {
                    if (_maxV < 1) then { _points pushBack _x } else { _vehs pushBack _x };
                };
            };
            default { _points pushBack _x };
        };
    } forEach (synchronizedObjects _logic);
    // the man's Eden Description (less any "@group" the lobby adds), or the class's name; numbered
    // where two would read the same
    private _fnc_number = {
        private _base = _this apply { _x select 1 };
        private _seen = createHashMap;
        {
            private _b = _x select 1;
            if (({ _x == _b } count _base) > 1) then {
                private _n = (_seen getOrDefault [_b, 0]) + 1;
                _seen set [_b, _n];
                _x set [1, format ["%1 %2", _b, _n]];
            };
        } forEach _this;
        _this
    };
    private _menT = (_men apply {
        private _desc = ((roleDescription _x) splitString "@") param [0, ""];
        if (_desc == "") then { _desc = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName") };
        [typeOf _x, _desc, getUnitLoadout _x, rank _x, skill _x]
    }) call _fnc_number;
    private _vehT = (_vehs apply {
        [typeOf _x, getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName"), getObjectTextures _x]
    }) call _fnc_number;
    // Removed as the Faction Compiler removes its templates; a group mate who wasn't synced stays
    private _groups = [];
    {
        { if (!isPlayer _x && {!(_x in _playable)}) then { _groups pushBackUnique group _x; deleteVehicle _x } } forEach crew _x;
        deleteVehicle _x;
    } forEach _vehs;
    { _groups pushBackUnique group _x; deleteVehicle _x } forEach _men;
    // a deleted man leaves his group at the end of the frame, so the emptied groups go a moment later
    [_groups] spawn {
        params ["_groups"];
        sleep 1;
        { if (!isNull _x && {(units _x) isEqualTo []}) then { _x call ALiVE_fnc_DeleteGroupRemote } } forEach _groups;
    };
    _logic setVariable ["ALiVE_recruitPoints", _points, true];
    _logic setVariable ["ALiVE_recruitTemplates", [_menT, _vehT], true];
    ["ALiVE Recruitment: offering %1 synced men and %2 synced vehicles (%3) at %4 recruitment points", count _menT, count _vehT, _vehT apply { _x select 0 }, count _points] call ALiVE_fnc_dump;
};

// Gives a recruit the loadout, rank and skill of the synced man he copies, or a vehicle the paint of
// the synced vehicle it copies. Made before the player's-machine check below, so a server can use it.
ALiVE_fnc_recruitApplyTemplate = {
    params ["_thing", "_template"];
    if (_template isEqualTo [] || {isNull _thing}) exitWith {};
    if (_thing isKindOf "CAManBase") then {
        _template params ["", "", ["_loadout", []], ["_rank", ""], ["_skill", -1]];
        if (_loadout isNotEqualTo []) then { _thing setUnitLoadout _loadout };
        if (_rank != "") then { _thing setRank _rank };
        if (_skill >= 0) then { _thing setSkill _skill };
    } else {
        { if (_x != "") then { _thing setObjectTextureGlobal [_forEachIndex, _x] } } forEach (_template param [2, []]);
    };
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
// player's faction that the editor would offer. _noFallback: the module's own or none (the synced
// men are the offer then, not the faction's roster).
ALiVE_fnc_recruitClasses = {
    params ["_logic", ["_noFallback", false]];
    private _raw = _logic getVariable ["unitClasses", ""];
    private _classes = if (_raw isEqualType "") then { (_raw splitString ", ") select { _x != "" } } else { [] };
    _classes = _classes select { isClass (configFile >> "CfgVehicles" >> _x) && {getNumber (configFile >> "CfgVehicles" >> _x >> "scope") >= 1} };
    if (_classes isEqualTo [] && {!_noFallback}) then {
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
    // out of the Player Logistics save too, or the next load would bring it back
    private _logisticsId = _thing getVariable ["ALiVE_sys_logistics_ID", ""];
    if (_isVehicle && {_logisticsId != ""} && {!isNil "ALiVE_SYS_LOGISTICS"}) then {
        [ALiVE_SYS_LOGISTICS, "removeObject", [_logisticsId]] call ALIVE_fnc_logistics;
    };
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
    params ["_thing", "_cost", "_isVehicle", ["_near", []]];
    // once per machine: the after-a-load pass can reach a vehicle while the buy is still finishing it
    if (_thing getVariable ["ALiVE_recruitDismissHere", false]) exitWith {};
    _thing setVariable ["ALiVE_recruitCost", _cost];
    // the recruitment objects the player has to be near to dismiss it; none, anywhere
    _thing setVariable ["ALiVE_recruitDismissAt", _near];
    // this machine has the action, so the after-a-load pass below doesn't add a second one
    _thing setVariable ["ALiVE_recruitDismissHere", true];
    private _name = getText (configFile >> "CfgVehicles" >> typeOf _thing >> "displayName");
    [
        _thing,
        format [localize "STR_ALIVE_RECRUIT_UI_DISMISS", _name],
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_takeOff1_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_takeOff1_ca.paa",
        "alive _target && {_this isEqualTo player} && {_this distance _target < 6} && {(_target getVariable ['ALiVE_recruitedBy', _target getVariable ['ALiVE_recruitedVehicleBy', '']]) isEqualTo getPlayerUID _this} && {_target isKindOf 'CAManBase' || {((crew _target) findIf { isPlayer _x }) < 0}} && {(_target getVariable ['ALiVE_recruitDismissAt', []]) isEqualTo [] || {((_target getVariable ['ALiVE_recruitDismissAt', []]) findIf { _this distance _x < 50 }) > -1}}",
        "alive _target",
        {}, {},
        { [_this select 0] call ALiVE_fnc_recruitDismiss },
        {},
        [], 2, 0.4, false, false
    ] call BIS_fnc_holdActionAdd;
};

// _template: one of the synced men the module offers (index 14 of the settings), [] for a class
ALiVE_fnc_recruitUnit = {
    params ["_object", "_class", "_settings", ["_template", []]];
    _settings params ["", "", "", "_max", "_skill", "", "", "", "_code"];
    private _group = group player;
    private _size = { alive _x } count units _group;
    if (_size >= _max) exitWith { [localize "STR_ALIVE_RECRUIT", format [localize "STR_ALIVE_RECRUIT_UI_GROUP_FULL", _max]] call ALIVE_fnc_sendHint; false };
    if (time < (player getVariable ["ALiVE_recruitNext", 0])) exitWith { [localize "STR_ALIVE_RECRUIT", localize "STR_ALIVE_RECRUIT_UI_WAIT"] call ALIVE_fnc_sendHint; false };
    player setVariable ["ALiVE_recruitNext", time + 3];
    private _cost = (_settings param [16, createHashMap]) getOrDefault [toLower _class, _settings param [10, 0]];
    if !([_cost] call ALiVE_fnc_recruitPay) exitWith { false };
    ([_object, _settings, false, _class] call ALiVE_fnc_recruitSpawnPos) params ["_pos", "_dir", "_exact"];
    private _unit = _group createUnit [_class, ASLToAGL _pos, [], [2, 0] select _exact, "NONE"];
    if (isNull _unit) exitWith {
        if (_cost > 0) then { [-_cost] call ALiVE_fnc_recruitAsk };
        [localize "STR_ALIVE_RECRUIT", localize "STR_ALIVE_RECRUIT_UI_NOBODY"] call ALIVE_fnc_sendHint; false
    };
    if (_exact) then { _unit setPosASL _pos };
    _unit setDir _dir;
    // the synced man's own kit, rank and skill; the module's Skill, when set, still has the last word
    [_unit, _template] call ALiVE_fnc_recruitApplyTemplate;
    [_unit] joinSilent _group;
    _unit setVariable ["ALiVE_recruited", true, true];
    // whose recruit he is, so a player save keeps only that player's own
    _unit setVariable ["ALiVE_recruitedBy", getPlayerUID player, true];
    if (_skill > 0) then { _unit setSkill _skill };
    // the module's code, kept with him so a player save that brings him back runs it again
    _unit setVariable ["ALiVE_recruitCode", _settings param [9, ""], true];
    // what he cost, kept with him so a player save keeps the refund
    _unit setVariable ["ALiVE_recruitCost", _cost, true];
    _unit call _code;
    if (_settings param [12, true]) then { [_unit, _cost, false, _settings param [13, []]] call ALiVE_fnc_recruitDismissAction };
    [localize "STR_ALIVE_RECRUIT", format [localize "STR_ALIVE_RECRUIT_UI_JOINED", _template param [1, getText (configFile >> "CfgVehicles" >> _class >> "displayName")], _size + 1, _max]] call ALIVE_fnc_sendHint;
    true
};

// This player's recruited vehicles that still run
ALiVE_fnc_recruitVehiclesOwned = {
    vehicles select { alive _x && {(_x getVariable ["ALiVE_recruitedVehicleBy", ""]) == getPlayerUID player} }
};

// _template: one of the synced vehicles the module offers (index 15 of the settings), [] for a class
ALiVE_fnc_recruitVehicle = {
    params ["_object", "_class", "_settings", ["_template", []]];
    _settings params ["", "", "", "", "", "_maxVeh", "", "", "_code"];
    private _have = count (call ALiVE_fnc_recruitVehiclesOwned);
    if (_have >= _maxVeh) exitWith { [localize "STR_ALIVE_RECRUIT", format [localize "STR_ALIVE_RECRUIT_UI_VEH_FULL", _have, _maxVeh]] call ALIVE_fnc_sendHint; false };
    if (time < (player getVariable ["ALiVE_recruitNext", 0])) exitWith { [localize "STR_ALIVE_RECRUIT", localize "STR_ALIVE_RECRUIT_UI_WAIT"] call ALIVE_fnc_sendHint; false };
    ([_object, _settings, true, _class] call ALiVE_fnc_recruitSpawnPos) params ["_pos", "_dir", "_exact"];
    if (_pos isEqualTo []) exitWith { [localize "STR_ALIVE_RECRUIT", localize "STR_ALIVE_RECRUIT_UI_SPAWN_TAKEN"] call ALIVE_fnc_sendHint; false };
    player setVariable ["ALiVE_recruitNext", time + 5];
    private _cost = (_settings param [16, createHashMap]) getOrDefault [toLower _class, _settings param [11, 0]];
    if !([_cost] call ALiVE_fnc_recruitPay) exitWith { false };
    private _veh = createVehicle [_class, [0, 0, 1000 + random 500], [], 0, "CAN_COLLIDE"];
    if (isNull _veh) exitWith {
        if (_cost > 0) then { [-_cost] call ALiVE_fnc_recruitAsk };
        [localize "STR_ALIVE_RECRUIT", localize "STR_ALIVE_RECRUIT_UI_VEH_NONE"] call ALIVE_fnc_sendHint; false
    };
    _veh setDir _dir;
    _veh setPosASL _pos;
    _veh setVelocity [0, 0, 0];
    // the synced vehicle's own paint
    [_veh, _template] call ALiVE_fnc_recruitApplyTemplate;
    _veh setVariable ["ALiVE_recruitedVehicleBy", getPlayerUID player, true];
    // a player's own, so a Zeus virtualise doesn't hand it to an AI commander
    _veh setVariable ["ALIVE_profileIgnore", true, true];
    _veh setVariable ["ALiVE_recruitCost", _cost, true];
    // Player Logistics saves only what it has been handed, and a bought vehicle never was, so it was
    // lost on load (A. Ares, 16 Oct). Handed over a moment later, once its owner has reached the
    // server, so the save keeps who bought it and what it cost.
    if (!isNil "ALiVE_SYS_LOGISTICS") then {
        // a save record of its own: Player Logistics names a record by class and position, and every
        // vehicle bought at one spot stands on the same spot, so a second one took over the first's
        _veh setVariable ["ALiVE_sys_logistics_ID", format ["%1_recruit_%2_%3", typeOf _veh, getPlayerUID player, round (diag_tickTime * 1000)], true];
        // destroyed, it leaves the save: the hooks that record a wreck run on the server, and a vehicle
        // bought here belongs to the buyer's machine, so one blown up empty came back whole on load
        _veh addMPEventHandler ["MPKilled", {
            if (isServer && {!isNil "ALiVE_SYS_LOGISTICS"}) then {
                private _id = (_this select 0) getVariable ["ALiVE_sys_logistics_ID", ""];
                if (_id != "") then { [ALiVE_SYS_LOGISTICS, "removeObject", [_id]] call ALIVE_fnc_logistics };
            };
        }];
        _veh spawn {
            sleep 2;
            if (isNull _this || {!alive _this}) exitWith {};
            [[ALiVE_SYS_LOGISTICS, "setEH", [_this]], "ALIVE_fnc_logistics", false, false] call BIS_fnc_MP;
            [ALiVE_SYS_LOGISTICS, "updateObject", [_this]] call ALIVE_fnc_logistics;
        };
    };
    _veh call _code;
    if (_settings param [12, true]) then { [_veh, _cost, true, _settings param [13, []]] call ALiVE_fnc_recruitDismissAction };
    [localize "STR_ALIVE_RECRUIT", format [localize "STR_ALIVE_RECRUIT_UI_VEH_READY", _template param [1, getText (configFile >> "CfgVehicles" >> _class >> "displayName")], _have + 1, _maxVeh]] call ALIVE_fnc_sendHint;
    true
};

[_logic, _synced] spawn {
    params ["_logic", "_synced"];
    waitUntil { sleep 1; !isNull player };
    // the synced men and vehicles, as the server noted them; a player's machine can start before the
    // server has published them
    private _menT = [];
    private _vehT = [];
    if (_synced) then {
        private _t = diag_tickTime;
        waitUntil { sleep 0.5; (!isNil { _logic getVariable "ALiVE_recruitTemplates" } && {!isNil { _logic getVariable "ALiVE_recruitPoints" }}) || {diag_tickTime - _t > 60} };
        if (isNil { _logic getVariable "ALiVE_recruitTemplates" }) then {
            ["ALiVE Recruitment: the server's list of synced units and vehicles did not arrive within 60 s, offering the class lists only"] call ALiVE_fnc_dump;
        };
        (_logic getVariable ["ALiVE_recruitTemplates", [[], []]]) params [["_m", []], ["_v", []]];
        _menT = _m;
        _vehT = _v;
    };
    private _num = { params ["_v", "_d"]; if (_v isEqualType "") then { _v = parseNumber _v }; if (_v isEqualType 0) then { _v } else { _d } };
    private _max = [_logic getVariable ["maxGroupSize", 8], 8] call _num;
    if (_max < 1) then { _max = 8 };
    private _skill = [_logic getVariable ["recruitSkill", 0], 0] call _num;
    private _maxVeh = [_logic getVariable ["maxVehicles", 2], 2] call _num;
    private _height = [_logic getVariable ["spawnHeight", 0], 0] call _num;
    private _classes = [_logic, _synced] call ALiVE_fnc_recruitClasses;
    private _rawV = _logic getVariable ["vehicleClasses", ""];
    private _vehicles = if (_rawV isEqualType "") then { (_rawV splitString ", ") select { _x != "" && {isClass (configFile >> "CfgVehicles" >> _x)} && {getNumber (configFile >> "CfgVehicles" >> _x >> "scope") >= 1} } } else { [] };
    if (_maxVeh < 1) then { _vehicles = []; _vehT = [] };
    private _rawP = _logic getVariable ["spawnPoints", ""];
    private _points = if (_rawP isEqualType "") then { (_rawP splitString ", ") select { _x != "" } } else { [] };
    private _rawC = _logic getVariable ["recruitCode", ""];
    private _code = if (_rawC isEqualType "" && {_rawC != ""}) then { compile _rawC } else { {} };
    private _window = (_logic getVariable ["recruitInterface", "window"]) != "actions";
    // what one soldier and one vehicle cost from the force pool; 0 is free
    private _unitCost = ([_logic getVariable ["unitCost", 0], 0] call _num) max 0;
    private _vehicleCost = ([_logic getVariable ["vehicleCost", 0], 0] call _num) max 0;
    // a cost per class name in place of those two (A. Ares on Discord, 24 Oct): "class=cost, class=cost"
    // or [["class", cost], ...]; settings index 16, lower-case class -> cost
    private _costs = createHashMap;
    private _rawO = _logic getVariable ["costOverrides", ""];
    if (_rawO isEqualType "" && {trim _rawO != ""}) then {
        private _pairs = if ((trim _rawO) select [0, 1] == "[") then { parseSimpleArray _rawO } else { (_rawO splitString ",;") apply { (trim _x) splitString "= " } };
        // an array with a slip in it (a class name without its quotes) doesn't read at all
        if (isNil "_pairs" || {!(_pairs isEqualType [])} || {_pairs isEqualTo [] && {(trim _rawO) select [0, 1] == "["}}) then {
            ["ALiVE Recruitment: Force Pool Cost per Class could not be read, write it as ClassName=cost, ClassName=cost: %1", _rawO] call ALiVE_fnc_dump;
            _pairs = [];
        };
        {
            private _ok = false;
            if (_x isEqualType [] && {count _x == 2}) then {
                _x params ["_c", "_n"];
                // a typo ("3O") would read as 0 and make the class free, so only a number counts
                if (_n isEqualType "") then { _n = if ((trim _n) regexMatch "\d+(\.\d+)?") then { parseNumber _n } else { "" } };
                if (_c isEqualType "" && {trim _c != ""} && {_n isEqualType 0}) then { _costs set [toLower (trim _c), _n max 0]; _ok = true };
            };
            if (!_ok) then { ["ALiVE Recruitment: Force Pool Cost per Class entry %1 skipped, write it as ClassName=cost", _x] call ALiVE_fnc_dump };
        } forEach _pairs;
    };
    // players can dismiss their own recruits and recruited vehicles (#1078): anywhere, only at the
    // recruitment point (within 50 m of one of this module's objects, so a squad can't be cashed in
    // mid-field; A. Ares on Discord, 16 Oct), or not at all
    private _rawD = _logic getVariable ["allowDismiss", true];
    private _dismissAt = if (_rawD isEqualType "") then { toLower _rawD } else { ["false", "true"] select (_rawD isNotEqualTo false) };
    private _dismiss = _dismissAt != "false";
    private _settings = [_logic, _classes, _vehicles, _max, _skill, _maxVeh, _points, _height, _code, ["", _rawC] select (_rawC isEqualType "" && {_rawC != ""}), _unitCost, _vehicleCost, _dismiss];
    // the recruitment objects; with the synced men and vehicles on offer, the ones the server left
    private _objects = if (_synced) then {
        (_logic getVariable ["ALiVE_recruitPoints", []]) select { !isNull _x }
    } else {
        (synchronizedObjects _logic) select { !(_x isKindOf "Logic") }
    };
    // where the Dismiss hold action works: anywhere (empty), or near these objects only
    _settings pushBack ([[], _objects] select (_dismissAt == "base"));
    // 14 and 15: the synced men and vehicles on offer, each as the server noted it
    _settings pushBack _menT;
    _settings pushBack _vehT;
    // 16: the costs per class
    _settings pushBack _costs;
    if (_objects isEqualTo [] || {(_classes + _vehicles + _menT + _vehT) isEqualTo []}) exitWith {
        ["ALiVE Recruitment: nothing to do (%1 synced objects, %2 unit classes, %3 vehicle classes, %4 synced men, %5 synced vehicles)", count _objects, count _classes, count _vehicles, count _menT, count _vehT] call ALiVE_fnc_dump;
    };
    {
        private _object = _x;
        if (_window) then {
            _object addAction [(localize "STR_ALIVE_RECRUIT") call ALiVE_fnc_actionTitle, { ["open", _this select 3] call ALiVE_fnc_recruitWindow },
                [_object, _settings], 1.5, true, true, "", "alive _target && {vehicle _this isEqualTo _this}", 5];
        } else {
            {
                _object addAction [
                    (format [localize "STR_ALIVE_RECRUIT_UI_ACTION_RECRUIT", getText (configFile >> "CfgVehicles" >> _x >> "displayName")]) call ALiVE_fnc_actionTitle,
                    { (_this select 3) call ALiVE_fnc_recruitUnit },
                    [_object, _x, _settings], 1.5, false, true, "", "alive _target && {vehicle _this isEqualTo _this}", 5
                ];
            } forEach _classes;
            {
                _object addAction [
                    (format [localize "STR_ALIVE_RECRUIT_UI_ACTION_TAKE", getText (configFile >> "CfgVehicles" >> _x >> "displayName")]) call ALiVE_fnc_actionTitle,
                    { (_this select 3) call ALiVE_fnc_recruitVehicle },
                    [_object, _x, _settings], 1.4, false, true, "", "alive _target && {vehicle _this isEqualTo _this}", 5
                ];
            } forEach _vehicles;
            {
                _object addAction [
                    (format [localize "STR_ALIVE_RECRUIT_UI_ACTION_RECRUIT", _x select 1]) call ALiVE_fnc_actionTitle,
                    { (_this select 3) call ALiVE_fnc_recruitUnit },
                    [_object, _x select 0, _settings, _x], 1.5, false, true, "", "alive _target && {vehicle _this isEqualTo _this}", 5
                ];
            } forEach _menT;
            {
                _object addAction [
                    (format [localize "STR_ALIVE_RECRUIT_UI_ACTION_TAKE", _x select 1]) call ALiVE_fnc_actionTitle,
                    { (_this select 3) call ALiVE_fnc_recruitVehicle },
                    [_object, _x select 0, _settings, _x], 1.4, false, true, "", "alive _target && {vehicle _this isEqualTo _this}", 5
                ];
            } forEach _vehT;
        };
    } forEach _objects;
    // Soldiers and vehicles this player recruited before a save come back (the player save, Player
    // Logistics) without their Dismiss action, which lives on the recruiter's machine; give it back.
    // Only classes this module offers, so a mission with two recruitment points gives each one back
    // its own point's Dismiss rule.
    if (_dismiss) then {
        [_settings param [13, []], (_classes + _vehicles + ((_menT + _vehT) apply { _x select 0 })) apply { toLower _x }] spawn {
            params ["_near", "_offered"];
            private _uid = getPlayerUID player;
            while {true} do {
                private _mine = (call ALiVE_fnc_recruitVehiclesOwned)
                    + ((units group player) select { alive _x && {!isPlayer _x} && {(_x getVariable ["ALiVE_recruitedBy", ""]) == _uid} });
                {
                    if (!(_x getVariable ["ALiVE_recruitDismissHere", false]) && {(toLower typeOf _x) in _offered}) then {
                        private _paid = _x getVariable ["ALiVE_recruitCost", 0];
                        if (_paid isEqualType "") then { _paid = parseNumber _paid };
                        if !(_paid isEqualType 0) then { _paid = 0 };
                        [_x, _paid, !(_x isKindOf "CAManBase"), _near] call ALiVE_fnc_recruitDismissAction;
                    };
                } forEach _mine;
                sleep 10;
            };
        };
    };
    _logic setVariable ["ALiVE_recruitReady", [count _objects, _classes, _vehicles, count _menT, count _vehT], false];
};
