	private ["_support", "_array","_sides"];
	_support = _this select 0;
	_array = _this select 1;

	_sides = [WEST,EAST,RESISTANCE,CIVILIAN];
	switch (_support) do
	{
		case "TRANSPORT" :
		{
			private ["_pos", "_dir", "_type", "_callsign", "_code","_tasks","_side"];
			_pos = _array select 0; _pos set [2, 0];
			_dir = _array select 1;
			_type = _array select 2;
			_callsign = toUpper (_array select 3);
			_code = _array select 4;
			_height = parsenumber(_array select 5);

			_tasks = ["Pickup", "Land", "land (Eng off)", "Move", "Circle","Insertion"];

			_transportfsm = "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\transport.fsm";
                            _faction = gettext(configfile >> "CfgVehicles" >> _type >> "faction");
                            _side = getNumber(configfile >> "CfgVehicles" >> _type >> "side");

                            switch (_side) do {
                                case 0 : {_side = EAST};
                                case 1 : {_side = WEST};
                                case 2 : {_side = RESISTANCE};
                                default {_side = EAST};
                            };


			private ["_veh"];
			_veh = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
			_veh setDir _dir;
			_veh setPosATL _pos;

			If(_height > 0) then {_veh setposasl [getposASL _veh select 0, getposASL _veh select 1, _height]; _veh setVelocity [0,0,-1]} else {_veh setPosATL _pos};

			private ["_grp"];
			_grp = createGroup _side;
			[_veh, _grp] call BIS_fnc_spawnCrew;

			  _ffvTurrets = [_type,true,true,false,true] call ALIVE_fnc_configGetVehicleTurretPositions;
                            _gunnerTurrets = [_type,false,true,true,true] call ALIVE_fnc_configGetVehicleTurretPositions;
                            _ffvTurrets = _ffvTurrets - _gunnerTurrets;



                            if(count _ffvTurrets > 0) then
                            {
                                for "_i" from 0 to (count _ffvTurrets)-1 do
                                    {
                                          _turretPath = _ffvTurrets call BIS_fnc_arrayPop;
                                         [_veh turretUnit _turretPath] join grpNull;
                                         deleteVehicle (_veh turretUnit _turretPath);
                                    };
                            };

                             _veh lockDriver true;
                            [_grp,0] setWaypointPosition [(getPos _veh),0];

                              _codeArray = [_code, ";"] Call CBA_fnc_split;
                            {
                                   If(_x != "") then {
                                                    [_veh, _x] spawn {
                                                                        private ["_veh", "_spawn"];
                                                                        _veh = _this select 0;
                                                                        _spawn = compile(_this select 1);
                                                                         [_veh] spawn _spawn;
                                                                      };
                                                        };
                                                        		} forEach _codeArray;


			 //Set Group ID
                            [[(units _grp select 0),_callsign], "fnc_setGroupID", false, false] spawn BIS_fnc_MP;

                            // set ownership flag for other modules
                            _veh setVariable ["ALIVE_CombatSupport", true];
                            _veh setVariable ["NEO_transportAvailableTasks", _tasks, true];

                            [_veh, _grp, _callsign, _pos, _dir, _height, _type, CS_RESPAWN,_code] execFSM _transportfsm;


			private ["_transportArray"];
			_transportArray = NEO_radioLogic getVariable format ["NEO_radioTrasportArray_%1", _side];
			_transportArray set [count _transportArray, [_veh, _grp, _callsign]];
			NEO_radioLogic setVariable [format ["NEO_radioTrasportArray_%1", _side], _transportArray, true];
		};

		case "CAS" :
		{
			private ["_pos", "_dir", "_type", "_callsign", "_code","_height","_aiport","_side"];
			_pos = _array select 0;
			_airport = [_pos] call ALiVE_fnc_getNearestAirportID;
			_pos set [2, 0];
			_dir = _array select 1;
			_type = _array select 2;
			_callsign = toUpper (_array select 3);
			_code = _array select 4;
			_height = parsenumber(_array select 5);

			_casfsm = "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\cas.fsm";

                            _faction = gettext(configfile >> "CfgVehicles" >> _type >> "faction");
                            _side = getNumber(configfile >> "CfgVehicles" >> _type >> "side");

                            switch (_side) do {
                                case 0 : {_side = EAST};
                                case 1 : {_side = WEST};
                                case 2 : {_side = RESISTANCE};
                                default {_side = EAST};
                            };


			private ["_veh"];
			_veh = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
			_veh setDir _dir;
			_veh setPosATL _pos;

			If(_height > 0) then {_veh setposasl [getposASL _veh select 0, getposASL _veh select 1, _height]; _veh setVelocity [0,0,-1]} else {_veh setPosATL _pos};

			private ["_grp"];
			_grp = createGroup _side;
			  If (getNumber(configFile >> "CfgVehicles" >> _type >> "isUav") == 1) then {
	                            	createVehicleCrew _veh;
	                            } else {
	                            	[_veh, _grp] call BIS_fnc_spawnCrew;
	                            };

			  _ffvTurrets = [_type,true,true,false,true] call ALIVE_fnc_configGetVehicleTurretPositions;
                            _gunnerTurrets = [_type,false,true,true,true] call ALIVE_fnc_configGetVehicleTurretPositions;
                            _ffvTurrets = _ffvTurrets - _gunnerTurrets;



                            if(count _ffvTurrets > 0) then
                            {
                                for "_i" from 0 to (count _ffvTurrets)-1 do
                                    {
                                          _turretPath = _ffvTurrets call BIS_fnc_arrayPop;
                                         [_veh turretUnit _turretPath] join grpNull;
                                         deleteVehicle (_veh turretUnit _turretPath);
                                    };
                            };

                             _veh lockDriver true;
                            [_grp,0] setWaypointPosition [(getPos _veh),0];

                              _codeArray = [_code, ";"] Call CBA_fnc_split;
                            {
                                   If(_x != "") then {
                                                    [_veh, _x] spawn {
                                                                        private ["_veh", "_spawn"];
                                                                        _veh = _this select 0;
                                                                        _spawn = compile(_this select 1);
                                                                         [_veh] spawn _spawn;
                                                                      };
                                                        };
                                                        		} forEach _codeArray;


				// Set Group ID
                            [[(units _grp select 0),_callsign], "fnc_setGroupID", false, false] spawn BIS_fnc_MP;

                            // set ownership flag for other modules
                            _veh setVariable ["ALIVE_CombatSupport", true];

                            //FSM
                            [_veh, _grp, _callsign, _pos, _airport, _dir, _height, _type, CS_RESPAWN, _code] execFSM _casfsm;

			private ["_casArray"];
			_casArray = NEO_radioLogic getVariable format ["NEO_radioCasArray_%1", _side];
			_casArray set [count _casArray, [_veh, _grp, _callsign]];
			NEO_radioLogic setVariable [format ["NEO_radioCasArray_%1", _side], _casArray, true];
					diag_log format ["Support with callsign  not found in Transport units"];
		};
		/*
case "ARTY" :
		{
			private ["_pos", "_class", "_callsign", "_unitCount", "_rounds", "_code", "_roundsUnit", "_roundsAvailable", "_canMove", "_units", "_grp", "_vehDir"];
			_pos = _array select 0; _pos set [2, 0];
			_class = _array select 1;
			_callsign = toUpper (_array select 2);
			_unitCount = round (_array select 3); if (_unitCount > 4) then { _unitCount = 4 }; if (_unitCount < 1) then { _unitCount = 1 };
			_rounds = _array select 4;
			_code = _array select 5;
			_roundsUnit = _class call NEO_fnc_artyUnitAvailableRounds;
			_roundsAvailable = [];
			_canMove = if (_class in ["MLRS", "GRAD_CDF", "GRAD_INS", "GRAD_RU"]) then { true } else { false };
			_units = [];
			_grp = createGroup _side;
			_vehDir = 0;

			for "_i" from 0 to (_unitCount - 1) do
			{
				private ["_vehPos", "_veh"];
				_vehPos = [_pos, 15, _vehDir] call BIS_fnc_relPos; _vehPos set [2, 0];
				_veh = createVehicle [_class, _vehPos, [], 0, "CAN_COLLIDE"];
				[nil, nil, rCALLVAR, [_veh], BIS_ARTY_F_initVehicle] call RE;
				_veh setDir _vehDir;
				_veh setPosATL _vehPos;
				[_veh, _grp] call BIS_fnc_spawnCrew;
				_veh lock true;
				_vehDir = _vehDir + 90;
				_units set [count _units, _veh];
			};

			private ["_battery"];
			_battery = (createGroup _side) createUnit ["BIS_ARTY_Logic", _pos, [], 0, "NONE"];
			waitUntil { !isNil { BIS_ARTY_LOADED } };

			_battery synchronizeObjectsAdd [_units select 0];
			waitUntil { (_units select 0) in (synchronizedObjects _battery) };
			[nil, nil, "per", rSPAWN, [_grp, _callsign], { (_this select 0) setGroupId [(_this select 1)] }] call RE;

			//Validate rounds
			{
				if ((_x select 0) in _roundsUnit) then
				{
					_roundsAvailable set [count _roundsAvailable, _x];
				};
			} forEach _rounds;
			_battery setVariable ["NEO_radioArtyBatteryRounds", _roundsAvailable, true];

			//Code to spawn
			[_battery, _grp, _units, units _grp] spawn _code;

			//FSM
			[_units, _grp, _callsign, _pos, _roundsAvailable, _canMove, _class, _battery] execFSM "scripts\NEO_radio\fsms\arty.fsm";

			private ["_artyArray"];
			_artyArray = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", _side];
			_artyArray set [count _artyArray, [_battery, _grp, _callsign, _units, _roundsAvailable]];
			NEO_radioLogic setVariable [format ["NEO_radioArtyArray_%1", _side], _artyArray, true];
		};
		*/
	};