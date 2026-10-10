#include "\x\alive\addons\sup_group_manager\script_component.hpp"
SCRIPT(recruitInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_recruitInit

Description:
Recruitment module (#977). Every object synced to the module gets a "Recruit"
action per unit class; the recruit is made beside the object and joins the
player's own group, until the group reaches the module's size cap.

Recruits belong to the player's group only: they are not ALiVE profiles, so
they don't come out of or go back into any force pool, and they aren't saved.

Parameters:
_this select 0: OBJECT - the module

Returns:
Nil

Examples:
(begin example)
[_logic] call ALIVE_fnc_recruitInit;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_logic", objNull, [objNull]]];

if (isNull _logic || {!hasInterface}) exitWith {};

// Made into one list of classes: the module's own, or failing that the infantry of the
// player's faction that the editor would offer.
ALiVE_fnc_recruitClasses = {
    params ["_logic"];
    private _raw = _logic getVariable ["unitClasses", ""];
    private _classes = if (_raw isEqualType "") then { (_raw splitString ", ") select { _x != "" } } else { [] };
    _classes = _classes select { isClass (configFile >> "CfgVehicles" >> _x) && {getNumber (configFile >> "CfgVehicles" >> _x >> "scope") >= 1} };
    if (_classes isEqualTo []) then {
        private _faction = faction player;
        _classes = ("getText (_x >> 'faction') == _faction && {getNumber (_x >> 'scope') == 2} && {configName _x isKindOf 'CAManBase'} && {getText (_x >> 'vehicleClass') != 'MenDiver'}" configClasses (configFile >> "CfgVehicles")) apply { configName _x };
        // The usual roles first, so the short list is the useful one.
        private _rank = {
            private _n = toLower _this;
            switch (true) do {
                case ("_soldier_f" in _n || {"rifleman" in _n}): { 0 };
                case ("_ar_" in _n || {"autorifle" in _n}): { 1 };
                case ("_medic_" in _n): { 2 };
                case ("_lat_" in _n || {"_at_" in _n}): { 3 };
                case ("_gl_" in _n || {"grenadier" in _n}): { 4 };
                case ("_m_" in _n || {"marksman" in _n}): { 5 };
                case ("engineer" in _n): { 6 };
                default { 10 };
            };
        };
        // The faction's regular soldiers where it files them apart from special forces and story
        // characters, and one of each role name, so the list reads like a roster.
        private _regular = _classes select { getText (configFile >> "CfgVehicles" >> _x >> "editorSubcategory") == "EdSubcat_Personnel" };
        if (count _regular >= 3) then { _classes = _regular };
        _classes = [_classes, [], { _x call _rank }, "ASCEND"] call ALiVE_fnc_SortBy;
        private _names = [];
        _classes = _classes select {
            private _n = getText (configFile >> "CfgVehicles" >> _x >> "displayName");
            if (_n in _names) then { false } else { _names pushBack _n; true }
        };
        _classes = _classes select [0, 8];
    };
    _classes
};

ALiVE_fnc_recruitUnit = {
    params ["_object", "_class", "_max"];
    private _group = group player;
    private _size = { alive _x } count units _group;
    if (_size >= _max) exitWith { hint format ["Your group is full: %1 is the most it can have.", _max] };
    if (time < (player getVariable ["ALiVE_recruitNext", 0])) exitWith { hint "Give the last recruit a moment." };
    player setVariable ["ALiVE_recruitNext", time + 3];
    private _pos = (getPosATL _object) getPos [3 + random 2, random 360];
    private _unit = _group createUnit [_class, _pos, [], 2, "NONE"];
    if (isNull _unit) exitWith { hint "Nobody is available to join you." };
    [_unit] joinSilent _group;
    _unit setVariable ["ALiVE_recruited", true, true];
    hint format ["%1 has joined your group (%2 of %3).", getText (configFile >> "CfgVehicles" >> _class >> "displayName"), _size + 1, _max];
};

[_logic] spawn {
    params ["_logic"];
    waitUntil { sleep 1; !isNull player };
    private _max = _logic getVariable ["maxGroupSize", 8];
    if (_max isEqualType "") then { _max = parseNumber _max };
    if (_max < 1) then { _max = 8 };
    private _classes = [_logic] call ALiVE_fnc_recruitClasses;
    private _objects = (synchronizedObjects _logic) select { !(_x isKindOf "Logic") };
    if (_objects isEqualTo [] || {_classes isEqualTo []}) exitWith {
        ["ALiVE Recruitment: nothing to do (%1 synced objects, %2 unit classes)", count _objects, count _classes] call ALiVE_fnc_dump;
    };
    {
        private _object = _x;
        {
            _object addAction [
                format ["Recruit %1", getText (configFile >> "CfgVehicles" >> _x >> "displayName")],
                { (_this select 3) call ALiVE_fnc_recruitUnit },
                [_object, _x, _max], 1.5, false, true, "", "alive _target && {vehicle _this isEqualTo _this}", 5
            ];
        } forEach _classes;
    } forEach _objects;
    _logic setVariable ["ALiVE_recruitReady", [count _objects, _classes], false];
};
