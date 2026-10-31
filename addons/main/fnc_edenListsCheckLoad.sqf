/* ----------------------------------------------------------------------------
Eden attribute load: ALiVE_ListsCheck

Description:
The Check button on the resupply tablet, Logistics Hub and Player FOBs modules (Lists start-up report). It reads the
module's list settings as last saved with OK and says, in a message, which list it uses, what the lists keep, and which
names in them aren't a vehicle, crate, soldier, gear item or group in this game, the same checks the mission's start-up
report makes. What players are finally offered isn't known until the mission runs: it depends on the player's side and
the AI Commanders.

Parameters:
Control - the attribute's controls group

Author:
Jman
---------------------------------------------------------------------------- */

params [["_group", controlNull, [controlNull]]];
private _btn = _group controlsGroupCtrl 310;
if (isNull _btn) exitWith {};

_btn ctrlAddEventHandler ["ButtonClick", {
    private _ent = (get3DENSelected "logic") param [0, objNull];
    if (isNull _ent) exitWith {};
    private _get = {
        private _v = (_ent get3DENAttribute _this) param [0, ""];
        if (_v isEqualType []) then { _v = _v joinString "," };
        if (_v isEqualType "") then { _v } else { "" }
    };
    // a list's name, Custom read from its name box; empty, or one no list has, is the default
    private _listOf = {
        params ["_comboProp", "_nameProp", "_default"];
        private _n = _comboProp call _get;
        if (_n == "CUSTOM") then { _n = trim (_nameProp call _get) };
        private _known = _n != "" && {isClass (missionConfigFile >> "CfgALiVELists" >> _n) || {isClass (configFile >> "CfgALiVELists" >> _n)}};
        [[_default, _n] select _known, _n != "" && {!_known}, _n]
    };
    // edits since the last check count: the lists are read afresh
    ["reset"] call ALIVE_fnc_lists;
    private _lines = [];
    // ["a","b","c"] -> "a, b and c"
    private _fnc_and = {
        if (count _this < 2) exitWith { _this joinString "" };
        format ["%1 and %2", (_this select [0, count _this - 1]) joinString ", ", _this select (count _this - 1)]
    };
    // what a set of rules keeps, as plain sentences; _boxes are this module's own names for its Only, Never and Also boxes
    private _fnc_explain = {
        params ["_rules", "_boxes", "_listName"];
        _boxes params ["_onlyBox", "_neverBox", "_alsoBox"];
        private _out = [];
        private _kindWords = createHashMapFromArray [["FORTIFICATION", "fortifications"], ["SUPPLY", "supply crates"], ["STATIC", "static weapons"], ["VEHICLE", "vehicles"], ["TROOPS", "troops"], ["GEAR", "gear"]];
        private _vehWords = createHashMapFromArray [["CAR", "cars"], ["TRUCK", "trucks"], ["ARMOUR", "armour"], ["ARTILLERY", "artillery"], ["AIR", "aircraft"], ["BOAT", "boats"]];
        private _kinds = _rules getOrDefault ["kinds", []];
        _out pushBack (if (_kinds isEqualTo [] || {(keys _kindWords) findIf { !(_x in _kinds) } < 0}) then {
            "It can offer every kind of thing: fortifications, supply crates, static weapons, vehicles, troops and gear."
        } else {
            format ["It can offer %1, and no other kind.", (_kinds apply { _kindWords getOrDefault [_x, toLower _x] }) call _fnc_and]
        });
        private _has = { _kinds isEqualTo [] || {_this in _kinds} };
        private _vk = _rules getOrDefault ["vehicleKinds", []];
        if (_vk isNotEqualTo [] && {"VEHICLE" call _has}) then {
            _out pushBack (if (_vk isEqualTo ["NONE"]) then { "Vehicles: none." } else {
                format ["Vehicles: only %1.", (_vk apply { _vehWords getOrDefault [_x, toLower _x] }) call _fnc_and]
            });
        };
        private _tier = _rules getOrDefault ["staticTier", -1];
        if (_tier >= 0 && {"STATIC" call _has}) then {
            _out pushBack (switch (true) do {
                case (_tier >= 3): { "Static weapons: light and heavy." };
                case (_tier == 2): { "Static weapons: machine guns and grenade launchers only, nothing heavier." };
                default { "Static weapons: none." };
            });
        };
        if (_rules getOrDefault ["fieldWorksOnly", false] && {"FORTIFICATION" call _has}) then { _out pushBack "Fortifications: only low field works, 3 m high or less." };
        if ((_rules getOrDefault ["fold", -1]) > 0) then {
            _out pushBack "One of each model is shown, without its camo and loadout versions.";
        };
        private _n = { params ["_box"]; count (_rules getOrDefault [_box + "Classes", []]) + count (_rules getOrDefault [_box + "Groups", []]) + count (_rules getOrDefault [_box + "Gear", []]) };
        private _items = { [format ["%1 named items", _this], "1 named item"] select (_this == 1) };
        private _only = ["only"] call _n;
        private _never = ["never"] call _n;
        private _also = ["also"] call _n;
        if (_only > 0) then { _out pushBack format ["Only %1 can be had, nothing else.", _only call _items] };
        if (_never > 0) then { _out pushBack format ["%1 can never be had.", _never call _items] };
        if (_also > 0) then { _out pushBack format ["%1 can be had on top of the kinds above.", _also call _items] };
        private _prices = count (_rules getOrDefault ["prices", createHashMap]);
        if (_prices > 0) then { _out pushBack format ["%1 its own price.", [format ["%1 items have", _prices], "1 item has"] select (_prices == 1)] };
        // names that aren't in this game: typed in one of the module's boxes, or written in the list itself
        private _boxOf = createHashMapFromArray [["Only", _onlyBox], ["Never", _neverBox], ["Also", _alsoBox]];
        private _bad = ((_rules getOrDefault ["missing", []]) apply { format ["- %1, typed in %2", _x select 0, _boxOf getOrDefault [_x select 1, _x select 1]] })
            + ((_rules getOrDefault ["listMissing", []]) apply { format ["- %1, written in the list %2", _x select 0, _listName] });
        if (_bad isEqualTo []) then {
            _out pushBack "<t color='#7fd67f'>Every name is in this game.</t>";
        } else {
            _out pushBack format ["<t color='#ff7f7f'>Not in this game, so ignored (check the spelling or the mod):</t>"];
            _out append _bad;
        };
        _out
    };
    // the List line: which list it uses, and why when that isn't the one set
    private _fnc_listLine = {
        params ["_list", "_default"];
        _list params ["_name", "_unknown", "_typedName"];
        if (_unknown) exitWith {
            if (_default == "") then { format ["<t color='#ff7f7f'>List %1 not found. Check the spelling.</t>", _typedName] }
            else { format ["<t color='#ff7f7f'>List %1 not found, so %2 is used. Check the spelling.</t>", _typedName, _default] }
        };
        if (_typedName == "") exitWith { ["", format ["Uses the %1 list.", _default]] select (_default != "") };
        format ["Uses the %1 list.", _name]
    };
    private _fnc_block = {
        params ["_title", "_typed", "_list", "_boxes", "_default"];
        private _name = _list select 0;
        private _rules = if (_name == "") then { _typed } else {
            private _r = ["merge", [["get", _name] call ALIVE_fnc_lists, _typed, false, true]] call ALIVE_fnc_lists;
            _r set ["listMissing", (["get", _name] call ALIVE_fnc_lists) getOrDefault ["listMissing", []]];
            _r
        };
        _lines pushBack format ["<t size='1.1' color='#ffb000'>%1</t>", _title];
        private _listLine = [_list, _default] call _fnc_listLine;
        if (_listLine != "") then { _lines pushBack _listLine };
        _lines append ([_rules, _boxes, _name] call _fnc_explain);
        _rules
    };
    private _tabletBoxes = ["Requisition Only These", "Never Requisition", "Also Requisition"];
    private _type = toLower typeOf _ent;
    private _tablet = (all3DENEntities select 3) select { toLower typeOf _x == "alive_sup_player_resupply" };
    private _fnc_tabletTyped = {
        params ["_e"];
        private _g = { private _v = (_e get3DENAttribute _this) param [0, ""]; if (_v isEqualType "") then { _v } else { "" } };
        ["parse", [
            "ALiVE_sup_player_resupply_pr_restrictionWhitelist" call _g,
            "ALiVE_sup_player_resupply_pr_restrictionBlacklist" call _g,
            "ALiVE_sup_player_resupply_pr_restrictionAlso" call _g
        ]] call ALIVE_fnc_lists
    };
    switch (true) do {
        case (_type == "alive_sup_player_resupply"): {
            ["The resupply tablet", [_ent] call _fnc_tabletTyped,
                ["ALiVE_sup_player_resupply_pr_list", "ALiVE_sup_player_resupply_pr_list_name", "STANDARD"] call _listOf, _tabletBoxes, "STANDARD"] call _fnc_block;
        };
        case (_type == "alive_sup_logistics_hub"): {
            private _typed = ["parse", ["ALiVE_sup_logistics_hub_hub_only" call _get, "ALiVE_sup_logistics_hub_hub_never" call _get, "ALiVE_sup_logistics_hub_hub_also" call _get]] call ALIVE_fnc_lists;
            ["This Logistics Hub", _typed, ["ALiVE_sup_logistics_hub_hub_list", "ALiVE_sup_logistics_hub_hub_list_name", ""] call _listOf,
                ["Only These", "Never", "Also"], ""] call _fnc_block;
            if (_tablet isNotEqualTo []) then {
                _lines pushBack "";
                _lines pushBack "The hub also follows the resupply tablet:";
                private _e = _tablet select 0;
                ["The resupply tablet", [_e] call _fnc_tabletTyped, [
                    ((_e get3DENAttribute "ALiVE_sup_player_resupply_pr_list") param [0, ""]),
                    ((_e get3DENAttribute "ALiVE_sup_player_resupply_pr_list_name") param [0, ""])
                ] call {
                    params ["_n", "_custom"];
                    if (_n == "CUSTOM") then { _n = trim _custom };
                    private _known = _n != "" && {isClass (missionConfigFile >> "CfgALiVELists" >> _n) || {isClass (configFile >> "CfgALiVELists" >> _n)}};
                    [["STANDARD", _n] select _known, _n != "" && {!_known}, _n]
                }, _tabletBoxes, "STANDARD"] call _fnc_block;
            };
        };
        case (_type == "alive_sup_fob"): {
            private _typed = ["parse", ["ALiVE_sup_fob_fob_only" call _get, "ALiVE_sup_fob_fob_blacklist" call _get, "ALiVE_sup_fob_fob_whitelist" call _get]] call ALIVE_fnc_lists;
            ["Player FOBs: what can be built", _typed,
                ["ALiVE_sup_fob_fob_buildpreset", "ALiVE_sup_fob_fob_buildpreset_name", "FOB_STANDARD"] call _listOf,
                ["Build Only These", "Never Build", "Also Build"], "FOB_STANDARD"] call _fnc_block;
            _lines pushBack "Each FOB size then offers its own share of this, worked out when the mission starts.";
        };
        default { _lines pushBack "This module has no lists to check." };
    };
    _lines pushBack "";
    _lines pushBack "<t color='#aaaaaa'>Shows the settings as last saved with OK.</t>";
    [parseText (_lines joinString "<br/>"), "ALiVE Lists", true, false, findDisplay 313] spawn BIS_fnc_guiMessage;
}];
