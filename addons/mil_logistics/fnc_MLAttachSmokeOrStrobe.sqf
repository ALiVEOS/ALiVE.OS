#include "\x\alive\addons\mil_logistics\script_component.hpp"
SCRIPT(MLAttachSmokeOrStrobe);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_MLAttachSmokeOrStrobe
Description:
Attaches a persistent smoke or strobe to an object depending on the time of day.
The attached object will be removed once a player is nearby.

This function will block if not spawned!

Parameters:
_this select 0: OBJECT - The vehicle to attach to

Returns:
Nil

See Also:
- <ALIVE_fnc_ML>

Author:
Marcel

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private _vehicle = param [0, objNull];

private _trigger = createTrigger ["EmptyDetector", getPos _vehicle];
_trigger setTriggerArea [10, 10, 0, false];
_trigger setTriggerActivation["ANYPLAYER", "PRESENT", false];
_trigger setTriggerStatements[
    "this",
    "(thisTrigger getVariable [""alive_ml_supplies_object"", objNull]) setVariable [""alive_ml_supplies_seen"", true, false];",
    ""
];
_trigger setVariable ["alive_ml_supplies_object", _vehicle];

private _timeOfDay = (call ALIVE_fnc_getEnvironment) select 0;
private _objClass = switch (_timeOfDay) do {
    case "DAY": {
        "SmokeShellRed";
    };
    case "EVENING";
    case "NIGHT": {
        "B_IRStrobe";
    };
};
private _objTimeToLive = getNumber (configfile >> "CfgAmmo" >> _objClass >> "timeToLive");

while {!isNull _vehicle && !(_vehicle getVariable ["alive_ml_supplies_seen", false])} do {
    private _obj = _objClass createVehicle (getPos _vehicle);
    _obj attachTo [_vehicle, [0, 0, 0]];

    private _timeout = time + (_objTimeToLive - 10);
    waitUntil {sleep 1; time > _timeout};

    detach _obj;

    // Hide the obj underground because IR strobes keep flashing for an x amount of minutes after the object has been deleted
    _obj setPos ((getPos _obj) vectorAdd [0, 0, -1000]);

    sleep 0.5;

    deleteVehicle _obj;
};

deleteVehicle _trigger;

nil;
