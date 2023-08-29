#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(infantryGuardProbabilityCount);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_infantryGuardProbabilityCount
Description:
Garrisons units in defensible structures and static weapons
Parameters:
Scalar - _countInfantry
Scalar - _guardProbability
Returns:
Scalar
Examples:
(begin example)
[_countInfantry,_guardProbability] call ALIVE_fnc_infantryGuardProbabilityCount
(end)
See Also:
Author:
Jman
---------------------------------------------------------------------------- */

params ["_countInfantry","_guardProbability"];
private ["_guardProbabilityCount"];
_guardProbabilityCount = 0;

// DEBUG -------------------------------------------------------------------------------------
if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
 ["ALIVE_fnc_infantryGuardProbabilityCount - Garrison _countInfantry: %1, _guardProbability: %2",_countInfantry, _guardProbability] call ALIVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

 switch (_guardProbability) do
            {
            	case "0": { _guardProbabilityCount = 0; };
            	case "0.2": {
            		      if (_countInfantry == 1) then { _guardProbabilityCount = 0; };
            		      if (_countInfantry == 2) then { _guardProbabilityCount = 1; };
							     	  if (_countInfantry > 2) then { _guardProbabilityCount = [1,2] call BIS_fnc_randomInt;};
            	};
            	case "0.6": { 
            		      if (_countInfantry == 1) then { _guardProbabilityCount = 0; };
            		      if (_countInfantry == 2) then { _guardProbabilityCount = 1; };
            		      if (_countInfantry == 3) then { _guardProbabilityCount = 2; };
            		      if (_countInfantry == 4) then { _guardProbabilityCount = 3; };
							     	  if (_countInfantry > 4) then { _guardProbabilityCount = [3,4] call BIS_fnc_randomInt;};
							     	
            	};
            	case "1": { 
             		      if (_countInfantry == 1) then { _guardProbabilityCount = 0; };
            		      if (_countInfantry == 2) then { _guardProbabilityCount = 1; };
            		      if (_countInfantry == 3) then { _guardProbabilityCount = 2; };
            		      if (_countInfantry == 4) then { _guardProbabilityCount = 3; };
            		      if (_countInfantry == 5) then { _guardProbabilityCount = 4; };
            		      if (_countInfantry == 6) then { _guardProbabilityCount = 5; };
							     	  if (_countInfantry > 6) then { _guardProbabilityCount = [5,6] call BIS_fnc_randomInt;};  	
            	};
            	default { 
            		      if (_countInfantry == 1) then { _guardProbabilityCount = 0; };
            		      if (_countInfantry == 2) then { _guardProbabilityCount = 1; };
							     	  if (_countInfantry > 2) then { _guardProbabilityCount = [1,2] call BIS_fnc_randomInt;};
            	};
            }; 
            
_guardProbabilityCount      