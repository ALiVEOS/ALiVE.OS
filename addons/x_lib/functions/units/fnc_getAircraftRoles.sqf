#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(getAircraftRoles);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getAircraftRoles

Description:
    Turns the capability flags reported by ALiVE_fnc_getAircraftCapabilities into
    the mission roles an aircraft can be given.

    Capabilities describe the airframe; roles describe what you can ask of it.
    Keeping the two apart lets a caller ask either question without one answer
    being baked into the other.

    This lived inside mil_ato until two modules needed it. The air commander asks
    so it can refuse airframes that resolve to no role at all, and mil_placement
    asks so an airfield does not fill up with aircraft nothing could ever task.
    Sitting in the module, it only existed once that module had run, so anything
    placed earlier could not consult it.

    An empty result is meaningful: nothing in the mission has a tasking use for
    the airframe. Transports and cargo aircraft land here, which is correct. They
    are flown by other parts of ALiVE, not tasked by the air commander.

Parameters:
    _class    : STRING or OBJECT - vehicle class name, or a live vehicle
    _loadout  : ARRAY (optional)  - magazines actually fitted, e.g. a profile's
                pylonLoadout snapshot. Passed through to the capability scan,
                which otherwise sees only each pylon's default attachment and so
                under-reports a refitted aircraft. Omit it to read the class
                defaults, which is the right question before anything is spawned.

Returns:
    ARRAY of role strings, any of: "Recon", "Attack", "Fighter", "CAS". Empty
    when the airframe has no tasking use.

Examples:
    (begin example)
        private _roles = ["B_Plane_CAS_01_F"] call ALiVE_fnc_getAircraftRoles;

        // refuse anything nothing could ever task
        if (count ([_class] call ALiVE_fnc_getAircraftRoles) == 0) exitWith {};
    (end)

Author:
    Tupolov
    Jman

---------------------------------------------------------------------------- */
params [
    ["_class", "", ["",objNull]],
    // Optional. Magazines actually fitted, e.g. a profile's pylonLoadout
    // snapshot. Merged with the config scan, which only ever sees each
    // pylon's default attachment and so under-reports a refitted aircraft.
    ["_loadout", [], [[]]]
];

if (_class isEqualType objNull) then {_class = typeof _class};

// Attack aircraft have air to surface capability
// Fighter aircraft have air to air capability
// Recon aircraft can actually find things - see the sensor note below
// Multi-role aircraft have both attack and fighter
//
// Roles are now derived from ALiVE_fnc_getAircraftCapabilities rather than
// guessed here. The rule this replaces credited ANY helicopter faster than
// 200 km/h as a reconnaissance platform, and every vanilla transport clears
// that bar - Ghost Hawk and Taru at 300, Mohawk at 250 - which is why troop
// carriers were being sent on reconnaissance and attack sorties they had no
// way to fly.
private _result = [];
private _caps = [_class, _loadout] call ALiVE_fnc_getAircraftCapabilities;

// Recon takes two things: something to observe with, and being the sort of
// aircraft you would send to look.
//
// Sensors alone are not enough. Some third-party transports carry genuine
// observation hardware - RHS fits the CH-53E with a pilot camera, and both
// this check and ACE's own agree it has one - but a heavy-lift helicopter
// is still not what you send to scout. So the aircraft must also be armed,
// or be a drone, which is what separates a scout from a troop carrier that
// happens to have a camera.
//
// "sensorsUnknown" means the airframe declares no sensor component at all,
// which is how older and modded content presents. Those stay eligible - a
// strict test there would quietly shrink the fleet on RHS or CUP, and an
// empty pool is a worse failure than an imperfect pick.
//
// The drone test needs both halves: isKindOf "UAV" misses the Darter, whose
// base inherits from Helicopter_Base_F rather than UAV, while the isUav
// config property resolves through inheritance and catches it.
private _canObserve = "sensors" in _caps || {"sensorsUnknown" in _caps};
private _isDrone = _class isKindOf "UAV"
                || {getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") == 1};

if (_canObserve && {"armed" in _caps || _isDrone}) then {
    _result pushBack "Recon";
};

// Anything that can hit a ground target can be sent against one. Note that
// a gun counts: a gun-only aircraft could previously never be selected for
// anything at all, because the role it was given was never requested.
if (["gun", "agGuided", "agUnguided"] findIf {_x in _caps} > -1) then {
    _result pushBack "Attack";
};

// Air-to-air, and only for fixed wing - the dispatcher restricts counter-air
// tasking to planes regardless, so granting it to helicopters only produced
// candidates that were then filtered out.
if ("aa" in _caps && {_class isKindOf "Plane"}) then {
    _result pushBack "Fighter";
};

// Retained for anything reading the stored roles. The dispatcher does not
// request "CAS" - gun-armed aircraft reach close air support through
// "Attack" above.
if ("gun" in _caps) then { _result pushBack "CAS" };

_result
