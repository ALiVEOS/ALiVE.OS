#include "\x\alive\addons\sup_group_manager\script_component.hpp"
SCRIPT(rallyInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_rallyInit

Description:
Rally Points module. Every object synced to it is a rally point, and so is every object of
the classes in Rally Point Classes (built during the mission too), the side's placement HQs and,
with Player FOBs placed, each FOB from the tier the Player FOBs setting names. A player standing at one gets a Rally Points action: a window of
the others, and Travel. A group leader brings the AI of their group that are near and on foot.
No trips with enemies near either end, ALiVE's virtual groups included, and a wait between
trips. Missions can add their own with ALiVE_fnc_rallyPoint.

Parameters:
_this select 0: OBJECT - the module

Author:
Jman
---------------------------------------------------------------------------- */

params [["_logic", objNull, [objNull]]];
if (isNull _logic) exitWith {};

// one module's settings apply; any more only add the objects synced to them
if (isNil "ALiVE_rallyLogic") then { ALiVE_rallyLogic = _logic };
private _main = ALiVE_rallyLogic == _logic;

private _side = toUpper (_logic getVariable ["rallySide", "ANY"]);
private _classes = ((_logic getVariable ["rallyClasses", ""]) splitString ", ") select { isClass (configFile >> "CfgVehicles" >> _x) };

if (isServer) then {
    private _synced = (synchronizedObjects _logic) select { !(_x isKindOf "Logic") };
    { ["add", [_x, "", _side, "synced"]] call ALiVE_fnc_rallyPoint } forEach _synced;
    if (_synced isEqualTo [] && {_classes isEqualTo []} && {(_logic getVariable ["rallyFOBs", 2]) in [0, "0", false, "false"]}) then {
        ["ALiVE Rally Points: nothing to do (no synced objects, no classes, FOBs off)"] call ALiVE_fnc_dump;
    };
    // objects of the listed classes, those built later included: looked for every 30 s, and the
    // list sent only when it changed
    if (_classes isNotEqualTo []) then {
        [_classes, _side] spawn {
            params ["_classes", "_side"];
            while { true } do {
                private _now = [];
                { _now append (allMissionObjects _x) } forEach _classes;
                ["sync", [_now, _side]] call ALiVE_fnc_rallyPoint;
                sleep 30;
            };
        };
    };
};

// Side HQs: the HQ and Field HQ buildings that placement modules (Military Placement, Custom Military
// Placement, the air commander) pick for their faction are rally points for that faction's side. They
// are picked during start-up, so they're looked for every 60 s.
private _hqs = _logic getVariable ["rallyHQs", true];
if (_hqs isEqualType "") then { _hqs = toLower _hqs != "false" };
if (isServer && {_main} && {_hqs}) then {
    [] spawn {
        private _done = [];
        while { true } do {
            sleep 60;
            {
                private _mod = _x;
                private _faction = _mod getVariable ["faction", ""];
                if (_faction isEqualType [] ) then { _faction = _faction param [0, ""] };
                private _sideNum = getNumber (configFile >> "CfgFactionClasses" >> _faction >> "side");
                private _side = ["EAST", "WEST", "GUER"] param [_sideNum, ""];
                if (_faction != "" && {_side != ""}) then {
                    {
                        private _b = _mod getVariable [_x, objNull];
                        if (_b isEqualType objNull && {!isNull _b} && {alive _b} && {!(_b in _done)}) then {
                            _done pushBack _b;
                            private _loc = nearestLocations [getPosATL _b, ["NameCityCapital", "NameCity", "NameVillage", "NameLocal", "Airport"], 1500];
                            private _place = if (_loc isNotEqualTo []) then { text (_loc select 0) } else { mapGridPosition _b };
                            ["add", [_b, format [localize (["STR_ALIVE_RALLY_HQ_NAME", "STR_ALIVE_RALLY_FIELDHQ_NAME"] select (_x == "FieldHQBuilding")), _place], _side, "hq"]] call ALiVE_fnc_rallyPoint;
                        };
                    } forEach ["HQBuilding", "FieldHQBuilding"];
                };
            } forEach (allMissionObjects "Module_F");
        };
    };
};

if (!hasInterface || {!_main}) exitWith {};

[_logic] spawn {
    params ["_logic"];
    waitUntil { sleep 1; !isNull player };
    // the rally point the player stands at, kept up to date for the action's condition
    if (isNil "ALiVE_rallyNearLoop") then {
        ALiVE_rallyNear = [];
        ALiVE_rallyNearLoop = [] spawn {
            while { true } do {
                ALiVE_rallyNear = if (alive player && {vehicle player == player}) then { ["near", [player]] call ALiVE_fnc_rallyPoint } else { [] };
                sleep 0.5;
            };
        };
    };
    // a map marker on each rally point this player may use (a FOB's once it's tier 2 and not damaged),
    // on this machine only, redrawn when the list changes
    private _show = _logic getVariable ["rallyMarkers", true];
    if (_show isEqualType "") then { _show = toLower _show != "false" };
    if (_show && {isNil "ALiVE_rallyMarkerLoop"}) then {
        ALiVE_rallyMarkerLoop = [] spawn {
            private _had = [];
            private _sig = [];
            while { true } do {
                private _rows = ["list", [player]] call ALiVE_fnc_rallyPoint;
                private _now = _rows apply { [_x select 0, (_x select 1) apply { round _x }] };
                if (_now isNotEqualTo _sig) then {
                    _sig = _now;
                    { deleteMarkerLocal _x } forEach _had;
                    _had = [];
                    {
                        private _m = createMarkerLocal [format ["ALiVE_rally_%1", _forEachIndex], ASLToAGL (_x select 1)];
                        _m setMarkerTypeLocal "mil_flag";
                        _m setMarkerColorLocal "ColorYellow";
                        _m setMarkerTextLocal format [localize "STR_ALIVE_RALLY_MARKER", _x select 0];
                        _had pushBack _m;
                    } forEach _rows;
                };
                sleep 5;
            };
        };
    };
    // scroll wheel, ACE interaction menu or both, as the module's Interface setting says; Auto uses
    // ACE when it is loaded
    private _ui = toUpper (_logic getVariable ["rallyInterface", "AUTO"]);
    // the player's own choice in Addon Options > ALiVE > Game wins over the module's (#1083); ACE
    // without ACE loaded still falls back to the scroll wheel below
    private _prefUI = missionNamespace getVariable ["ALiVE_prefInterface", "MODULE"];
    if (_prefUI != "MODULE") then { _ui = _prefUI };
    private _hasAce = isClass (configFile >> "CfgPatches" >> "ace_interact_menu");
    private _useAce = _hasAce && {_ui in ["AUTO", "ACE", "BOTH"]};
    private _useScroll = !_useAce || {_ui == "BOTH"};
    private _cond = "ALiVE_rallyNear isNotEqualTo [] && {vehicle _this == _this} && {lifeState _this in ['HEALTHY','INJURED']} && {!captive _this}";
    if (_useScroll) then {
        private _add = {
            player addAction [localize "STR_ALIVE_RALLY_ACTION", { ["open"] call ALiVE_fnc_rallyWindow }, nil, 1.48, true, true, "", ALiVE_rallyCond, 5];
        };
        ALiVE_rallyCond = _cond;
        call _add;
        player addEventHandler ["Respawn", { player addAction [localize "STR_ALIVE_RALLY_ACTION", { ["open"] call ALiVE_fnc_rallyWindow }, nil, 1.48, true, true, "", ALiVE_rallyCond, 5] }];
    };
    if (_useAce) then {
        waitUntil { sleep 1; !isNil "ace_interact_menu_fnc_createAction" };
        private _a = ["ALiVE_Rally", localize "STR_ALIVE_RALLY_ACTION", "", { ["open"] call ALiVE_fnc_rallyWindow },
            { ALiVE_rallyNear isNotEqualTo [] && {vehicle player == player} && {lifeState player in ["HEALTHY", "INJURED"]} && {!captive player} }] call ace_interact_menu_fnc_createAction;
        ["CAManBase", 1, ["ACE_SelfActions"], _a, true] call ace_interact_menu_fnc_addActionToClass;
    };
    _logic setVariable ["ALiVE_rallyReady", true];
};
