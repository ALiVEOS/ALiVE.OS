#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(removeIED);

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_ied
// Remove IED
private ["_IEDs","_town","_position","_size","_j","_nodel","_debug"];

if !(isServer) exitWith {["RemoveIED Not running on server!"] call ALiVE_fnc_dump;};

_position = _this select 0;
_town = _this select 1;

_IEDs = [[GVAR(STORE), "IEDs"] call ALiVE_fnc_hashGet, _town] call ALiVE_fnc_hashGet;


    //["REMOVE IED: %1",_IEDs] call ALIVE_fnc_dump;

_removeIED = {
    private ["_IED","_IEDObj","_IEDCharge","_IEDskin","_IEDpos","_trgr"];

    // Resolved integration mode - "mine" means we defer to Arma's mineActive
    // detection (legacy thirdParty=Yes), "alive" means full ALiVE pipeline.
    private _integrationMode = ADDON getVariable ["resolvedIntegrationMode", "alive"];
    private _thirdParty = (_integrationMode == "mine");

    _IEDpos = [_value, "IEDpos", [0,0,0]] call ALiVE_fnc_hashGet;
    _IEDskin = [_value, "IEDskin", "ALIVE_IEDUrbanSmall_Remote_Ammo"] call ALiVE_fnc_hashGet;

    // Find the IED object at its exact stored position.
    // Use a tight 1m radius to prevent cross-town contamination: if we use a wider
    // radius (e.g. 4m) nearObjects may return an IED belonging to a different town
    // that happens to be nearby, causing that object to be deleted from multiple
    // town hashes and wiped from the world prematurely.
    _IEDObjArr = _IEDpos nearObjects [_IEDskin, 1];

    // If no object found at exact position, remove from store and skip
    if (count _IEDObjArr == 0) then {
        [_IEDs, _key] call ALiVE_fnc_hashRem;
        [[GVAR(STORE), "IEDs"] call ALiVE_fnc_hashGet, _town, _IEDs] call ALiVE_fnc_hashSet;
    } else {

    _IEDObj = _IEDObjArr select 0;

    // Assuming 3rd party IED mods are using mines
    if (isNil "_IEDObj" || {(!(mineActive _IEDObj) && (_thirdParty))}) then {
        //["IED NOT FOUND at %1 for %2", _IEDpos, _IEDskin] call ALiVE_fnc_dump;

        // Remove the IED from the store
        [_IEDs, _key] call ALiVE_fnc_hashRem;
        [[GVAR(STORE), "IEDs"] call ALiVE_fnc_hashGet, _town, _IEDs] call ALiVE_fnc_hashSet;
    };

    if (ADDON getVariable "debug") then {
        private _debugmarkers = ADDON getVariable ["debugmarkers",[]];
        {

            if ((markerPos _x) distance _IEDpos < 3) then {
                // ["IED delete marker: %1, %2, %3", _x, markerpos _x, _IEDpos] call ALiVE_fnc_dump;
                [_x] call cba_fnc_deleteEntity;
                _debugmarkers set [_foreachindex, -1];
                ADDON setVariable ["debugmarkers", _debugmarkers - [-1]];
            };
        } foreach _debugmarkers;
    };

    _IEDCharge = _IEDobj getVariable ["charge", nil];

    // Delete Triggers
    _trgr = (position _IEDObj) nearObjects ["EmptyDetector", 3];
    {
        deleteVehicle _x;
    } foreach _trgr;

    deleteVehicle _IEDCharge;
    deleteVehicle _IEDObj;

    }; // end else (IED object found)

};

[_IEDs, _removeIED] call CBA_fnc_hashEachPair;

if ([ADDON, "debug"] call MAINCLASS) then {
    ["Removed IEDs at %1 (%2)", _town, _position ] call ALIVE_fnc_dump;
};