_vehicle = _this select 0;
_id = _this select 1;
_marker = _this select 2;
_spawnpos = _this select 3;

//If marker doesnt exist create it
//if !([_marker] call ALIVE_fnc_markerExists) then {
//	createmarkerlocal [_marker,_spawnpos];
//};

//Init defaults on server
if (isServer) then {
	
	//set defaults
	_vehicle setvariable ["_id",_id,true];
	_vehicle setvariable ["_spawnpos",_spawnPos,true];
	_vehicle setvariable ["_marker",_marker,true];
	_vehicle setvariable ["_active",(_vehicle getvariable ["_active",true]),true];

	//Prepare respawn function;
	fnc_veh_respawn = {
	
		_vehicle = _this select 0;
		
		_vehicle spawn {
			_id = _this getvariable "_id";
			_spawnPos = _this getvariable "_spawnpos";
			_active = _this getvariable "_active";
			_marker = _this getvariable "_marker";
			_type = typeof _this;
			    
			sleep 10;
			_vehicle = _type createVehicle _spawnPos;
            		deletevehicle _this;
			    
			_vehicle setvariable ["_id",_id,true];
			_vehicle setvariable ["_spawnpos",_spawnPos,true];
			_vehicle setvariable ["_active",_active,true];
			_vehicle setvariable ["_marker",_marker,true];
			    
			_vehicle addEventhandler ["killed", {
					_this call fnc_veh_respawn;
			}];
            
			call compile format["%1 = _vehicle",_id];
			Publicvariable _id;
		};
	};

	//Add Eventhandler
	_vehicle addEventhandler ["killed", {
		_this call fnc_veh_respawn;
	}];

	//Inform all clients about initialised object
	call compile format["%1 = _vehicle",_id];
	PublicVariable _id;
};

//On all localities
//wait for initialised object
//waituntil {!(isnil {call compile _id})};

//Move marker locally
_id spawn {
	waituntil {
	     _vehicle = call compile _this;

	     waituntil {!isnil "_vehicle" && {alive _vehicle}};
	     _marker = _vehicle getvariable "_marker";

	     if (_vehicle getvariable ["_active",true]) then {
	         _marker setmarkerposLocal (getposATL _vehicle);
	     };
	     
	     sleep 1;
	};
};