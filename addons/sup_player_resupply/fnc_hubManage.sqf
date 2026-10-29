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
- Permissions: Who Can Collect and Who Can Dismantle for the hub's module, and every hub of it
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
    ["permOpen"], ["permFill"], ["permToggle", [column, rule]], ["permApply"] - the Permissions window
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
        private _supplies = localize (["STR_ALIVE_HUB_UI_NO", "STR_ALIVE_HUB_UI_YES"] select (_logic getVariable ["ALiVE_hub_supplies", false]));
        (_d displayCtrl 92911) ctrlSetStructuredText parseText format [localize "STR_ALIVE_HUB_UI_STATUS", _sideName, _state, _collect, _cat, _supplies, mapGridPosition _hub];

        private _may = [_hub] call _mayChange;
        { (_d displayCtrl _x) ctrlEnable _may } forEach [92912, 92913, 92914];
        (_d displayCtrl 92915) ctrlEnable (_may && _alive);
        { (_d displayCtrl _x) ctrlSetTooltip (["", localize "STR_ALIVE_HUB_UI_NOT_ALLOWED"] select !_may) } forEach [92913, 92914, 92915];

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
        if (isNull _hub || {!([_hub] call _mayChange)}) exitWith {};
        closeDialog 0;
        [_hub] spawn {
            params ["_hub"];
            uiSleep 0.1;
            if (!createDialog "ALiVE_HubPermWindow") exitWith {};
            uiNamespace setVariable ["ALiVE_hub_manageHub", _hub];
            ALiVE_hub_permDraft = nil;
            ["permFill"] call ALIVE_fnc_hubManage;
        };
    };

    case "permFill": {
        private _d = findDisplay 9292;
        private _hub = uiNamespace getVariable ["ALiVE_hub_manageHub", objNull];
        if (isNull _d || {isNull _hub}) exitWith {};
        private _logic = (_hub getVariable ["ALiVE_hub", []]) param [3, objNull];
        if (isNil "ALiVE_hub_permDraft") then {
            (["rules", [_logic]] call ALIVE_fnc_hub) params ["_cRules", "_cNames"];
            (["rules", [_logic, "DISMANTLE"]] call ALIVE_fnc_hub) params ["_dRules", "_dNames"];
            ALiVE_hub_permDraft = [(toUpper _cRules) splitString "[]""', ", (toUpper _dRules) splitString "[]""', "];
            (_d displayCtrl 92935) ctrlSetText _cNames;
            (_d displayCtrl 92936) ctrlSetText _dNames;
            private _n = { ((_x getVariable ["ALiVE_hub", []]) param [3, objNull]) isEqualTo _logic } count (missionNamespace getVariable ["ALiVE_hub_list", []]);
            (_d displayCtrl 92921) ctrlSetText format [localize "STR_ALIVE_HUB_UI_PERM_TITLE", ["label", [_hub]] call ALIVE_fnc_hub];
            (_d displayCtrl 92922) ctrlSetStructuredText parseText format [localize "STR_ALIVE_HUB_UI_PERM_NOTE", _n];
        };
        {
            _x params ["_col", "_base"];
            private _ticked = ALiVE_hub_permDraft select _col;
            {
                private _b = _d displayCtrl (_base + _forEachIndex);
                _b ctrlSetText format ["%1  %2", ["[  ]", "[+]"] select (_x in _ticked), localize format ["STR_ALIVE_HUB_UI_WHO_%1", _x]];
                _b ctrlSetTooltip localize format ["STR_ALIVE_HUB_WHO_%1_COMMENT", _x];
            } forEach ["SIDE", "LEADER", "ITEM", "LIST"];
        } forEach [[0, 92925], [1, 92929]];
    };

    case "permToggle": {
        if (isNil "ALiVE_hub_permDraft") exitWith {};
        _args params [["_col", 0, [0]], ["_token", "", [""]]];
        private _ticked = ALiVE_hub_permDraft select _col;
        if (_token in _ticked) then { _ticked deleteAt (_ticked find _token) } else { _ticked pushBack _token };
        ["permFill"] call ALIVE_fnc_hubManage;
    };

    // both columns in one request: the server takes one request every 2 s from a player
    case "permApply": {
        private _d = findDisplay 9292;
        private _hub = uiNamespace getVariable ["ALiVE_hub_manageHub", objNull];
        if (isNull _d || {isNull _hub} || {isNil "ALiVE_hub_permDraft"}) exitWith {};
        ["permissions", [(ALiVE_hub_permDraft select 0) joinString ",", ctrlText (_d displayCtrl 92935), _hub call BIS_fnc_netId, "BOTH",
            (ALiVE_hub_permDraft select 1) joinString ",", ctrlText (_d displayCtrl 92936)]] remoteExecCall ["ALIVE_fnc_hubRequest", 2];
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
