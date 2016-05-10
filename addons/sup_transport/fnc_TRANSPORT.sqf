#include <\x\alive\addons\sup_transport\script_component.hpp>
SCRIPT(TRANSPORT);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_transport
Description:
XXXXXXXXXX

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enabled
Boolean - enabled - Enabled or disable module

Parameters:
none

Description:
Transport Module! Detailed description to follow

Examples:
[_logic, "factions", ["OPF_F"] call ALiVE_fnc_Transport;
[_logic, "houses", _nonStrategicHouses] call ALiVE_fnc_Transport;
[_logic, "spawnDistance", 500] call ALiVE_fnc_Transport;
[_logic, "active", true] call ALiVE_fnc_Transport;

See Also:
- <ALIVE_fnc_TransportInit>

Author:
Gunny

---------------------------------------------------------------------------- */

#define SUPERCLASS nil

private ["_logic","_operation","_args"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,nil);
ALIVE_coreLogic = _logic;
            _position = getposATL ALIVE_coreLogic;
            _callsign = _logic getvariable ["transport_callsign",true];
            _type = _logic getvariable ["transport_type",true];
             CASPOS = _position; PublicVariable "CASPOS";
_init =	compile (_logic getvariable ["Init",""]);





