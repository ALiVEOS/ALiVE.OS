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

// A mission maker's own word comes first (TheLogatron, 12 Nov: mod guns ALiVE doesn't count as artillery).
// Each list holds class names, and a class counts if it is or inherits from one of them. Read before the
// cache, so a list changed mid-mission applies at once. Set on the server, e.g. in init.sqf:
//   ALiVE_artilleryExclude = ["my_spotter_truck"];   never artillery
//   ALiVE_artilleryInclude = ["my_mortar_carrier"];  always artillery
// The Commander Artillery module's Extra artillery classes field adds to the include list. A listed
// vehicle with no artillery computer is counted but can't fire (getArtilleryAmmo is empty for it).
private _fnc_listed = {
    _this isEqualType [] && {(_this findIf { _x isEqualType "" && {_x != ""} && {_class isKindOf _x} }) >= 0}
};
if ((missionNamespace getVariable ["ALiVE_artilleryExclude", []]) call _fnc_listed) exitWith { false };
if ((missionNamespace getVariable ["ALiVE_artilleryInclude", []]) call _fnc_listed) exitWith { true };
private _fromModules = missionNamespace getVariable "ALiVE_artilleryModuleInclude";
if (isNil "_fromModules") then {
    _fromModules = [];
    {
        private _text = _x getVariable ["extraArtillery", _x getVariable ["ALiVE_mil_artillery_extraArtillery", ""]];
        if (_text isEqualType "") then { _fromModules append ((_text splitString ", ;") select { _x != "" }) };
    } forEach (entities "ALiVE_mil_artillery");
    // the modules exist once the mission is running; before that, look again next time
    if (time > 0) then { ALiVE_artilleryModuleInclude = _fromModules };
};
if (_fromModules call _fnc_listed) exitWith { true };

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
        // demand lethal ordnance in config. A launcher can still read empty
        // if its rounds sit somewhere the walk does not look - recognise those
        // by the same name signature isRocketArtillery uses
        private _rounds = _class call ALIVE_fnc_getArtyRounds;
        _result = count (_rounds - ["SMOKE","ILLUM"]) > 0;

        if (!_result) then {
            private _sig = toLower format ["%1 %2", _class, getText (configfile >> "CfgVehicles" >> _class >> "model")];
            _result = (["bm21", "bm-21", "grad", "mlrs", "m270", "himars", "m142", "smerch", "uragan", "rm70", "rm-70", "katyusha"] findIf { _x in _sig }) > -1;
        };
    };

    // a mortar fails the elevation test: the Mk6, the RHS M252 and 2B14 all report a maxElev of 13, the tube
    // being laid by the artillery computer instead. Vehicle-mounted mortars can also report low elevations.
    // A StaticMortar or mortar name counts when it has lethal artillery rounds; the LandVehicle and
    // artilleryScanner guards above still apply, including to mortars mounted on cars or tanks.
    if (!_result) then {
        private _sig = toLower format ["%1 %2", _class, getText (configfile >> "CfgVehicles" >> _class >> "model")];
        // the same names getArtilleryType reads as a mortar (no "type63": that is also a rocket launcher)
        if (_class isKindOf "StaticMortar" || {(["mortar","m252","2b14","podnos","l16","m224","m29","type53","mk6","60mm","81mm","82mm","120mm"] findIf { _x in _sig }) > -1}) then {
            _result = count ((_class call ALIVE_fnc_getArtyRounds) - ["SMOKE","ILLUM"]) > 0;
        };
    };
};

[ALIVE_isArtilleryCache, _class, _result] call ALIVE_fnc_hashSet;

_result
