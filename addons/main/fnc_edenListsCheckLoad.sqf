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
    private _fnc_block = {
        params ["_title", "_typed", "_list"];
        _list params ["_name", "_unknown", "_typedName"];
        private _rules = ["merge", [["get", _name] call ALIVE_fnc_lists, _typed, false, true]] call ALIVE_fnc_lists;
        _rules set ["name", _name];
        _rules set ["listMissing", (["get", _name] call ALIVE_fnc_lists) getOrDefault ["listMissing", []]];
        _lines pushBack format ["<t size='1.1' color='#ffb000'>%1</t>", _title];
        _lines pushBack format ["List: %1%2", _name, ["", format [" (%1 isn't a list, so the default is used)", _typedName]] select _unknown];
        _lines pushBack (["describe", [_rules, true]] call ALIVE_fnc_lists);
        _rules
    };
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
                ["ALiVE_sup_player_resupply_pr_list", "ALiVE_sup_player_resupply_pr_list_name", "STANDARD"] call _listOf] call _fnc_block;
        };
        case (_type == "alive_sup_logistics_hub"): {
            private _typed = ["parse", ["ALiVE_sup_logistics_hub_hub_only" call _get, "ALiVE_sup_logistics_hub_hub_never" call _get, "ALiVE_sup_logistics_hub_hub_also" call _get]] call ALIVE_fnc_lists;
            private _list = ["ALiVE_sup_logistics_hub_hub_list", "ALiVE_sup_logistics_hub_hub_list_name", ""] call _listOf;
            if ((_list select 0) == "") then {
                _lines pushBack "<t size='1.1' color='#ffb000'>This Logistics Hub</t>";
                _lines pushBack (["describe", [_typed, false]] call ALIVE_fnc_lists);
            } else {
                ["This Logistics Hub", _typed, _list] call _fnc_block;
            };
            if (_tablet isNotEqualTo []) then {
                _lines pushBack "";
                _lines pushBack "It also keeps to the resupply tablet's Never list and, unless it has a List or Only These list of its own, the tablet's kinds:";
                private _e = _tablet select 0;
                ["The resupply tablet", [_e] call _fnc_tabletTyped, [
                    ((_e get3DENAttribute "ALiVE_sup_player_resupply_pr_list") param [0, ""]),
                    ((_e get3DENAttribute "ALiVE_sup_player_resupply_pr_list_name") param [0, ""])
                ] call {
                    params ["_n", "_custom"];
                    if (_n == "CUSTOM") then { _n = trim _custom };
                    private _known = _n != "" && {isClass (missionConfigFile >> "CfgALiVELists" >> _n) || {isClass (configFile >> "CfgALiVELists" >> _n)}};
                    [["STANDARD", _n] select _known, _n != "" && {!_known}, _n]
                }] call _fnc_block;
            };
        };
        case (_type == "alive_sup_fob"): {
            private _typed = ["parse", ["ALiVE_sup_fob_fob_only" call _get, "ALiVE_sup_fob_fob_blacklist" call _get, "ALiVE_sup_fob_fob_whitelist" call _get]] call ALIVE_fnc_lists;
            ["Player FOBs, what can be built", _typed,
                ["ALiVE_sup_fob_fob_buildpreset", "ALiVE_sup_fob_fob_buildpreset_name", "FOB_STANDARD"] call _listOf] call _fnc_block;
            _lines pushBack "What a FOB of each size finally offers is worked out when the mission starts.";
        };
        default { _lines pushBack "This module has no lists to check." };
    };
    _lines pushBack "";
    _lines pushBack "<t color='#aaaaaa'>Read from the settings as last saved with OK. Only (Only These), Never and Also are the three name boxes; a name followed by its box is one that isn't in this game.</t>";
    [parseText (_lines joinString "<br/>"), "ALiVE Lists", true, false, findDisplay 313] spawn BIS_fnc_guiMessage;
}];
