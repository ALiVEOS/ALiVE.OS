#include "\x\alive\addons\mil_IED\script_component.hpp"

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_ied
#define DEFAULT_VB_IED_THREAT 5
#define DEFAULT_VBIED_SIDE "CIV"

SCRIPT(createVBIED);

if (isNil QUOTE(ADDON)) exitWith {};

params [
    "_vehicle",
    ["_threat", ADDON getvariable ["VB_IED_Threat", DEFAULT_VB_IED_THREAT]]
];

private _debug = ADDON getVariable ["debug", false];
private _side = ADDON getvariable ["VB_IED_Side", DEFAULT_VBIED_SIDE];

if (_vehicle getVariable [QUOTE(ADDON(VBIED)),false]) exitWith {};

private _fate = random 100;

if (_debug) then {
    diag_log format ["Threat: %1, Fate: %4, Side: %2, VBIED: %3", _threat, _side, (_vehicle getvariable [QUOTE(ADDON(VBIED)), false]), _fate];
};

if (_fate > _threat || str(side _vehicle) != _side || (_vehicle isKindOf "Quadbike_01_base_F") ) exitWith {};

// Make sure vehicle is not in blacklist

private _blacklist = [ADDON, "blacklist"] call MAINCLASS;
private _inBlacklist = (_blacklist findIf { [_vehicle, _x] call ALiVE_fnc_inArea }) != -1;
if (_inBlacklist) exitWith {};

// Make sure vehicle is in taor

private _taor = [ADDON, "taor"] call MAINCLASS;
private _inTAOR = (_taor findIf { [_vehicle, _x] call ALiVE_fnc_inArea }) != -1;
if (!_inTAOR) exitWith {};

// create IED object and attach to vehicle
//_IEDskins = ["Land_IED_v1_PMC","Land_IED_v2_PMC","Land_IED_v3_PMC","Land_IED_v4_PMC"];

private _IED = createVehicle ["ALIVE_DemoCharge_Remote_Ammo", getposATL _vehicle, [], 0, "CAN_COLLIDE"];
_IED setDir 270;
if (_vehicle isKindOf "vn_bicycle_base" || _vehicle isKindOf "Motorcycle") then {
    _IED attachTo [_vehicle, [0,0,-1]];
} else {
    _IED attachTo [_vehicle, [0,-1,-1.08]];
};
_IED setVectorUp [0,0,-1];

// add debug marker logic

[
    {
        params ["_vehicle","_handle"];

        if (!alive _vehicle) exitwith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };

        if  (ADDON getVariable ["debug",false]) then {
            private _marker = _vehicle getvariable ["marker",nil];
            if (isNil "_marker" || {!(_marker in allMapMarkers)}) then {
                private _t = format["vbied_r%1", floor (random 1000)];
                _marker = [_t, getposATL _vehicle, "Icon", [0.5,0.5], "TYPE:", "mil_dot", "COLOR:", "ColorRed", "GLOBAL","TEXT:","VBIED"] call CBA_fnc_createMarker;
                _vehicle setVariable ["marker", _marker];
            } else {
                _marker setmarkerpos (position _vehicle);
            };
        } else {
            private _marker = _vehicle getVariable ["marker", ""];
            deletemarker _marker;
        };
    },
    0.3,
    _vehicle
] call CBA_fnc_addPerFrameHandler;

// Set up trigger to detonate IED
private _booby = [_IED, typeOf _vehicle] call ALIVE_fnc_armIED;

// Add damage handler
private _ehID = _IED addeventhandler ["HandleDamage",{
    private _IED = _this select 0;

    if (MOD(mil_IED) getVariable "debug") then {
        diag_log format ["ALIVE-%1 IED: %2 explodes due to damage by %3", time, _IED, (_this select 3)];
        [_IED getvariable "Marker"] call cba_fnc_deleteEntity;
    };

    private _iedPos = getpos _IED;
    "M_Mo_120mm_AT" createVehicle [_iedPos select 0, _iedPos select 1,0];

    private _trgr = (position _IED) nearObjects ["EmptyDetector", 3];
    {
        deleteVehicle _x;
    } foreach _trgr;

    // Update Sector Hostility
    [position _IED, [str(side (_this select 3))], +10] call ALiVE_fnc_updateSectorHostility;

    deletevehicle _IED;
}];

_IED setVariable ["ehID", _ehID, true];
_IED setvariable ["charge", _IED, true];

if (_debug) then {
    diag_log format ["ALIVE-%1 IED: Creating VB-IED for %2 at %3", time, typeof _vehicle, getposATL _vehicle];
};

_vehicle setVariable [QUOTE(ADDON(VBIED)),true];