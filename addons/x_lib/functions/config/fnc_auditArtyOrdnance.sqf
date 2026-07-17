#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(auditArtyOrdnance);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_auditArtyOrdnance

Description:
Report what ALiVE can see of an artillery gun's ordnance, and name the guns that
would offer an empty round list. Answers "why does my battery have nothing to
fire?" without a code read.

A gun offers rounds only where two things agree: the round types its ordnance
classifies as, and the round counts set on the module. This audits the first.
When it reports no rounds the gun cannot offer anything whatever the module is
set to.

There are two ways to read a gun, and they do not always agree:

    config    - CAPABILITY: everything the gun can ever load. Free, works on a
                classname, and is what a module knows before anything spawns. It
                is the right answer for a round list, because the module stocks
                the battery. It is only ever as good as where ALIVE_fnc_getArtyMagazines
                looks: rocket artillery hangs its launcher off a pylon rather than
                a turret, and until that was read the Calliope reported eleven hull
                machine guns and the BM-21 reported nothing at all.
    the gun   - INVENTORY: what the spawned vehicle is loaded with right now, via
                getArtilleryAmmo. Needs a live vehicle. It is NOT a better config -
                it is a different question, and usually a narrower answer. A
                vanilla mortar spawns carrying HE/ILLUM/SMOKE but can load SADARM,
                CLUSTER and LASER as well.

Read config first and only ask the gun when config finds nothing, which is what
ALIVE_fnc_getArtyRounds does. Preferring the gun would strip round types from
every gun that spawns part-loaded - measured at 45 of 178, vanilla included.

The live sweep runs both and names where they disagree, sorted by whether that
disagreement matters.

Parameters:
0: Nothing, String, Array of Strings, or Object - what to audit.
    omitted / []  - every artillery vehicle in the loaded config (scope 2 and
                    artilleryScanner), which is what the module dropdowns offer
    "CLASSNAME"   - one gun by name
    ["A","B"]     - those guns by name (note the nesting in the examples)
    _someVehicle  - a live gun
1: Boolean - live sweep (default false). Spawns one of each subject, reads it
    both ways, removes it, and reports where config and the gun disagree.
    MUST be spawned, not called - it suspends between spawn and read.

Returns:
Array of [classname, magazineCount, roundTypes, isRocketArtillery, readFromLiveGun],
and logs the same to the RPT prefixed [ALiVE ARTY AUDIT]. The live sweep returns
[classname, configRounds, gunRounds, differ, isRocketArtillery] and logs
[ALiVE ARTY AUDIT LIVE].

Examples:
(begin example)
// every gun the module dropdowns can offer, read from config
[] call ALIVE_fnc_auditArtyOrdnance;

// one gun, or several
["SPE_M4A1_T34_Calliope"] call ALIVE_fnc_auditArtyOrdnance;
[["SPE_M4A1_T34_Calliope","RHS_BM21_MSV_01"]] call ALIVE_fnc_auditArtyOrdnance;

// a live gun - aim at one
[cursorObject] call ALIVE_fnc_auditArtyOrdnance;

// LIVE SWEEP - spawn every gun, read it both ways, report the disagreements.
// Run it in an empty mission: it spawns and removes one vehicle at a time.
[[], true] spawn ALIVE_fnc_auditArtyOrdnance;
(end)

See Also:
- ALIVE_fnc_getArtyRounds
- ALIVE_fnc_getArtyMagazines
- ALIVE_fnc_isMagazineOfOrdnanceType

Author:
Jman
---------------------------------------------------------------------------- */

params [["_subjects", [], [[], "", objNull]], ["_spawnLive", false, [false]]];

if (_subjects isEqualType "" || {_subjects isEqualType objNull}) then { _subjects = [_subjects] };

// no subject given - audit whatever the module dropdowns would offer, using the
// same test they use (main/fnc_listFactionRoleVehicles.sqf narrows further on
// turret elevation; this stays wide so nothing is missed)
if (_subjects isEqualTo []) then {
    _subjects = ("getNumber (_x >> 'scope') == 2 && getNumber (_x >> 'artilleryScanner') > 0" configClasses (configFile >> "CfgVehicles")) apply { configName _x };
};

private _allTypes = ["HE","SMOKE","WP","SADARM","CLUSTER","LASER","MINE","AT MINE","ROCKETS","ILLUM"];

// _this = a magazine list. Mirrors the classify loop in fnc_getArtyRounds - kept
// separate so the sweep can classify a magazine list of its own choosing and
// compare the two readings.
private _fnc_classify = {
    private _out = [];
    {
        private _mag = _x;
        {
            if ([_x, _mag] call ALIVE_fnc_isMagazineOfOrdnanceType) then {
                _out pushBackUnique _x;
            };
        } forEach _allTypes;
    } forEach _this;
    _out
};

// ---------------------------------------------------------------------------
// live sweep - read every gun both ways and report where they disagree
// ---------------------------------------------------------------------------

