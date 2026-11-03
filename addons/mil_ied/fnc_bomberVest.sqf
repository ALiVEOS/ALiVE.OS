#include "\x\alive\addons\mil_IED\script_component.hpp"
SCRIPT(bomberVest);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_bomberVest

Description:
Dresses a suicide bomber: puts on his vest and straps explosive charges across his chest and belly
where everyone can see them. Server only.

The vest comes from the setting given. Left empty or at the default ALiVE vest, a loaded mod's own
suicide vest is used when there is one, otherwise the ALiVE vest. A mission maker's own list always
wins, less any class that does not exist.

Works wherever he is local: the vest and items go on through his owner's machine. The charges are
plain objects made on the server that every player sees, and they follow his body as he moves. They go when he is deleted, when his
vest comes off or is changed (looted from his body, or it went off), and stay on him while he is
armed and about to go off.

Parameters:
Object - the bomber
String - the vest setting: one class or a comma separated list, "" for the default
Array - items to put in the vest (optional)

Returns:
String - the vest he wears

Examples:
(begin example)
[_bomber, MOD(mil_ied) getVariable ["Bomber_Vest", ""]] call ALiVE_fnc_bomberVest;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]], ["_setting", "", [""]], ["_items", [], [[]]]];

if (!isServer || {isNull _unit}) exitWith { "" };

private _default = "V_ALiVE_Suicide_Vest";

// a loaded mod's own suicide vests, looked up once per mission
private _modVests = missionNamespace getVariable "ALiVE_bomberModVests";
if (isNil "_modVests") then {
    _modVests = ("getNumber (_x >> 'scope') == 2 && {getNumber (_x >> 'ItemInfo' >> 'type') == 701}" configClasses (configFile >> "CfgWeapons")) select {
        private _name = toLower (configName _x + " " + getText (_x >> "displayName"));
        (["suicide", "bomb vest", "bombvest", "explosive vest", "s-vest", "svest"] findIf { _x in _name }) > -1
    } apply { configName _x };
    _modVests = _modVests - [_default];
    missionNamespace setVariable ["ALiVE_bomberModVests", _modVests];
    ["ALiVE IED: suicide vests from loaded mods: %1", _modVests] call ALiVE_fnc_dump;
};

private _list = ([_setting, " ", ""] call CBA_fnc_replace) splitString ",";
private _own = _list select { isClass (configFile >> "CfgWeapons" >> _x) };
if (count _own < count _list) then {
    ["ALiVE IED: Bomber Vest classes that do not exist, left out: %1", _list - _own] call ALiVE_fnc_dump;
};
// the default (empty, or just the ALiVE vest) gives way to a mod's own
if (_own isEqualTo [] || {_own isEqualTo [_default]}) then {
    _own = [[_default], _modVests] select (_modVests isNotEqualTo []);
};
private _vest = selectRandom _own;

// dressed again: the old charges go first
{ deleteVehicle _x } forEach (_unit getVariable ["ALiVE_bomberCharges", []]);
_unit setVariable ["ALiVE_bomberCharges", []];
// the vest only goes on where he is local: a man a headless client or a Zeus owns gets it from there
if (local _unit) then {
    removeVest _unit;
    _unit addVest _vest;
    { _unit addItemToVest _x } forEach _items;
} else {
    [_unit] remoteExecCall ["removeVest", _unit];
    [_unit, _vest] remoteExecCall ["addVest", _unit];
    { [_unit, _x] remoteExecCall ["addItemToVest", _unit] } forEach _items;
};

// a mod's suicide vest already shows its explosives
if (_vest in _modVests) exitWith { _vest };

// charges: [bone, offset, dir, up]
private _model = "\A3\Weapons_F\explosives\c4_charge_small.p3d";
private _charges = [];
{
    _x params ["_bone", "_off", "_dir", "_up"];
    private _c = createSimpleObject [_model, [0, 0, 0]];
    _c attachTo [_unit, _off, _bone, true];
    _c setVectorDirAndUp [_dir, _up];
    _charges pushBack _c;
} forEach [
    ["pelvis", [-0.1, 0.1, 0.15], [0.5, 0.5, 0], [-0.5, 0.5, 0]],
    ["pelvis", [0, 0.12, 0.15], [1, 0, 0], [0, 1, 0]],
    ["pelvis", [0.1, 0.1, 0.15], [0.5, -0.5, 0], [0.5, 0.5, 0]]
];
_unit setVariable ["ALiVE_bomberCharges", _charges];

if !(_unit getVariable ["ALiVE_bomberDeletedEH", false]) then {
    _unit setVariable ["ALiVE_bomberDeletedEH", true];
    _unit addEventHandler ["Deleted", {
        params ["_unit"];
        { deleteVehicle _x } forEach (_unit getVariable ["ALiVE_bomberCharges", []]);
    }];
};

[_unit, _vest, _charges] spawn {
    params ["_unit", "_vest", "_charges"];
    // from another machine the vest takes a moment to show here
    private _until = time + 15;
    waitUntil { sleep 0.5; isNull _unit || {vest _unit == _vest} || {time > _until} };
    waitUntil {
        sleep 1;
        isNull _unit ||
        // the vest came off or was swapped; an armed bomber strips his to go off and keeps the charges
        {vest _unit != _vest && {!(alive _unit && {_unit getVariable ["ALiVE_bomberArmed", false]})}}
    };
    { deleteVehicle _x } forEach _charges;
};

_vest
