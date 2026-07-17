#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(isArtillery);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isArtillery

Description:
Checks if vehicle is an Artillery vehicle. Artillery OBSERVATION vehicles
(spotters like the RHS PRP-3) carry the artillery computer too but own no
gun - they are excluded by demanding lethal indirect-fire ordnance.

Parameters:
Vehicle - The vehicle

Returns:
Boolean

Examples:
(begin example)
_result = [_vehicle] call ALIVE_fnc_isArtillery;
(end)

See Also:
ALIVE_getEmptyVehiclePositions

Author:
HighHead
Jman
---------------------------------------------------------------------------- */
private ["_class","_hasArtyScanner"];

_class = _this select 0;

switch (typeName _class) do {
    case ("OBJECT") : {_class = typeOf _class};
    case ("STRING") : {_class = _class};
};

// callers hit this in monitor loops and config sweeps - cache per class
if (isNil "ALIVE_isArtilleryCache") then {
    ALIVE_isArtilleryCache = [] call ALIVE_fnc_hashCreate;
};
private _cached = [ALIVE_isArtilleryCache, _class] call ALIVE_fnc_hashGet;
if (!isNil "_cached") exitWith { _cached };

private _result = false;

_hasArtyScanner = getnumber(configfile >> "CfgVehicles" >> _class >> "artilleryScanner");

if (_class iskindOf "LandVehicle" && {_hasArtyScanner > 0}) then {

    // any turret elevating past 45 degrees counts (walk all turrets, not just
    // MainTurret - mod artillery often mounts the gun on a different turret).
    // 45 rather than 65 so rocket artillery qualifies: launcher tubes top out
    // around 55 degrees, while direct-fire guns stay well under 45 - and those
    // lack the artillery computer the check above demands anyway
    private _high = false;
    {
        if (getNumber (_x >> "maxElev") > 45) exitWith { _high = true };
    } forEach ("isClass _x" configClasses (configfile >> "CfgVehicles" >> _class >> "Turrets"));

    if (_high) then {
        // spotter guard: observation vehicles pass both checks above (scanner
        // flag + high-elevation optics/MG turret) without owning a gun, so
        // demand lethal ordnance in config. Launchers whose weapon is added
        // by script (BM-21 family) show an empty config loadout - recognise
        // those by the same name signature isRocketArtillery uses
        private _rounds = _class call ALIVE_fnc_getArtyRounds;
        _result = count (_rounds - ["SMOKE","ILLUM"]) > 0;

        if (!_result) then {
            private _sig = toLower format ["%1 %2", _class, getText (configfile >> "CfgVehicles" >> _class >> "model")];
            _result = (["bm21", "bm-21", "grad", "mlrs", "m270", "himars", "m142", "smerch", "uragan", "rm70", "rm-70", "katyusha"] findIf { _x in _sig }) > -1;
        };
    };
};

[ALIVE_isArtilleryCache, _class, _result] call ALIVE_fnc_hashSet;

_result
