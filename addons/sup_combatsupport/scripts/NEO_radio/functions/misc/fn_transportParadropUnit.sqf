// NEO_fnc_transportParadropUnit
// ------------------------------------------------------------------
// One jumper of a PARADROP (NEO_fnc_transportParadrop), run where the jumper is local: out of
// the helicopter and straight into an open steerable parachute, as on a static line. Nothing is
// taken off the jumper, so the backpack and everything else they carry lands with them.
//
// Params: [_unit, _chopper]
//
// Author: Jman
// ------------------------------------------------------------------
params ["_unit", "_chopper"];

if (!local _unit || {!alive _unit} || {vehicle _unit != _chopper}) exitWith {};

unassignVehicle _unit;
moveOut _unit;

// 12 m straight below the cabin, clear of the main and tail rotors even with the helicopter at a
// hover (6 m behind it put a jumper by the tail rotor), carrying on at its speed; a player gets the
// canopy they can steer, AI the round one they come straight down under
private _chute = createVehicle [["NonSteerable_Parachute_F", "Steerable_Parachute_F"] select (isPlayer _unit), [0, 0, 1000], [], 0, "CAN_COLLIDE"];
_chute setPosASL (_chopper modelToWorldWorld [0, 0, -12]);
_chute setDir getDir _chopper;
_chute setVelocity (velocity _chopper);
_unit moveInDriver _chute;

if (isPlayer _unit) then {
    [localize "STR_ALIVE_COMBATSUPPORT", localize "STR_ALIVE_CS_PARADROP_HINT"] call ALIVE_fnc_sendHint;
};
