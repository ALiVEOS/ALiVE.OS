#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskManhunt);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskManhunt

Description:
HVT manhunt (Eric and A. Ares on Discord, 24 Oct). With HVT Manhunt Chance above 0 on the C2ISTAR module, that share
of HVT (Assassination) tasks start with the man hidden and a search area on the map in place of a target. Clues
narrow it: civilians telling players of enemies near it, intel read from his men, prisoners' and informants'
answers (all of them reach ALIVE_fnc_taskKnownEnemy "report" or ALIVE_fnc_OPCOMToggleInstallations). Three clues
raise a Wiretap task near his hideout; its success forecasts where he will be and when, for about ten minutes.
Missed, he moves 2 to 4 km and half of what was known goes with him. Six clues give the forecast without a
wiretap. Server side; the state is kept in the task's params.

Parameters:
    STRING - "start", "clue", "tick" or "end"
    ARRAY  - "start": [params, task ID, task side, enemy side text, search centre, description]
             "clue":  [side text or "", positions, enemy side text or "", reach in m]
             "tick":  [task (the Destroy stage), params, task player UIDs]
    STRING - "end": the task ID

Returns:
    Nothing

Author:
Jman
---------------------------------------------------------------------------- */

params [["_mode", "", [""]], ["_args", []]];

if (!isServer) exitWith {};

// root task ID -> [task side, enemy side, params]
if (isNil "ALiVE_c2istar_manhunts") then { ALiVE_c2istar_manhunts = createHashMap };

private _fnc_get = { params ["_p", "_k", "_d"]; [_p, _k, _d] call ALIVE_fnc_hashGet };
private _fnc_set = { params ["_p", "_k", "_v"]; [_p, _k, _v] call ALIVE_fnc_hashSet };

// the search area's radius for the clues gathered
private _fnc_radius = { [1500, 900, 500] select ((_this max 0) min 2) };

// a place's name, or its 1 km grid square when no named place is near
private _fnc_placeName = {
    private _n = [_this] call ALIVE_fnc_taskGetNearestLocationName;
    if (_n == "") then {
        private _g = mapGridPosition _this;
        private _h = floor ((count _g) / 2);
        _n = format ["grid %1%2", _g select [0, 2 min _h], _g select [_h, 2 min _h]];
    };
    _n
};

