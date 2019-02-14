#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(removeIED);

// Remove IED
private ["_IEDs","_town","_position","_size","_j","_nodel","_debug"];

if !(isServer) exitWith {diag_log "RemoveIED Not running on server!";};

_position = _this select 0;
_town = _this select 1;

_IEDs = [[GVAR(STORE), "IEDs"] call ALiVE_fnc_hashGet, _town] call ALiVE_fnc_hashGet;


    //["REMOVE IED: %1",_IEDs] call ALIVE_fnc_dump;

_removeIED = {
    private ["_IED","_IEDObj","_IEDCharge","_IEDskin","_IEDpos","_trgr"];

    private _thirdParty = ADDON getVariable ["thirdParty",false];

    _IEDpos = [_value, "IEDpos", [0,0,0]] call ALiVE_fnc_hashGet;
    _IEDskin = [_value, "IEDskin", "ALIVE_IEDUrbanSmall_Remote_Ammo"] call ALiVE_fnc_hashGet;

    // Delete Objects
    _IEDObj = (_IEDpos nearObjects [_IEDskin, 4]) select 0;

    //["REMOVE IED: %1, %2, %3",_IEDpos, _IEDskin, _IEDObj] call ALIVE_fnc_dump;

    // Assuming 3rd party IED mods are using mines
    if (isNil "_IEDObj" || {(!(mineActive _IEDObj) && (_thirdParty))}) then {
        //diag_log format["IED NOT FOUND at %1 for %2", _IEDpos, _IEDskin];

        // Remove the IED from the store
        [_IEDs, _key] call ALiVE_fnc_hashRem;
        [[GVAR(STORE), "IEDs"] call ALiVE_fnc_hashGet, _town, _IEDs] call ALiVE_fnc_hashSet;
    };

    if (ADDON getVariable "debug") then {
        private _debugmarkers = ADDON getVariable ["debugmarkers",[]];
        {

            if ((markerPos _x) distance _IEDpos < 3) then {
                // diag_log format["IED delete marker: %1, %2, %3", _x, markerpos _x, _IEDpos];
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

};

[_IEDs, _removeIED] call CBA_fnc_hashEachPair;

if ([ADDON, "debug"] call MAINCLASS) then {
    ["Removed IEDs at %1 (%2)", _town, _position ] call ALIVE_fnc_dump;
};