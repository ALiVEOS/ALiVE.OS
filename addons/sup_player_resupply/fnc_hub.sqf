#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
SCRIPT(hub);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_hub

Description:
The Logistics Hub module (#1091). Every object synced to it is a hub of its side. A player of that
side standing at one can choose Collect at a Hub on the Player Logistics tablet: the requisition is
set out beside them straight away, with no convoy and no wait, and paid from the force pool as a
delivery would be. Who Can Collect picks who may (anyone on the side, group leaders, players
carrying a Player Logistics access item, named players; admins always), and the hub's own Only
These, Never and Also lists narrow or widen the tablet's catalogue for what is collected there.

Players' machines only ask, to show or hide the tablet; Military Logistics asks the server again
("validateCollect") before anything is made.

The module's settings exist only on the server, as Eden puts them there, so the server publishes
what players' machines need: on each hub ALiVE_hub = [side, alive, radius, module], on each module
ALiVE_hub_settings = [side, radius, who, names, only, never, also], and the list of hubs as
ALiVE_hub_list.

Parameters:
    ["init", [module]] - server: reads the settings, tags the synced objects
    ["settings", [module]] - [side, radius, who, names, only, never, also], any machine
    ["rules", [module]] - Who Can Collect as [rules, names]: an admin's in-game change, or the module's
    ["catalogueRules", [module]] - the module's three lists read by ALIVE_fnc_PRCatalogueRules
    ["unitSide", [unit]] - the unit's side as text, a civilian-side player counted by faction
    ["nearHub", [unit]] - the nearest working hub of the unit's side within its radius, or objNull
    ["isAdmin", [unit]] - a logged-in or voted admin, or anyone in single player
    ["mayWho", [unit, rules, names]] - whether Who Can Collect style rules let the unit in
    ["mayCollect", [unit, hub]] - an admin, or let in by the hub's module
    ["sideCatalogue", [sideText]] - server: every class the tablet could list for that side, lower case
    ["validateCollect", [hubNetId, playerID, faction, forceMakeup]] - server: "" when the requisition
        may be collected, else why not; with the player, hub and module
    ["collectCost", [forceMakeup]] - what a collected requisition takes from the force pool
    ["permissions", [rules, names, hubNetId]] - server, through ALIVE_fnc_hubRequest: an admin's change
        to Who Can Collect, for one hub's module or (hubNetId "") for every module

Returns:
See above

Examples:
(begin example)
["nearHub", [player]] call ALIVE_fnc_hub;
// an admin, from the debug console: only group leaders may collect at the hub being looked at
["permissions", ["LEADER", "", cursorObject call BIS_fnc_netId]] remoteExecCall ["ALIVE_fnc_hubRequest", 2];
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_op", ""], ["_args", []]];
if !(_args isEqualType []) then { _args = [_args] };

// One line in the RPT when any Hub module has Debug on
private _debug = { if (missionNamespace getVariable ["ALiVE_hub_debug", false]) then { _this call ALiVE_fnc_dump } };

private _result = nil;

switch (_op) do {

    case "init": {
        _args params [["_logic", objNull, [objNull]]];
        if (isNull _logic || {!isServer}) exitWith {};
        if !(isNil {_logic getVariable "ALiVE_hub_settings"}) exitWith {};
        _logic setVariable ["moduleType", "ALIVE_HUB"];
        _logic setVariable ["startupComplete", false];

        // Settings: a Combo arrives as text, an Edit as text or (an older save) a number
        private _text = { params ["_name", "_default"]; private _v = _logic getVariable [_name, _default]; if (_v isEqualType "") then { _v } else { str _v } };
        private _side = toUpper (["hub_side", "WEST"] call _text);
        if !(_side in ["WEST", "EAST", "GUER"]) then { _side = "WEST" };
        private _radius = parseNumber (["hub_radius", "10"] call _text);
        if (_radius <= 0) then { _radius = 10 };
        _radius = (_radius max 2) min 100;
        private _who = toUpper (["hub_collect_who", "SIDE"] call _text);
        _who = (((_who splitString "[]""', ") select { _x in ["SIDE", "LEADER", "ITEM", "LIST"] }) joinString ",");
        private _names = ["hub_collect_list", ""] call _text;
        private _settings = [_side, _radius, _who, _names, ["hub_only", ""] call _text, ["hub_never", ""] call _text, ["hub_also", ""] call _text];
        _logic setVariable ["ALiVE_hub_settings", _settings, true];

        private _debugOn = (toLower (["hub_debug", "false"] call _text)) in ["true", "1", "yes"];
        if (_debugOn) then { ALiVE_hub_debug = true; publicVariable "ALiVE_hub_debug" };

        if (isNil "ALiVE_hub_registry") then { ALiVE_hub_registry = createHashMap };
        if (isNil "ALiVE_hub_modules") then { ALiVE_hub_modules = [] };
        if (isNil "ALiVE_hub_list") then { ALiVE_hub_list = [] };
        ALiVE_hub_modules pushBackUnique _logic;

        // What the module is synced to. Collect needs Player Combat Logistics; Military Logistics
        // is what pays for it.
        private _synced = synchronizedObjects _logic;
        private _collect = (_synced findIf { typeOf _x == "ALiVE_SUP_PLAYER_RESUPPLY" }) > -1;
        private _mlMods = _synced select { typeOf _x == "ALiVE_mil_logistics" };
        _logic setVariable ["ALiVE_hub_collect", _collect, true];
        if (!_collect && {_mlMods isEqualTo []}) then {
            ["ALiVE Logistics Hub: the module at %1 is synced to neither Player Combat Logistics nor Military Logistics, so its hubs do nothing. Sync it to one or both.", mapGridPosition _logic] call ALiVE_fnc_dumpR;
        };

        // The hubs: the objects synced to it, as a static object
        private _hubs = [];
        {
            private _o = _x;
            switch (true) do {
                case (_o isKindOf "Logic"): {};
                case (_o isKindOf "EmptyDetector"): {
                    ["ALiVE Logistics Hub: a trigger is synced to the module at %1; a hub must be an object, so it is left out", mapGridPosition _logic] call ALiVE_fnc_dumpR;
                };
                case (_o isKindOf "AllVehicles"): {
                    ["ALiVE Logistics Hub: %1 is a vehicle or a soldier; a hub must be a static object, so it is left out", typeOf _o] call ALiVE_fnc_dumpR;
                };
                case (isSimpleObject _o): {
                    ["ALiVE Logistics Hub: %1 at %2 is a simple object, which can't carry what players' machines read, so it is left out", typeOf _o, mapGridPosition _o] call ALiVE_fnc_dumpR;
                };
                case ((_o call BIS_fnc_netId) in ALiVE_hub_registry): {
                    ["ALiVE Logistics Hub: %1 at %2 is synced to two Hub modules; the first one keeps it", typeOf _o, mapGridPosition _o] call ALiVE_fnc_dumpR;
                };
                default { _hubs pushBack _o };
            };
        } forEach _synced;
        if (_hubs isEqualTo []) then {
            ["ALiVE Logistics Hub: no object is synced to the module at %1, so it has no hubs", mapGridPosition _logic] call ALiVE_fnc_dumpR;
        };
        {
            // side, alive, owning module, offers Collect, source Military Logistics modules, and what a
            // rebuild needs: class, position, direction, up vector
            // BIS_fnc_netId, not netId: in single player every object has the same netId
            ALiVE_hub_registry set [_x call BIS_fnc_netId, [_side, true, _logic, _collect, _mlMods, typeOf _x, getPosATL _x, getDir _x, vectorUp _x]];
            _x setVariable ["ALiVE_hub", [_side, true, _radius, _logic], true];
            ALiVE_hub_list pushBackUnique _x;
        } forEach _hubs;
        publicVariable "ALiVE_hub_list";
        ["ALiVE Logistics Hub: %1 hubs of side %2, radius %3 m, Who Can Collect [%4], Collect %5", count _hubs, _side, _radius, _who, ["off (not synced to Player Combat Logistics)", "on"] select _collect] call _debug;

        // The side's catalogue, and what can't work, worked out off the frame
        [_logic, _side, _collect, _mlMods] spawn {
            params ["_logic", "_side", "_collect", "_mlMods"];
            if (_collect) then { ["sideCatalogue", [_side]] call ALIVE_fnc_hub };
            private _commanderSides = {
                ((synchronizedObjects _this) select { (_x getVariable ["moduleType", ""]) == "ALIVE_OPCOM" && {!isNil {_x getVariable "handler"}} }) apply { [_x getVariable "handler", "side", ""] call ALIVE_fnc_hashGet }
            };
            if (_collect) then {
                private _t0 = time;
                waitUntil { sleep 5; time - _t0 > 600 || {((entities "Module_F") findIf { typeOf _x == "ALiVE_mil_logistics" && {_x getVariable ["initialAnalysisComplete", false]} }) > -1} };
                private _served = (entities "Module_F") findIf { typeOf _x == "ALiVE_mil_logistics" && {_x getVariable ["initialAnalysisComplete", false]} && {_side in (_x call _commanderSides)} };
                if (_served < 0) then {
                    ["ALiVE Logistics Hub: Collect is on at the module at %1, but no Military Logistics module serves side %2, so requisitions at these hubs will be refused", mapGridPosition _logic, _side] call ALiVE_fnc_dumpR;
                };
            };
            {
                if !(_side in (_x call _commanderSides)) then {
                    ["ALiVE Logistics Hub: the Military Logistics module at %1 has no AI Commander of side %2, so the hubs of the module at %3 are no supply point for it", mapGridPosition _x, _side, mapGridPosition _logic] call ALiVE_fnc_dumpR;
                };
            } forEach _mlMods;
        };

        _logic setVariable ["startupComplete", true, true];
    };

    case "settings": {
        _args params [["_logic", objNull, [objNull]]];
        _result = if (isNull _logic) then { nil } else { _logic getVariable "ALiVE_hub_settings" };
        if (isNil "_result" || {!(_result isEqualType [])} || {count _result < 7}) then { _result = ["WEST", 10, "SIDE", "", "", "", ""] };
    };

    case "rules": {
        _args params [["_logic", objNull, [objNull]]];
        _result = if (isNull _logic) then { [] } else { _logic getVariable ["ALiVE_hub_perm_collect", []] };
        if !(_result isEqualTypeArray ["", ""]) then {
            private _s = ["settings", [_logic]] call ALIVE_fnc_hub;
            _result = [_s select 2, _s select 3];
        };
    };

    // Kept per machine once the settings are there: the lists are parsed against this machine's config
    case "catalogueRules": {
        _args params [["_logic", objNull, [objNull]]];
        _result = if (isNull _logic) then { nil } else { _logic getVariable "ALiVE_hub_catRules" };
        if (isNil "_result") then {
            private _s = if (isNull _logic) then { nil } else { _logic getVariable "ALiVE_hub_settings" };
            if (isNil "_s") exitWith { _result = createHashMap };
            _result = ["parse", [_s select 4, _s select 5, _s select 6]] call ALIVE_fnc_PRCatalogueRules;
            _logic setVariable ["ALiVE_hub_catRules", _result];
        };
    };

    case "unitSide": {
        _args params [["_unit", objNull, [objNull]]];
        private _sideText = [[side group _unit] call ALIVE_fnc_sideObjectToNumber] call ALIVE_fnc_sideNumberToText;
        if (_sideText == "CIV") then {
            _sideText = [[(faction _unit) call ALiVE_fnc_factionSide] call ALIVE_fnc_sideObjectToNumber] call ALIVE_fnc_sideNumberToText;
        };
        _result = _sideText;
    };

    // The ACE menu asks this every frame it is open: a mission with no hubs stops at the first test,
    // and one with hubs reads a handful of distances from the published list
    case "nearHub": {
        _args params [["_unit", objNull, [objNull]]];
        _result = objNull;
        if (isNull _unit || {isNil "ALiVE_hub_list"} || {ALiVE_hub_list isEqualTo []}) exitWith {};
        private _sideText = ["unitSide", [_unit]] call ALIVE_fnc_hub;
        private _best = 1e9;
        {
            private _info = _x getVariable ["ALiVE_hub", []];
            if (_info isEqualTypeArray ["", true, 0, objNull] && {_info select 1} && {(_info select 0) == _sideText}) then {
                private _d = _unit distance _x;
                if (_d <= (_info select 2) && {_d < _best}) then { _best = _d; _result = _x };
            };
        } forEach ALiVE_hub_list;
    };

    case "isAdmin": {
        _args params [["_unit", objNull, [objNull]]];
        _result = !isNull _unit && {if (hasInterface && {_unit isEqualTo player}) then { call ALiVE_fnc_isServerAdmin } else { !isMultiplayer || {isServer && {(admin owner _unit) > 0}} }};
    };

    // Who Can Collect: any ticked rule lets the unit in. No admin test here; mayCollect makes it.
    case "mayWho": {
        _args params [["_unit", objNull, [objNull]], ["_rules", "", [""]], ["_names", "", [""]]];
        _result = false;
        if (isNull _unit) exitWith {};
        private _who = (toUpper _rules) splitString "[]""', ";
        // leading a group with another player in it: anyone alone in a group of their own leads it
        private _leads = { leader group _unit isEqualTo _unit && {(units group _unit) findIf { isPlayer _x && {_x != _unit} } > -1} };
        _result = "SIDE" in _who
            || {"LEADER" in _who && _leads}
            || {"ITEM" in _who && {
                // carried, as the tablet's own access items are: standing at a command post doesn't count here
                private _pr = missionNamespace getVariable ["ALIVE_SUP_PLAYER_RESUPPLY", objNull];
                private _items = if (isNull _pr) then { "" } else { [_pr, "pr_item"] call ALIVE_fnc_PR };
                private _custom = if (isNull _pr) then { "" } else { [_pr, "pr_item_custom"] call ALIVE_fnc_PR };
                if !(_items isEqualType "") then { _items = "" };
                if !(_custom isEqualType "") then { _custom = "" };
                [_items, _custom, ["ALIVE_Tablet"], _unit, false] call ALIVE_fnc_playerHasAccessItems
            }}
            || {"LIST" in _who && {
                private _list = (toLower _names) splitString (",; " + toString [9, 10, 13]);
                // a player ID, a unit class, or the slot's variable name from Eden (P1, jtac...)
                (getPlayerUID _unit) in _list || {(toLower typeOf _unit) in _list} || {(toLower vehicleVarName _unit) in _list}
            }};
    };

    case "mayCollect": {
        _args params [["_unit", objNull, [objNull]], ["_hub", objNull, [objNull]]];
        _result = false;
        if (isNull _unit || {isNull _hub}) exitWith {};
        private _info = _hub getVariable ["ALiVE_hub", []];
        if !(_info isEqualTypeArray ["", true, 0, objNull]) exitWith {};
        if (["isAdmin", [_unit]] call ALIVE_fnc_hub) exitWith { _result = true };
        (["rules", [_info select 3]] call ALIVE_fnc_hub) params ["_rules", "_names"];
        _result = ["mayWho", [_unit, _rules, _names]] call ALIVE_fnc_hub;
    };

    // What the tablet could list for a side, built once per side with the tablet's own sort (scope 2,
    // the side or no side, the mission's blacklist and whitelist): a hashmap of lower-case class names
    case "sideCatalogue": {
        _args params [["_sideText", "WEST", [""]]];
        if (isNil "ALiVE_HUB_sideCatalogue") then { ALiVE_HUB_sideCatalogue = createHashMap };
        _result = ALiVE_HUB_sideCatalogue get _sideText;
        if (isNil "_result") then {
            private _black = missionNamespace getVariable ["ALiVE_PR_BLACKLIST", []];
            private _white = missionNamespace getVariable ["ALiVE_PR_WHITELIST", []];
            if !(_black isEqualType []) then { _black = [] };
            if !(_white isEqualType []) then { _white = [] };
            private _sorted = [_sideText, _black, _white] call ALIVE_fnc_sortCFGVehiclesByClass;
            _result = createHashMap;
            { { _result set [toLower _x, true] } forEach _x } forEach (_sorted select 2);
            ALiVE_HUB_sideCatalogue set [_sideText, _result];
            ["ALiVE Logistics Hub: side %1 catalogue holds %2 classes", _sideText, count _result] call _debug;
        };
    };

    // What a collected requisition takes from the pool, counted as a delivery counts what it makes:
    // one a vehicle, one a group, one each kind of soldiers asked for, one the crates and stores
    case "collectCost": {
        _args params [["_fm", [], [[]]]];
        private _n = 0;
        if ((_fm param [1, []]) isNotEqualTo []) then { _n = _n + 1 };
        _n = _n + count (_fm param [2, []]);
        { if ((_fm param [_x, []]) isNotEqualTo []) then { _n = _n + 1 } } forEach [3, 4, 5];
        { _n = _n + count (_fm param [_x, []]) } forEach [6, 7, 8];
        _result = _n;
    };

    // Everything a collect must pass before anything is made. The faction and the class lists come
    // from the player's machine, so each is checked against the hub here.
    case "validateCollect": {
        _args params [["_netId", "", [""]], ["_playerID", "", [""]], ["_faction", "", [""]], ["_fm", [], [[]]]];
        _result = ["", objNull, objNull, objNull];
        private _why = call {
            if !(isServer) exitWith { "not the server" };
            if (isNil "ALiVE_hub_registry" || {!(_netId in ALiVE_hub_registry)}) exitWith { format ["%1 is no hub", _netId] };
            (ALiVE_hub_registry get _netId) params ["_hubSide", "_alive", "_logic", "_collect"];
            private _hub = _netId call BIS_fnc_objectFromNetId;
            if (isNull _hub || {!_alive}) exitWith { "the hub is down" };
            if (!_collect) exitWith { "the hub's module isn't synced to Player Combat Logistics" };
            private _i = playableUnits findIf { getPlayerUID _x == _playerID };
            private _player = if (_i > -1) then { playableUnits select _i } else { if (!isMultiplayer && {hasInterface}) then { player } else { objNull } };
            if (isNull _player || {isMultiplayer && {_playerID == "" || {!isPlayer _player}}}) exitWith { format ["no player %1", _playerID] };
            // a request sent from one machine in another player's name: the tablet only ever sends its
            // own player's, so the sending machine must be the player's
            if (isRemoteExecuted && {remoteExecutedOwner > 2} && {owner _player != remoteExecutedOwner}) exitWith { format ["%1's request came from another machine", name _player] };
            _result set [1, _player]; _result set [2, _hub]; _result set [3, _logic];
            if ((["unitSide", [_player]] call ALIVE_fnc_hub) != _hubSide) exitWith { format ["%1 is not of side %2", name _player, _hubSide] };
            if (_faction == "" || {!isClass (configFile >> "CfgFactionClasses" >> _faction) && {isNil "ALIVE_factionCustomMappings" || {!(_faction in (ALIVE_factionCustomMappings select 1))}}}) exitWith { format ["no faction %1", _faction] };
            if (([[_faction call ALiVE_fnc_factionSide] call ALIVE_fnc_sideObjectToNumber] call ALIVE_fnc_sideNumberToText) != _hubSide) exitWith { format ["faction %1 is not of side %2", _faction, _hubSide] };
            private _radius = (["settings", [_logic]] call ALIVE_fnc_hub) select 1;
            if (_player distance _hub > _radius + 2) exitWith { format ["%1 is %2 m from the hub", name _player, round (_player distance _hub)] };
            if !(["mayCollect", [_player, _hub]] call ALIVE_fnc_hub) exitWith { format ["%1 may not collect here (Who Can Collect)", name _player] };

            // the shape the tablet sends, and nothing else: crates as class names, vehicles and soldiers
            // as [class, info], groups as [group, [kind, faction, category]]. Anything else is refused,
            // as is a vehicle among the crates or a vehicle among the soldiers.
            private _isPair = { _x isEqualType [] && {(_x param [0, 0]) isEqualType ""} };
            if (count _fm < 9 || {(_fm select [1, 8]) findIf { !(_x isEqualType []) } > -1}) exitWith { "a malformed request" };
            if ((_fm select 1) findIf { !(_x isEqualType "") } > -1) exitWith { "a malformed request" };
            if ({ (_fm select _x) findIf { !(call _isPair) } > -1 } count [2, 3, 4, 5, 6, 7, 8] > 0) exitWith { "a malformed request" };
            if ({ (_fm select _x) findIf { !((_x param [1, 0]) isEqualType []) } > -1 } count [6, 7, 8] > 0) exitWith { "a malformed request" };
            if (count (_fm select 1) > 30) exitWith { "over the load of crates and stores" };
            if ((_fm select 1) findIf { _x isKindOf "Man" || {_x isKindOf "LandVehicle"} || {_x isKindOf "Air"} || {_x isKindOf "Ship"} } > -1) exitWith { "a vehicle or soldier among the crates" };
            if ((_fm select 2) findIf { !((_x select 0) isKindOf "AllVehicles") || {(_x select 0) isKindOf "Man"} } > -1) exitWith { "something other than a vehicle among the vehicles" };
            if ({ (_fm select _x) findIf { !((_x select 0) isKindOf "Man") } > -1 } count [3, 4, 5] > 0) exitWith { "something other than a soldier among the soldiers" };

            // convoy limits: 5 groups, 5 vehicles, 8 soldiers
            private _groups = 0; { _groups = _groups + count (_fm param [_x, []]) } forEach [6, 7, 8];
            private _men = 0; { _men = _men + count (_fm param [_x, []]) } forEach [3, 4, 5];
            if (_groups > 5 || {count (_fm param [2, []]) > 5} || {_men > 8}) exitWith { "over the convoy limit" };
            if (["collectCost", [_fm]] call ALIVE_fnc_hub == 0) exitWith { "nothing asked for" };

            // every class: in the side's catalogue or an Also list, then the hub's lists
            private _sideCat = ["sideCatalogue", [_hubSide]] call ALIVE_fnc_hub;
            private _hubRules = ["catalogueRules", [_logic]] call ALIVE_fnc_hub;
            private _pr = missionNamespace getVariable ["ALIVE_SUP_PLAYER_RESUPPLY", objNull];
            private _prRules = if (isNull _pr) then { createHashMap } else { _pr getVariable ["pr_catalogueRules", createHashMap] };
            private _alsoLower = ((_hubRules getOrDefault ["alsoClasses", []]) + (_prRules getOrDefault ["alsoClasses", []])) apply { toLower _x };
            private _classes = (_fm param [1, []]) select { _x isEqualType "" };
            { { _classes pushBack (_x select 0) } forEach (_fm select _x) } forEach [2, 3, 4, 5];
            private _bad = _classes findIf {
                !(_x isEqualType "") || {!isClass (configFile >> "CfgVehicles" >> _x)}
                || {!((toLower _x) in _sideCat) && {!((toLower _x) in _alsoLower)}}
                || {!(["allows", [_hubRules, _x]] call ALIVE_fnc_PRCatalogueRules)}
            };
            if (_bad > -1) exitWith { format ["%1 is not offered at this hub", _classes select _bad] };

            // every group: one of the side's, under its faction, and allowed by the hub's lists
            private _sideConfig = configFile >> "CfgGroups" >> (["West", "East", "Indep"] select ((["WEST", "EAST", "GUER"] find _hubSide) max 0));
            private _badGroup = "";
            {
                {
                    if (_badGroup != "") exitWith {};
                    _x params [["_group", ""], ["_info", []]];
                    private _gFaction = if (_info isEqualType []) then { _info param [1, ""] } else { "" };
                    private _ok = _group isEqualType "" && {_gFaction isEqualType ""} && {_gFaction != ""};
                    if (_ok) then {
                        // the groups may sit under the faction a custom mapping names (Guerilla for BLU_G_F)
                        private _folders = [_gFaction];
                        if (!isNil "ALIVE_factionCustomMappings" && {_gFaction in (ALIVE_factionCustomMappings select 1)}) then {
                            private _m = [ALIVE_factionCustomMappings, _gFaction] call ALIVE_fnc_hashGet;
                            private _f = [_m, "GroupFactionName", ""] call ALIVE_fnc_hashGet;
                            if (_f isEqualType "" && {_f != ""}) then { _folders pushBackUnique _f };
                        };
                        private _gFactionSide = if (isClass (configFile >> "CfgFactionClasses" >> _gFaction)) then { [[_gFaction call ALiVE_fnc_factionSide] call ALIVE_fnc_sideObjectToNumber] call ALIVE_fnc_sideNumberToText } else { "" };
                        _ok = _gFactionSide == _hubSide && {
                            (_folders findIf {
                                private _fc = _sideConfig >> _x;
                                isClass _fc && {(("true" configClasses _fc) findIf { isClass (_x >> _group) }) > -1}
                            }) > -1
                        } && {["allowsGroup", [_hubRules, _gFaction, _group]] call ALIVE_fnc_PRCatalogueRules};
                    };
                    if (!_ok) then { _badGroup = format ["%1", _group] };
                } forEach (_fm param [_x, []]);
            } forEach [6, 7, 8];
            if (_badGroup != "") exitWith { format ["the group %1 is not offered at this hub", _badGroup] };
            ""
        };
        _result set [0, _why];
    };

    // An admin's change to Who Can Collect, through ALIVE_fnc_hubRequest only. Holds until the
    // mission restarts.
    case "permissions": {
        _result = false;
        _args params [["_rules", "", [""]], ["_names", "", [""]], ["_netId", "", [""]]];
        if (isNil "_ALiVE_hubCaller") exitWith {};
        private _caller = _ALiVE_hubCaller;
        if (isNull _caller || {!(["isAdmin", [_caller]] call ALIVE_fnc_hub)}) exitWith {
            ["ALiVE Logistics Hub - %1 asked to change who can collect, but is no admin", name _caller] call ALiVE_fnc_dump;
        };
        _rules = (((toUpper _rules) splitString "[]""', ") select { _x in ["SIDE", "LEADER", "ITEM", "LIST"] }) joinString ",";
        _names = toString (((toArray _names) select { _x >= 32 && {!(_x in [34, 38, 39, 60, 62])} }) select [0, 2000]);
        if (_netId != "" && {isNil "ALiVE_hub_registry" || {!(_netId in ALiVE_hub_registry)}}) exitWith {
            ["ALiVE Logistics Hub - %1 named %2, which is no hub, so nothing changed", name _caller, _netId] call ALiVE_fnc_dump;
            ["ALiVE", localize "STR_ALIVE_HUB_PERMISSIONS_NONE"] remoteExec ["ALIVE_fnc_sendHint", owner _caller];
        };
        private _modules = if (_netId == "") then { missionNamespace getVariable ["ALiVE_hub_modules", []] } else { [(ALiVE_hub_registry get _netId) select 2] };
        { _x setVariable ["ALiVE_hub_perm_collect", [_rules, _names], true] } forEach _modules;
        ["ALiVE Logistics Hub - %1 set who can collect to [%2], list [%3], on %4 module(s)", name _caller, _rules, _names, count _modules] call ALiVE_fnc_dump;
        ["ALiVE", format [localize "STR_ALIVE_HUB_PERMISSIONS_SET", count _modules]] remoteExec ["ALIVE_fnc_sendHint", owner _caller];
        _result = true;
    };
};

if (isNil "_result") then { nil } else { _result }
