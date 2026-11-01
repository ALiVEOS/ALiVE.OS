#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
SCRIPT(hubManage);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_hubManage

Description:
The Manage Hub window (Jman, 29 Oct), on a player's machine. Manage Hub, on the scroll menu and the
ACE menu at one of the side's Logistics Hubs, opens it (data\ui\hubManage.hpp):
- the hub's side and state (working, or down and back in about N minutes), who may collect there and
  whether this player may, what it offers, and whether the AI Commanders supply from it
- its name, shown on the map marker and in the window: Rename, for admins and players Who Can
  Dismantle lets in; an empty name goes back to the grid
- Permissions: Who Can Collect and Who Can Dismantle for the hub's module, and every hub of it; admins only
- Collect: opens the Player Logistics tablet with Collect at a Hub picked, while the hub is working,
  offers Collect and lets this player collect
- Dismantle: pressed twice within 10 s, for the same players; the hub is down until its Repair Time
The server checks everything again (ALIVE_fnc_hubRequest) and its answer shows on the window's last line.

Parameters:
    ["action", [hub]] - adds Manage Hub to the hub on this machine (sent by the server with the hub)
    ["open", [hub]] - opens the window
    ["standingAt", [unit]] - the hub of the unit's side it stands at, or objNull
    ["refresh"] - fills it again; once a second while it is open
    ["do", "RENAME" | "DISMANTLE"] - a button
    ["collect"] - the Collect button
    ["permOpen"] - the Permissions window (the one every site shares, ALiVE_fnc_siteWhoDialog)
    ["notify", [key, format args]] - the server's answer: on the window and as the usual message
    ["closed"] - the window closed

Returns:
"standingAt": the hub, or objNull; otherwise nothing

Author:
Jman
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {};

params [["_op", "", [""]], ["_args", []]];
private _result = nil;

// may this player change the hub: an admin, or of its side and let in by Who Can Dismantle
private _mayChange = {
    params ["_hub"];
    (["isAdmin", [player]] call ALIVE_fnc_hub)
        || {(["unitSide", [player]] call ALIVE_fnc_hub) == ((_hub getVariable ["ALiVE_hub", []]) param [0, ""]) && {["mayDismantle", [player, _hub]] call ALIVE_fnc_hub}}
};

