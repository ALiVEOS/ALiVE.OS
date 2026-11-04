/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_siteClock

Description:
The one clock every player site that goes down shares (a FOB, a Logistics hub, a rally point), and
what players see of it. The server keeps a list of down sites, each with when it comes back (or, for
a FOB, when it is lost), and calls the site's own code when that time is reached. Starting a site's
clock again calls off the earlier wait; a FOB's repair count can stand still (an engineer at work).
The list goes to every machine, and each player's map shows his own side's down sites with the time
left. The down, back and lost notifications are worded here too, the same for every kind of site,
and the one test of who holds a site's ground that a site taken by the enemy uses.

Times are serverTime in multiplayer and time in single player, as every machine can read them.

Parameters:
    ["newKey", [prefix]]                         - a key no other site has: prefix and a number (STRING)
    ["start", [key, seconds, function, call, info]] - server: the site is down. In seconds the server
                                                   runs call (an array, e.g. ["hubRestore", [id]]) with
                                                   the function named; info is [side ("WEST".., "ANY"),
                                                   position, label, "back" or "repair"] for the map
    ["cancel", [key]]                            - server: the site is back or gone; no call is made
    ["sync", [key, paused, side, label]]         - server: stand still or run on, and a new side or name
                                                   (a FOB taken while down). Seconds left, -1 for none
    ["left", [key]]                              - server: seconds left, -1 for no clock (NUMBER)
    ["advance", [key, seconds]]                  - server: as if that much time had passed (for tests)
    ["notify", [what, to, label, minutes]]       - server: tell players. what: "down" (back in minutes),
                                                   "repair" (repair within minutes), "lost", "back" or
                                                   "taken" (by the side told).
                                                   to: a side ("WEST".., "ANY" for everyone) or units
    ["draw", []]                                 - a player's machine: the map markers for down sites
    ["holder", [position, side, radius]]         - server: the enemy side holding the ground there: the one
                                                   with most men within radius, soldiers or ALiVE groups not
                                                   spawned, while none of the side's own are. "" for none (STRING)

Examples:
(begin example)
["start", ["hub:" + _netId, 600, "ALIVE_fnc_hub", ["hubRestore", [_netId]], ["WEST", _pos, "Depot", "back"]]] call ALiVE_fnc_siteClock;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]], ["_args", []]];
if (isRemoteExecuted) exitWith { nil };
private _result = nil;
private _now = { [time, serverTime] select isMultiplayer };

// what players are sent: [key, side, position, label, mode, at (-1 while it stands still), seconds left then]
private _publish = {
    ALiVE_siteDown = values ALiVE_siteClock apply { _x select 3 };
    publicVariable "ALiVE_siteDown";
    if (hasInterface) then { ["draw"] call ALiVE_fnc_siteClock };
};

