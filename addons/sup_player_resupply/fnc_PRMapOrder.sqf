#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
SCRIPT(PRMapOrder);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PRMapOrder

Description:
Player Combat Logistics ordered from outside the game, for example from the War Room's live map,
where whoever asks isn't in the mission. Server side, and only for code already running on the
server: a call that arrives by remoteExec is refused, so a client can't use it.

A request is posted to Military Logistics exactly as the tablet posts one, so the same checks apply
there (the tablet's Never list, the force pool, which logistics module answers). Instead of the
requesting player it names a side, a destination and, when men are to join a group, one of that
side's player groups, by its leader's player UID. Nobody moves between groups: delivered men join
the chosen group, and that group's leader hears the logistics replies. A request with no group is
answered to nobody in game.

Actions:
"request" - [side, destination, delivery, items, leaderUID, orderedBy]
    side        "WEST" / "EAST" / "GUER" (or "INDEPENDENT"), or a side
    destination [x, y] or [x, y, z]
    delivery    "AIRDROP", "INSERT" (helicopter) or "CONVOY"; must be allowed on the module
    items       up to 20 of [name, orders, count]: name is a class name, or Faction>Group as the
                Tablet Catalogue page shows a group; orders is "Join", "Static" or "Reinforce" for
                men and groups ("" for anything else); count 1 to 10 (default 1)
    leaderUID   the player UID of the leader of the group men should join; "" when nothing joins
    orderedBy   free text for the log (optional)
    Returns [true, requestID, requesterID] or [false, reason]. Keep requestID and requesterID to
    cancel. Reasons: "badargs", "refused", "busy" (under 10 s since the side's last order),
    "nomodule" (no Player Combat Logistics module), "delivery" (that delivery is off on the
    module), "nogroup" (Join items without a group in game on that side), "unknown:<name>".
"cancel" - [side, requestID, requesterID]: cancels a request still on its way, as the tablet's
    Cancel does. Returns [true] or [false, reason].
"sendHome" - [leaderUID]: sends home the delivered men in that player's group, as the tablet's
    Send Home does. Returns [true] or [false, "nogroup"].

Examples:
(begin example)
["request", ["WEST", [3200, 5800], "AIRDROP", [["Box_NATO_Ammo_F", "", 2]], "", "War Room: Jman"]] call ALIVE_fnc_PRMapOrder;
["request", ["WEST", [3200, 5800], "INSERT", [["B_Soldier_F", "Join", 2]], "76561198000000000", "War Room: Jman"]] call ALIVE_fnc_PRMapOrder;
(end)

See Also:
- <ALIVE_fnc_PRSendHome>

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith { [false, "refused"] };
if (isRemoteExecuted) exitWith {
    ["ALiVE PR - map order: refused a call sent by remoteExec from machine %1", remoteExecutedOwner] call ALiVE_fnc_dump;
    [false, "refused"]
};
params [["_action", "", [""]], ["_args", [], [[]]]];
private _say = { ["ALiVE PR - map order: %1", _this] call ALiVE_fnc_dump };

private _fnc_side = {
    params ["_s"];
    if (_s isEqualType west) exitWith { if (_s in [west, east, resistance]) then { _s } else { sideUnknown } };
    if !(_s isEqualType "") exitWith { sideUnknown };
    switch (toUpper _s) do {
        case "WEST": {west};
        case "EAST": {east};
        case "GUER";
        case "INDEPENDENT";
        case "RESISTANCE": {resistance};
        default {sideUnknown};
    }
};
private _fnc_player = {
    params ["_uid", "_side"];
    if !(_uid isEqualType "" && {_uid != ""}) exitWith { objNull };
    private _i = allPlayers findIf { getPlayerUID _x == _uid && {alive _x} };
    if (_i < 0) exitWith { objNull };
    private _p = allPlayers select _i;
    if (side group _p != _side) exitWith { objNull };
    _p
};
// the faction a request is filed under: the chosen leader's, else the first of a commander of the side
private _fnc_faction = {
    params ["_side", "_leader"];
    if (!isNull _leader) exitWith { faction _leader };
    private _sideText = [[_side] call ALIVE_fnc_sideObjectToNumber] call ALIVE_fnc_sideNumberToText;
    private _f = "";
    {
        if (_f == "" && {_x isEqualType []} && {([_x, "side", ""] call ALiVE_fnc_hashGet) == _sideText}) then {
            _f = ([_x, "factions", []] call ALiVE_fnc_hashGet) param [0, ""];
        };
    } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
    if (_f == "") then { _f = ["BLU_F", "OPF_F", "IND_F"] select ([west, east, resistance] find _side) };
    _f
};

switch (toLower _action) do {

    case "request": {
        if !(count _args in [5, 6]) exitWith { "refused a request that is not [side, destination, delivery, items, leaderUID]" call _say; [false, "badargs"] };
        _args params [["_sideIn", ""], ["_dest", [], [[]]], ["_delivery", "", [""]], ["_items", [], [[]]], ["_leaderUID", "", [""]], ["_by", "", [""]]];
        private _side = [_sideIn] call _fnc_side;
        if (_side == sideUnknown) exitWith { "refused a request without a usable side" call _say; [false, "badargs"] };
        if !(count _dest in [2, 3] && {(_dest findIf { !(_x isEqualType 0) || {!finite _x} }) < 0}) exitWith { "refused a request without a usable destination" call _say; [false, "badargs"] };
        _dest = [_dest select 0, _dest select 1, 0];
        if (_by == "") then { _by = "an order from outside the game" };

        if (isNil "ALIVE_SUP_PLAYER_RESUPPLY" || {isNull ALIVE_SUP_PLAYER_RESUPPLY}) exitWith { "refused: no Player Combat Logistics module" call _say; [false, "nomodule"] };
        private _deliveryType = switch (toUpper _delivery) do { case "AIRDROP": {"PR_AIRDROP"}; case "INSERT": {"PR_HELI_INSERT"}; case "CONVOY": {"PR_STANDARD"}; default {""} };
        if (_deliveryType == "") exitWith { format ["refused a request for delivery '%1'", _delivery] call _say; [false, "badargs"] };
        private _allowVar = switch (_deliveryType) do { case "PR_AIRDROP": {"pr_restrictionDeliveryAirDrop"}; case "PR_HELI_INSERT": {"pr_restrictionDeliveryInsert"}; default {"pr_restrictionDeliveryConvoy"} };
        private _allowed = [ALIVE_SUP_PLAYER_RESUPPLY, _allowVar] call ALIVE_fnc_PR;
        if (!isNil "_allowed" && {!(_allowed in [true, "true", 1])}) exitWith { format ["refused: %1 is off on the module", _delivery] call _say; [false, "delivery"] };

        if (_items isEqualTo [] || {count _items > 20}) exitWith { "refused a request with no items, or more than 20" call _say; [false, "badargs"] };

        private _payload = [];
        private _emptyVehicles = [];
        private _staticIndividuals = [];
        private _joinIndividuals = [];
        private _reinforceIndividuals = [];
        private _staticGroups = [];
        private _joinGroups = [];
        private _reinforceGroups = [];
        private _bad = "";
        private _wantsGroup = false;
        {
            if !(_x isEqualType [] && {count _x in [1, 2, 3]}) exitWith { _bad = "badargs" };
            _x params [["_name", "", [""]], ["_orders", "", [""]], ["_n", 1, [0]]];
            _n = ((round _n) max 1) min 10;
            _orders = switch (toUpper _orders) do { case "JOIN": {"Join"}; case "STATIC": {"Static"}; case "REINFORCE": {"Reinforce"}; default {""} };
            private _parts = _name splitString ">";
            if (count _parts == 2) then {
                // a group, Faction>Group
                _parts params ["_gFaction", "_gClass"];
                private _found = false;
                private _category = "";
                {
                    private _c = _x;
                    {
                        if (configName _x == _gClass) exitWith { _found = true; _category = configName _c };
                    } forEach ("true" configClasses _c);
                    if (_found) exitWith {};
                } forEach ("true" configClasses (configFile >> "CfgGroups" >> (["West", "East", "Indep"] select ([west, east, resistance] find _side)) >> _gFaction));
                if (!_found) exitWith { _bad = "unknown:" + _name };
                if (_orders == "") then { _orders = "Reinforce" };
                private _entry = [_gClass, ["Groups", _gFaction, _category]];
                for "_i" from 1 to _n do {
                    switch (_orders) do {
                        case "Join": { _joinGroups pushBack +_entry; _wantsGroup = true };
                        case "Static": { _staticGroups pushBack +_entry };
                        default { _reinforceGroups pushBack +_entry };
                    };
                };
            } else {
                if !(isClass (configFile >> "CfgVehicles" >> _name)) exitWith { _bad = "unknown:" + _name };
                if (_name isKindOf "Man") then {
                    if (_orders == "") then { _orders = "Reinforce" };
                    private _entry = [_name, ["Individuals", getText (configFile >> "CfgVehicles" >> _name >> "faction")]];
                    for "_i" from 1 to _n do {
                        switch (_orders) do {
                            case "Join": { _joinIndividuals pushBack +_entry; _wantsGroup = true };
                            case "Static": { _staticIndividuals pushBack +_entry };
                            default { _reinforceIndividuals pushBack +_entry };
                        };
                    };
                } else {
                    if ((_name isKindOf "LandVehicle" || {_name isKindOf "Air"} || {_name isKindOf "Ship"}) && {!(_name isKindOf "StaticWeapon")}) then {
                        private _category = switch (true) do {
                            case (_name isKindOf "Air"): {"Air"};
                            case (_name isKindOf "Ship"): {"Ship"};
                            case (_name isKindOf "Tank" || {_name isKindOf "Wheeled_APC_F"} || {_name isKindOf "Tracked_APC"} || {_name isKindOf "Wheeled_APC"}): {"Armored"};
                            default {"Car"};
                        };
                        for "_i" from 1 to _n do { _emptyVehicles pushBack [_name, ["Vehicles", _category]] };
                    } else {
                        // crates, defence stores and static weapons, as the tablet sends them
                        for "_i" from 1 to _n do { _payload pushBack _name };
                    };
                };
            };
        } forEach _items;
        if (_bad != "") exitWith { format ["refused a request: %1", _bad] call _say; [false, _bad] };

        private _leader = [_leaderUID, _side] call _fnc_player;
        if (_wantsGroup && {isNull _leader}) exitWith { "refused: men to join a group, but no player of the side with that UID is in game" call _say; [false, "nogroup"] };

        // one order every 10 s per side
        if (isNil "ALiVE_PR_mapOrderLast") then { ALiVE_PR_mapOrderLast = createHashMap };
        if (time - (ALiVE_PR_mapOrderLast getOrDefault [str _side, -100]) < 10) exitWith { format ["refused %1: the side's last order was under 10 s ago", _by] call _say; [false, "busy"] };
        ALiVE_PR_mapOrderLast set [str _side, time];

        private _sideText = [[_side] call ALIVE_fnc_sideObjectToNumber] call ALIVE_fnc_sideNumberToText;
        private _faction = [_side, _leader] call _fnc_faction;
        // the replies go to the chosen leader; with no group, to an id nobody in game holds
        private _requesterID = if (isNull _leader) then { "MAPORDER_" + _sideText } else { getPlayerUID _leader };
        // a request id the tablet's own (whole seconds of mission time) can't take
        if (isNil "ALiVE_PR_mapOrderCount") then { ALiVE_PR_mapOrderCount = 0 };
        ALiVE_PR_mapOrderCount = ALiVE_PR_mapOrderCount + 1;
        private _requestID = floor time + ALiVE_PR_mapOrderCount / 1000;
        private _forceMakeup = [_requestID, _payload, _emptyVehicles, _staticIndividuals, _joinIndividuals, _reinforceIndividuals, _staticGroups, _joinGroups, _reinforceGroups];
        private _event = ['LOGCOM_REQUEST', [_dest, _faction, _sideText, _forceMakeup, _deliveryType, _requesterID], "PR"] call ALIVE_fnc_event;
        [ALIVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;
        format ["%1 asked %2 (%3) for %4 by %5 at %6%7: request %8", _by, _sideText, _faction, _items, _delivery, mapGridPosition _dest,
            ["", format [", men joining %1's group", name _leader]] select _wantsGroup, _requestID] call _say;
        [true, _requestID, _requesterID]
    };

    case "cancel": {
        _args params [["_sideIn", ""], ["_requestID", -1, [0]], ["_requesterID", "", [""]]];
        private _side = [_sideIn] call _fnc_side;
        if (_side == sideUnknown || {_requestID < 0} || {_requesterID == ""}) exitWith { "refused a cancel that is not [side, requestID, requesterID]" call _say; [false, "badargs"] };
        private _sideText = [[_side] call ALIVE_fnc_sideObjectToNumber] call ALIVE_fnc_sideNumberToText;
        private _faction = [_side, [_requesterID, _side] call _fnc_player] call _fnc_faction;
        private _event = ['LOGCOM_CANCEL_REQUEST', [_faction, _sideText, floor time, _requesterID, _requestID], "PR"] call ALIVE_fnc_event;
        [ALIVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;
        format ["cancel asked for request %1 (%2)", _requestID, _requesterID] call _say;
        [true]
    };

    case "sendhome": {
        _args params [["_leaderUID", "", [""]]];
        private _i = allPlayers findIf { getPlayerUID _x == _leaderUID && {alive _x} };
        if (_i < 0) exitWith { [false, "nogroup"] };
        [allPlayers select _i] call ALIVE_fnc_PRSendHome;
        format ["send home asked for %1's group", name (allPlayers select _i)] call _say;
        [true]
    };

    default { format ["refused unknown action '%1'", _action] call _say; [false, "badargs"] };
};
