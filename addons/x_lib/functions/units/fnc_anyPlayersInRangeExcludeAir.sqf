#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(anyPlayersInRangeExcludeAir);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_anyPlayersInRangeExcludeAir

Description:
Return the number of players within range of a position, excluding any players in planes

Parameters:
Array - Position measuring from
Number - Distance being measured (optional)
Bool - Also exclude player in helicopters

Returns:
Number - Returns number of players within range

Examples:
(begin example)
// No players in range
([_pos, 2500] call ALiVE_fnc_anyPlayersInRangeExcludeAir == 0)
(end)

Author:
ARJay

Peer Reviewed:
Wolffy 20131117
---------------------------------------------------------------------------- */

private ["_pos","_dist","_includeHelicopters","_players","_player","_anyInRange","_vehicleClass","_vehicleKind","_vehicle"];
PARAMS_1(_pos);
DEFAULT_PARAM(1,_dist,2500);
DEFAULT_PARAM(2,_includeHelicopters,false);

_players = allPlayers + allCurators;
_anyInRange = false;

scopeName "main";

{
	_player = _x;
	
	// they are in range
	if((getPos _player) distance _pos < _dist) then {
		_vehicle = vehicle _player;
		
		// air check
		if!(_vehicle == _player) then {
			_vehicleClass = typeOf _vehicle;
			_vehicleKind = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;
			
			// not a plane
			if!(_vehicleKind == "Plane") then {
			    if(_includeHelicopters) then {
			        if!(_vehicleKind == "Helicopter") then {
			            _anyInRange = true;
			            breakTo "main";
                    };
			    }else{
			        _anyInRange = true;
			        breakTo "main";
			    };
			};
		}else{
			_anyInRange = true;
			breakTo "main";
		};
	};
} forEach _players;

_anyInRange