switch (_op) do {
    case "newKey": {
        _args params [["_prefix", "site", [""]]];
        ALiVE_siteClockN = (missionNamespace getVariable ["ALiVE_siteClockN", 0]) + 1;
        _result = format ["%1:%2", _prefix, ALiVE_siteClockN];
    };

    case "start": {
        if (!isServer) exitWith {};
        _args params [["_key", "", [""]], ["_wait", 0, [0]], ["_fn", "", [""]], ["_call", [], [[]]], ["_info", [], [[]]]];
        if (_key == "") exitWith {};
        _info params [["_side", "ANY", [""]], ["_pos", [0, 0, 0], [[]]], ["_label", "", [""]], ["_mode", "back", [""]]];
        if (isNil "ALiVE_siteClock") then { ALiVE_siteClock = createHashMap };
        private _at = (call _now) + (_wait max 0);
        // an earlier wait under the same key is called off by being replaced
        ALiVE_siteClock set [_key, [_at, _fn, _call, [_key, _side, _pos, _label, _mode, _at, _wait max 0]]];
        call _publish;
        // one watch for every site, started the first time one goes down
        if (isNil "ALiVE_siteClockWatch" || {scriptDone ALiVE_siteClockWatch}) then {
            ALiVE_siteClockWatch = [] spawn {
                while { true } do {
                    sleep 1;
                    private _t = [time, serverTime] select isMultiplayer;
                    private _due = [];
                    isNil {
                        { if ((_y select 0) >= 0 && {(_y select 0) <= _t}) then { _due pushBack [_x, _y] } } forEach ALiVE_siteClock;
                        { ALiVE_siteClock deleteAt (_x select 0) } forEach _due;
                    };
                    if (_due isNotEqualTo []) then {
                        ALiVE_siteDown = values ALiVE_siteClock apply { _x select 3 };
                        publicVariable "ALiVE_siteDown";
                        if (hasInterface) then { ["draw"] call ALiVE_fnc_siteClock };
                        {
                            (_x select 1) params ["", "_fn", "_call"];
                            private _code = missionNamespace getVariable [_fn, {}];
                            // each in its own script, so one that waits holds up no other
                            [_code, _call] spawn { params ["_code", "_call"]; _call call _code };
                        } forEach _due;
                    };
                };
            };
        };
        _result = _key;
    };

    case "cancel": {
        if (!isServer || {isNil "ALiVE_siteClock"}) exitWith {};
        _args params [["_key", "", [""]]];
        if (_key in ALiVE_siteClock) then {
            ALiVE_siteClock deleteAt _key;
            call _publish;
        };
    };

    case "sync": {
        _result = -1;
        if (!isServer || {isNil "ALiVE_siteClock"}) exitWith {};
        _args params [["_key", "", [""]], ["_paused", false, [false]], ["_side", "", [""]], ["_label", "", [""]]];
        private _e = ALiVE_siteClock get _key;
        if (isNil "_e") exitWith {};
        private _shown = _e select 3;
        private _t = call _now;
        private _left = if ((_e select 0) < 0) then { _shown select 6 } else { ((_e select 0) - _t) max 0 };
        private _was = +_shown;
        if (_paused) then {
            _e set [0, -1];
            _shown set [5, -1];
            _shown set [6, _left];
        } else {
            if ((_e select 0) < 0) then {
                _e set [0, _t + _left];
                _shown set [5, _t + _left];
                _shown set [6, _left];
            };
        };
        if (_side != "") then { _shown set [1, _side] };
        if (_label != "") then { _shown set [3, _label] };
        if (_shown isNotEqualTo _was) then { call _publish };
        _result = _left;
    };

    case "left": {
        _result = -1;
        if (isNil "ALiVE_siteClock") exitWith {};
        _args params [["_key", "", [""]]];
        private _e = ALiVE_siteClock get _key;
        if (isNil "_e") exitWith {};
        _result = if ((_e select 0) < 0) then { (_e select 3) select 6 } else { ((_e select 0) - (call _now)) max 0 };
    };

    case "advance": {
        if (!isServer || {isNil "ALiVE_siteClock"}) exitWith {};
        _args params [["_key", "", [""]], ["_s", 0, [0]]];
        private _e = ALiVE_siteClock get _key;
        if (isNil "_e") exitWith {};
        private _shown = _e select 3;
        if ((_e select 0) < 0) then {
            _shown set [6, ((_shown select 6) - _s) max 0];
        } else {
            _e set [0, (_e select 0) - _s];
            _shown set [5, _e select 0];
        };
        call _publish;
    };

    case "notify": {
        if (!isServer) exitWith {};
        _args params [["_what", "", [""]], ["_to", "ANY", ["", []]], ["_label", "", [""]], ["_min", 0, [0]]];
        private _key = switch (_what) do {
            case "down": { "STR_ALIVE_SITE_DOWN_BACK" };
            case "repair": { "STR_ALIVE_SITE_DOWN_REPAIR" };
            case "lost": { "STR_ALIVE_SITE_LOST" };
            case "back": { "STR_ALIVE_SITE_BACK" };
            case "taken": { "STR_ALIVE_SITE_TAKEN" };
            default { "" };
        };
        if (_key == "") exitWith {};
        private _msg = format [localize _key, _label, (ceil _min) max 1];
        private _target = if (_to isEqualType []) then { _to select { isPlayer _x } } else {
            if (_to == "ANY") then { 0 } else { [_to] call ALIVE_fnc_sideTextToObject }
        };
        if (_target isEqualTo []) exitWith {};
        ["ALiVE", _msg] remoteExec ["ALIVE_fnc_sendHint", _target];
        // a notice to a side is kept in that side's Radio Log by the server itself, so it is there for a player who
        // joins later even if nobody on the side was on; one to a group's units stays with them
        private _heard = ["side", ""] select (_to isEqualType []);
        ["HQ", _msg, _heard] remoteExec ["ALIVE_fnc_radioLog", _target];
        if (_heard == "side") then {
            { ["record", [_x, "HQ", _msg]] call ALIVE_fnc_radioLogStore } forEach ([[_to], ["WEST", "EAST", "GUER"]] select (_to == "ANY"));
        };
    };

    case "holder": {
        _result = "";
        if (!isServer) exitWith {};
        _args params [["_pos", [0, 0, 0], [[]]], ["_side", "", [""]], ["_r", 60, [0]]];
        if !(_side in ["WEST", "EAST", "GUER"]) exitWith {};
        private _own = [_side] call ALIVE_fnc_sideTextToObject;
        private _men = createHashMap;
        private _held = false;
        {
            private _crew = if (_x isKindOf "CAManBase") then { [_x] } else { crew _x };
            {
                if (alive _x) then {
                    private _s = side group _x;
                    // a player on the civilian side counts for his faction's side, as the hubs count him
                    if (_s == civilian) then { _s = (faction _x) call ALiVE_fnc_factionSide };
                    if (_s == _own) then { _held = true };
                    if (_s in [west, east, independent] && {[_own, _s] call BIS_fnc_sideIsEnemy}) then { _men set [str _s, (_men getOrDefault [str _s, 0]) + 1] };
                };
            } forEach _crew;
            if (_held) exitWith {};
        } forEach (_pos nearEntities [["CAManBase", "LandVehicle", "StaticWeapon", "Air", "Ship"], _r]);
        if (_held) exitWith {};
        // ALiVE's groups not spawned: a spawned one's men were counted above
        if (!isNil "ALiVE_profileSystem") then {
            {
                private _s = _x;
                private _n = { !([_x, "active", false] call ALIVE_fnc_hashGet) } count ([_pos, _r, [_s, "entity"], true] call ALIVE_fnc_getNearProfiles);
                if (_n > 0) then {
                    if (_s == _side) then { _held = true } else {
                        if ([_own, [_s] call ALIVE_fnc_sideTextToObject] call BIS_fnc_sideIsEnemy) then { _men set [_s, (_men getOrDefault [_s, 0]) + _n] };
                    };
                };
            } forEach ["WEST", "EAST", "GUER"];
        };
        if (_held) exitWith {};
        private _most = 0;
        { if (_y > _most) then { _most = _y; _result = _x } } forEach _men;
    };

    case "draw": {
        if (!hasInterface) exitWith {};
        if (isNull player) exitWith {
            if (isNil "ALiVE_siteDownWait") then {
                ALiVE_siteDownWait = [] spawn { waitUntil { sleep 1; !isNull player }; ALiVE_siteDownWait = nil; ["draw"] call ALiVE_fnc_siteClock };
            };
        };
        private _side = str (side group player);
        private _t = call _now;
        private _rows = (missionNamespace getVariable ["ALiVE_siteDown", []]) select { (_x select 1) in ["ANY", _side] };
        private _want = _rows apply { "ALiVE_siteDown_" + (_x select 0) };
        private _pins = !isNil "ALiVE_mapPins_reg";
        {
            if !(_x in _want) then {
                if (_pins) then { ["release", [_x]] call ALiVE_fnc_mapPins };
                deleteMarkerLocal _x;
            };
        } forEach (missionNamespace getVariable ["ALiVE_siteDownMarkers", []]);
        {
            _x params ["_key", "", "_pos", "_label", "_mode", "_at", "_left"];
            private _m = "ALiVE_siteDown_" + _key;
            if (markerType _m == "") then {
                createMarkerLocal [_m, _pos];
                _m setMarkerTypeLocal "mil_warning";
                _m setMarkerColorLocal "ColorOrange";
            };
            _m setMarkerPosLocal _pos;
            private _min = (ceil (([_left, _at - _t] select (_at >= 0)) / 60)) max 1;
            private _text = format [localize (switch (true) do {
                case (_at < 0): { "STR_ALIVE_SITE_MARK_PAUSED" };
                case (_mode == "repair"): { "STR_ALIVE_SITE_MARK_REPAIR" };
                default { "STR_ALIVE_SITE_MARK_BACK" };
            }), _label, _min];
            _m setMarkerTextLocal _text;
            if (_pins) then { ["adopt", [_m, _text, 80, "ColorOrange", {}, [], ""]] call ALiVE_fnc_mapPins };
        } forEach _rows;
        ALiVE_siteDownMarkers = _want;
        // the minutes count down on the map while anything is down
        if (_rows isNotEqualTo [] && {isNil "ALiVE_siteDownTick"}) then {
            ALiVE_siteDownTick = [] spawn {
                while { (missionNamespace getVariable ["ALiVE_siteDown", []]) isNotEqualTo [] } do {
                    sleep 20;
                    ["draw"] call ALiVE_fnc_siteClock;
                };
                ALiVE_siteDownTick = nil;
            };
        };
        _result = count _want;
    };
};

if (isNil "_result") then { nil } else { _result }
