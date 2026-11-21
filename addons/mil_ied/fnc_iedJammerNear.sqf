#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(iedJammerNear);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_iedJammerNear
Description:
Is a vehicle with a working jammer near this place: the IED module's Jammer Radius and Jammer Vehicles. Used by the
trigger man (armIED) and the FPV drone (createFPVDrone).

A jammer works while its vehicle is alive with the engine on: an RHS DUKE that is shown and not destroyed, a class in
Jammer Vehicles, or a vehicle given ALiVE_IED_Jammer true (false switches one off). RHS has no jammer entry in its
config, so the DUKE is read from the vehicle's animation sources, once per class (ALiVE_IED_JammerFits).

Parameters:
0: OBJECT or ARRAY - the object, or a position (AGL), to look around
1: NUMBER - radius in metres (optional; default the module's Jammer Radius, 0 = off)

Returns:
BOOL - true if a working jammer is within the radius

Author:
Jman
---------------------------------------------------------------------------- */

params [["_at", objNull, [objNull, []]], ["_radius", -1, [0]]];

if (_at isEqualTo objNull) exitWith { false };
if (_radius < 0) then { _radius = ADDON getVariable ["IED_Jammer_Radius", 150] };
if (_radius <= 0) exitWith { false };
private _jamClasses = ADDON getVariable ["IED_Jammer_Vehicles", []];

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

((_at nearEntities [["LandVehicle"], _radius]) findIf { _x call _fnc_jammerWorks }) > -1
