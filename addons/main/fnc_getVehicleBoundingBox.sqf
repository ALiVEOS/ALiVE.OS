#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(getVehicleBoundingBox);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getVehicleBoundingBox
Description:
    Returns the bounding-box dimensions [length, width, height] for a vehicle
    classname. First call per class spawns the vehicle off-map at [0,0,5000],
    reads `boundingBoxReal`, deletes the temp instance, and caches the
    [length, width, height] tuple in a mission-scoped hashmap. Subsequent
    calls hit the cache and return immediately.

    The off-map spawn is necessary because `boundingBoxReal` requires an
    instance - CfgVehicles doesn't expose model dimensions directly, and
    `sizeOf` returns only a single number (bounding-sphere radius) which
    loses the length-vs-width distinction needed for footprint checks.

Parameters:
    _this select 0: STRING - vehicle classname (CfgVehicles entry)

Returns:
    ARRAY [_length, _width, _height] - dimensions in metres.
                                       [4, 2, 2] fallback if class not found.

Examples:
    (begin example)
    [["B_MRAP_01_F"]] call ALiVE_fnc_getVehicleBoundingBox;
    // -> [5.4, 2.5, 2.5] approximate
    (end)

See Also:
    ALiVE_fnc_findVehicleSpawnPosition
Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_vehicleClass", "", [""]]];

if (_vehicleClass == "") exitWith { [4, 2, 2] };

// Mission-scoped cache. Cleared automatically when the mission ends.
if (isNil "ALiVE_vehicleBBoxCache") then {
    ALiVE_vehicleBBoxCache = createHashMap;
};

private _classLower = toLower _vehicleClass;
private _cached = ALiVE_vehicleBBoxCache get _classLower;
if (!isNil "_cached") exitWith { _cached };

// Validate config before spawning - missing classes get a sane fallback
// rather than spamming RPT with createVehicle warnings.
if !(isClass (configFile >> "CfgVehicles" >> _vehicleClass)) exitWith {
    private _fallback = [4, 2, 2];
    ALiVE_vehicleBBoxCache set [_classLower, _fallback];
    _fallback
};

// Off-map spawn at high altitude (5000 m) to avoid colliding with anything
// at ground level. CAN_COLLIDE so the engine fully resolves the model bbox.
private _temp = createVehicle [_vehicleClass, [0, 0, 5000], [], 0, "CAN_COLLIDE"];
if (isNull _temp) exitWith {
    private _fallback = [4, 2, 2];
    ALiVE_vehicleBBoxCache set [_classLower, _fallback];
    _fallback
};

private _bbox = boundingBoxReal _temp;
deleteVehicle _temp;

// boundingBoxReal returns [[minX, minY, minZ], [maxX, maxY, maxZ]].
// Convention in Arma: X = lateral (width), Y = forward/aft (length),
// Z = vertical (height).
_bbox params ["_min", "_max"];
private _width  = abs ((_max select 0) - (_min select 0));
private _length = abs ((_max select 1) - (_min select 1));
private _height = abs ((_max select 2) - (_min select 2));

// Defensive: degenerate bboxes (zero-size, mod-broken models) get the
// fallback so downstream maths doesn't divide by zero.
if (_length < 0.5 || _width < 0.5) then {
    _length = 4;
    _width = 2;
    _height = 2;
};

private _result = [_length, _width, _height];
ALiVE_vehicleBBoxCache set [_classLower, _result];
_result
