#include "\x\alive\addons\sup_ground\script_component.hpp"
SCRIPT(GROUND);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_GROUND
Description:
Ground transport support module (#690). A data holder only: sync it to the Combat
Support module, which spawns the crewed vehicle and runs its orders. Orders are given
from the Combat Support tablet: Pickup, Move, Road patrol and Return to base. While it
drives, the crew checks the road ahead for IEDs and mines and rolls to disarm them.

Parameters:
_this select 0: OBJECT - the module
_this select 1: STRING - operation

Author:
Jman
---------------------------------------------------------------------------- */
params [["_logic", objNull, [objNull]], ["_operation", "", [""]]];

switch (_operation) do {
    case "init": {
        if (isServer) then {
            _logic setVariable ["super", nil];
            _logic setVariable ["class", ALIVE_fnc_GROUND];
        };
    };
};
