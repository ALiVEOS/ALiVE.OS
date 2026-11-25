#include "\x\alive\addons\mil_OPCOM\script_component.hpp"
SCRIPT(OPCOMdroneSupport);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOMdroneSupport

Description:
Drone Support. While the commander attacks an objective, a group of the attack
that is spawned (so a player is near) sends a drone at a hostile it knows about
there. Called every 30 s by the commander's own loop; does nothing while the
setting is None.

Few sends 1 drone per attack on an objective, Many up to 3; the count starts
again once the objective is no longer being attacked (taken, or the attack is
called off). A group of the objective's section qualifies when it is spawned,
its leader is AI and its Drone Wait has passed. Its target is one its leader
knows: hostile, 300 m to Drone Launch Range (at most 1 km) from the leader and
within the objective's size + 150 m of its centre, on the ground, not under a
roof, not already chased by a drone, and with no unit of the commander's side
(or a side friendly to it) within 30 m, as attackers close on an objective. A
man on foot gets a dropper, a crewed land vehicle (Medium or Large warhead
only) an FPV dive.

Every drone setting comes from the IED module (warhead, battery, jammers, Most
Drones At Once, Drone Wait), and the flight is ALiVE_fnc_createFPVDrone's, so
it shares the module's drone cap. With no IED module placed nothing is sent.
Battles that aren't spawned get no drones. Nothing is saved.

At most 6 leaders are looked at per pass. With Debug on, each launch is
written to the RPT, and each reason a launch was skipped once per pass, only
when the reasons differ from the last pass.

Parameters:
Hash - the commander's handler
HashMap - the loop's state (counts per objective, last reasons)

Returns:
Nil

Author:
Jman
---------------------------------------------------------------------------- */

#define DRONE_FRIENDLY_RADIUS 30
#define DRONE_TARGET_MARGIN 150
#define DRONE_MIN_RANGE 300
#define DRONE_MAX_RANGE 1000
#define DRONE_MAX_LEADERS 6

params ["_handler", ["_state", createHashMap]];

private _max = switch (toLower format ["%1", [_handler, "droneSupport", "none"] call ALiVE_fnc_HashGet]) do { case "few": { 1 }; case "many": { 3 }; default { 0 } };
if (_max == 0) exitWith {};

private _sideText = [_handler, "side", "EAST"] call ALiVE_fnc_HashGet;
private _side = [_sideText] call ALiVE_fnc_sideTextToObject;
private _iedOn = !isNil "ALiVE_mil_ied" && {!isNull ALiVE_mil_ied};
private _debug = ([_handler, "debug", false] call ALiVE_fnc_HashGet) || {_iedOn && {ALiVE_mil_ied getVariable ["debug", false]}};

if (!_iedOn) exitWith {
    if (_debug && {!(_state getOrDefault ["warned", false])}) then {
        _state set ["warned", true];
        ["OPCOM %1: Drone Support is set but there is no IED module, so no drones are sent", _side] call ALiVE_fnc_dump;
    };
};
if (ALiVE_mil_ied getVariable ["Drone_LAFSOff", false]) exitWith {};
if (isNil "ALiVE_IED_drones") then { ALiVE_IED_drones = [] };

private _counts = _state getOrDefault ["counts", createHashMap];
_state set ["counts", _counts];
private _why = [];
private _fnc_why = { _why pushBackUnique _this };

private _range = ((ALiVE_mil_ied getVariable ["Drone_Range", 2000]) min DRONE_MAX_RANGE) max (DRONE_MIN_RANGE + 50);
private _vehOk = (ALiVE_mil_ied getVariable ["Drone_Charge", "MEDIUM"]) != "SMALL";
private _wait = 60 * (ALiVE_mil_ied getVariable ["Drone_Wait", 10]);
private _leaders = 0;

