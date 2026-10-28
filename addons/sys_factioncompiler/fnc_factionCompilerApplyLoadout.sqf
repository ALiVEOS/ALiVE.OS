#include "\x\alive\addons\sys_factioncompiler\script_component.hpp"
SCRIPT(factionCompilerApplyLoadout);

params [
    ["_unit", objNull, [objNull]],
    ["_factionId", "", [""]],
    ["_groupId", "", [""]]
];

if (isNull _unit || {_factionId isEqualTo ""} || {_groupId isEqualTo ""}) exitWith {false};

private _factionData = [_factionId] call ALIVE_fnc_factionCompilerGetFactionData;
if (isNil "_factionData") exitWith {false};

private _compiledGroups = [_factionData, "compiledGroups"] call ALIVE_fnc_hashGet;
private _groupData = [_compiledGroups, _groupId] call ALIVE_fnc_hashGet;
if (isNil "_groupData") exitWith {false};

private _units = [_groupData, "units", []] call ALIVE_fnc_hashGet;
private _unitIndex = _unit getVariable ["profileIndex", -1];
if (_unitIndex < 0 || {_unitIndex >= count _units}) exitWith {false};

private _unitData = _units select _unitIndex;
private _loadout = [_unitData, "loadout", []] call ALIVE_fnc_hashGet;
if (_loadout isEqualTo []) exitWith {false};

// A class with no uniform in its config dresses itself by script a moment after it is made (WebKnight's
// zombies take 0.1-5 s, at random). A template read before that holds no clothes, and putting that kit
// back would strip the unit to its underwear (and take a Shooter's gun), so the unit is left to dress
// first and keeps what it gets in any slot the template left empty.
if ((_loadout select 3) isEqualTo [] && {getText (configFile >> "CfgVehicles" >> typeOf _unit >> "uniformClass") isEqualTo ""}) exitWith {
    [_unit, _loadout] spawn {
        params ["_unit", "_loadout"];
        private _until = time + 6;
        waitUntil { sleep 0.25; isNull _unit || {uniform _unit != ""} || {time > _until} };
        if (isNull _unit || {!alive _unit}) exitWith {};
        private _own = getUnitLoadout _unit;
        private _kit = +_loadout;
        {
            private _slot = _kit select _x;
            if (_slot isEqualTo [] || {_slot isEqualTo ""}) then { _kit set [_x, _own select _x] };
        } forEach [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
        _unit setUnitLoadout _kit;
    };
    true
};

_unit setUnitLoadout _loadout;
true

