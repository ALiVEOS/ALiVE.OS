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

// profileIndex is the man's place in the profile now, and a death closes the gap, so after one the
// survivors no longer line up with the compiled slots. Walk the profile's classes in order against the
// compiled ones to find which slot this man came from; if they will not line up, keep his index.
private _profile = [ALIVE_profileHandler, "getProfile", _unit getVariable ["profileID", ""]] call ALIVE_fnc_profileHandler;
if (!isNil "_profile" && {_profile isEqualType []}) then {
    private _now = [_profile, "unitClasses", []] call ALIVE_fnc_hashGet;
    if (count _now < count _units && {_unitIndex < count _now}) then {
        private _next = 0;
        private _slot = -1;
        for "_i" from 0 to _unitIndex do {
            private _class = _now select _i;
            private _at = -1;
            for "_j" from _next to (count _units - 1) do {
                if (_at < 0 && {([_units select _j, "class", ""] call ALIVE_fnc_hashGet) == _class}) then { _at = _j };
            };
            if (_at < 0) exitWith { _slot = -1 };
            _next = _at + 1;
            _slot = _at;
        };
        if (_slot >= 0) then { _unitIndex = _slot };
    };
};

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