{
    private _objective = _x;
    private _oid = [_objective, "objectiveID", ""] call ALiVE_fnc_HashGet;
    if !(([_objective, "opcom_state", ""] call ALiVE_fnc_HashGet) in ["attack", "attacking"]) then { _counts deleteAt _oid; continue };
    private _used = _counts getOrDefault [_oid, 0];
    if (_used >= _max) then { continue };
    if ((count ALiVE_IED_drones) >= (ALiVE_mil_ied getVariable ["Drone_Max", 2])) exitWith { "Most Drones At Once is reached" call _fnc_why };
    if (_leaders >= DRONE_MAX_LEADERS) exitWith {};
    private _c = [_objective, "center", [0, 0, 0]] call ALiVE_fnc_HashGet;
    private _reach = (([_objective, "size", 150] call ALiVE_fnc_HashGet) max 50) + DRONE_TARGET_MARGIN;

    private _pick = [];
    {
        private _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
        if (isNil "_profile") then { continue };
        if !([_profile, "active", false] call ALiVE_fnc_HashGet) then { continue };
        private _grp = [_profile, "group", grpNull] call ALiVE_fnc_HashGet;
        if (isNil "_grp" || {!(_grp isEqualType grpNull)} || {isNull _grp}) then { continue };
        private _lead = leader _grp;
        if (!alive _lead || {isPlayer _lead}) then { continue };
        if ((_lead distance2D _c) > (_range + _reach)) then { "no spawned group of the attack is in reach" call _fnc_why; continue };
        if (time < (_grp getVariable ["ALiVE_IED_droneGroupNext", 0])) then { "the attack's groups are on Drone Wait" call _fnc_why; continue };
        if (_leaders >= DRONE_MAX_LEADERS) exitWith {};
        _leaders = _leaders + 1;
        private _known = (_lead targets [true, _range]) select {
            private _t = _x;
            alive _t && {(_t distance2D _c) < _reach} && {(_t distance _lead) > DRONE_MIN_RANGE}
            && {(["height", [_t]] call ALiVE_fnc_createFPVDrone) < 25}
            && {isNull (_t getVariable ["ALiVE_IED_droneOn", objNull])}
            && {time > (_t getVariable ["ALiVE_IED_droneNext", 0])}
            && {if (_t isKindOf "Man") then { (vehicle _t) isEqualTo _t } else {
                _vehOk && {_t isKindOf "LandVehicle"} && {!(_t isKindOf "StaticWeapon")} && {((crew _t) findIf { alive _x }) >= 0}
            }}
        };
        if (_known isEqualTo []) then { "the attack's groups know of no target at the objective" call _fnc_why; continue };
        // attackers close on the objective: a target among them is left alone
        private _clear = _known select {
            private _t = _x;
            ((_t nearEntities [["CAManBase", "LandVehicle"], DRONE_FRIENDLY_RADIUS]) findIf { alive _x && {_x != _t} && {_x isKindOf "CAManBase" || {((crew _x) findIf { alive _x }) >= 0}} && {(_side getFriend (side _x)) >= 0.6} }) < 0
        };
        if (_clear isEqualTo []) then { "every target has the commander's own men within 30 m" call _fnc_why; continue };
        _clear = _clear select { !(["roofed", [_x]] call ALiVE_fnc_createFPVDrone) };
        if (_clear isEqualTo []) then { "every target is under a roof" call _fnc_why; continue };
        _pick = [_grp, selectRandom _clear];
        break;
    } forEach (([_objective, "section", []] call ALiVE_fnc_HashGet) call BIS_fnc_arrayShuffle);

    if (_pick isEqualTo []) then { continue };
    _pick params ["_grp", "_tgt"];
    private _kind = ["fpv", "dropper"] select (_tgt isKindOf "Man");
    private _uav = [_tgt, _grp, [], sideUnknown, _kind] call ALiVE_fnc_createFPVDrone;
    if (isNull _uav) then { "the drone could not be launched" call _fnc_why; continue };
    _used = _used + 1;
    _counts set [_oid, _used];
    private _until = time + _wait;
    _grp setVariable ["ALiVE_IED_droneGroupNext", _until];
    _tgt setVariable ["ALiVE_IED_droneNext", _until max (_tgt getVariable ["ALiVE_IED_droneNext", 0])];
    if (_debug) then {
        private _d = ALiVE_IED_drones param [(ALiVE_IED_drones findIf { (_x get "uav") isEqualTo _uav }), createHashMap];
        ["OPCOM %1: Drone Support at objective %2 (%3): group %4 sent a %5 at %6 (%7) %8 m away, %9 of %10 for this attack", _side, _oid, mapGridPosition _c, groupId _grp,
            ["FPV drone", "dropper"] select (_d getOrDefault ["dropper", false]), [typeOf _tgt, name _tgt] select (_tgt isKindOf "Man"), side _tgt,
            round ((leader _grp) distance _tgt), _used, _max] call ALiVE_fnc_dump;
    };
} forEach ([_handler, "objectives", []] call ALiVE_fnc_HashGet);

// the reasons, once each, only when they differ from the last pass
_why sort true;
if (_debug && {_why isNotEqualTo (_state getOrDefault ["why", []])}) then {
    { ["OPCOM %1: Drone Support sent nothing this pass for some attacks: %2", _side, _x] call ALiVE_fnc_dump } forEach _why;
};
_state set ["why", _why];
