/*
    Faction runtime, version 1. Shipped inside every faction mod exported from ALiVE; needs CBA only.
    Gives a soldier the loadout stored on his class (ALiVE_FS_loadout[]), on the machine he is local to.
    Called by CBA with [_unit, _mode]:
      "init"     InitPost, a frame after he is made. Once per machine.
      "respawn"  Respawn, one frame later.
      "local"    he has just become local here (handed to a headless client, or taken over by a player).
    Left alone: a unit with ALiVE_OverrideLoadout set, and a unit whose gear no longer matches his class
    (the mission gave him something else) unless the class says ALiVE_FS_force = 1.
    ALiVE_FS_aceMedic (1 medic, 2 doctor) and ALiVE_FS_aceEngineer (2 advanced) are put on him first, as
    ACE's own variables, so they hold for a unit the mission dressed too.
    "local" always makes that comparison, force or not: the game sometimes puts a unit back to his class
    gear when he changes owner, and only a unit in exactly his class gear is dressed again.
    The third parameter names another config class to read the ALiVE_FS_ entries from (used by tests).
    Gear pools (ALiVE_FS_pools[], class ALiVE_FS_Pools_<tag>): one weighted random pick per pool goes into
    the loadout first; the code is a copy of ALiVE_fnc_fsPoolRoll in ALiVE's sys_orbatcreator, keep them alike.
    Author: Jman
*/
params [["_unit", objNull, [objNull]], ["_mode", "init", [""]], ["_cfg", configNull, [configNull]]];

if (is3DEN || {isNull _unit} || {!alive _unit} || {!local _unit}) exitWith {false};
if (isNull _cfg) then { _cfg = configOf _unit };
if (getNumber (_cfg >> "ALiVE_FS_owned") != 1) exitWith {false};

// ACE medical and engineer training from his class, whatever gear the mission gave him. ACE reads these levels
// from a variable on the unit only. A number already there (the mission's, or ACE's Eden attribute) is kept;
// ACE's own true/false for an engineer is not a level, so it gives way. Without ACE nothing reads them.
{
    _x params ["_entry", "_var"];
    private _n = getNumber (_cfg >> _entry);
    if (_n > 0 && {!((_unit getVariable [_var, false]) isEqualType 0)}) then { _unit setVariable [_var, _n, true] };
} forEach [["ALiVE_FS_aceMedic", "ace_medical_medicClass"], ["ALiVE_FS_aceEngineer", "ACE_IsEngineer"]];

if (_unit getVariable ["ALiVE_OverrideLoadout", false]) exitWith {false};
if (_mode == "init" && {_unit getVariable ["ALiVE_FS_done", false]}) exitWith {false};

private _loadout = getArray (_cfg >> "ALiVE_FS_loadout");
if (count _loadout != 10) exitWith {false};

if (getNumber (_cfg >> "ALiVE_FS_noRandom") == 1) then { _unit setVariable ["BIS_enableRandomization", false] };

// is he still in the gear his class gives a new unit?
private _asClass = true;
if (_mode == "local" || {getNumber (_cfg >> "ALiVE_FS_force") != 1}) then {
    private _now = getUnitLoadout _unit;
    private _class = getUnitLoadout (typeOf _unit);
    // headgear and facewear are randomised by the game, and radio mods swap the map, radio and GPS:
    // none of those is the mission dressing the unit
    { _class set [_x, _now select _x] } forEach [6, 7, 9];
    _asClass = _now isEqualTo _class;
};

// this machine only: another machine that takes him over looks at his gear, not at a flag
_unit setVariable ["ALiVE_FS_done", true];
if (!_asClass) exitWith {false};

// gear pools: one weighted random pick each (a copy of ALiVE_fnc_fsPoolRoll)
private _root = configFile >> ("ALiVE_FS_Pools_" + getText (_cfg >> "ALiVE_FS_tag"));
private _pools = (getArray (_cfg >> "ALiVE_FS_pools")) apply { [getNumber (_root >> _x >> "slot"), getArray (_root >> _x >> "items"), getArray (_root >> _x >> "weights")] };
if (count _pools > 0) then {
    _loadout = +_loadout;
    {
        _x params [["_slot", -1], ["_items", []], ["_weights", []]];
        if (count _items > 0 && {count _items == count _weights}) then {
            private _pick = _items selectRandomWeighted _weights;
            private _at = [0, 2, 1, 3, 4, 5, 6, 7] param [_slot, -1];
            switch (true) do {
                case (_slot in [0, 1, 2] && {_pick isEqualType []} && {count _pick > 0}): {
                    private _old = _loadout select _at;
                    _loadout set [_at, +_pick];
                    private _oldMags = if (_old isEqualType [] && {count _old > 0}) then { ([_old select 0] call BIS_fnc_compatibleMagazines) apply { toLower _x } } else { [] };
                    private _newMags = ([_pick select 0] call BIS_fnc_compatibleMagazines) apply { toLower _x };
                    private _mag = (_pick param [4, []]) param [0, ""];
                    if (_mag isEqualTo "") then { _mag = ([_pick select 0] call BIS_fnc_compatibleMagazines) param [0, ""] };
                    if !(_mag isEqualTo "") then {
                        private _ammo = getNumber (configFile >> "CfgMagazines" >> _mag >> "count");
                        private _swapped = 0;
                        {
                            private _box = _loadout select _x;
                            if (_box isEqualType [] && {count _box > 1}) then {
                                {
                                    private _what = _x select 0;
                                    if (_what isEqualType "" && {(toLower _what) in _oldMags} && {!((toLower _what) in _newMags)}) then {
                                        (_box select 1) set [_forEachIndex, [_mag, _x param [1, 1], _ammo]];
                                        _swapped = _swapped + 1;
                                    };
                                } forEach (_box select 1);
                            };
                        } forEach [3, 4, 5];
                        if (_swapped == 0 && {_oldMags isEqualTo []}) then {
                            private _box = [4, 3, 5] findIf { private _b = _loadout select _x; _b isEqualType [] && {count _b > 1} };
                            if (_box >= 0) then { ((_loadout select ([4, 3, 5] select _box)) select 1) pushBack [_mag, 2, _ammo] };
                        };
                    };
                };
                case (_slot in [3, 4, 5] && {_pick isEqualType ""}): {
                    private _old = _loadout select _at;
                    _loadout set [_at, [_pick, if (_old isEqualType [] && {count _old > 1}) then { +(_old select 1) } else { [] }]];
                };
                case (_slot in [6, 7] && {_pick isEqualType ""}): { _loadout set [_at, _pick] };
                default {};
            };
        };
    } forEach _pools;
};

_unit setUnitLoadout _loadout;

private _insignia = getText (_cfg >> "ALiVE_FS_insignia");
if (_insignia != "") then { [_unit, _insignia] call BIS_fnc_setUnitInsignia };

private _face = getText (_cfg >> "ALiVE_FS_face");
private _speaker = getText (_cfg >> "ALiVE_FS_speaker");
if (_face != "" || {_speaker != ""}) then { [_unit, _face, _speaker] call BIS_fnc_setIdentity };

true
