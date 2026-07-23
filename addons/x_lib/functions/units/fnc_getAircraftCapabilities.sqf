#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(getAircraftCapabilities);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getAircraftCapabilities

Description:
    Reports what an aircraft can actually do, derived from its config and - when
    the caller supplies one - its real fitted loadout.

    Replaces the role guessing in mil_ato, which credited any helicopter faster
    than 200 km/h as a reconnaissance platform. Every vanilla transport clears
    that bar (Ghost Hawk and Taru at 300, Mohawk at 250) while carrying no
    target-acquisition sensors at all, which is why troop carriers were being
    sent on reconnaissance and attack sorties they could not fly.

    Returns capability FLAGS, not roles. A caller decides what a task needs; this
    only reports what the airframe has. That split is deliberate - the old model
    baked the decision into the derivation, which is how it ended up emitting a
    "CAS" role nothing ever asked for.

Parameters:
    _class    : STRING or OBJECT - vehicle class name, or a live vehicle
    _loadout  : ARRAY (optional)  - magazine classes actually fitted, e.g. from
                a profile's pylonLoadout snapshot or getPylonMagazines. Merged
                with the config scan rather than replacing it, because a static
                scan sees only each pylon's DEFAULT attachment and so
                under-reports. Absence of a capability here means "not known to
                have it", never "known not to have it".

Returns:
    ARRAY of capability strings, any of:
      "armed"          - carries any offensive armament at all
      "gun"            - cannon or machine gun
      "agUnguided"     - unguided air-to-ground (rockets, bombs)
      "agGuided"       - guided air-to-ground
      "aa"             - air-to-air missiles
      "antiRadiation"  - anti-radar missiles, the one capability SEAD needs
      "sensors"        - target-acquisition sensors (IR / visual / laser)
      "sensorsUnknown" - the airframe declares no sensor component at all, so
                         nothing can be concluded either way. Callers should
                         treat this as permission to fall back, NOT as "no
                         sensors" - it is how pre-sensor-overhaul and modded
                         airframes present, and rejecting them would quietly
                         shrink the usable fleet.
    Empty array means nothing was detected - treat that as "unknown", not as
    "useless", and fall back rather than rejecting the airframe.

Examples:
    (begin example)
    private _caps = ["B_Heli_Attack_01_F"] call ALiVE_fnc_getAircraftCapabilities;
    // ["armed","gun","agGuided","sensors"]

    // with the fitted loadout from a virtualised profile
    private _fitted = [_profile,"pylonLoadout",[]] call ALiVE_fnc_hashGet;
    private _caps = [_class, _fitted] call ALiVE_fnc_getAircraftCapabilities;
    (end)

See Also:
    ALiVE_fnc_isArmed

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_class", "", ["", objNull]],
    ["_loadout", [], [[]]]
];

if (_class isEqualType objNull) then { _class = typeOf _class };
if (_class == "") exitWith { [] };

private _cfg = configFile >> "CfgVehicles" >> _class;
if (isNull _cfg) exitWith { [] };

private _caps = [];

// ------------------------------------------------------------------------
// Sensors. This is the discriminator the old speed heuristic could not be.
// A target-acquisition sensor (IR / visual / laser) is what separates an
// attack or scout airframe from a troop carrier: Blackfoot and Kajman carry
// three of these each, every vanilla transport carries none.
//
// PassiveRadar is deliberately NOT counted - it is a radar warning receiver,
// fitted to transports too, and says nothing about finding ground targets.
// ------------------------------------------------------------------------
// There are three cases here, not two, and the third is what keeps modded
// content working:
//   has the component AND a target-acquisition sensor -> capable
//   has the component but only PassiveRadar           -> NOT capable. This is
//       every vanilla transport, and the case the old speed rule got wrong.
//   no component at all                               -> UNKNOWN. Content from
//       before the sensor overhaul, and plenty of mods, define no sensors at
//       all. Reporting those as incapable would quietly shrink the usable
//       fleet, so they get "sensorsUnknown" and callers stay permissive.
private _sensors = _cfg >> "Components" >> "SensorsManagerComponent" >> "Components";
if (isClass _sensors) then {
    private _found = false;
    {
        if (isClass (_sensors >> _x)) exitWith { _found = true; };
    } forEach ["IRSensorComponent", "VisualSensorComponent", "LaserSensorComponent"];
    if (_found) then { _caps pushBack "sensors" };
} else {
    _caps pushBack "sensorsUnknown";
};

