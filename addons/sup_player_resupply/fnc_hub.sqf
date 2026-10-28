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

Synced to Military Logistics, each hub is also a point the AI Commanders of its side supply from:
a delivery or a resupply convoy sets off from the nearest one, as from the commander's own position.

A hub can be lost: destroyed, dismantled by the enemy with nobody of its side within 60 m, or
dismantled by its own side (Who Can Dismantle; admins always). While it is down nothing is
collected there and it supplies nothing. With a Repair Time it comes back after that many seconds.

The module's settings exist only on the server, as Eden puts them there, so the server publishes
what players' machines need: on each hub ALiVE_hub = [side, alive, radius, module], on each module
ALiVE_hub_settings = [side, radius, who, names, only, never, also, enemy can dismantle, dismantle
time, repair time, dismantle who, dismantle names], and the list of hubs as ALiVE_hub_list.

Parameters:
    ["init", [module]] - server: reads the settings, tags the synced objects
    ["tag", [object, module]] - server: makes the object one of the module's hubs, with its hold actions
    ["settings", [module]] - the settings above, any machine
    ["rules", [module, kind]] - Who Can Collect (kind "COLLECT", the default) or Who Can Dismantle
        ("DISMANTLE") as [rules, names]: an admin's in-game change, or the module's
    ["catalogueRules", [module]] - the module's three lists read by ALIVE_fnc_PRCatalogueRules
    ["unitSide", [unit]] - the unit's side as text, a civilian-side player counted by faction
    ["nearHub", [unit]] - the nearest working hub of the unit's side within its radius, or objNull
    ["isAdmin", [unit]] - a logged-in or voted admin, or anyone in single player
    ["mayWho", [unit, rules, names]] - whether Who Can Collect style rules let the unit in
    ["mayCollect", [unit, hub]] - an admin, or let in by the hub's module
    ["mayDismantle", [unit, hub]] - the same, for its own side's hold action
    ["sideCatalogue", [sideText]] - server: every class the tablet could list for that side, lower case
    ["validateCollect", [hubNetId, playerID, faction, forceMakeup, sender]] - server: "" when the requisition
        may be collected, else why not; with the player, hub and module. sender is the machine the
        request came from, as ALIVE_fnc_addEventToServer noted it (-1 when it came from the server's own machine)
    ["collectCost", [forceMakeup]] - what a collected requisition takes from the force pool
    ["commanderFactions", [side, mlModules]] - server: the factions of those modules' AI Commanders of that side
    ["nodeAdd", [hub]] - server: the hub joins its side's supply network, for every such faction
    ["nodeRemove", [hubNetId]] - server: it leaves it again (a delivery's units merged into it stay as a plain node)
    ["permissions", [rules, names, hubNetId, kind]] - server, through ALIVE_fnc_hubRequest: an admin's change
        to Who Can Collect (kind "COLLECT", the default) or Who Can Dismantle ("DISMANTLE"), for one hub's
        module or (hubNetId "") for every module
    ["dismantle", [hubNetId]] - server, through ALIVE_fnc_hubRequest: a player's hold action finished
    ["hubDown", [hubNetId, destroyed, byName, byEnemy]] - server: the hub stops working, and with a
        Repair Time comes back later
    ["hubRestore", [hubNetId]] - server: the hub works again, rebuilt if it can't be mended

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
        private _dismantle = (toLower (["hub_dismantle", "true"] call _text)) in ["true", "1", "yes"];
        private _dismantleTime = parseNumber (["hub_dismantle_time", "15"] call _text);
        if (_dismantleTime <= 0) then { _dismantleTime = 15 };
        _dismantleTime = (_dismantleTime max 1) min 120;
        private _repairTime = (parseNumber (["hub_repair_time", "0"] call _text)) max 0;
        private _dWho = toUpper (["hub_dismantle_who", ""] call _text);
        _dWho = (((_dWho splitString "[]""', ") select { _x in ["SIDE", "LEADER", "ITEM", "LIST"] }) joinString ",");
        private _settings = [_side, _radius, _who, _names, ["hub_only", ""] call _text, ["hub_never", ""] call _text, ["hub_also", ""] call _text,
            _dismantle, _dismantleTime, _repairTime, _dWho, ["hub_dismantle_list", ""] call _text];
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
        _logic setVariable ["ALiVE_hub_mlMods", _mlMods];
        { ["tag", [_x, _logic]] call ALIVE_fnc_hub } forEach _hubs;
        publicVariable "ALiVE_hub_list";
        ["ALiVE Logistics Hub: %1 hubs of side %2, radius %3 m, Who Can Collect [%4], Collect %5, enemy can dismantle %6, repair %7 s, Who Can Dismantle [%8]",
            count _hubs, _side, _radius, _who, ["off (not synced to Player Combat Logistics)", "on"] select _collect, _dismantle, _repairTime, _dWho] call _debug;

        // The side's catalogue, what can't work, and the hubs' place in the supply network, worked
        // out off the frame
        [_logic, _side, _collect, _mlMods, _hubs] spawn {
            params ["_logic", "_side", "_collect", "_mlMods", "_hubs"];
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

            // Supply points: once Military Logistics has set up its network, after its first look at
            // the objectives
            if (_mlMods isEqualTo []) exitWith {};
            private _t1 = time;
            waitUntil { sleep 5; time - _t1 > 600 || {(_mlMods findIf { !(_x getVariable ["initialAnalysisComplete", false]) }) < 0} };
            if (isNil "ALIVE_ML_supplyNetwork") exitWith {
                ["ALiVE Logistics Hub: Military Logistics has no supply network after 10 minutes, so the hubs of the module at %1 are no supply point", mapGridPosition _logic] call ALiVE_fnc_dumpR;
            };
            { ["nodeAdd", [_x]] call ALIVE_fnc_hub } forEach _hubs;
        };

        _logic setVariable ["startupComplete", true, true];
    };

    // One object becomes a hub: in the registry, its state broadcast, on the public list, a handler for
    // its destruction and the two dismantle hold actions. The actions are added once and never removed:
    // their conditions read the hub's state, so they hide while it is down and show again after a repair.
    case "tag": {
        _args params [["_hub", objNull, [objNull]], ["_logic", objNull, [objNull]]];
        if (!isServer || {isNull _hub} || {isNull _logic}) exitWith {};
        private _s = ["settings", [_logic]] call ALIVE_fnc_hub;
        private _side = _s select 0;
        // BIS_fnc_netId, not netId: in single player every object has the same netId
        private _netId = _hub call BIS_fnc_netId;
        // side, alive, owning module, offers Collect, source Military Logistics modules, and what a
        // rebuild needs: class, position, direction, up vector
        ALiVE_hub_registry set [_netId, [_side, true, _logic, _logic getVariable ["ALiVE_hub_collect", false], _logic getVariable ["ALiVE_hub_mlMods", []],
            typeOf _hub, getPosATL _hub, getDir _hub, vectorUp _hub]];
        _hub setVariable ["ALiVE_hub", [_side, true, _s select 1, _logic], true];
        ALiVE_hub_list pushBackUnique _hub;

        // MPKilled, not Killed: Killed fires only where the object is local, and a crate can move to a player's machine
        _hub addMPEventHandler ["MPKilled", {
            params ["_hub"];
            if (isServer) then { ["hubDown", [_hub call BIS_fnc_netId, true]] call ALIVE_fnc_hub };
        }];
        // deleted by Zeus or a script: down as if destroyed, so the AI stop sending convoys from an empty spot
        _hub setVariable ["ALiVE_hub_netId", _netId];
        _hub addEventHandler ["Deleted", {
            params ["_hub"];
            ["hubDown", [_hub getVariable ["ALiVE_hub_netId", ""], true]] call ALIVE_fnc_hub;
        }];

        private _icon = "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa";
        private _done = {
            params ["_target"];
            ["dismantle", [_target call BIS_fnc_netId]] remoteExecCall ["ALIVE_fnc_hubRequest", 2];
        };
        // the enemy: none of the hub's side within 60 m, as for the insurgents' roadblocks
        if (_s select 7) then {
            [_hub, localize "STR_ALIVE_HUB_ACTION_DISMANTLE", _icon, _icon,
                "_this distance2D _target < (8 max ((sizeOf typeOf _target) / 2)) && {(_target getVariable ['ALiVE_hub', []]) params [['_s', ''], ['_a', false]]; _a && {private _hs = [_s] call ALIVE_fnc_sideTextToObject; [side group _this, _hs] call BIS_fnc_sideIsEnemy && {({alive _x && {side group _x == _hs}} count (_target nearEntities [['CAManBase', 'LandVehicle', 'StaticWeapon'], 60])) == 0}}}",
                "_caller distance2D _target < (8 max ((sizeOf typeOf _target) / 2))", {}, {}, _done, {}, [], _s select 8, 6, false
            // a dedicated server has no player to hold it
            ] remoteExec ["BIS_fnc_holdActionAdd", [0, -2] select isDedicated, "ALiVE_hub_enemy_" + _netId];
        };
        // its own side: Who Can Dismantle, admins always
        [_hub, localize "STR_ALIVE_HUB_ACTION_DISMANTLE", _icon, _icon,
            "_this distance2D _target < (8 max ((sizeOf typeOf _target) / 2)) && {(_target getVariable ['ALiVE_hub', []]) params [['_s', ''], ['_a', false]]; _a && {(['unitSide', [_this]] call ALIVE_fnc_hub) == _s} && {['mayDismantle', [_this, _target]] call ALIVE_fnc_hub}}",
            "_caller distance2D _target < (8 max ((sizeOf typeOf _target) / 2))", {}, {}, _done, {}, [], _s select 8, 6, false
        ] remoteExec ["BIS_fnc_holdActionAdd", [0, -2] select isDedicated, "ALiVE_hub_own_" + _netId];
    };

    case "settings": {
        _args params [["_logic", objNull, [objNull]]];
        _result = if (isNull _logic) then { nil } else { _logic getVariable "ALiVE_hub_settings" };
        if (isNil "_result" || {!(_result isEqualType [])} || {count _result < 12}) then { _result = ["WEST", 10, "SIDE", "", "", "", "", true, 15, 0, "", ""] };
    };

    case "rules": {
        _args params [["_logic", objNull, [objNull]], ["_kind", "COLLECT", [""]]];
        private _dismantle = _kind == "DISMANTLE";
        _result = if (isNull _logic) then { [] } else { _logic getVariable [["ALiVE_hub_perm_collect", "ALiVE_hub_perm_dismantle"] select _dismantle, []] };
        if !(_result isEqualTypeArray ["", ""]) then {
            private _s = ["settings", [_logic]] call ALIVE_fnc_hub;
            _result = [[_s select 2, _s select 3], [_s select 10, _s select 11]] select _dismantle;
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

    case "mayDismantle": {
        _args params [["_unit", objNull, [objNull]], ["_hub", objNull, [objNull]]];
        _result = false;
        if (isNull _unit || {isNull _hub}) exitWith {};
        private _info = _hub getVariable ["ALiVE_hub", []];
        if !(_info isEqualTypeArray ["", true, 0, objNull]) exitWith {};
        if (["isAdmin", [_unit]] call ALIVE_fnc_hub) exitWith { _result = true };
        (["rules", [_info select 3, "DISMANTLE"]] call ALIVE_fnc_hub) params ["_rules", "_names"];
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

    // The factions of the AI Commanders of a side among those synced to these Military Logistics modules
    case "commanderFactions": {
        _args params [["_side", "", [""]], ["_mlMods", [], [[]]]];
        _result = [];
        {
            {
                if ((_x getVariable ["moduleType", ""]) == "ALIVE_OPCOM" && {!isNil {_x getVariable "handler"}}) then {
                    private _h = _x getVariable "handler";
                    if (([_h, "side", ""] call ALIVE_fnc_hashGet) == _side) then {
                        { _result pushBackUnique _x } forEach ([_h, "factions", []] call ALIVE_fnc_hashGet);
                    };
                };
            } forEach (synchronizedObjects _x);
        } forEach _mlMods;
    };

    // A hub in the supply network is [position, profile IDs, false, "HUB", its netId]: Military Logistics
    // counts it while it is there, with no profiles of its own
    case "nodeAdd": {
        _args params [["_hub", objNull, [objNull]]];
        _result = 0;
        if (!isServer || {isNull _hub} || {isNil "ALIVE_ML_supplyNetwork"} || {isNil "ALiVE_hub_registry"}) exitWith {};
        private _netId = _hub call BIS_fnc_netId;
        private _entry = ALiVE_hub_registry getOrDefault [_netId, []];
        if (count _entry < 5 || {!(_entry select 1)}) exitWith {};
        private _factions = ["commanderFactions", [_entry select 0, _entry select 4]] call ALIVE_fnc_hub;
        {
            private _nodes = [ALIVE_ML_supplyNetwork, _x, []] call ALIVE_fnc_hashGet;
            if ((_nodes findIf { (_x param [4, ""]) isEqualTo _netId }) < 0) then {
                _nodes pushBack [getPosATL _hub, [], false, "HUB", _netId];
                [ALIVE_ML_supplyNetwork, _x, _nodes] call ALIVE_fnc_hashSet;
            };
        } forEach _factions;
        _result = count _factions;
        ["ALiVE Logistics Hub: %1 at %2 is a supply point for %3", typeOf _hub, mapGridPosition _hub, _factions] call _debug;
    };

    case "nodeRemove": {
        _args params [["_netId", "", [""]]];
        if (!isServer || {_netId == ""} || {isNil "ALIVE_ML_supplyNetwork"}) exitWith {};
        {
            private _nodes = [ALIVE_ML_supplyNetwork, _x, []] call ALIVE_fnc_hashGet;
            private _i = _nodes findIf { (_x param [4, ""]) isEqualTo _netId };
            if (_i > -1) then {
                private _ids = (_nodes select _i) select 1;
                // a delivery that finished beside the hub merged its units in: they stay as a plain node
                if (_ids isEqualTo []) then { _nodes deleteAt _i } else { _nodes set [_i, [(_nodes select _i) select 0, _ids]] };
                [ALIVE_ML_supplyNetwork, _x, _nodes] call ALIVE_fnc_hashSet;
            };
        } forEach (ALIVE_ML_supplyNetwork select 1);
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
        _args params [["_netId", "", [""]], ["_playerID", "", [""]], ["_faction", "", [""]], ["_fm", [], [[]]], ["_sender", -1, [0]]];
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
            // own player's, so the machine that sent it must be the player's. A player on the server's
            // own machine (a hosted game's host) sends straight to the event log, so has no sender.
            if (isMultiplayer && {_sender != ([owner _player, -1] select (local _player))}) exitWith { format ["%1's request came from another machine", name _player] };
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
        _args params [["_rules", "", [""]], ["_names", "", [""]], ["_netId", "", [""]], ["_kind", "COLLECT", [""]]];
        if (isNil "_ALiVE_hubCaller") exitWith {};
        private _caller = _ALiVE_hubCaller;
        _kind = toUpper _kind;
        if !(_kind in ["COLLECT", "DISMANTLE"]) exitWith {};
        private _what = ["collect", "dismantle"] select (_kind == "DISMANTLE");
        if (isNull _caller || {!(["isAdmin", [_caller]] call ALIVE_fnc_hub)}) exitWith {
            ["ALiVE Logistics Hub - %1 asked to change who can %2, but is no admin", name _caller, _what] call ALiVE_fnc_dump;
        };
        _rules = (((toUpper _rules) splitString "[]""', ") select { _x in ["SIDE", "LEADER", "ITEM", "LIST"] }) joinString ",";
        _names = toString (((toArray _names) select { _x >= 32 && {!(_x in [34, 38, 39, 60, 62])} }) select [0, 2000]);
        if (_netId != "" && {isNil "ALiVE_hub_registry" || {!(_netId in ALiVE_hub_registry)}}) exitWith {
            ["ALiVE Logistics Hub - %1 named %2, which is no hub, so nothing changed", name _caller, _netId] call ALiVE_fnc_dump;
            ["ALiVE", localize "STR_ALIVE_HUB_PERMISSIONS_NONE"] remoteExec ["ALIVE_fnc_sendHint", owner _caller];
        };
        private _modules = if (_netId == "") then { missionNamespace getVariable ["ALiVE_hub_modules", []] } else { [(ALiVE_hub_registry get _netId) select 2] };
        { _x setVariable [["ALiVE_hub_perm_collect", "ALiVE_hub_perm_dismantle"] select (_kind == "DISMANTLE"), [_rules, _names], true] } forEach _modules;
        ["ALiVE Logistics Hub - %1 set who can %2 to [%3], list [%4], on %5 module(s)", name _caller, _what, _rules, _names, count _modules] call ALiVE_fnc_dump;
        ["ALiVE", format [localize (["STR_ALIVE_HUB_PERMISSIONS_SET", "STR_ALIVE_HUB_PERMISSIONS_SET_DISMANTLE"] select (_kind == "DISMANTLE")), count _modules]] remoteExec ["ALIVE_fnc_sendHint", owner _caller];
        _result = true;
    };

    // A player's dismantle hold action finished; everything it showed on their machine is asked again
    case "dismantle": {
        _result = false;
        _args params [["_netId", "", [""]]];
        if (isNil "_ALiVE_hubCaller") exitWith {};
        private _caller = _ALiVE_hubCaller;
        if (isNull _caller || {!alive _caller} || {isNil "ALiVE_hub_registry"} || {!(_netId in ALiVE_hub_registry)}) exitWith {};
        private _e = ALiVE_hub_registry get _netId;
        private _hub = _netId call BIS_fnc_objectFromNetId;
        private _why = call {
            if (!(_e select 1) || {isNull _hub}) exitWith { "the hub is down" };
            // a large building is reached at its walls, not its centre
            if (_caller distance2D _hub > (10 max ((sizeOf typeOf _hub) / 2 + 2))) exitWith { format ["%1 is %2 m from it", name _caller, round (_caller distance2D _hub)] };
            if ((["unitSide", [_caller]] call ALIVE_fnc_hub) == (_e select 0)) exitWith {
                ["", format ["%1 may not dismantle it (Who Can Dismantle)", name _caller]] select !(["mayDismantle", [_caller, _hub]] call ALIVE_fnc_hub)
            };
            private _hs = [_e select 0] call ALIVE_fnc_sideTextToObject;
            if !((["settings", [_e select 2]] call ALIVE_fnc_hub) select 7) exitWith { "the enemy can't dismantle it" };
            if !([side group _caller, _hs] call BIS_fnc_sideIsEnemy) exitWith { format ["%1 is not its enemy", name _caller] };
            // its side's soldiers, spawned, or held by ALiVE as profiles not spawned (a spawned one is already counted above)
            if (({alive _x && {side group _x == _hs}} count (_hub nearEntities [["CAManBase", "LandVehicle", "StaticWeapon"], 60])) > 0
                || {!isNil "ALiVE_profileSystem" && {(([getPosATL _hub, 60, [_e select 0, "entity"], true] call ALIVE_fnc_getNearProfiles) findIf { !([_x, "active", false] call ALIVE_fnc_hashGet) }) >= 0}}) exitWith {
                ["ALiVE", localize "STR_ALIVE_HUB_DISMANTLE_DEFENDED"] remoteExec ["ALIVE_fnc_sendHint", owner _caller];
                "its side is within 60 m"
            };
            ""
        };
        if (_why != "") exitWith {
            ["ALiVE Logistics Hub - %1 asked to dismantle %2, refused: %3", name _caller, _netId, _why] call ALiVE_fnc_dump;
        };
        private _enemy = (["unitSide", [_caller]] call ALIVE_fnc_hub) != (_e select 0);
        ["hubDown", [_netId, false, name _caller, _enemy]] call ALIVE_fnc_hub;
        if (_enemy) then {
            ["ALiVE", format [localize "STR_ALIVE_HUB_DISMANTLED_BY_US", mapGridPosition _hub]] remoteExec ["ALIVE_fnc_sendHint", side group _caller];
        };
        _result = true;
    };

    case "hubDown": {
        _args params [["_netId", "", [""]], ["_destroyed", false, [false]], ["_by", "", [""]], ["_enemy", false, [false]]];
        if (!isServer || {isNil "ALiVE_hub_registry"} || {!(_netId in ALiVE_hub_registry)}) exitWith {};
        private _e = ALiVE_hub_registry get _netId;
        if !(_e select 1) exitWith {};
        _e set [1, false];
        private _logic = _e select 2;
        private _s = ["settings", [_logic]] call ALIVE_fnc_hub;
        private _hub = _netId call BIS_fnc_objectFromNetId;
        if (!isNull _hub) then { _hub setVariable ["ALiVE_hub", [_e select 0, false, _s select 1, _logic], true] };
        ["nodeRemove", [_netId]] call ALIVE_fnc_hub;
        private _grid = mapGridPosition (_e select 6);
        private _msg = if (_destroyed) then { format [localize "STR_ALIVE_HUB_LOST", _grid] } else {
            if (_enemy) then { format [localize "STR_ALIVE_HUB_DISMANTLED", _grid] } else { format [localize "STR_ALIVE_HUB_DISMANTLED_OWN", _grid, _by] }
        };
        ["ALiVE", _msg] remoteExec ["ALIVE_fnc_sendHint", [_e select 0] call ALIVE_fnc_sideTextToObject];
        ["ALiVE Logistics Hub: %1 at %2 is down (%3)", _e select 5, _grid, ["dismantled", "destroyed"] select _destroyed] call _debug;

        // a repair later, unless it is down and back up again before then
        if (isNil "ALiVE_hub_downs") then { ALiVE_hub_downs = createHashMap };
        private _n = (ALiVE_hub_downs getOrDefault [_netId, 0]) + 1;
        ALiVE_hub_downs set [_netId, _n];
        if ((_s select 9) > 0) then {
            [_netId, _s select 9, _n] spawn {
                params ["_netId", "_wait", "_n"];
                sleep _wait;
                if ((ALiVE_hub_downs getOrDefault [_netId, 0]) == _n) then { ["hubRestore", [_netId]] call ALIVE_fnc_hub };
            };
        };
    };

    case "hubRestore": {
        _args params [["_netId", "", [""]]];
        if (!isServer || {isNil "ALiVE_hub_registry"} || {!(_netId in ALiVE_hub_registry)}) exitWith {};
        private _e = ALiVE_hub_registry get _netId;
        if (_e select 1) exitWith {};
        _e params ["_side", "", "_logic", "", "", "_class", "_pos", "_dir", "_up"];
        private _hub = _netId call BIS_fnc_objectFromNetId;
        // mended where it stands, and its ruins cleared; a dismantled hub has none, so nothing nearby is touched
        if (isNull _hub || {!alive _hub}) then {
            if (!isNull _hub) then { _hub setDamage 0 };
            { if ((_x distance2D _pos) <= 10) then { deleteVehicle _x } } forEach (nearestObjects [_pos, ["Ruins_F"], 15]);
        };
        if (isNull _hub || {!alive _hub}) then {
            // it can't be mended: a new one of the same kind in the same place, a hub under its own id
            if (!isNull _hub) then { deleteVehicle _hub };
            remoteExec ["", "ALiVE_hub_enemy_" + _netId];
            remoteExec ["", "ALiVE_hub_own_" + _netId];
            ALiVE_hub_registry deleteAt _netId;
            ALiVE_hub_list = ALiVE_hub_list select { !isNull _x && {_x != _hub} };
            _hub = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];
            _hub setDir _dir;
            _hub setVectorUp _up;
            _hub setPosATL _pos;
            // a moment for players' machines to learn of the new object before its hold actions are sent
            if (canSuspend) then { sleep 1 };
            ["tag", [_hub, _logic]] call ALIVE_fnc_hub;
            publicVariable "ALiVE_hub_list";
            ["ALiVE Logistics Hub: %1 at %2 could not be mended, so a new one stands in its place", _class, mapGridPosition _pos] call _debug;
        } else {
            _e set [1, true];
            _hub setVariable ["ALiVE_hub", [_side, true, (["settings", [_logic]] call ALIVE_fnc_hub) select 1, _logic], true];
        };
        ["nodeAdd", [_hub]] call ALIVE_fnc_hub;
        ["ALiVE", format [localize "STR_ALIVE_HUB_BACK", mapGridPosition _pos]] remoteExec ["ALIVE_fnc_sendHint", [_side] call ALIVE_fnc_sideTextToObject];
    };
};

if (isNil "_result") then { nil } else { _result }
