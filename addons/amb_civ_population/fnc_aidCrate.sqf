#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(aidCrate);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_aidCrate

Description:
Hands a container of food and water to the nearest town, without any C2ISTAR task.

A container holding at least 10 of the module's water and ration items can be handed over
from the container itself (scroll menu, or ACE interaction), from the dialog's Hand Over Crate
button, from the ACE civilian menu or from the classic scroll menu on a civilian. The town
nearest the container (within 200 m of its centre) takes it: tension towards the giver's side
eases across the sector as a Negotiate does, everyone living in that town calms down a little,
and the container is used up. Each town can take one every Aid Crate Cooldown seconds.

Parameters:
String - The operation
Array - Its arguments

Returns:
items - [] -> the water and ration classes, lower case
count - [container] -> how many water and ration items it holds
nearest - [object or position, radius] -> the nearest container with enough in it, or objNull
handover - [container, side text, player] -> on the server: "delivered", "toofew", "notown",
           "cooldown", "disabled" or "gone". Any other machine hands it to the server.
notify - [string key, format arguments] -> the side panel message on this machine
addActions - [container] -> the scroll action on it, and the ACE one once per machine

Examples:
(begin example)
["handover", [_crate, str side group player, player]] remoteExecCall ["ALiVE_fnc_aidCrate", 2];
_n = ["count", [_crate]] call ALiVE_fnc_aidCrate;
(end)

See Also:
ALiVE_fnc_selectRoleAction, ALiVE_fnc_civInteract

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_operation", "", [""]],
    ["_arguments", []]
];

// Enough in one container to count as a delivery.
#define AIDCRATE_MIN_ITEMS 10
// How far from a town's centre a container can be and still go to it.
#define AIDCRATE_TOWN_RANGE 200

private ["_result"];