// ------------------------------------------------------------------------
// Weapons. A laser designator marks a spotting platform just as a sensor
// does; a cannon is a gun.
// ------------------------------------------------------------------------
private _weapons = [];
if (!isNil "BIS_fnc_weaponsEntityType") then {
    _weapons = [_class, true] call BIS_fnc_weaponsEntityType;
};

{
    if (_x isKindOf ["CannonCore", configFile >> "CfgWeapons"]) then {
        if !("gun" in _caps) then { _caps pushBack "gun" };
    };
    // isKindOf rather than an exact match, so mounted designators that subclass
    // the vanilla one still count - the same test the previous role code used.
    if (_x isKindOf ["Laserdesignator_mounted", configFile >> "CfgWeapons"] && {!("sensors" in _caps)}) then {
        _caps pushBack "sensors";
    };
} forEach _weapons;

// ------------------------------------------------------------------------
// Munitions. Union of the config scan and any fitted loadout the caller
// passed in.
//
// The config scan reads each pylon's DEFAULT attachment only, so it misses
// anything refitted in Eden or an arsenal - which is exactly how a mission
// maker equips an anti-radiation loadout. Hence the union rather than
// either source alone.
//
// The loadout array is COPIED before use. A profile's pylonLoadout snapshot
// is handed out by reference and is replayed onto the aircraft when it
// spawns, so touching the caller's array here would corrupt the loadout the
// aircraft is rebuilt with.
// ------------------------------------------------------------------------
private _magazines = [];
if (!isNil "BIS_fnc_magazinesEntityType") then {
    _magazines = [_class, true] call BIS_fnc_magazinesEntityType;
};

{
    if (!isNil "_x" && {_x isEqualType ""} && {_x != ""} && {!(_x in _magazines)}) then {
        _magazines pushBack _x;
    };
} forEach (+_loadout);

private _ammoRoot = configFile >> "CfgAmmo";

{
    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
    if (_ammo != "") then {
        private _aCfg = _ammoRoot >> _ammo;

        // Anti-radiation. The strongest signal available and the only one SEAD
        // can be gated on: vanilla gives these a dedicated base class and an
        // anti-radiation seeker component. Verified against HARM and Kh-58.
        if (
            _ammo isKindOf ["ammo_Missile_AntiRadiationBase", _ammoRoot]
            || {isClass (_aCfg >> "Components" >> "SensorsManagerComponent" >> "Components" >> "AntiRadiationSensorComponent")}
        ) then {
            if !("antiRadiation" in _caps) then { _caps pushBack "antiRadiation" };
        };

        // Only actual ordnance counts. Without this the lock values alone were
        // enough, and a countermeasure or a door-gun round that happens to carry
        // airLock=1 read as guided air-to-ground - which credited an RHS Chinook
        // with an attack capability it does not have.
        private _isOrdnance = _ammo isKindOf ["MissileBase", _ammoRoot]
                           || {_ammo isKindOf ["RocketBase", _ammoRoot]}
                           || {_ammo isKindOf ["BombCore", _ammoRoot]}
                           || {_ammo isKindOf ["ShellBase", _ammoRoot]};

        private _airLock = getNumber (_aCfg >> "airLock");
        private _lockSpeed = getNumber (_aCfg >> "missileLockMaxSpeed");
        private _guided = _isOrdnance && {_lockSpeed > 0 || {_airLock > 0}};

        if (_guided) then {
            // Fast-target lock means it is meant for aircraft; slow or
            // ground-locking means it is meant for things on the ground.
            if (_airLock > 1 || {_lockSpeed >= 150}) then {
                if !("aa" in _caps) then { _caps pushBack "aa" };
            } else {
                if !("agGuided" in _caps) then { _caps pushBack "agGuided" };
            };
        } else {
            // Anything that explodes but does not guide - rockets, bombs. The
            // ordnance test applies here too: without it, a countermeasure or a
            // door-gun round with a little splash damage counted as an attack
            // capability, which is how a heavy-lift transport ended up credited
            // with one.
            private _hit = getNumber (_aCfg >> "indirectHit");
            if (_isOrdnance && {_hit > 0} && {!("agUnguided" in _caps)}) then {
                _caps pushBack "agUnguided";
            };
        };
    };
} forEach _magazines;

// ------------------------------------------------------------------------
// "armed" is a summary, not a separate detection - it is true when anything
// offensive was found. Derived last so it cannot disagree with the flags it
// summarises.
// ------------------------------------------------------------------------
if (["gun", "agUnguided", "agGuided", "aa", "antiRadiation"] findIf {_x in _caps} > -1) then {
    _caps pushBack "armed";
};

_caps