switch (_mode) do {

    case "start": {
        _args params ["_params", "_taskID", "_taskSide", "_enemySide", "_center", "_baseDesc"];
        {
            [_params, _x select 0, _x select 1] call _fnc_set;
        } forEach [
            ["Manhunt", true], ["ManhuntClues", 0], ["ManhuntPending", 0], ["ManhuntNeed", 3],
            ["ManhuntRadius", 1500], ["ManhuntCenter", +_center], ["ManhuntDrawn", false],
            ["ManhuntStage", "search"], ["ManhuntWiretapID", ""], ["ManhuntWiretapAt", 0],
            ["ManhuntWindow", []], ["ManhuntMeetPos", []], ["ManhuntMeetName", ""], ["ManhuntMoved", false],
            ["ManhuntExtended", false], ["ManhuntMoves", 0], ["ManhuntLastClueAt", -1e6], ["ManhuntBaseDesc", _baseDesc]
        ];
        ALiVE_c2istar_manhunts set [_taskID, [_taskSide, _enemySide, _params, time]];
        ["C2ISTAR - HVT manhunt %1 for %2: hideout at %3, search area centred on %4", _taskID, _taskSide,
            mapGridPosition ([_params, "HVTArea", [0,0,0]] call _fnc_get), mapGridPosition _center] call ALiVE_fnc_dump;
    };

    case "clue": {
        _args params [["_side", ""], ["_positions", []], ["_enemy", ""], ["_reach", 1500]];
        private _norm = { if (_this in ["RESISTANCE", "INDEPENDENT"]) then { "GUER" } else { _this } };
        _side = _side call _norm;
        _enemy = _enemy call _norm;
        _reach = (_reach max 1500) min 3000;
        _positions = _positions select { _x isEqualType [] && {count _x > 1} };
        if (_positions isEqualTo []) exitWith {};
        {
            private _id = _x;
            _y params ["_hSide", "_hEnemy", "_params"];
            private _stage = [_params, "ManhuntStage", ""] call _fnc_get;
            if (_stage in ["search", "wiretap"]
                && {_side == "" || {_side == _hSide}}
                && {_enemy == "" || {_enemy == _hEnemy}}) then {
                // near him, or anywhere inside the search area drawn on the map
                private _area = [_params, "HVTArea", [0,0,0]] call _fnc_get;
                private _c = [_params, "ManhuntCenter", _area] call _fnc_get;
                private _r = [_params, "ManhuntRadius", 1500] call _fnc_get;
                if ((_positions findIf { (_x distance2D _area) < _reach || {(_x distance2D _c) < _r} }) > -1) then {
                    [_params, "ManhuntPending", ([_params, "ManhuntPending", 0] call _fnc_get) + 1] call _fnc_set;
                };
            };
        } forEach ALiVE_c2istar_manhunts;
        // a task gone without its end being called (a manual removal) leaves its entry. Not one just started: its
        // task is registered only once the whole task set is built
        {
            private _t = [ALIVE_taskHandler, "getTask", _x] call ALIVE_fnc_taskHandler;
            if (isNil "_t" && {time - ((ALiVE_c2istar_manhunts get _x) param [3, 0]) > 300}) then { ALiVE_c2istar_manhunts deleteAt _x };
        } forEach (keys ALiVE_c2istar_manhunts);
    };

    case "end": {
        if (_args isEqualType "" && {_args in ALiVE_c2istar_manhunts}) then {
            // a Wiretap task raised for the hunt has no purpose left
            private _params = (ALiVE_c2istar_manhunts get _args) select 2;
            private _wt = [_params, "ManhuntWiretapID", ""] call _fnc_get;
            ALiVE_c2istar_manhunts deleteAt _args;
            if (_wt != "") then {
                [_params, "ManhuntWiretapID", ""] call _fnc_set;
                private _w = [ALIVE_taskHandler, "getTask", _wt] call ALIVE_fnc_taskHandler;
                if (!isNil "_w") then { [ALIVE_taskHandler, "TASK_DELETE", [_wt, _w select 1, _w select 2]] call ALIVE_fnc_taskHandler };
            };
            ["C2ISTAR - HVT manhunt %1 ended", _args] call ALiVE_fnc_dump;
        };
    };

    case "tick": {
        _args params ["_task", "_params", "_taskPlayers"];
        private _stageID = _task select 0;
        private _rootID = _task select 11;
        // dropped while the task was still being built: put back from the task itself
        if !(_rootID in ALiVE_c2istar_manhunts) then {
            private _es = ([_params, "enemyFaction", ""] call _fnc_get) call ALiVE_fnc_factionSide;
            ALiVE_c2istar_manhunts set [_rootID, [_task select 2, [[_es] call ALIVE_fnc_sideObjectToNumber] call ALIVE_fnc_sideNumberToText, _params, time]];
        };
        (ALiVE_c2istar_manhunts get _rootID) params ["_taskSide", "_enemySide"];
        private _stage = [_params, "ManhuntStage", "search"] call _fnc_get;
        if (_stage == "found") exitWith {};

        // found the usual way (a player within 200 m, or his side has seen him): the hunt is over, the task follows him
        if ([_params, "HVTFound", false] call _fnc_get) exitWith {
            [_taskPlayers, _stageID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            [_params, "ManhuntStage", "found"] call _fnc_set;
            ["C2ISTAR - HVT manhunt %1: he has been found", _rootID] call ALiVE_fnc_dump;
        };

        private _unit = [_params, "unit", [[], "", "", ""]] call _fnc_get;
        private _name = format ["%1 %2", _unit select 1, _unit select 2];
        private _sideObj = [_taskSide] call ALiVE_fnc_sideTextToObject;
        private _hq = switch (_sideObj) do { case west: {"BLU"}; case east: {"OPF"}; case resistance: {"IND"}; default {"HQ"} };
        private _fnc_radio = {
            [_taskSide, [objNull, _this, "side", _sideObj, false, false, false, true, _hq]] call ALIVE_fnc_radioBroadcastToSide;
        };
        private _fnc_update = {
            params ["_pos", "_extra"];
            // the task taken down while this tick ran (a player cancelling it): nothing to update
            private _still = [ALiVE_TaskHandler, "getTask", _stageID] call ALiVE_fnc_TaskHandler;
            if (isNil "_still") exitWith {};
            _task set [3, +_pos];
            _task set [6, ([_params, "ManhuntBaseDesc", ""] call _fnc_get) + "<br/><br/>" + _extra];
            [ALiVE_TaskHandler, "TASK_UPDATE", _task] call ALiVE_fnc_TaskHandler;
        };
        private _fnc_draw = {
            private _c = [_params, "ManhuntCenter", [0,0,0]] call _fnc_get;
            private _r = [_params, "ManhuntRadius", 1500] call _fnc_get;
            [_c, _enemySide, _taskPlayers, _stageID, "search", _r] call ALIVE_fnc_taskCreateMarkersForPlayers;
        };
        private _fnc_recentre = {
            private _r = (([_params, "ManhuntClues", 0] call _fnc_get) call _fnc_radius);
            private _area = [_params, "HVTArea", [0,0,0]] call _fnc_get;
            [_params, "ManhuntRadius", _r] call _fnc_set;
            [_params, "ManhuntCenter", _area getPos [random (_r - 200), random 360]] call _fnc_set;
            call _fnc_draw;
        };
        // move him: not made yet, he is made there (the Destroy stage spawns him at HVTArea); made and not on any
        // player's screen, his profiles are put there; on someone's screen he stays put. Returns whether he moved.
        private _fnc_moveTo = {
            params ["_to"];
            if !([_params, "HVTSpawned", false] call _fnc_get) exitWith { [_params, "HVTArea", +_to] call _fnc_set; true };
            private _profiles = ([_params, "entityProfileIDs", []] call _fnc_get) apply { [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler };
            _profiles = _profiles select { !isNil "_x" };
            if ((_profiles findIf { _x select 2 select 1 }) > -1) exitWith { false };
            {
                [_x, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                [_x, "setPosition", _to getPos [3 * _forEachIndex, random 360]] call ALIVE_fnc_profileEntity;
            } forEach _profiles;
            [_params, "HVTArea", +_to] call _fnc_set;
            true
        };
        private _fnc_forecast = {
            // a Wiretap task still open is no longer needed
            private _openWt = [_params, "ManhuntWiretapID", ""] call _fnc_get;
            if (_openWt != "") then {
                private _w = [ALIVE_taskHandler, "getTask", _openWt] call ALIVE_fnc_taskHandler;
                if (!isNil "_w") then { [ALIVE_taskHandler, "TASK_DELETE", [_openWt, _task select 1, _taskSide]] call ALIVE_fnc_taskHandler };
                [_params, "ManhuntWiretapID", ""] call _fnc_set;
            };
            private _area = [_params, "HVTArea", [0,0,0]] call _fnc_get;
            private _meet = [];
            private _places = (nearestLocations [_area, ["NameVillage", "NameCity", "NameCityCapital", "NameLocal"], 1500])
                select { (locationPosition _x distance2D _area) > 600 && {!surfaceIsWater locationPosition _x} };
            if (_places isNotEqualTo []) then { _meet = locationPosition (selectRandom _places) };
            for "_i" from 1 to 40 do {
                if (_meet isNotEqualTo []) exitWith {};
                private _c = _area getPos [600 + random 600, random 360];
                if (!surfaceIsWater _c && {(_c select 0) > 0} && {(_c select 1) > 0} && {(_c select 0) < worldSize} && {(_c select 1) < worldSize}) then { _meet = _c };
            };
            if (_meet isEqualTo []) then { _meet = +_area };
            _meet = [_meet, 150] call ALiVE_fnc_findFlatArea;
            _meet set [2, 0];
            private _start = time + 900 + random 600;
            [_params, "ManhuntWindow", [_start, _start + 600]] call _fnc_set;
            [_params, "ManhuntMeetPos", _meet] call _fnc_set;
            [_params, "ManhuntMeetName", _meet call _fnc_placeName] call _fnc_set;
            [_params, "ManhuntMoved", false] call _fnc_set;
            [_params, "ManhuntExtended", false] call _fnc_set;
            [_params, "ManhuntStage", "window"] call _fnc_set;
            // as the game clock shows them, with the mission's time acceleration
            private _at = [((daytime + (_start - time) * timeMultiplier / 3600) mod 24), "HH:MM"] call BIS_fnc_timeToString;
            private _to = [((daytime + (_start + 600 - time) * timeMultiplier / 3600) mod 24), "HH:MM"] call BIS_fnc_timeToString;
            private _place = _meet call _fnc_placeName;
            // the task points at the meeting, and the search area comes off the map
            [_taskPlayers, _stageID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            [_meet, format [localize "STR_ALIVE_C2ISTAR_MANHUNT_DESC_WINDOW", _name, _place, mapGridPosition _meet, _at, _to]] call _fnc_update;
            (format [localize "STR_ALIVE_C2ISTAR_MANHUNT_MSG_WINDOW", _name, _place, _at, _to]) call _fnc_radio;
            ["C2ISTAR - HVT manhunt %1: he is expected at %2 from %3 (in %4 s)", _rootID, mapGridPosition _meet, _at, round (_start - time)] call ALiVE_fnc_dump;
        };

        if !([_params, "ManhuntDrawn", false] call _fnc_get) then {
            call _fnc_draw;
            [_params, "ManhuntDrawn", true] call _fnc_set;
        };

        // a clue, at most one each two minutes: one conversation with a civilian can report the same place several times
        private _pending = [_params, "ManhuntPending", 0] call _fnc_get;
        if (_pending > 0 && {_stage in ["search", "wiretap"]} && {time - ([_params, "ManhuntLastClueAt", -1e6] call _fnc_get) >= 120}) then {
            private _clues = ([_params, "ManhuntClues", 0] call _fnc_get) + 1;
            [_params, "ManhuntClues", _clues] call _fnc_set;
            [_params, "ManhuntPending", 0] call _fnc_set;
            [_params, "ManhuntLastClueAt", time] call _fnc_set;
            // the area is redrawn only when it shrinks: a new circle at the same size each time would let players
            // narrow him down to where the circles overlap
            private _was = [_params, "ManhuntRadius", 1500] call _fnc_get;
            private _r = _clues call _fnc_radius;
            if (_r < _was) then {
                call _fnc_recentre;
                [[_params, "ManhuntCenter", [0,0,0]] call _fnc_get, format [localize "STR_ALIVE_C2ISTAR_MANHUNT_DESC_AREA", _r]] call _fnc_update;
                (format [localize "STR_ALIVE_C2ISTAR_MANHUNT_MSG_CLUE", _name, _r]) call _fnc_radio;
            };
            ["C2ISTAR - HVT manhunt %1: clue %2, search area %3 m", _rootID, _clues, _r] call ALiVE_fnc_dump;
        };
        private _clues = [_params, "ManhuntClues", 0] call _fnc_get;

        // enough to tap his network: a Wiretap task on a house near his hideout, raised as current as the AI
        // Commander's are (the task handler only runs current tasks)
        if (_stage == "search" && {_clues >= ([_params, "ManhuntNeed", 3] call _fnc_get)} && {_clues < 6}) then {
            private _area = [_params, "HVTArea", [0,0,0]] call _fnc_get;
            private _near = _area getPos [300 + random 600, random 360];
            private _houses = (nearestObjects [_near, ["House_F"], 300]) select { alive _x && {count (_x buildingPos -1) > 2} };
            // a new ID each time: a finished one stays in ALiVE_c2istar_finishedTasks
            private _n = ([_params, "ManhuntWiretaps", 0] call _fnc_get) + 1;
            [_params, "ManhuntWiretaps", _n] call _fnc_set;
            private _wt = format ["%1mhwt%2", _rootID, _n];
            private _td = [_wt, _task select 1, _taskSide, _task select 4, "Wiretap", "Map",
                if (_houses isEqualTo []) then { _near } else { getPosATL (_houses select 0) },
                _task select 7, [_params, "enemyFaction", ""] call _fnc_get, "Y", "Side"];
            if (_houses isNotEqualTo []) then { _td pushBack [_houses select 0] };
            [ALIVE_eventLog, "addEvent", ["TASK_GENERATE", _td, "C2ISTAR"] call ALIVE_fnc_event] call ALIVE_fnc_eventLog;
            [_params, "ManhuntWiretapID", _wt] call _fnc_set;
            [_params, "ManhuntWiretapAt", time] call _fnc_set;
            [_params, "ManhuntStage", "wiretap"] call _fnc_set;
            _stage = "wiretap";
            private _r = [_params, "ManhuntRadius", 1500] call _fnc_get;
            [[_params, "ManhuntCenter", [0,0,0]] call _fnc_get, format [localize "STR_ALIVE_C2ISTAR_MANHUNT_DESC_WIRETAP", _r, (_td select 6) call _fnc_placeName]] call _fnc_update;
            ["C2ISTAR - HVT manhunt %1: Wiretap task %2 raised at %3", _rootID, _wt, mapGridPosition (_td select 6)] call ALiVE_fnc_dump;
        };

        if (_stage == "wiretap") then {
            private _wt = [_params, "ManhuntWiretapID", ""] call _fnc_get;
            private _how = (missionNamespace getVariable ["ALiVE_c2istar_finishedTasks", createHashMap]) getOrDefault [_wt, ""];
            private _live = [ALIVE_taskHandler, "getTask", _wt] call ALIVE_fnc_taskHandler;
            switch (true) do {
                case (_how == "Succeeded"): { call _fnc_forecast; _stage = "window" };
                // failed, cancelled, or never made (no house to tap, or the task could not be built): two more clues
                case (_how != "" || {isNil "_live" && {time - ([_params, "ManhuntWiretapAt", 0] call _fnc_get) > 60}}): {
                    ["C2ISTAR - HVT manhunt %1: Wiretap task %2 %3; two more clues are needed", _rootID, _wt, [_how, "was not made"] select (_how == "")] call ALiVE_fnc_dump;
                    [_params, "ManhuntWiretapID", ""] call _fnc_set;
                    [_params, "ManhuntNeed", _clues + 2] call _fnc_set;
                    [_params, "ManhuntStage", "search"] call _fnc_set;
                    _stage = "search";
                    [[_params, "ManhuntCenter", [0,0,0]] call _fnc_get, format [localize "STR_ALIVE_C2ISTAR_MANHUNT_DESC_AREA", [_params, "ManhuntRadius", 1500] call _fnc_get]] call _fnc_update;
                };
            };
        };

        // enough clues without a wiretap
        if (_stage in ["search", "wiretap"] && {_clues >= 6}) then { call _fnc_forecast; _stage = "window" };

        if (_stage == "window") then {
            ([_params, "ManhuntWindow", []] call _fnc_get) params [["_from", 1e9], ["_until", 1e9]];
            private _meet = [_params, "ManhuntMeetPos", []] call _fnc_get;
            // his window opens: he goes to the meeting, tried each tick while he is on a player's screen (he can't be
            // moved then). The task points there only once he is
            if (time >= _from && {time < _until} && {!([_params, "ManhuntMoved", false] call _fnc_get)}) then {
                if ([_meet] call _fnc_moveTo) then {
                    [_params, "ManhuntMoved", true] call _fnc_set;
                    ["C2ISTAR - HVT manhunt %1: his window opens, he is at %2", _rootID, mapGridPosition _meet] call ALiVE_fnc_dump;
                };
            };
            if (time >= _until) then {
                private _area = [_params, "HVTArea", [0,0,0]] call _fnc_get;
                private _players = (_taskPlayers apply { [_x] call ALIVE_fnc_getPlayerByUID }) select { !isNull _x && {alive _x} };
                private _close = (_players findIf { (_x distance2D _area) < 400 }) > -1;
                // players on him: five more minutes, once, as moving him mid-fight would read as cheating
                if (_close && {!([_params, "ManhuntExtended", false] call _fnc_get)}) exitWith {
                    [_params, "ManhuntExtended", true] call _fnc_set;
                    [_params, "ManhuntWindow", [_from, _until + 300]] call _fnc_set;
                    ["C2ISTAR - HVT manhunt %1: players are close, his window runs five more minutes", _rootID] call ALiVE_fnc_dump;
                };
                // he slips away: a new hideout 2 to 4 km off, clear of players, with half of what was known
                private _new = [];
                for "_i" from 1 to 40 do {
                    if (_new isNotEqualTo []) exitWith {};
                    private _c = _area getPos [2000 + random 2000, random 360];
                    if (!surfaceIsWater _c && {(_c select 0) > 0} && {(_c select 1) > 0} && {(_c select 0) < worldSize} && {(_c select 1) < worldSize}
                        && {(_players findIf { (_x distance2D _c) < 1200 }) < 0}) then { _new = _c };
                };
                if (_new isEqualTo []) then { _new = _area getPos [2500, random 360] };
                _new = [_new, 300] call ALiVE_fnc_findFlatArea;
                _new set [2, 0];
                // on a player's screen he can't be moved: he stays where he is (never having reached the meeting), and
                // the search starts again round him
                if !([_new] call _fnc_moveTo) then { _new = +_area };
                private _place = [_params, "ManhuntMeetName", ""] call _fnc_get;
                [_params, "HVTFound", false] call _fnc_set;
                [_params, "HVTSentPos", []] call _fnc_set;
                [_params, "ManhuntClues", floor (_clues / 2)] call _fnc_set;
                [_params, "ManhuntNeed", 3] call _fnc_set;
                [_params, "ManhuntWiretapID", ""] call _fnc_set;
                [_params, "ManhuntWindow", []] call _fnc_set;
                [_params, "ManhuntMoves", ([_params, "ManhuntMoves", 0] call _fnc_get) + 1] call _fnc_set;
                [_params, "ManhuntStage", "search"] call _fnc_set;
                call _fnc_recentre;
                private _r = [_params, "ManhuntRadius", 1500] call _fnc_get;
                [[_params, "ManhuntCenter", [0,0,0]] call _fnc_get, format [localize "STR_ALIVE_C2ISTAR_MANHUNT_DESC_AREA", _r]] call _fnc_update;
                (format [localize "STR_ALIVE_C2ISTAR_MANHUNT_MSG_SLIPPED", _name, _place]) call _fnc_radio;
                ["C2ISTAR - HVT manhunt %1: missed at %2, he has moved to %3 with %4 clue(s) left", _rootID, _place, mapGridPosition _new, floor (_clues / 2)] call ALiVE_fnc_dump;
            };
        };
    };
};
