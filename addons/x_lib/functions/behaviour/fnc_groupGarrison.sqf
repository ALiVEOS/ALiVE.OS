#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(groupGarrison);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupGarrison
Description:
Garrisons units in defensible structures and static weapons
Parameters:
Group - group
Array - position
Scalar - radius
Boolean - move to position instantly (no animation)
Boolean - optional, only profiled vehicles (to avoid garrisoning player vehicles)
Returns:
Examples:
(begin example)
[_group,_position,200,true] call ALIVE_fnc_groupGarrison;
(end)
See Also:
Author:
ARJay, Highhead
---------------------------------------------------------------------------- */

params ["_group", "_position", "_radius", "_moveInstantly", ["_onlyProfiled", false, [true]]];
private _units = units _group;
if (count _units < 2) exitwith {};

private _leader = leader (group (_units select 0));
private _units = _units - [_leader];

if(isNil "ALiVE_STATIC_DATA_LOADED") then {
    call compile preprocessFileLineNumbers "\x\alive\addons\main\static\staticData.sqf";
};

if (!_moveInstantly) then {
    _group lockWP true;
};

doStop _leader;

private _staticWeapons = nearestObjects [_position, ["StaticWeapon"], _radius];
private _armedCars = nearestObjects [_position, ["Car"], _radius];
{
    if (!([_x] call ALiVE_fnc_isArmed) || {_onlyProfiled && {isnil {_x getvariable "profileID"}}}) then {_armedCars = _armedCars - [_x]};
    false
} count _armedCars;
_staticWeapons = _staticWeapons + _armedCars;

if (count _staticWeapons > 0) then {
    {
        private _weapon = _x;
        private _positionCount = [_weapon] call ALIVE_fnc_vehicleCountEmptyPositions;
        
        if (count _units > 0) then {
            
            private _unit = _units select 0;
            
            if (!isNil "_unit") then {
                
                if(_positionCount > 0) then {
                    if(_moveInstantly) then {
                        _unit assignAsGunner _weapon;
                        _unit moveInGunner _weapon;
                    } else {
                        _unit assignAsGunner _weapon;
                        [_unit] orderGetIn true;
                    };
                };
                
                _units = _units - [_unit];
            };
        };
        false
    } count _staticWeapons;
};

if (count _units == 0) exitwith {};

private _buildings = nearestObjects [_position, ALIVE_garrisonPositions select 1, _radius];

if (count _buildings > 0) then {
    {
        private _building = _x;
        private _class = typeOf _building;
        private _buildingPositions = [ALIVE_garrisonPositions, _class] call ALIVE_fnc_hashGet;
        
        if !(isNil "_buildingPositions") then {
            {
                if (_foreachIndex > ((count _units)-1)) exitwith {};
                
                if (count _units > 0) then {
                    
                    private _unit = _units select 0;
                    private _origPos = position _unit;
                    private _position = _building buildingpos _x;
                   
                    if (!isNil "_unit") then {
                        if (_moveInstantly) then {
                            
                            if (str(_position) find "[0,0" != -1) then {
                                ["ALiVE Group Garrison - Warning! %1 building-pos in %2 detected! Unit %3 reset to %4!",_position,_building,_unit,_origPos] call ALiVE_fnc_Dump;
                                
                                _unit setpos _origPos;
                            } else {
                                _unit setposATL _position;
                            };
                            
                            _unit setdir ((_unit getRelDir _building)-180);
                            dostop _unit;
                            
                            _unit disableAI "PATH";
                            sleep 0.03;
                            
                        } else {
                            
                            [_unit,_origPos,_position,_building] spawn {
                                params ["_unit", "_origPos", "_position", "_building"];
                                
	                            if (str(_position) find "[0,0" != -1) then {
                                    ["ALiVE Group Garrison - Warning! %1 building-pos in %2 detected! Unit %3 reset to %4!",_position,_building,_unit,_origPos] call ALiVE_fnc_Dump;
                                    
	                                [_unit, _origPos] call ALiVE_fnc_doMoveRemote;
	                            } else {
	                                [_unit, _position] call ALiVE_fnc_doMoveRemote;
	                            };            

                                waitUntil {sleep 1; _unit call ALiVE_fnc_unitReadyRemote};
                                
                                doStop _unit;                                                 
                            };
                        };
                        
                        _units = _units - [_unit];
                    };
                };
            } forEach _buildingPositions;
        };
        false
    } count _buildings;
    
} else {

    private _buildings = [_position, floor(_radius/2)] call ALIVE_fnc_getEnterableHouses;
    
    {
        
        private _building = _x;
        private _buildingPositions = [_building] call ALIVE_fnc_getBuildingPositions;
        
        {
            if (_foreachIndex > ((count _units)-1)) exitwith {};
            
            if (count _units > 0) then {
                
                private _unit = _units select 0;
                private _origPos = position _unit;
                private _position = _x;
                
                if (!isNil "_unit") then {
                    
                    if(_moveInstantly) then {
                        
                        if (str(_position) find "[0,0" != -1) then {
                            ["ALiVE Group Garrison - Warning! %1 building-pos in %2 detected! Unit %3 reset to %4!",_position,_building,_unit,_origPos] call ALiVE_fnc_Dump;
                            _unit setpos _origPos;
                        } else {
                            _unit setposATL _position;
                        };
                        
                        _unit setdir ((_unit getRelDir _building)-180);
                        dostop _unit;
                        
                        _unit disableAI "PATH";
                        sleep 0.03;
                        
                    } else {
                        [_unit,_origPos,_position,_building] spawn {
                            params ["_unit", "_origPos", "_position", "_building"];   
                            
                            if (str(_position) find "[0,0" != -1) then {
                                ["ALiVE Group Garrison - Warning! %1 building-pos in %2 detected! Unit %3 reset to %4!",_position,_building,_unit,_origPos] call ALiVE_fnc_Dump;
                                [_unit, _origPos] call ALiVE_fnc_doMoveRemote;
                            } else {
                                [_unit, _position] call ALiVE_fnc_doMoveRemote;
                            };
                            
                            waitUntil {sleep 1; _unit call ALiVE_fnc_unitReadyRemote};
                            
                            doStop _unit;                                                 
                        };
                    };
                    _units = _units - [_unit];
                };
            };
        } foreach _buildingPositions;
        false
    } count _buildings;
};