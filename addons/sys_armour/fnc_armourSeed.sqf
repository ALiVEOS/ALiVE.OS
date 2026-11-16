#include "\x\alive\addons\sys_armour\script_component.hpp"
SCRIPT(armourSeed);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_armourSeed

Description:
Feeds one armour set's vest and bullet values into ACE medical.

ACE works out the armour of each worn item and the penetration of each bullet
once, then keeps the result in two lookup tables for the rest of the mission
(ace_medical_engine_armorCache, key "<item>$<hitpoint>", and
ace_medical_damage_ammoCache, key lower-case ammo class). Writing ALiVE's
values into those tables before the first hit means ACE uses them from then
on, with no ALiVE code running on hits, no other mod's class redefined, and
engine damage (walls, vehicles, games without ACE) left as the mod ships it.

The values only matter to ACE's armour-penetration wounds (the ACE medical
option "alternate armour penetration", on by default). With that option off
the set changes nothing, so nothing is written.

If ACE renames or removes these tables, the set switches itself off with an
RPT warning; nothing else changes.

Parameters:
CONFIG - the set, a class of ALiVE_ArmourSets

Returns:
BOOL - true if values were written

Examples:
(begin example)
[configFile >> "ALiVE_ArmourSets" >> "RHS"] call ALIVE_fnc_armourSeed;
(end)

See Also:
- <ALIVE_fnc_armourInit>

Author:
Jman
---------------------------------------------------------------------------- */

params ["_set"];

private _t0 = diag_tickTime;
private _name = getText (_set >> "displayName");

if !(isClass (configFile >> "CfgPatches" >> "ace_medical_engine")) exitWith {
    diag_log format ["ALiVE armour: %1 set is on but ACE medical is not loaded; its vest and ammo values work through ACE medical, so stock values stay in use", _name];
    false
};

private _armorCache = missionNamespace getVariable "ace_medical_engine_armorCache";
private _ammoCache = missionNamespace getVariable "ace_medical_damage_ammoCache";

if (isNil "_armorCache" || {isNil "_ammoCache"} || {!(_armorCache isEqualType createHashMap)} || {!(_ammoCache isEqualType createHashMap)}) exitWith {
    diag_log format ["ALiVE armour: WARNING %1 set disabled: this ACE version does not have the armour and ammo tables ALiVE writes to (ace_medical_engine_armorCache, ace_medical_damage_ammoCache); stock values stay in use", _name];
    false
};

if !(missionNamespace getVariable ["ace_medical_alternateArmorPenetration", true]) exitWith {
    diag_log format ["ALiVE armour: %1 set is on but the ACE medical option 'alternate armour penetration' is off; the set only changes that calculation, so nothing was written", _name];
    false
};

// ---------------------------------------------------------------- tiers

// ACE's own armour for a vest hitpoint (ace_medical_engine_fnc_getItemArmor):
// above 24 it is scaled back using passThrough
private _aceVestArmour = {
    params ["_armor", "_passThrough"];
    _passThrough = 0.1 max _passThrough min 1;
    if (_armor > 24) then {(log (_armor / (_passThrough ^ 0.6))) * 10} else {_armor};
};

private _webbing = (getArray (_set >> "webbing")) apply {toLowerANSI _x};
private _webbingCap = getNumber (_set >> "webbingCap");

// [length, prefix, cap, tier], longest prefix first
private _prefixes = [];
{
    private _tier = _x;
    {
        _prefixes pushBack [count _x, toLowerANSI _x, getNumber (_tier >> "cap"), configName _tier];
    } forEach getArray (_tier >> "prefixes");
} forEach ("true" configClasses (_set >> "Tiers"));
_prefixes sort false;

// first name in the class chain (the vest, then its parents) that a tier
// covers; [] when none does
private _tierOf = {
    params ["_cfg"];
    private _result = [];
    while {isClass _cfg && {_result isEqualTo []}} do {
        private _class = toLowerANSI configName _cfg;
        if (_class in _webbing) then {
            _result = [_webbingCap, "W"];
        } else {
            private _i = _prefixes findIf {(_class find (_x select 1)) == 0};
            if (_i > -1) then {
                _result = [(_prefixes select _i) select 2, (_prefixes select _i) select 3];
            };
        };
        _cfg = inheritsFrom _cfg;
    };
    _result
};

private _torso = (getArray (_set >> "torsoHitpoints")) apply {toLowerANSI _x};
private _neck = (getArray (_set >> "neckHitpoints")) apply {toLowerANSI _x};
private _neckCap = getNumber (_set >> "neckCap");
private _sourceAddons = (getArray (_set >> "sourceAddons")) apply {toLowerANSI _x};

// ---------------------------------------------------------------- vests

private _vestCount = 0;
private _entryCount = 0;
private _seededHitpoints = [];
private _unmapped = [];

