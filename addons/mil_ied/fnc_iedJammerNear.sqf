#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(iedJammerNear);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_iedJammerNear
Description:
Is a working jammer near this place: the IED module's jammer settings. Used by the trigger man (armIED) and the FPV
drone (createFPVDrone).

A vehicle's jammer works while the vehicle is alive with the engine on: an RHS DUKE that is shown and not destroyed, a
class in Jammer Vehicles, or a vehicle given ALiVE_IED_Jammer true (false switches one off), within Jammer Radius.
RHS has no jammer entry in its config, so the DUKE is read from the vehicle's animation sources, once per class
(ALiVE_IED_JammerFits).

A carried jammer works while the man carrying it is alive, player or AI, within Carried Jammer Radius: a backpack,
weapon or item listed in Carried Jammers, or a man given ALiVE_IED_Jammer true (false switches his off).

With Crows Electronic Warfare loaded, its own jammers count with no setup, whatever they are placed on (a vehicle, a
man, an object): each while it is switched on in the mod, within the mod's own effective radius. Drones need one with
the mod's drone jamming; a trigger man is stopped by either kind. A drone the mod is jamming (a player aiming a Spectrum
Device with the jammer antenna at it) counts too.

A drone that EW Drone Jammer is jamming, or that Grouse's Counter-Drone Suite has knocked out, counts as jammed.
Both mods pick their drones and their range themselves, so these count for drones only.

Jammer Radius 0 turns all of it off.

Parameters:
0: OBJECT or ARRAY - the object, or a position (AGL), to look around
1: NUMBER - radius in metres for vehicles (optional; default the module's Jammer Radius, 0 = off)
2: BOOL - true when asking for a drone (optional, default false)

Returns:
BOOL - true if a working jammer is within the radius

Author:
Jman
---------------------------------------------------------------------------- */

params [["_at", objNull, [objNull, []]], ["_radius", -1, [0]], ["_forDrone", false, [true]]];

if (_at isEqualTo objNull) exitWith { false };
if (_radius < 0) then { _radius = ADDON getVariable ["IED_Jammer_Radius", 150] };
if (_radius <= 0) exitWith { false };
private _jamClasses = ADDON getVariable ["IED_Jammer_Vehicles", []];

// Crows Electronic Warfare (crowsEW_main_jamMap, kept on the server: [object, falloff radius, effective radius,
// switched on, capabilities]); a drone it is jamming is in crowsEW_spectrum_activeJammedUnits
if (_forDrone && {_at isEqualType objNull} && {_at in (missionNamespace getVariable ["crowsEW_spectrum_activeJammedUnits", []])}) exitWith { true };
// EW Drone Jammer marks a drone it is jamming (EWDJ_jamState "soft", or "hard" for a hard kill), and Grouse's
// Counter-Drone Suite one it has knocked out (UAVDisabled): each mod picks its drones and range itself
if (_forDrone && {_at isEqualType objNull} && {(_at getVariable ["EWDJ_jamState", ""]) isNotEqualTo "" || {(_at getVariable ["UAVDisabled", false]) isEqualTo true}}) exitWith { true };
private _crows = missionNamespace getVariable ["crowsEW_main_jamMap", 0];
if (_crows isEqualType createHashMap && {count _crows > 0} && {
    (values _crows) findIf {
        _x params [["_obj", objNull, [objNull]], ["_fall", 0], ["_eff", 0, [0]], ["_on", false, [true]], ["_caps", [], [[]]]];
        _on && {alive _obj} && {["DroneJammer", "VoiceCommsJammer"] select [0, [2, 1] select _forDrone] findIf { _x in _caps } > -1} && {(_obj distance _at) < _eff}
    } > -1
}) exitWith { true };

// Sania and Electronic Warfare REDUX: a Sania, Sania_with_tripod or Volnorez_1 that the mod has switched on
// (DB_jammer_isActive). REDUX gives each jammer its own range (DB_Jammer_range) and jams fully out to
// DB_Jammer_fullJamRatio of it (default 0.45); Sania has one range for all, DB_Jammer_maxJamDistance (default 600 m).
// The jammers are listed again every 5 s (ALiVE_IED_saniaList)
if (isClass (configFile >> "CfgVehicles" >> "Sania_Base")) then {
    if (time > (missionNamespace getVariable ["ALiVE_IED_saniaAt", -1])) then {
        ALiVE_IED_saniaAt = time + 5;
        ALiVE_IED_saniaList = entities "Sania_Base";
    };
};
if ((missionNamespace getVariable ["ALiVE_IED_saniaList", []]) findIf {
    alive _x && {_x getVariable ["DB_jammer_isActive", false]} && {
        private _r = _x getVariable ["DB_Jammer_range", -1];
        private _reach = if (_r isEqualType 0 && {_r >= 0}) then {
            _r * (missionNamespace getVariable ["DB_Jammer_fullJamRatio", 0.45])
        } else {
            missionNamespace getVariable ["DB_Jammer_maxJamDistance", 600]
        };
        (_x distance _at) < _reach
    }
} > -1) exitWith { true };

private _fnc_jammerWorks = {
    private _v = _this;
    if (!alive _v || {!isEngineOn _v}) exitWith { false };
    private _set = _v getVariable ["ALiVE_IED_Jammer", 0];
    if (_set isEqualType true) exitWith { _set };
    if ((toLower typeOf _v) in _jamClasses) exitWith { true };
    if (isNil "ALiVE_IED_JammerFits") then { ALiVE_IED_JammerFits = createHashMap };
    private _fit = ALiVE_IED_JammerFits getOrDefault [typeOf _v, []];
    if (_fit isEqualTo []) then {
        private _src = configOf _v >> "AnimationSources";
        private _hide = ["DUKE_Hide", "Hide_DUKE"] select { isClass (_src >> _x) };
        private _hits = (("true" configClasses _src) select { private _n = toLower configName _x; (_n find "hitduke") == 0 })
            apply { getText (_x >> "hitpoint") } select { _x != "" };
        _fit = [_hide param [0, ""], _hits];
        ALiVE_IED_JammerFits set [typeOf _v, _fit];
    };
    _fit params ["_hide", "_hits"];
    // shown, and not every one of its parts destroyed
    _hide != "" && {(_v animationSourcePhase _hide) < 0.5} && {_hits isEqualTo [] || {(_hits findIf { (_v getHitPointDamage _x) < 1 }) > -1}}
};
if (((_at nearEntities [["LandVehicle"], _radius]) findIf { _x call _fnc_jammerWorks }) > -1) exitWith { true };

// carried: Carried Jammers is a set of lower case class names (IED_Jammer_Carried, a hashmap)
private _cRadius = ADDON getVariable ["IED_Jammer_Carried_Radius", 50];
if (_cRadius <= 0) exitWith { false };
private _carried = ADDON getVariable ["IED_Jammer_Carried", createHashMap];
private _fnc_carries = {
    private _m = _this;
    if (!alive _m) exitWith { false };
    private _set = _m getVariable ["ALiVE_IED_Jammer", 0];
    if (_set isEqualType true) exitWith { _set };
    if (count _carried == 0) exitWith { false };
    (toLower backpack _m) in _carried
        || {(weapons _m) findIf { (toLower _x) in _carried } > -1}
        || {(assignedItems _m + items _m) findIf { (toLower _x) in _carried } > -1}
};
((_at nearEntities [["CAManBase"], _cRadius]) findIf { _x call _fnc_carries }) > -1