switch (_operation) do {

    case "items": {
        // Read once and kept: the action condition asks every frame the player looks at a box.
        private _items = missionNamespace getVariable [QGVAR(aidItems), []];
        if (_items isEqualTo []) then {
            private _src = missionNamespace getVariable [QMOD(amb_civ_population), objNull];
            _items = ((_src getVariable ["waterItems", []]) + (_src getVariable ["rationItems", []])) apply {toLower _x};
            if !(_items isEqualTo []) then { missionNamespace setVariable [QGVAR(aidItems), _items] };
        };
        _result = _items;
    };

    case "count": {
        _arguments params [["_container", objNull, [objNull]]];
        _result = 0;
        if (isNull _container) exitWith {};
        private _wanted = ["items"] call ALiVE_fnc_aidCrate;
        if (_wanted isEqualTo []) exitWith {};
        private _n = 0;
        {
            _x params ["_classes", "_counts"];
            {
                if ((toLower _x) in _wanted) then { _n = _n + (_counts select _forEachIndex) };
            } forEach _classes;
        } forEach [getItemCargo _container, getMagazineCargo _container];
        _result = _n;
    };

    case "nearest": {
        _arguments params [["_from", objNull, [objNull, []]], ["_radius", 15, [0]]];
        _result = objNull;
        if (_from isEqualType objNull && {isNull _from}) exitWith {};
        {
            if (!(_x getVariable [QGVAR(aidCrateUsed), false]) && {(["count", [_x]] call ALiVE_fnc_aidCrate) >= AIDCRATE_MIN_ITEMS}) exitWith { _result = _x };
        } forEach (nearestObjects [_from, ["ReammoBox_F"], _radius]);
    };

    case "notify": {
        _arguments params [["_key", "", [""]], ["_args", [], [[]]]];
        if (!hasInterface || {_key == ""}) exitWith {};
        private _title = format ["<t size='1.5' color='#68a7b7' shadow='1'>%1</t><br/>", localize "STR_ALIVE_CIV_POP_AIDCRATE_TITLE"];
        private _text = format ["%1<t>%2</t>", _title, format ([localize _key] + _args)];
        ["openSideSmall", 0.3] call ALIVE_fnc_displayMenu;
        ["setSideSmallText", _text] spawn ALIVE_fnc_displayMenu;

        // An open dialog's Hand Over Crate button follows the crate being gone.
        if (!isNull findDisplay 923 && {!isNil "ALiVE_civInteractHandler"}) then {
            [] spawn { sleep 1; if (!isNull findDisplay 923) then { [ALiVE_civInteractHandler, "refreshHostilityIndicator"] call ALiVE_fnc_civInteract } };
        };
    };

    case "handover": {
        if (!isServer) exitWith { ["handover", _arguments] remoteExecCall ["ALiVE_fnc_aidCrate", 2] };

        _arguments params [["_container", objNull, [objNull]], ["_sideText", "", [""]], ["_player", objNull, [objNull]]];

        private _reply = {
            params ["_key", ["_args", []]];
            if (!isNull _player) then { ["notify", [_key, _args]] remoteExecCall ["ALiVE_fnc_aidCrate", _player] };
        };

        // Only the player who asked, standing by the crate, for their own side: what a client sends
        // is checked here, not taken on trust.
        // (a call made on the server itself, by a script, may name the side and no player)
        if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNull _player || {owner _player != remoteExecutedOwner}}) exitWith { _result = "gone" };
        if (!isNull _player) then { _sideText = str side group _player };
        if !(missionNamespace getVariable ["ALiVE_amb_civ_population_AidCrateEnabled", false]) exitWith {
            ["STR_ALIVE_CIV_POP_AIDCRATE_GONE"] call _reply;
            _result = "disabled";
        };
        // Two players handing over the same crate: the first one takes it.
        if (isNull _container || {_container getVariable [QGVAR(aidCrateUsed), false]} || {!isNull _player && {(_player distance _container) > 50}}) exitWith {
            ["STR_ALIVE_CIV_POP_AIDCRATE_GONE"] call _reply;
            _result = "gone";
        };
        if !(_sideText in ["EAST", "WEST", "GUER"]) exitWith {
            ["STR_ALIVE_CIV_POP_AIDCRATE_NOTOWN"] call _reply;
            _result = "notown";
        };

        private _count = ["count", [_container]] call ALiVE_fnc_aidCrate;
        if (_count < AIDCRATE_MIN_ITEMS) exitWith {
            ["STR_ALIVE_CIV_POP_AIDCRATE_TOOFEW"] call _reply;
            _result = "toofew";
        };

        // The nearest town, as a C2ISTAR aid task finds it, but it has to be close.
        private _pos = getPosATL _container;
        private _cluster = [];
        private _clusterID = "";
        private _best = 1e10;
        if (!isNil "ALIVE_clustersCivSettlement" && {!isNil "ALIVE_clusterHandler"}) then {
            {
                private _candidate = [ALIVE_clusterHandler, "getCluster", _x] call ALIVE_fnc_clusterHandler;
                if !(isNil "_candidate") then {
                    private _centre = [_candidate, "center", []] call ALIVE_fnc_hashGet;
                    if (count _centre >= 2 && {(_pos distance2D _centre) < _best}) then {
                        _best = _pos distance2D _centre;
                        _cluster = _candidate;
                        _clusterID = _x;
                    };
                };
            } forEach (ALIVE_clustersCivSettlement select 1);
        };
        if (_cluster isEqualTo [] || {_best > AIDCRATE_TOWN_RANGE}) exitWith {
            ["STR_ALIVE_CIV_POP_AIDCRATE_NOTOWN"] call _reply;
            _result = "notown";
        };

        // The effect reaches every town in the sector, so the cooldown covers the towns near this
        // one too: three villages close together can't take three crates in a minute.
        private _centre = [_cluster, "center", _pos] call ALIVE_fnc_hashGet;
        private _nearby = [];
        {
            private _c = [ALIVE_clusterHandler, "getCluster", _x] call ALIVE_fnc_clusterHandler;
            if (!isNil "_c" && {(([_c, "center", [0,0,0]] call ALIVE_fnc_hashGet) distance2D _centre) < 1500}) then { _nearby pushBack _c };
        } forEach (ALIVE_clustersCivSettlement select 1);
        if ((_nearby findIf { ([_x, "aidCrateCooldownUntil", 0] call ALIVE_fnc_hashGet) > serverTime }) >= 0) exitWith {
            ["STR_ALIVE_CIV_POP_AIDCRATE_COOLDOWN"] call _reply;
            _result = "cooldown";
        };

        _container setVariable [QGVAR(aidCrateUsed), true, true];

        private _cooldown = missionNamespace getVariable ["ALiVE_amb_civ_population_AidCrateCooldown", 1800];
        private _maxEffect = missionNamespace getVariable ["ALiVE_amb_civ_population_AidCrateMaxEffect", 35];
        private _value = ((5 + floor (_count / 5)) min _maxEffect) max 0;

        { [_x, "aidCrateCooldownUntil", serverTime + (_cooldown max 0)] call ALIVE_fnc_hashSet } forEach _nearby;

        // The sector's towns, as a Negotiate moves them: easier on the giver, harder on the rest.
        [_centre, [_sideText], _value * -1] call ALiVE_fnc_updateSectorHostility;
        [_centre, ["EAST", "WEST", "GUER"] - [_sideText], _value] call ALiVE_fnc_updateSectorHostility;

        // Everyone living in the town calms down a little, so the dialog reads it too. Cars are
        // agents as well, with fuel where a person keeps hostility.
        private _drop = ceil (_value / 5);
        if (!isNil "ALIVE_agentHandler") then {
            private _townAgents = [[ALIVE_agentHandler, "agentsByCluster"] call ALIVE_fnc_hashGet, _clusterID] call ALIVE_fnc_hashGet;
            if !(isNil "_townAgents") then {
                {
                    if (((_x select 2) select 4) == "agent") then {
                        private _new = (((_x select 2) select 12) - _drop) max 0;
                        [_x, "posture", _new] call ALIVE_fnc_hashSet;
                        private _unit = (_x select 2) select 5;
                        if (!isNull _unit && {alive _unit}) then {
                            _unit setVariable ["ALiVE_CivPop_Hostility", _new, true];
                        };
                    };
                } forEach (_townAgents select 2);
            };
        };

        // With C2ISTAR loaded the town's Hearts and Minds support follows, as an aid task would
        // move it, so the dialog's answers improve with it. Its task cooldown is left as it was.
        if (!isNil "ALIVE_fnc_taskUpdateCivilianSupportState" && {!isNil "ALIVE_fnc_taskGetCivilianSupportState"}) then {
            private _state = [_cluster, _sideText] call ALIVE_fnc_taskGetCivilianSupportState;
            if !(_state isEqualTo []) then {
                private _taskCooldown = [_state, "cooldownUntil", 0] call ALIVE_fnc_hashGet;
                [_cluster, _sideText, "AidDelivery", _value, 0, "success"] call ALIVE_fnc_taskUpdateCivilianSupportState;
                [_state, "cooldownUntil", _taskCooldown] call ALIVE_fnc_hashSet;
            };
        };

        private _town = if (!isNil "ALIVE_fnc_taskGetNearestLocationName") then {
            [_centre] call ALIVE_fnc_taskGetNearestLocationName
        } else {
            private _locs = nearestLocations [_centre, ["NameCityCapital", "NameCity", "NameVillage", "NameLocal"], 1000];
            if (_locs isEqualTo []) then {mapGridPosition _centre} else {text (_locs select 0)}
        };

        ["STR_ALIVE_CIV_POP_AIDCRATE_DELIVERED", [_town]] call _reply;

        if (!isNil "ALIVE_civilianPopulationSystem" && {[ALIVE_civilianPopulationSystem, "debug", false] call ALiVE_fnc_hashGet}) then {
            ["ALiVE Civilian Population - aid crate of %1 items handed to %2 (%3) by %4: hostility %5 for %4, agents calmed by %6", _count, _town, _clusterID, _sideText, _value * -1, _drop] call ALiVE_fnc_dump;
        };

        // Only the food and water go: anything else in the box (weapons, ammunition) stays, and the
        // box goes only when it's empty.
        private _wanted = ["items"] call ALiVE_fnc_aidCrate;
        private _items = getItemCargo _container;
        private _mags = magazinesAmmoCargo _container;
        clearItemCargoGlobal _container;
        clearMagazineCargoGlobal _container;
        { if !((toLower _x) in _wanted) then { _container addItemCargoGlobal [_x, (_items select 1) select _forEachIndex] } } forEach (_items select 0);
        { if !((toLower (_x select 0)) in _wanted) then { _container addMagazineAmmoCargo [_x select 0, 1, _x select 1] } } forEach _mags;
        if (((getItemCargo _container) select 0) isEqualTo [] && {((getMagazineCargo _container) select 0) isEqualTo []}
            && {((getWeaponCargo _container) select 0) isEqualTo []} && {((getBackpackCargo _container) select 0) isEqualTo []}) then {
            deleteVehicle _container;
        } else {
            _container setVariable [QGVAR(aidCrateUsed), false, true];
        };
        _result = "delivered";
    };

    case "addActions": {
        _arguments params [["_container", objNull, [objNull]]];
        if (!hasInterface || {isNull _container}) exitWith {};

        // ACE players use the ACE action below; a scroll action as well would offer it twice
        private _ace = isClass (configFile >> "CfgPatches" >> "ace_interact_menu");
        if (!_ace) then { _container addAction [
            (localize "STR_ALIVE_CIV_POP_AIDCRATE_ACTION") call ALiVE_fnc_actionTitle,
            { params ["_target", "_caller"]; ["handover", [_target, str side group _caller, _caller]] remoteExecCall ["ALiVE_fnc_aidCrate", 2] },
            [],
            1.5,
            false,
            true,
            "",
            "(missionNamespace getVariable ['ALiVE_amb_civ_population_AidCrateEnabled', false]) && {(['count', [_target]] call ALiVE_fnc_aidCrate) >= 10}",
            4
        ] };

        // ACE: one action on the class covers every box, so it's added once per machine.
        if (isNil QGVAR(aidCrateAce) && {_ace}) then {
            GVAR(aidCrateAce) = true;
            private _action = [
                "ALiVE_AidCrate_HandOver",
                localize "STR_ALIVE_CIV_POP_AIDCRATE_ACTION",
                "",
                { ["handover", [_target, str side group _player, _player]] remoteExecCall ["ALiVE_fnc_aidCrate", 2] },
                { (missionNamespace getVariable ["ALiVE_amb_civ_population_AidCrateEnabled", false]) && {(["count", [_target]] call ALiVE_fnc_aidCrate) >= 10} }
            ] call ace_interact_menu_fnc_createAction;
            ["ReammoBox_F", 0, ["ACE_MainActions"], _action, true] call ace_interact_menu_fnc_addActionToClass;
        };
    };
};

if (!isNil "_result") then {_result} else {nil};