{
    private _vest = _x;
    private _tier = [_vest] call _tierOf;
    private _entries = configProperties [_vest >> "ItemInfo" >> "HitpointsProtectionInfo", "isClass _x", true];

    if (_tier isEqualTo []) then {
        // an armoured vest from the set's own addons that no tier covers
        if (((configSourceAddonList _vest) findIf {(toLowerANSI _x) in _sourceAddons}) > -1) then {
            private _chest = _entries findIf {toLowerANSI getText (_x >> "hitpointName") == "hitchest"};
            if (_chest > -1) then {
                private _e = _entries select _chest;
                if ([getNumber (_e >> "armor"), getNumber (_e >> "passThrough")] call _aceVestArmour > 12) then {
                    _unmapped pushBack configName _vest;
                };
            };
        };
    } else {
        _tier params ["_cap"];
        private _done = [];
        private _changed = false;
        {
            private _hitpoint = getText (_x >> "hitpointName");
            private _hpLower = toLowerANSI _hitpoint;
            private _armor = getNumber (_x >> "armor");

            // ACE uses the first entry for a hitpoint, armoured or not, so a
            // later entry for the same hitpoint is never read
            if !(_hpLower in _done) then {_done pushBack _hpLower} else {_armor = 0};

            if (_armor > 0) then {

                private _limit = -1;
                if (_hpLower in _torso) then {_limit = _cap};
                if (_hpLower in _neck) then {_limit = _cap min _neckCap};

                if (_limit >= 0) then {
                    private _own = [_armor, getNumber (_x >> "passThrough")] call _aceVestArmour;
                    // values are only ever lowered
                    if (_limit < _own) then {
                        // ACE builds the key from the class and hitpoint names
                        // as the engine hands them over; write each spelling
                        // that can occur
                        {
                            private _item = _x;
                            {
                                _armorCache set [format ["%1$%2", _item, _x], _limit];
                            } forEach ([_hitpoint, _hpLower] arrayIntersect [_hitpoint, _hpLower]);
                        } forEach ([configName _vest, toLowerANSI configName _vest] arrayIntersect [configName _vest, toLowerANSI configName _vest]);
                        _seededHitpoints pushBackUnique _hpLower;
                        _entryCount = _entryCount + 1;
                        _changed = true;
                    };
                };
            };
        } forEach _entries;
        if (_changed) then {_vestCount = _vestCount + 1};
    };
} forEach ("getNumber (_x >> 'ItemInfo' >> 'type') == 701" configClasses (configFile >> "CfgWeapons"));

// ACE also keeps each soldier's total per hitpoint until his kit changes;
// clear those so soldiers that already exist pick up the new values
{
    private _unit = _x;
    {
        _unit setVariable [format ["ace_medical_engine_armorCache$%1", _x], nil];
    } forEach _seededHitpoints;
} forEach allUnits;

// ---------------------------------------------------------------- ammo

private _ammoCount = 0;
private _ammoInherited = [];

if (missionNamespace getVariable [getText (_set >> "ammoSetting"), true]) then {
    private _table = createHashMap;
    {
        _table set [toLowerANSI configName _x, getNumber _x];
    } forEach configProperties [_set >> "Ammo", "isNumber _x", true];

    {
        private _ammo = _x;
        private _class = toLowerANSI configName _ammo;
        private _hit = getNumber (_ammo >> "hit");

        if (_hit > 0 && {(_class find "blank") == -1}) then {
            // nearest listed class in the chain
            private _value = -1;
            private _cfg = _ammo;
            private _from = "";
            while {isClass _cfg && {_value < 0}} do {
                _value = _table getOrDefault [toLowerANSI configName _cfg, -1];
                if (_value >= 0) then {_from = toLowerANSI configName _cfg};
                _cfg = inheritsFrom _cfg;
            };

            if (_value > 0) then {
                private _own = getNumber (_ammo >> "caliber");
                // a round already above the listed value keeps its own
                if (_value > _own) then {
                    // same layout as ace_medical_damage_fnc_getAmmoData:
                    // [hit, caliber x 0.015 (ACE armour penetrability), typicalSpeed]
                    _ammoCache set [_class, [_hit, _value * 0.015, getNumber (_ammo >> "typicalSpeed")]];
                    _ammoCount = _ammoCount + 1;
                    if (_from != _class) then {_ammoInherited pushBack format ["%1<%2", configName _ammo, _from]};
                };
            };
        };
    } forEach ("getText (_x >> 'simulation') == 'shotBullet'" configClasses (configFile >> "CfgAmmo"));
};

diag_log format [
    "ALiVE armour: %1 set applied: %2 hitpoints on %3 vests, %4 bullets, in %5 ms",
    _name, _entryCount, _vestCount, _ammoCount, round ((diag_tickTime - _t0) * 1000)
];

// rounds that took a value from a listed parent, to check the chain is right
if (_ammoInherited isNotEqualTo []) then {
    diag_log format ["ALiVE armour: %1 set: %2 bullets took a parent's value: %3", _name, count _ammoInherited, _ammoInherited];
};

if (_unmapped isNotEqualTo []) then {
    diag_log format ["ALiVE armour: %1 set: %2 armoured vests have no tier and keep their stock values: %3", _name, count _unmapped, _unmapped];
};

true
