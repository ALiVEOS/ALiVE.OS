#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(outbreakCaches);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_outbreakCaches

Description:
Outbreak game mode: supply caches hidden in towns for players to find. Each is a crate in
a house, filled from the mission's own factions' weapons, magazines and medical kit, with
food and water from the civilian module. By default they go only into towns that have
fallen: most of their people are dead, or zombies are in the town and half of its people
are gone. A cache emptied by players is taken away after the Refill time and a new one is
hidden in another town.

"init" (server) reads the Virtual AI module's settings and starts the loop. "markerText"
runs on each player's machine to label a cache's marker in that player's own language.

Parameters:
String - "init" or "markerText"
Any - "init": the Virtual AI module; "markerText": [marker, looted]

Returns:
Nothing

Examples:
(begin example)
["init", _logic] call ALiVE_fnc_outbreakCaches;
(end)

See Also:
ALiVE_fnc_profileSystemInit, ALiVE_fnc_zombieHunt

Author:
Jman
---------------------------------------------------------------------------- */

params [["_mode", "init"], ["_args", []]];

switch (_mode) do {

    case "markerText": {
        if (!hasInterface) exitWith {};
        _args params [["_marker", ""], ["_looted", false]];
        if (_marker == "") exitWith {};
        _marker setMarkerTextLocal localize (["STR_ALIVE_PROFILE_SYSTEM_OUTBREAK_CACHE_MARKER", "STR_ALIVE_PROFILE_SYSTEM_OUTBREAK_CACHE_MARKER_EMPTY"] select _looted);
    };

    case "init": {
        if (!isServer) exitWith {};
        private _logic = _args;
        if (isNull _logic || {!isNil "ALiVE_outbreakCaches"}) exitWith {};

        // the settings: a number setting that isn't one falls back to its default, with one RPT line
        private _num = {
            params ["_key", "_default", "_min", "_max", "_label"];
            private _raw = _logic getVariable [_key, str _default];
            private _v = if (_raw isEqualType 0) then { _raw } else {
                private _t = ((str _raw) splitString " """) joinString "";
                if (_t == "" || {((_t splitString "") - ["0","1","2","3","4","5","6","7","8","9"]) isNotEqualTo []}) then { -1 } else { parseNumber _t }
            };
            if (_v < 0) then {
                ["ALiVE Outbreak Caches - %1 reads %2, which is not a whole number, so it uses %3. Correct it on the Virtual AI module.", _label, str _raw, _default] call ALiVE_fnc_dumpR;
                _v = _default;
            };
            (_v max _min) min _max
        };
        private _count = ["outbreakCacheCount", 12, 1, 50, "Supply Caches"] call _num;
        private _refill = ["outbreakCacheRefill", 60, 0, 1440, "Cache Refill"] call _num;
        private _where = _logic getVariable ["outbreakCacheWhere", "fallen"];
        if !(_where in ["fallen", "any"]) then { _where = "fallen" };
        private _markers = _logic getVariable ["outbreakCacheMarkers", "found"];
        if !(_markers in ["hidden", "found", "all"]) then { _markers = "found" };
        private _lootRaw = _logic getVariable ["outbreakCacheLoot", ""];
        if !(_lootRaw isEqualType "") then { _lootRaw = str _lootRaw };

        // the mission's own loot list: "class" or "class:min-max", comma separated. Any entry replaces the automatic pool
        private _custom = [];
        private _dropped = [];
        {
            private _parts = (_x splitString ": ") select { _x != "" };
            if (_parts isNotEqualTo []) then {
                private _class = _parts select 0;
                private _range = ((_parts param [1, "1"]) splitString "-") apply { (parseNumber _x) max 0 };
                private _lo = _range param [0, 1];
                private _hi = (_range param [1, _lo]) max _lo;
                if (isClass (configFile >> "CfgWeapons" >> _class) || {isClass (configFile >> "CfgMagazines" >> _class)} || {isClass (configFile >> "CfgVehicles" >> _class)}) then {
                    if (_hi > 0) then { _custom pushBack [_class, _lo, _hi] };
                } else { _dropped pushBack _class };
            };
        } forEach ((_lootRaw splitString ",[]""'") apply { _x trim [" ", 0] });
        if (_dropped isNotEqualTo []) then {
            ["ALiVE Outbreak Caches - the Cache Loot list names classes this game doesn't have, which are left out: %1", _dropped] call ALiVE_fnc_dumpR;
        };

        ALiVE_outbreakCaches = createHashMapFromArray [
            ["count", _count], ["refill", _refill * 60], ["where", _where], ["markers", _markers], ["custom", _custom],
            ["rows", []], ["nextId", 0], ["towns", createHashMap], ["pool", []], ["crateClasses", []]
        ];
        ["ALiVE Outbreak Caches - %1 caches, in %2 towns, refill %3 min (0 = never), markers %4, %5", _count, _where, _refill, _markers,
            ["automatic loot", format ["the mission's own loot list (%1 entries)", count _custom]] select (_custom isNotEqualTo [])] call ALiVE_fnc_dump;

        [] spawn {
            // the towns, the civilians and the AI Commanders' factions all come later than this module
            private _t = time + 120;
            waitUntil { sleep 2; (!isNil "ALIVE_clustersCivSettlement" && {!isNil "ALIVE_clusterHandler"} && {!isNil "OPCOM_instances"} && {OPCOM_instances isNotEqualTo []}) || {time > _t} };
            if (isNil "ALIVE_clustersCivSettlement" || {isNil "ALIVE_clusterHandler"}) exitWith {
                ["ALiVE Outbreak Caches - the map's towns never arrived (no Civilian Placement module?), so no supply caches are hidden."] call ALiVE_fnc_dumpR;
            };
            // the civilian population registers its people a little after the towns
            _t = time + 60;
            waitUntil { sleep 2; !isNil "ALIVE_agentHandler" || {time > _t} };
            if (isNil "ALIVE_agentHandler") then {
                ["ALiVE Outbreak Caches - no Civilian Population module, so a town counts as fallen only while zombies are in it."] call ALiVE_fnc_dump;
            };
            sleep 10;
            ALiVE_outbreakCaches set ["started", true];
            while { !isNil "ALiVE_outbreakCaches" } do {
                ["tick"] call ALiVE_fnc_outbreakCaches;
                sleep 30;
            };
        };
    };

    // the towns: [id, centre] for each town of the map
    case "towns": {
        private _out = [];
        {
            private _c = [ALIVE_clusterHandler, "getCluster", _x] call ALIVE_fnc_clusterHandler;
            if (!isNil "_c") then {
                private _centre = [_c, "center", []] call ALIVE_fnc_hashGet;
                if (count _centre >= 2) then { _out pushBack [_x, _centre] };
            };
        } forEach (ALIVE_clustersCivSettlement select 1);
        _out
    };

    // which towns have fallen. Each town's people are counted the first time it is seen with any, and a town falls when
    // fewer than a quarter of them are left, or zombies are in it and fewer than 60% are left. A town without
    // civilians (no Civilian Population module, or none placed there) falls while zombies are in it.
    case "fallen": {
        private _towns = ALiVE_outbreakCaches get "towns";
        private _byCluster = [];
        if (!isNil "ALIVE_agentHandler") then {
            private _h = [ALIVE_agentHandler, "agentsByCluster"] call ALIVE_fnc_hashGet;
            if (!isNil "_h") then { _byCluster = _h };
        };
        private _zSide = missionNamespace getVariable ["ALiVE_ZOMBIESIDE", "EAST"];
        private _out = [];
        {
            _x params ["_id", "_centre"];
            private _rec = _towns getOrDefault [_id, [-1, -1]];
            _rec params ["_base", "_fallenAt"];
            private _now = -1;
            if (_byCluster isNotEqualTo []) then {
                private _list = [_byCluster, _id] call ALIVE_fnc_hashGet;
                _now = if (isNil "_list") then { 0 } else { { ((_x select 2) select 4) == "agent" } count (_list select 2) };
            };
            if (_base < 0 && {_now > 0}) then { _base = _now };
            if (_fallenAt < 0) then {
                private _zombies = ([_centre, 250, [_zSide]] call ALIVE_fnc_getNearProfiles) isNotEqualTo [];
                private _fell = if (_base > 0) then { (_now < 0.25 * _base) || {_zombies && {_now < 0.6 * _base}} } else { _zombies };
                if (_fell) then {
                    _fallenAt = serverTime;
                    ["ALiVE Outbreak Caches - %1 has fallen (%2 of %3 people left%4)", _id, _now max 0, _base max 0, ["", ", zombies in the town"] select _zombies] call ALiVE_fnc_dump;
                };
            };
            _towns set [_id, [_base, _fallenAt]];
            if (_fallenAt >= 0) then { _out pushBack _x };
        } forEach (["towns"] call ALiVE_fnc_outbreakCaches);
        _out
    };

    // what a cache is filled with: [[class, min, max], ...], built once from the mission's own AI Commanders' factions
    case "pool": {
        private _pool = ALiVE_outbreakCaches get "pool";
        if (_pool isNotEqualTo []) exitWith { _pool };
        private _custom = ALiVE_outbreakCaches get "custom";
        if (_custom isNotEqualTo []) exitWith { ALiVE_outbreakCaches set ["pool", _custom]; _custom };
        private _zombie = (missionNamespace getVariable ["ALiVE_zombieFactions", []]) apply { toLower _x };
        private _factions = [];
        if (!isNil "OPCOM_instances") then {
            { { if !((toLower _x) in _zombie) then { _factions pushBackUnique toLower _x } } forEach ([_x, "factions", []] call ALiVE_fnc_HashGet) } forEach OPCOM_instances;
        };
        private _weapons = [];
        private _mags = [];
        private _packs = [];
        if (_factions isNotEqualTo []) then {
            private _units = ("getNumber (_x >> 'scope') == 2 && {(toLower getText (_x >> 'faction')) in _factions} && {(configName _x) isKindOf 'CAManBase'}" configClasses (configFile >> "CfgVehicles"));
            {
                // rifles and pistols that take a magazine (S.O.G.'s torches sit in the pistol slot)
                { if (getNumber (configFile >> "CfgWeapons" >> _x >> "type") in [1, 2] && {(compatibleMagazines _x) isNotEqualTo []}) then { _weapons pushBackUnique _x } } forEach getArray (_x >> "weapons");
                { _mags pushBackUnique _x } forEach getArray (_x >> "magazines");
                private _b = getText (_x >> "backpack");
                if (_b != "") then { _packs pushBackUnique _b };
            } forEach _units;
        };
        private _civ = (entities "ALiVE_amb_civ_population") param [0, objNull];
        private _food = (_civ getVariable ["waterItems", missionNamespace getVariable ["ALiVE_CivPop_Interaction_WaterItems", []]])
            + (_civ getVariable ["rationItems", missionNamespace getVariable ["ALiVE_CivPop_Interaction_RationItems", []]]);
        _food = _food select { _x isEqualType "" && {isClass (configFile >> "CfgWeapons" >> _x) || {isClass (configFile >> "CfgMagazines" >> _x)}} };
        if (_weapons isEqualTo []) then {
            ["ALiVE Outbreak Caches - no weapons found in the AI Commanders' factions %1, so caches hold a plain survivor kit.", _factions] call ALiVE_fnc_dump;
            _weapons = ["hgun_P07_F", "SMG_02_F"];
            _mags = ["16Rnd_9x21_Mag", "30Rnd_9x21_Mag_SMG_02"];
        };
        // kept as the parts to draw from each time: weapons, the faction's magazines, backpacks, food and water
        _pool = [["weapons", _weapons], ["mags", _mags], ["packs", _packs], ["food", _food]];
        ["ALiVE Outbreak Caches - loot from %1: %2 weapons, %3 backpacks, %4 kinds of food and water", _factions, count _weapons, count _packs, count _food] call ALiVE_fnc_dump;
        ALiVE_outbreakCaches set ["pool", _pool];
        _pool
    };

    // put one cache's loot in the crate; returns how many things went in
    case "fill": {
        private _crate = _args;
        clearWeaponCargoGlobal _crate;
        clearMagazineCargoGlobal _crate;
        clearItemCargoGlobal _crate;
        clearBackpackCargoGlobal _crate;
        private _put = {
            params ["_class", "_n"];
            if (_n <= 0) exitWith { 0 };
            switch (true) do {
                case (isClass (configFile >> "CfgMagazines" >> _class)): { _crate addMagazineCargoGlobal [_class, _n] };
                case (isClass (configFile >> "CfgVehicles" >> _class)): { _crate addBackpackCargoGlobal [_class, _n] };
                case (getNumber (configFile >> "CfgWeapons" >> _class >> "type") in [1, 2, 4]): { _crate addWeaponCargoGlobal [_class, _n] };
                default { _crate addItemCargoGlobal [_class, _n] };
            };
            _n
        };
        private _pool = ["pool"] call ALiVE_fnc_outbreakCaches;
        private _total = 0;
        if ((ALiVE_outbreakCaches get "custom") isNotEqualTo []) then {
            // the mission's own list
            { _x params ["_class", "_lo", "_hi"]; _total = _total + ([_class, _lo + floor random (_hi - _lo + 1)] call _put) } forEach _pool;
        } else {
            private _p = createHashMapFromArray _pool;
            private _mags = _p get "mags";
            private _weapons = _p get "weapons";
            for "_i" from 1 to (1 + floor random 2) do {
                private _w = selectRandom _weapons;
                _total = _total + ([_w, 1] call _put);
                // the faction's own magazines for it, or the weapon's first one
                private _fits = (compatibleMagazines _w) apply { toLower _x };
                private _m = _mags select { (toLower _x) in _fits };
                private _mag = if (_m isNotEqualTo []) then { selectRandom _m } else { (compatibleMagazines _w) param [0, ""] };
                if (_mag != "") then { _total = _total + ([_mag, 3 + floor random 3] call _put) };
            };
            if (isClass (configFile >> "CfgWeapons" >> "FirstAidKit")) then { _total = _total + (["FirstAidKit", 2 + floor random 3] call _put) };
            private _food = _p get "food";
            if (_food isNotEqualTo []) then { for "_i" from 1 to (1 + floor random 3) do { _total = _total + ([selectRandom _food, 1] call _put) } };
            private _packs = _p get "packs";
            if (_packs isNotEqualTo [] && {random 1 < 0.3}) then { _total = _total + ([selectRandom _packs, 1] call _put) };
        };
        _total
    };

    // how many things are in a crate now
    case "contents": {
        private _crate = _args;
        if (isNull _crate) exitWith { 0 };
        count (weaponCargo _crate) + count (magazineCargo _crate) + count (itemCargo _crate) + count (backpackCargo _crate)
    };

    // a crate class that holds things, matching the era of the mission's factions
    case "crateClass": {
        private _classes = ALiVE_outbreakCaches get "crateClasses";
        if (_classes isEqualTo []) then {
            private _zombie = (missionNamespace getVariable ["ALiVE_zombieFactions", []]) apply { toLower _x };
            private _f = "";
            if (!isNil "OPCOM_instances") then {
                { { if (_f == "" && {!((toLower _x) in _zombie)}) then { _f = toLower _x } } forEach ([_x, "factions", []] call ALiVE_fnc_HashGet) } forEach OPCOM_instances;
            };
            // the era from the faction's own soldiers: S.O.G.'s factions are O_PAVN and B_MACV, but their men are vn_
            private _unit = "";
            if (_f != "") then {
                _unit = toLower configName (("getNumber (_x >> 'scope') == 2 && {(toLower getText (_x >> 'faction')) == _f} && {(configName _x) isKindOf 'CAManBase'}" configClasses (configFile >> "CfgVehicles")) param [0, configNull]);
            };
            private _theme = switch (true) do {
                case (_f select [0, 3] == "vn_" || {_unit select [0, 3] == "vn_"}): { "VIETNAM" };
                case (_f select [0, 4] == "spe_" || {_unit select [0, 4] == "spe_"}): { "WW2" };
                case (_f select [0, 3] == "gm_" || {_unit select [0, 3] == "gm_"}): { "COLDWAR" };
                default { "MODERN" };
            };
            private _themes = missionNamespace getVariable ["ALiVE_INS_propThemes", createHashMap];
            // the Installation Props theme's crates when the AI Commander has loaded them, then the era's own boxes; the
            // vanilla ones only for the modern era or when none of the era's hold anything
            private _era = switch (_theme) do {
                case "VIETNAM": { ["vn_b_ammobox_01", "vn_b_ammobox_02", "vn_o_ammobox_01", "vn_o_ammobox_02", "Land_vn_pavn_weapons_cache"] };
                case "WW2": { ["SPE_BasicAmmunitionBox_GER", "SPE_BasicWeaponsBox_US", "SPE_Weaponcrate_K98_GER"] };
                case "COLDWAR": { ["gm_AmmoBox_wood_01_empty", "gm_AmmoBox_wood_03_empty", "gm_ammobox_aluminium_01_empty"] };
                default { ["Box_Syndicate_Wps_F", "Box_IND_Wps_F", "Box_East_Wps_F"] };
            };
            private _list = ((_themes getOrDefault [_theme, []]) param [2, []]) + _era;
            _classes = _list select {
                private _c = configFile >> "CfgVehicles" >> _x;
                isClass _c && {_x isKindOf "ReammoBox_F"} && {getNumber (_c >> "maximumLoad") > 0}
            };
            if (_classes isEqualTo []) then {
                _classes = ["Box_Syndicate_Wps_F", "Box_IND_Wps_F", "Box_East_Wps_F"] select { isClass (configFile >> "CfgVehicles" >> _x) };
                if (_classes isEqualTo []) then { _classes = ["Box_IND_Support_F"] };
                ["ALiVE Outbreak Caches - no crate of the %1 era holds things, so the caches use %2.", _theme, _classes] call ALiVE_fnc_dump;
            };
            ["ALiVE Outbreak Caches - %1 era crates: %2", _theme, _classes] call ALiVE_fnc_dump;
            ALiVE_outbreakCaches set ["crateClasses", _classes];
        };
        selectRandom _classes
    };

    // a spot indoors in the town, under a roof: [position ATL, house] or []
    case "spot": {
        private _centre = _args;
        private _houses = (nearestObjects [_centre, ["House"], 150]) select { alive _x && {count (_x buildingPos -1) > 0} };
        _houses = (_houses call BIS_fnc_arrayShuffle) select [0, 30];
        private _out = [];
        private _free = { _this select { private _s = _x; ((ALiVE_outbreakCaches get "rows") findIf { ((_x select 3) distance _s) < 20 }) < 0 } };
        // a spot under a roof in any of the houses first; only when none has one, any spot in a house (open huts)
        {
            private _h = _x;
            private _spots = (([_h] call ALIVE_fnc_getBuildingPositions) select {
                private _a = ATLtoASL _x;
                lineIntersects [_a vectorAdd [0, 0, 0.5], _a vectorAdd [0, 0, 2.5]]
            }) call _free;
            if (_spots isNotEqualTo []) exitWith { _out = [selectRandom _spots, _h] };
        } forEach _houses;
        if (_out isEqualTo []) then {
            {
                private _h = _x;
                private _spots = ((_h buildingPos -1) select { (_x select 2) < 30 }) call _free;
                if (_spots isNotEqualTo []) exitWith { _out = [selectRandom _spots, _h] };
            } forEach _houses;
        };
        _out
    };

    case "marker": {
        // a cache's marker, made once on the server for everyone; each player's machine writes the label in its own language
        private _row = _args;
        _row params ["_id", "_town", "_crate", "_pos", "_state"];
        private _name = format ["ALiVE_outbreakCache_%1", _id];
        if (getMarkerColor _name == "") then {
            createMarker [_name, _pos];
            _name setMarkerShape "ICON";
            _name setMarkerType (["mil_dot", "mil_box"] select (isClass (configFile >> "CfgMarkers" >> "mil_box")));
            _name setMarkerSize [0.7, 0.7];
        };
        _name setMarkerColor (["ColorGreen", "ColorGrey"] select (_state == "looted"));
        ["markerText", [_name, _state == "looted"]] remoteExecCall ["ALiVE_fnc_outbreakCaches", 0, _name];
    };

    case "unmark": {
        private _name = format ["ALiVE_outbreakCache_%1", _args];
        if (getMarkerColor _name != "") then { deleteMarker _name };
        remoteExecCall ["", _name];
    };

    // every 30 seconds: note what players have found or emptied, take away emptied caches once the refill time is up,
    // and hide new ones until the count is reached
    case "tick": {
        private _c = ALiVE_outbreakCaches;
        private _rows = _c get "rows";
        private _players = (allPlayers - entities "HeadlessClient_F") select { alive _x };
        private _markers = _c get "markers";
        private _refill = _c get "refill";
        // row: [id, town, crate, position ATL, state, put in, emptied at, found]
        {
            private _row = _x;
            _row params ["_id", "_town", "_crate", "_pos", "_state", "_put", "_emptiedAt", "_found"];
            if (!_found && {(_players findIf { (_x distance _pos) < 12 }) >= 0}) then {
                _row set [7, true];
                if (_markers == "found") then { ["marker", _row] call ALiVE_fnc_outbreakCaches };
            };
            // emptied: under 30% of what was put in (a player who puts his own kit in it keeps it full a while longer)
            if (_state == "full" && {(["contents", _crate] call ALiVE_fnc_outbreakCaches) < 0.3 * _put}) then {
                _row set [4, "looted"];
                _row set [6, serverTime];
                ["ALiVE Outbreak Caches - cache %1 at %2 has been emptied", _id, _town] call ALiVE_fnc_dump;
                if (_markers == "all" || {_markers == "found" && {_row select 7}}) then { ["marker", _row] call ALiVE_fnc_outbreakCaches };
            };
        } forEach _rows;
        // an emptied cache goes once its refill time is up and nobody is near enough to see it go
        if (_refill > 0) then {
            private _gone = _rows select {
                private _p = _x select 3;
                (_x select 4) == "looted" && {serverTime - (_x select 6) > _refill} && {(_players findIf { (_x distance _p) < 300 }) < 0}
            };
            {
                deleteVehicle (_x select 2);
                ["unmark", _x select 0] call ALiVE_fnc_outbreakCaches;
                _c set ["lastTown", _x select 1];
                ["ALiVE Outbreak Caches - cache %1 at %2 taken away; a new one will be hidden elsewhere", _x select 0, _x select 1] call ALiVE_fnc_dump;
            } forEach _gone;
            _rows = _rows - _gone;
            _c set ["rows", _rows];
        };
        // a crate destroyed or deleted by something else is forgotten, so another takes its place
        private _lost = _rows select { isNull (_x select 2) };
        { ["unmark", _x select 0] call ALiVE_fnc_outbreakCaches } forEach _lost;
        _rows = _rows - _lost;
        _c set ["rows", _rows];

        // hide new ones, two a tick: in a town without one, out of sight of players
        private _towns = if ((_c get "where") == "any") then { ["towns"] call ALiVE_fnc_outbreakCaches } else { ["fallen"] call ALiVE_fnc_outbreakCaches };
        private _used = _rows apply { _x select 1 };
        private _last = _c getOrDefault ["lastTown", ""];
        _towns = _towns select {
            private _t = _x;
            !((_t select 0) in _used) && {(_t select 0) != _last || {count _towns == 1}}
            && {(_players findIf { (_x distance2D (_t select 1)) < 300 }) < 0}
        };
        _towns = _towns call BIS_fnc_arrayShuffle;
        private _added = 0;
        {
            if (count _rows >= (_c get "count") || {_added >= 2}) exitWith {};
            _x params ["_town", "_centre"];
            private _spot = ["spot", _centre] call ALiVE_fnc_outbreakCaches;
            if (_spot isNotEqualTo []) then {
                _spot params ["_pos", "_house"];
                private _crate = createVehicle [["crateClass"] call ALiVE_fnc_outbreakCaches, [0, 0, 0], [], 0, "CAN_COLLIDE"];
                _crate setPosATL _pos;
                _crate setDir random 360;
                _crate allowDamage false;
                // held where it was put: some era boxes slide or drop through a hut's floor once physics wakes up.
                // Its inventory still opens
                _crate enableSimulationGlobal false;
                _crate setVariable ["ALiVE_outbreakCache", true, true];
                private _put = ["fill", _crate] call ALiVE_fnc_outbreakCaches;
                private _id = _c get "nextId";
                _c set ["nextId", _id + 1];
                private _row = [_id, _town, _crate, _pos, "full", _put, -1, false];
                _rows pushBack _row;
                _added = _added + 1;
                if (_markers == "all") then { ["marker", _row] call ALiVE_fnc_outbreakCaches };
                ["ALiVE Outbreak Caches - cache %1 hidden at %2 (%3, %4 things in a %5)", _id, _town, mapGridPosition _pos, _put, typeOf _crate] call ALiVE_fnc_dump;
            };
        } forEach _towns;
        _c set ["rows", _rows];
    };
};
