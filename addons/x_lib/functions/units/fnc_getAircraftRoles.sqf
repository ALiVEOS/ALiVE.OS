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
    when the airframe has no tasking use. A fighter needs a radar as well as
    air-to-air missiles, a fighter armed only with its cannon is not given the
    ground roles, and the Blackfish and Xi'an families resolve to Recon only.

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
// Fighter aircraft have air to air capability and a radar to use it with
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

// A fighter needs more than air-to-air missiles: a radar to find its target
// with, and fixed wing (the dispatcher keeps counter-air for planes
// regardless, so granting it to helicopters only produced candidates that
// were then filtered out). Attack jets carry a pair of missiles for their own
// defence, and reading those as a fighter marked the A-10 down for close air
// support and made it a candidate for patrols. Measured on the LAN mod set:
// the A-10, A-164, To-199 and Su-25 carry no radar; the F-22, MiG-29, T-50
// and every vanilla fighter do. An airframe that declares no sensors at all
// keeps the old reading, so an older or modded fleet keeps its fighters.
private _fighter = ("aa" in _caps) && {_class isKindOf "Plane"}
    && {("radar" in _caps) || {"sensorsUnknown" in _caps}};

// A fighter whose only ground weapon is its cannon is not sent at ground
// targets. The F-22, MiG-29 and T-50 carry nothing else for them.
private _gunOnlyFighter = _fighter && {"gun" in _caps}
    && {!("agGuided" in _caps)} && {!("agUnguided" in _caps)};

// Anything else that can hit a ground target can be sent against one. Note
// that a gun counts: a gun-only aircraft could previously never be selected
// for anything at all, because the role it was given was never requested.
if (((["gun", "agGuided", "agUnguided"] findIf {_x in _caps}) > -1) && {!_gunOnlyFighter}) then {
    _result pushBack "Attack";
};

if (_fighter) then {
    _result pushBack "Fighter";
};

// Retained for anything reading the stored roles. The dispatcher does not
// request "CAS" - gun-armed aircraft reach close air support through
// "Attack" above.
if (("gun" in _caps) && {!_gunOnlyFighter}) then { _result pushBack "CAS" };

// The Blackfish and Xi'an families are transports with guns, flown for
// reconnaissance and nothing else: Recon only, and only when the scan found
// something to observe with. Their unarmed variants already resolve to no
// role at all, which leaves them to the parts of ALiVE that fly transports.
if ((_class isKindOf "VTOL_01_base_F") || {_class isKindOf "VTOL_02_base_F"}) then {
    _result = _result arrayIntersect ["Recon"];
};

_result
