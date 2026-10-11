#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(heliGunnersArm);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_heliGunnersArm

Description:
Let an AI helicopter's door gunners fire back while its pilot keeps flying his
route. Call it straight after the crew has been calmed (CARELESS, BLUE, targeting
off), as often as that calming is applied: it sets combat mode YELLOW, turns the
crew's targeting back on and keeps the pilot's AUTOCOMBAT off, and leaves CARELESS.

Measured on the rig (Ghost Hawk and RHS Mi-8MTV3 past 8 riflemen 300 m off the
track, 11 Oct): door gunners don't fire with combat mode BLUE, or with TARGET off on
the pilot, who leads the group. With the crew CARELESS, combat mode YELLOW, only the
pilot's AUTOCOMBAT off and targeting on, they fire and the pilot keeps his route
and his own weapons quiet. Unaided, a helicopter crew barely spots infantry, so a
loop started once per aircraft shows the gunners the nearest hostile in sight every
2.5 s and orders the shot; it does nothing while the crew is BLUE (being landed).

A helicopter with no AI in an armed turret (a copilot's seat is a turret too) is
left exactly as it was; so is one whose armed turrets hold only flares or a laser
designator. Does nothing where the helicopter isn't local.

Parameters:
Object - the helicopter

Returns:
Bool - true when it has gunners and they were armed

Examples:
(begin example)
[_heli] call ALiVE_fnc_heliGunnersArm;
(end)

See Also:
NEO_fnc_transportGunnerDefend

Author:
Jman
---------------------------------------------------------------------------- */

params [["_heli", objNull, [objNull]]];

if (isNull _heli || {!alive _heli} || {!local _heli}) exitWith { false };

private _fnc_gunners = {
    ((allTurrets _heli) select {
        ((_heli weaponsTurret _x) select {
            !(_x isKindOf ["CMFlareLauncher", configFile >> "CfgWeapons"]) && {!(_x isKindOf ["Laserdesignator_mounted", configFile >> "CfgWeapons"])}
        }) isNotEqualTo []
    }) apply { _heli turretUnit _x } select {
        alive _x && {_x != driver _heli} && {!isPlayer _x}
    }
};
if ((call _fnc_gunners) isEqualTo [] || {isNull driver _heli}) exitWith { false };

private _grp = group driver _heli;
_grp setCombatMode "YELLOW";
{ _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (crew _heli select { !isPlayer _x && {group _x == _grp} });
(driver _heli) disableAI "AUTOCOMBAT";

if !(_heli getVariable ["ALiVE_heliGunnersLoop", false]) then {
    _heli setVariable ["ALiVE_heliGunnersLoop", true];
    [_heli, _fnc_gunners] spawn {
        params ["_heli", "_fnc_gunners"];
        while { alive _heli && {alive driver _heli} && {local _heli} } do {
            private _grp = group driver _heli;
            private _gunners = call _fnc_gunners;
            if (_gunners isEqualTo []) exitWith {};
            if (combatMode _grp != "BLUE") then {
                private _gside = side _grp;
                private _t = objNull;
                private _td = 1e9;
                {
                    if (alive _x && {side _x != civilian} && {(_gside getFriend (side _x)) < 0.6}
                        && {(_x distance _heli) < _td}
                        && {lineIntersectsSurfaces [eyePos _heli, aimPos _x, _heli, _x] isEqualTo []}) then {
                        _td = _x distance _heli;
                        _t = _x;
                    };
                } forEach (_heli nearEntities [["Man", "Car", "Tank", "Air", "Ship"], 800]);
                if (!isNull _t) then {
                    _grp reveal [_t, 4];
                    { _x doTarget _t; _x doFire _t } forEach _gunners;
                };
            };
            sleep 2.5;
        };
        _heli setVariable ["ALiVE_heliGunnersLoop", false];
    };
};

true