switch (_op) do {

    // Scroll menu, and the ACE menu when ACE is loaded: shown to the hub's own side, standing at it
    case "action": {
        _args params [["_hub", objNull, [objNull]]];
        if (isNull _hub || {!isNil {_hub getVariable "ALiVE_hub_manageAdded"}}) exitWith {};
        _hub setVariable ["ALiVE_hub_manageAdded", true];
        _hub addAction [localize "STR_ALIVE_HUB_UI_MANAGE", { ["open", [_this select 0]] call ALIVE_fnc_hubManage }, nil, 1.4, false, true, "",
            "vehicle _this == _this && {_this distance2D _target < (8 max ((sizeOf typeOf _target) / 2))} && {((_target getVariable ['ALiVE_hub', []]) param [0, '']) == (['unitSide', [_this]] call ALIVE_fnc_hub)}", 60];
        // ACE: Manage Hub in the self-interaction menu while standing at one of the side's hubs, as Manage FOB
        // is. On the tent itself ACE only reached it from 2 m of its centre, so the entry never showed.
        if (isClass (configFile >> "CfgPatches" >> "ace_interact_menu") && {isNil "ALiVE_hub_aceAdded"}) then {
            ALiVE_hub_aceAdded = true;
            [] spawn {
                waitUntil { sleep 1; !isNil "ace_interact_menu_fnc_createAction" && {!isNull player} };
                private _a = ["ALiVE_hub_manage", localize "STR_ALIVE_HUB_UI_MANAGE", "", { ["open", [["standingAt", [_player]] call ALIVE_fnc_hubManage]] call ALIVE_fnc_hubManage },
                    { vehicle _player == _player && {!isNull (["standingAt", [_player]] call ALIVE_fnc_hubManage)} }] call ace_interact_menu_fnc_createAction;
                ["CAManBase", 1, ["ACE_SelfActions"], _a, true] call ace_interact_menu_fnc_addActionToClass;
            };
        };
        // Trade In Vehicles: on the player, for the driver of a stopped vehicle at one of his side's hubs that
        // takes trade-ins (the server checks it all again), and again on each new body after a respawn
        if (isNil "ALiVE_hub_tradeAdded") then {
            ALiVE_hub_tradeAdded = true;
            [] spawn {
                waitUntil { sleep 1; !isNull player };
                player addEventHandler ["Respawn", { ["tradeAction", [_this select 0]] call ALIVE_fnc_hubManage }];
                ["tradeAction", [player]] call ALIVE_fnc_hubManage;
            };
        };
    };

    case "tradeAction": {
        _args params [["_unit", objNull, [objNull]]];
        if (isNull _unit) exitWith {};
        _unit addAction [localize "STR_ALIVE_HUB_UI_TRADE_IN", {
            ["tradeIn", [netId vehicle (_this select 1)]] remoteExecCall ["ALIVE_fnc_hubRequest", 2];
        }, nil, 1.3, false, true, "",
            "!isNil 'ALiVE_hub_tradeOn' && {vehicle _this != _this} && {driver vehicle _this == _this} && {speed vehicle _this < 3} && {!isNull (['tradeHub', [_this]] call ALIVE_fnc_hubManage)}"];
    };

    // the hub of the unit's side, near enough, that takes trade-ins, or objNull
    case "tradeHub": {
        _args params [["_unit", objNull, [objNull]]];
        _result = ["nearHub", [_unit]] call ALIVE_fnc_hub;
        if (!isNull _result && {((["settings", [(_result getVariable ["ALiVE_hub", []]) param [3, objNull]]] call ALIVE_fnc_hub) param [13, "OFF"]) == "OFF"}) then { _result = objNull };
    };

    // the hub of the unit's side it stands at (the scroll menu's reach), or objNull
    case "standingAt": {
        _args params [["_unit", objNull, [objNull]]];
        private _side = ["unitSide", [_unit]] call ALIVE_fnc_hub;
        private _list = (missionNamespace getVariable ["ALiVE_hub_list", []]) select {
            !isNull _x && {((_x getVariable ["ALiVE_hub", []]) param [0, ""]) == _side} && {_unit distance2D _x < (8 max ((sizeOf typeOf _x) / 2))}
        };
        _result = _list param [0, objNull];
    };

    case "open": {
        _args params [["_hub", objNull, [objNull]]];
        if (isNull _hub || {!createDialog "ALiVE_HubWindow"}) exitWith {};
        uiNamespace setVariable ["ALiVE_hub_manageHub", _hub];
        ALiVE_hub_dismantleArmed = -100;
        ((findDisplay 9291) displayCtrl 92912) ctrlSetText (_hub getVariable ["ALiVE_hub_name", ""]);
        ["refresh"] call ALIVE_fnc_hubManage;
        // the state changes while it is open: down, back, renamed, permissions changed
        [] spawn {
            while { !isNull (findDisplay 9291) } do {
                uiSleep 1;
                ["refresh"] call ALIVE_fnc_hubManage;
            };
        };
    };

    case "refresh": {
        private _d = findDisplay 9291;
        if (isNull _d) exitWith {};
        private _hub = uiNamespace getVariable ["ALiVE_hub_manageHub", objNull];
        private _info = if (isNull _hub) then { [] } else { _hub getVariable ["ALiVE_hub", []] };
        // removed, or no longer the player's side's, while the window was open
        if (count _info < 4 || {(_info select 0) != (["unitSide", [player]] call ALIVE_fnc_hub)}) exitWith { closeDialog 0 };
        _info params ["_side", "_alive", "", "_logic"];
        private _s = ["settings", [_logic]] call ALIVE_fnc_hub;

        (_d displayCtrl 92910) ctrlSetText (["label", [_hub]] call ALIVE_fnc_hub);

        private _sideName = switch (_side) do { case "EAST": {"OPFOR"}; case "GUER": {"Independent"}; default {"BLUFOR"} };
        private _state = if (_alive) then { localize "STR_ALIVE_HUB_UI_WORKING" } else {
            private _back = _hub getVariable ["ALiVE_hub_backAt", -1];
            private _now = [time, serverTime] select isMultiplayer;
            if (_back < 0) then { localize "STR_ALIVE_HUB_UI_DOWN" } else {
                private _min = ceil ((_back - _now) / 60);
                if (_min <= 0) then { localize "STR_ALIVE_HUB_UI_DOWN_SOON" } else { format [localize "STR_ALIVE_HUB_UI_DOWN_BACK", _min] }
            }
        };
        private _collect = if !(_logic getVariable ["ALiVE_hub_collect", false]) then { localize "STR_ALIVE_HUB_UI_COLLECT_OFF" } else {
            (["rules", [_logic]] call ALIVE_fnc_hub) params ["_rules", "_names"];
            private _who = ((toUpper _rules) splitString "[]""', ") apply { localize format ["STR_ALIVE_HUB_UI_WHO_%1", _x] };
            if (_who isEqualTo []) then { _who = [localize "STR_ALIVE_HUB_UI_WHO_NOBODY"] };
            format ["%1 (%2)", _who joinString ", ", localize (["STR_ALIVE_HUB_UI_YOU_MAY_NOT", "STR_ALIVE_HUB_UI_YOU_MAY"] select (["mayCollect", [player, _hub]] call ALIVE_fnc_hub))]
        };
        // the module's three lists, as names counted
        private _count = { count (_this splitString (",; " + toString [9, 10, 13])) };
        private _cat = if (((_s select 4) call _count) + ((_s select 5) call _count) + ((_s select 6) call _count) == 0) then { localize "STR_ALIVE_HUB_UI_CAT_ALL" } else {
            format [localize "STR_ALIVE_HUB_UI_CAT_RULES", (_s select 4) call _count, (_s select 5) call _count, (_s select 6) call _count]
        };
        // and the List it uses: a built-in one by its name in the List box, a mission's own as typed;
        // one that names no list in the game leaves the hub as Not set, so it isn't shown
        private _listName = _s param [12, ""];
        if (_listName isEqualType "" && {_listName != ""} && {((["get", _listName] call ALIVE_fnc_lists) getOrDefault ["name", ""]) != ""}) then {
            private _key = "STR_ALIVE_LISTS_" + toUpper _listName;
            private _shown = if (isLocalized _key) then { localize _key } else { ((_listName regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"] };
            _cat = if (((_s select 4) call _count) + ((_s select 5) call _count) + ((_s select 6) call _count) == 0) then {
                format [localize "STR_ALIVE_HUB_UI_CAT_LIST_ONLY", _shown]
            } else {
                format [localize "STR_ALIVE_HUB_UI_CAT_LIST", _shown, _cat]
            };
        };
        private _supplies = localize (["STR_ALIVE_HUB_UI_NO", "STR_ALIVE_HUB_UI_YES"] select (_logic getVariable ["ALiVE_hub_supplies", false]));
        (_d displayCtrl 92911) ctrlSetStructuredText parseText format [localize "STR_ALIVE_HUB_UI_STATUS", _sideName, _state, _collect, _cat, _supplies, mapGridPosition _hub];

        private _may = [_hub] call _mayChange;
        { (_d displayCtrl _x) ctrlEnable _may } forEach [92912, 92913];
        (_d displayCtrl 92915) ctrlEnable (_may && _alive);
        { (_d displayCtrl _x) ctrlSetTooltip (["", localize "STR_ALIVE_HUB_UI_NOT_ALLOWED"] select !_may) } forEach [92913, 92915];
        // Permissions is for admins only, as on FOBs
        private _admin = ["isAdmin", [player]] call ALIVE_fnc_hub;
        (_d displayCtrl 92914) ctrlEnable _admin;
        (_d displayCtrl 92914) ctrlSetTooltip (["", localize "STR_ALIVE_HUB_UI_PERM_ADMIN"] select !_admin);

        // Collect: the tablet offers Collect at a Hub, and this hub would take the player's order
        private _tablet = !isNil "ALIVE_SUP_PLAYER_RESUPPLY" && {"PR_COLLECT" in ([ALIVE_SUP_PLAYER_RESUPPLY, "deliveryListValues"] call ALIVE_fnc_PR)};
        private _whyNot = switch (true) do {
            case (!_tablet || {!(_logic getVariable ["ALiVE_hub_collect", false])}): { localize "STR_ALIVE_HUB_UI_COLLECT_TIP_OFF" };
            case (!_alive): { localize "STR_ALIVE_HUB_UI_COLLECT_TIP_DOWN" };
            case !(["mayCollect", [player, _hub]] call ALIVE_fnc_hub): { localize "STR_ALIVE_HUB_UI_COLLECT_TIP_NOT_YOU" };
            default { "" };
        };
        (_d displayCtrl 92918) ctrlEnable (_whyNot == "");
        (_d displayCtrl 92918) ctrlSetTooltip _whyNot;
        if (time - (missionNamespace getVariable ["ALiVE_hub_dismantleArmed", -100]) > 10) then {
            (_d displayCtrl 92915) ctrlSetText localize "STR_ALIVE_HUB_UI_DISMANTLE";
        };
    };

    // the tablet opens on its own; Collect at a Hub is then picked as if the player had clicked it
    case "collect": {
        if (isNil "ALIVE_SUP_PLAYER_RESUPPLY") exitWith {};
        closeDialog 0;
        [] spawn {
            uiSleep 0.1;
            ["OPEN", []] call ALIVE_fnc_PRTabletOnAction;
            private _until = diag_tickTime + 5;
            waitUntil { !isNull ((findDisplay 60001) displayCtrl 60005) && {lbSize ((findDisplay 60001) displayCtrl 60005) > 0} || {diag_tickTime > _until} };
            private _list = (findDisplay 60001) displayCtrl 60005;
            if (isNull _list) exitWith {};
            private _i = ([ALIVE_SUP_PLAYER_RESUPPLY, "deliveryListValues"] call ALIVE_fnc_PR) find "PR_COLLECT";
            if (_i > -1 && {_i < lbSize _list}) then { _list lbSetCurSel _i };
        };
    };

    case "do": {
        private _d = findDisplay 9291;
        private _hub = uiNamespace getVariable ["ALiVE_hub_manageHub", objNull];
        if (isNull _d || {isNull _hub}) exitWith {};
        (_d displayCtrl 92916) ctrlSetStructuredText parseText "";
        private _netId = _hub call BIS_fnc_netId;
        switch (_args) do {
            case "RENAME": { ["rename", [_netId, ctrlText (_d displayCtrl 92912)]] remoteExecCall ["ALIVE_fnc_hubRequest", 2] };
            // pressed twice within 10 s, as Dismantle FOB is
            case "DISMANTLE": {
                if (time - (missionNamespace getVariable ["ALiVE_hub_dismantleArmed", -100]) <= 10) then {
                    ALiVE_hub_dismantleArmed = -100;
                    ["dismantle", [_netId]] remoteExecCall ["ALIVE_fnc_hubRequest", 2];
                    closeDialog 0;
                } else {
                    ALiVE_hub_dismantleArmed = time;
                    (_d displayCtrl 92915) ctrlSetText localize "STR_ALIVE_HUB_UI_DISMANTLE_AGAIN";
                    (_d displayCtrl 92916) ctrlSetStructuredText parseText format [localize "STR_ALIVE_HUB_UI_DISMANTLE_CONFIRM", ["label", [_hub]] call ALIVE_fnc_hub];
                };
            };
        };
    };

    case "permOpen": {
        private _hub = uiNamespace getVariable ["ALiVE_hub_manageHub", objNull];
        if (isNull _hub || {!(["isAdmin", [player]] call ALIVE_fnc_hub)}) exitWith {};
        private _logic = (_hub getVariable ["ALiVE_hub", []]) param [3, objNull];
        (["rules", [_logic]] call ALIVE_fnc_hub) params ["_cRules", "_cNames"];
        (["rules", [_logic, "DISMANTLE"]] call ALIVE_fnc_hub) params ["_dRules", "_dNames"];
        private _tokens = ["SIDE", "LEADER", "OWNER", "ITEM", "LIST"] apply { [_x, localize format ["STR_ALIVE_HUB_UI_WHO_%1", _x], localize format ["STR_ALIVE_HUB_WHO_%1_COMMENT", _x]] };
        private _n = { ((_x getVariable ["ALiVE_hub", []]) param [3, objNull]) isEqualTo _logic } count (missionNamespace getVariable ["ALiVE_hub_list", []]);
        // both columns in one request: the server takes one request every 2 s from a player
        private _apply = compile format ["params ['_c', '_d']; ['permissions', [_c select 0, _c select 1, %1, 'BOTH', _d select 0, _d select 1]] remoteExecCall ['ALIVE_fnc_hubRequest', 2]",
            str (_hub call BIS_fnc_netId)];
        ["open", [format [localize "STR_ALIVE_HUB_UI_PERM_TITLE", ["label", [_hub]] call ALIVE_fnc_hub], format [localize "STR_ALIVE_HUB_UI_PERM_NOTE", _n], [
            [localize "STR_ALIVE_HUB_COLLECT_WHO", localize "STR_ALIVE_HUB_COLLECT_LIST", localize "STR_ALIVE_HUB_COLLECT_LIST_COMMENT", _tokens, _cRules, _cNames],
            [localize "STR_ALIVE_HUB_DISMANTLE_WHO", localize "STR_ALIVE_HUB_DISMANTLE_LIST", localize "STR_ALIVE_HUB_DISMANTLE_LIST_COMMENT", _tokens, _dRules, _dNames]
        ], _apply, compile format ["['permReset', [%1]] remoteExecCall ['ALIVE_fnc_hubRequest', 2]; closeDialog 0", str (_hub call BIS_fnc_netId)]]] call ALiVE_fnc_siteWhoDialog;
    };

    case "notify": {
        _args params [["_key", "", [""]], ["_fmt", [], [[]]]];
        if (_key == "") exitWith {};
        private _text = format ([localize _key] + _fmt);
        [localize "STR_ALIVE_HUB", _text, true] call ALIVE_fnc_sendHint;
        {
            private _d = findDisplay (_x select 0);
            if (!isNull _d) then { (_d displayCtrl (_x select 1)) ctrlSetStructuredText parseText _text };
        } forEach [[9291, 92916], [9292, 92922]];
    };

    case "closed": {
        ALiVE_hub_dismantleArmed = -100;
    };
};

if (!isNil "_result") then { _result } else { nil }