if (_spawnLive) exitWith {

    if (!canSuspend) exitWith {
        ["ALiVE ARTY AUDIT - the live sweep suspends, so it has to be spawned: [[], true] spawn ALIVE_fnc_auditArtyOrdnance"] call ALiVE_fnc_dump;
        []
    };

    // one at a time, each removed before the next, so nothing piles up and the
    // sweep leaves the mission as it found it
    private _at = [0,0,0];
    private _rows = [];

    {
        private _class = _x;
        private _veh = createVehicle [_class, _at, [], 0, "NONE"];

        if (isNull _veh) then {
            ["ALiVE ARTY AUDIT LIVE - %1 | could not be spawned, skipped", _class] call ALiVE_fnc_dump;
        } else {
            // a launcher mounted at spawn is not there on the first frame
            uiSleep 0.05;

            private _cfgRounds = (_class call ALIVE_fnc_getArtyMagazines) call _fnc_classify;
            private _gunRounds = (getArtilleryAmmo [_veh]) call _fnc_classify;
            private _differ = !(_cfgRounds isEqualTo _gunRounds);
            // carry the rocket verdict too. It is derived from the ordnance, so a
            // change to what the ordnance read returns can silently flip it - the
            // RHS HIMARS was only ever answering "rocket" off a misread fuel tank,
            // and correcting that read turned it into a howitzer with a howitzer's
            // ranges. A sweep with no column for it could not see that happen.
            private _rocket = [_class] call ALIVE_fnc_isRocketArtillery;

            _rows pushBack [_class, _cfgRounds, _gunRounds, _differ, _rocket];

            ["ALiVE ARTY AUDIT LIVE - %1 | config %2 | the gun %3 | %4 | rocket artillery %5",
                _class, _cfgRounds, _gunRounds, if (_differ) then {"DIFFER"} else {"same"}, _rocket] call ALiVE_fnc_dump;

            deleteVehicle _veh;
        };
    } forEach _subjects;

    private _differing = _rows select { _x select 3 };

    // config blind - the gun offers ordnance the config read cannot see. This is
    // a gap in getArtyMagazines, not a fact about the vehicle: rocket artillery
    // hangs its launcher off a pylon, and the Calliope and BM-21 sat here until
    // the walk learned to read them. Go and find where the config declares it
    private _cfgBlind = (_differing select { (_x select 1) isEqualTo [] && {!((_x select 2) isEqualTo [])} }) apply { _x select 0 };

    // config lists MORE than the gun carries. Expected and harmless: getArtilleryAmmo
    // reports what is loaded right now, config reports what the gun can ever load,
    // and the module stocks it - so config is the right answer for a round list.
    private _cfgWider = (_differing select {
        !((_x select 1) isEqualTo []) && {((_x select 2) - (_x select 1)) isEqualTo []}
    }) apply { _x select 0 };

    // neither contains the other - config names ordnance the gun does not, which is
    // config describing magazines the gun never fires as artillery. This is the
    // only bucket worth chasing (the RHS HIMARS reports its fuel tanks here)
    private _cfgWrong = (_differing select {
        !((_x select 1) isEqualTo []) && {!(((_x select 2) - (_x select 1)) isEqualTo [])}
    }) apply { _x select 0 };

    ["ALiVE ARTY AUDIT LIVE - %1 gun(s) swept, %2 where config and the gun disagree", count _rows, count _differing] call ALiVE_fnc_dump;
    if !(_cfgBlind isEqualTo []) then {
        ["ALiVE ARTY AUDIT LIVE - config sees no ordnance, the gun does. The config read is not looking where these keep it - find that place, do not assume it cannot be read: %1", _cfgBlind] call ALiVE_fnc_dump;
    };
    if !(_cfgWider isEqualTo []) then {
        ["ALiVE ARTY AUDIT LIVE - config lists more than the gun is loaded with, which is expected - config is capability, the gun is inventory: %1", _cfgWider] call ALiVE_fnc_dump;
    };
    if !(_cfgWrong isEqualTo []) then {
        ["ALiVE ARTY AUDIT LIVE - the gun names ordnance config does not, so config is describing magazines it cannot fire as artillery: %1", _cfgWrong] call ALiVE_fnc_dump;
    };

    _rows
};

// ---------------------------------------------------------------------------
// single reading - config, or the gun if one was handed over
// ---------------------------------------------------------------------------

private _rows = [];

{
    private _subject = _x;
    private _live = _subject isEqualType objNull;
    private _class = if (_live) then { typeOf (vehicle _subject) } else { _subject };

    // count the config magazines separately from the round scan: the scan may
    // answer off a live gun, and the gap between the two is the whole diagnosis
    private _cfgMagCount = count (_class call ALIVE_fnc_getArtyMagazines);
    private _rounds = _subject call ALIVE_fnc_getArtyRounds;
    private _rocket = [_class] call ALIVE_fnc_isRocketArtillery;

    _rows pushBack [_class, _cfgMagCount, _rounds, _rocket, _live];
} forEach _subjects;

{
    ["ALiVE ARTY AUDIT - %1 | magazines %2 | rounds %3 | rocket artillery %4 | read from %5",
        _x select 0, _x select 1, _x select 2, _x select 3,
        if (_x select 4) then {"the live gun"} else {"config"}] call ALiVE_fnc_dump;
} forEach _rows;

private _empty = _rows select { (_x select 2) isEqualTo [] };

["ALiVE ARTY AUDIT - %1 gun(s) audited, %2 with no rounds to offer", count _rows, count _empty] call ALiVE_fnc_dump;

// split on what was actually read, not on the magazine count. A count is not
// evidence: a gun whose ordnance the walk cannot find still reports whatever its
// config does list, and that can be hull machine guns and nothing that fires.
private _byName = (_empty select { !(_x select 4) }) apply { _x select 0 };
private _byLive = (_empty select { _x select 4 }) apply { _x select 0 };

if !(_byName isEqualTo []) then {
    ["ALiVE ARTY AUDIT - no rounds from config. Audit a live one to learn why: rounds there means the config read is missing where this gun keeps its ordnance, nothing there means the classifier missed the magazines: %1", _byName] call ALiVE_fnc_dump;
};
if !(_byLive isEqualTo []) then {
    ["ALiVE ARTY AUDIT - no rounds from the live gun either - the magazines are there and no ordnance type matched them (ALIVE_fnc_isMagazineOfOrdnanceType): %1", _byLive] call ALiVE_fnc_dump;
};

_rows
