#include <\x\alive\addons\sup_combatSupport\script_component.hpp>
SCRIPT(combatSupport);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_combatSupport
Description:
Creates the server side object to store settings

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

The popup menu will change to show status as functions are enabled and disabled.

Examples:
(begin example)
// Create instance by placing editor module and specifying name myModule
(end)

See Also:
- <ALIVE_fnc_combatSupportInit>
- <ALIVE_fnc_combatSupportRWGExec>

Author:
NEO, adapted by Gunny for ALiVE
---------------------------------------------------------------------------- */

#define SUPERCLASS nil

private ["_logic","_operation","_args"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,[]);

switch(_operation) do {
        case "init": {
                /*
                MODEL - no visual just reference data
                - server side object only
				- enabled/disabled
                */

                // Ensure only one module is used
                if (isServer && !(isNil "ALIVE_combatSupport")) exitWith {
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_CS_ERROR1");
                };

                //Only one init per instance is allowed
            	if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SUP COMBATSUPPORT - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

            	//Start init
            	_logic setVariable ["initGlobal", false];

                //Load Functions on all localities and wait for the init to have passed
				call ALiVE_fnc_combatSupportFncInit;

                //Create basics on server
                if (isServer) then {

                        // if server, initialise module game logic
                        _logic setVariable ["super", SUPERCLASS];
                        _logic setVariable ["class", ALIVE_fnc_combatSupport];

                        //not publicVariable to clients yet to let it init before
                        NEO_radioLogic = _logic;

                        _CS_Set_Respawn = NEO_radioLogic getvariable ["combatsupport_respawn","3"];
                        CS_RESPAWN = parsenumber(_CS_Set_Respawn);
                        _CAS_SET_RESPAWN_LIMIT = NEO_radioLogic getvariable ["combatsupport_casrespawnlimit","3"];
                        CAS_RESPAWN_LIMIT = parsenumber(_CAS_SET_RESPAWN_LIMIT);
                        _TRANS_SET_RESPAWN_LIMIT = NEO_radioLogic getvariable ["combatsupport_transportrespawnlimit","3"];
                        TRANS_RESPAWN_LIMIT = parsenumber(_TRANS_SET_RESPAWN_LIMIT);
                        _ARTY_SET_RESPAWN_LIMIT = NEO_radioLogic getvariable ["combatsupport_artyrespawnlimit","3"];
						ARTY_RESPAWN_LIMIT = parsenumber(_ARTY_SET_RESPAWN_LIMIT);

						_transportArrays = [];
						_casArrays = [];
						_artyArrays = [];
						_sides = [WEST,EAST,RESISTANCE,CIVILIAN];

				        for "_i" from 0 to ((count synchronizedObjects _logic)-1) do {

                            _entry = vehicle ((synchronizedObjects _logic) select _i);
                            _type = _entry getvariable ["CS_TYPE","CAS"];
                            _cargoCount = getNumber(configFile >> "cfgVehicles" >> typeOf _entry >> "transportSoldier");

                            if (_entry isKindOf "Air") then {
                            	switch (toLower(_type)) do {
                                    case ("cas") : {
                                        private ["_position","_callsign","_type"];

                                        _callsign = _entry getvariable ["CS_CALLSIGN",groupID (group _entry)];
	                                    _height = _entry getvariable ["CS_HEIGHT",0];
	                                    _code = "";

	                                    _position = getposATL _entry;
	                                    _id = [_position] call ALiVE_fnc_getNearestAirportID;
	                                    _type = typeOf _entry;
	                                    _direction =  getDir _entry;

	                                    _casArray = [_position,_direction, _type, _callsign, _id,_code,_height];
	                                    _casArrays set [count _casArrays,_casArray];
                                    };

                                    case ("transport") : {
	                                    private ["_position","_callsign","_type"];

                                        _callsign = _entry getvariable ["CS_CALLSIGN",groupID (group _entry)];
	                                    _height = _entry getvariable ["CS_HEIGHT",0];
	                                    _code = "";

	                                    _position = getposATL _entry;
	                                    _id = [_position] call ALiVE_fnc_getNearestAirportID;
	                                    _type = typeOf _entry;
	                                    _direction =  getDir _entry;

	                                    _transportArray = [_position,_direction,_type, _callsign,["Pickup", "Land", "land (Eng off)", "Move", "Circle","Insertion"],_code,_height];
	                                    _transportArrays set [count _transportArrays,_transportArray];
                                    };
                                };
                            } else {
                                switch (tolower(_type)) do {
                                   case ("arty") : {
	                                    private ["_position","_callsign","_type"];

	                                    _position = getposATL _entry;
					    				_direction =  getDir _entry;
	                                    _class = typeOf _entry;

					   					_callsign = _entry getvariable ["CS_CALLSIGN",groupID (group _entry)];

	                                    _he = ["HE",parsenumber(_entry getvariable ["CS_artillery_he","30"])];
	                                    _illum = ["ILLUM",parsenumber(_entry getvariable ["CS_artillery_illum","30"])];
	                                    _smoke = ["SMOKE",parsenumber(_entry getvariable ["CS_artillery_smoke","30"])];
	                                    _guided = ["SADARM",parsenumber(_entry getvariable ["CS_artillery_guided","30"])];
	                                    _cluster = ["CLUSTER",parsenumber(_entry getvariable ["CS_artillery_cluster","30"])];
	                                    _lg = ["LASER",parsenumber(_entry getvariable ["CS_artillery_lg","30"])];
	                                    _mine = ["MINE",parsenumber(_entry getvariable ["CS_artillery_atmine","30"])];
	                                    _atmine = ["AT MINE",parsenumber(_entry getvariable ["CS_artillery_atmine","30"])];
	                                    _rockets = ["ROCKETS",parsenumber(_entry getvariable ["CS_artillery_rockets","16"])];

	                                    _ordnance = [_he,_illum,_smoke,_guided,_cluster,_lg,_mine,_atmine, _rockets];
										_code = "";
	                                    _artyArray = [_position,_class, _callsign,3,_ordnance,_code];
	                                    _artyArrays set [count _artyArrays,_artyArray];
                                    };
                                };
                            };

				            switch (typeOf ((synchronizedObjects _logic) select _i)) do {
                                case ("ALiVE_sup_cas") : {
                                    private ["_position","_callsign","_type"];

                                    _position = getposATL ((synchronizedObjects _logic) select _i);
                                    _callsign = ((synchronizedObjects _logic) select _i) getvariable ["cas_callsign","EAGLE ONE"];
                                    _type = ((synchronizedObjects _logic) select _i) getvariable ["cas_type","B_Heli_Attack_01_F"];
                                    _heightset = ((synchronizedObjects _logic) select _i) getvariable ["cas_height","0"];
                                    _direction =  getDir ((synchronizedObjects _logic) select _i);
                                    _id = [_position] call ALiVE_fnc_getNearestAirportID;
                                    _height = parsenumber(_heightset);
                                    _code = ((synchronizedObjects _logic) select _i) getvariable ["cas_code",""];
                                    _code = [_code,"this","(_this select 0)"] call CBA_fnc_replace;

                                    _casArray = [_position,_direction, _type, _callsign, _id,_code,_height];
                                    _casArrays set [count _casArrays,_casArray];
                                };
                                case ("ALiVE_SUP_TRANSPORT") : {
                                    private ["_position","_callsign","_type"];

                                    _position = getposATL ((synchronizedObjects _logic) select _i);
                                    _callsign = ((synchronizedObjects _logic) select _i) getvariable ["transport_callsign","FRIZ ONE"];
                                    _type = ((synchronizedObjects _logic) select _i) getvariable ["transport_type","B_Heli_Transport_01_camo_F"];
                                    _heightset = ((synchronizedObjects _logic) select _i) getvariable ["transport_height","0"];
                                    _height = parsenumber(_heightset);
                                    _direction =  getDir ((synchronizedObjects _logic) select _i);
                                    _code = ((synchronizedObjects _logic) select _i) getvariable ["transport_code",""];
                                    _code = [_code,"this","(_this select 0)"] call CBA_fnc_replace;



                                    _transportArray = [_position,_direction,_type, _callsign,["Pickup", "Land", "land (Eng off)", "Move", "Circle","Insertion"],_code,_height];
                                    _transportArrays set [count _transportArrays,_transportArray];
                                };
                                case ("ALiVE_sup_artillery") : {
                                    private ["_position","_callsign","_type"];

                                    _position = getposATL ((synchronizedObjects _logic) select _i);
                                    _callsign = ((synchronizedObjects _logic) select _i) getvariable ["artillery_callsign","FOX ONE"];
                                    _class = ((synchronizedObjects _logic) select _i) getvariable ["artillery_type","B_Mortar_01_F"];
                                    _setherounds = ((synchronizedObjects _logic) select _i) getvariable ["artillery_he","30"];
                                    _setillumrounds = ((synchronizedObjects _logic) select _i) getvariable ["artillery_illum","30"];
                                    _setsmokerounds = ((synchronizedObjects _logic) select _i) getvariable ["artillery_smoke","30"];
                                    _setguidedrounds = ((synchronizedObjects _logic) select _i) getvariable ["artillery_guided","30"];
                                    _setclusterrounds = ((synchronizedObjects _logic) select _i) getvariable ["artillery_cluster","30"];
                                    _setlgrounds = ((synchronizedObjects _logic) select _i) getvariable ["artillery_lg","30"];
                                    _setminerounds = ((synchronizedObjects _logic) select _i) getvariable ["artillery_mine","30"];
                                    _setatminerounds = ((synchronizedObjects _logic) select _i) getvariable ["artillery_atmine","30"];
                                    _setrocketrounds = ((synchronizedObjects _logic) select _i) getvariable ["artillery_rockets","16"];

                                    _direction =  getDir ((synchronizedObjects _logic) select _i);
                                    _code = ((synchronizedObjects _logic) select _i) getvariable ["artillery_code",""];
                                    _code = [_code,"this","(_this select 0)"] call CBA_fnc_replace;

                                    _herounds = parsenumber(_setherounds);
                                    _illumrounds = parsenumber(_setillumrounds);
                                    _smokerounds = parsenumber(_setsmokerounds);
                                    _guidedrounds = parsenumber(_setguidedrounds);
                                    _clusterrounds = parsenumber(_setclusterrounds);
                                    _lgrounds = parsenumber(_setlgrounds);
                                    _minerounds = parsenumber(_setminerounds);
                                    _atminerounds = parsenumber(_setatminerounds);
                                    _rocketrounds = parsenumber(_setrocketrounds);

                                    _he = ["HE",_herounds];
                                    _illum = ["ILLUM",_illumrounds];
                                    _smoke = ["SMOKE",_smokerounds];
                                    _guided = ["SADARM",_guidedrounds];
                                    _cluster = ["CLUSTER",_clusterrounds];
                                    _lg = ["LASER",_lgrounds];
                                    _mine = ["MINE",_minerounds];
                                    _atmine = ["AT MINE",_atminerounds];
                                    _rockets = ["ROCKETS", _rocketrounds];

                                   _ordnance = [_he,_illum,_smoke,_guided,_cluster,_lg,_mine,_atmine, _rockets];

                                    _artyArray = [_position,_class, _callsign,3,_ordnance,_code];
                                    _artyArrays set [count _artyArrays,_artyArray];
                                };
				            };
				        };

					    SUP_CASARRAYS  = _casArrays; PublicVariable "SUP_CASARRAYS";
					    SUP_TRANSPORTARRAYS  = _transportArrays; PublicVariable "SUP_TRANSPORTARRAYS";
					    SUP_ARTYARRAYS = _artyArrays; PublicVariable "SUP_ARTYARRAYS";

                        {
                        	NEO_radioLogic setVariable [format ["NEO_radioTrasportArray_%1", _x], [],true];
							NEO_radioLogic setVariable [format ["NEO_radioCasArray_%1", _x], [],true];
							NEO_radioLogic setVariable [format ["NEO_radioArtyArray_%1", _x], [],true];
						} foreach _sides;

						private ["_t", "_c", "_a"];
                        _t = [];
                        _c = [];
                        _a = [];


                        // Transport

                        {
                            private ["_pos", "_dir", "_type", "_callsign", "_tasks", "_code","_Height","_side"];
                            _pos = _x select 0; _pos set [2, 0];
                            _dir = _x select 1;
                            _type = _x select 2;
                            _callsign = toUpper (_x select 3);
                            _tasks = _x select 4;
                            _code =  _x select 5;
                             _height = _x select 6;



							_transportfsm = "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\transport.fsm";
                            _faction = gettext(configfile >> "CfgVehicles" >> _type >> "faction");
                            _side = getNumber(configfile >> "CfgVehicles" >> _type >> "side");

                            switch (_side) do {
                                case 0 : {_side = EAST};
                                case 1 : {_side = WEST};
                                case 2 : {_side = RESISTANCE};
                                default {_side = EAST};
                            };

                            private ["_veh","_grp"];

                            _veh = nearestObjects [_pos, [_type], 5];

                            if (count _veh == 0) then {
	                            _grp = createGroup _side;
	                            _veh = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
	                            _veh setDir _dir;
	                            _veh setPosATL _pos;

	                            If(_height > 0) then {_veh setposasl [getposASL _veh select 0, getposASL _veh select 1, _height]; _veh setVelocity [0,0,-1]} else {_veh setPosATL _pos};

	                            [_veh, _grp] call BIS_fnc_spawnCrew;
 							} else {
                                _veh = _veh select 0;
                                _grp = group (driver _veh);
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




                            //Set Group ID
                            [[(units _grp select 0),_callsign], "fnc_setGroupID", false, false] spawn BIS_fnc_MP;

                            // set ownership flag for other modules
                            _veh setVariable ["ALIVE_CombatSupport", true];
                            _veh setVariable ["NEO_transportAvailableTasks", _tasks, true];

                            [_veh, _grp, _callsign, _pos, _dir, _height, _type, CS_RESPAWN,_code] execFSM _transportfsm;

                            _t = NEO_radioLogic getVariable format ["NEO_radioTrasportArray_%1", _side];
                            _t set [count _t, [_veh, _grp, _callsign]];

                            NEO_radioLogic setVariable [format ["NEO_radioTrasportArray_%1", _side], _t,true];

                        } forEach SUP_TRANSPORTARRAYS;



                        // CAS

						{
                            private ["_pos", "_dir", "_type", "_callsign", "_airport", "_code","_side"];
                            _pos = _x select 0; _pos set [2, 0];
                            _dir = _x select 1;
                            _type = _x select 2;
                            _callsign = toUpper (_x select 3);
                            _airport = _x select 4;
                            _code = _x select 5;
                            _height = _x select 6;

                            _faction = gettext(configfile >> "CfgVehicles" >> _type >> "faction");
                            _side = getNumber(configfile >> "CfgVehicles" >> _type >> "side");
							_casfsm = "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\cas.fsm";

                            switch (_side) do {
                                case 0 : {_side = EAST};
                                case 1 : {_side = WEST};
                                case 2 : {_side = RESISTANCE};
                                default {_side = EAST};
                            };

                            private ["_veh","_grp"];

                            _veh = nearestObjects [_pos, [_type], 5];

                            if (count _veh == 0) then {
	                            _grp = createGroup _side;
	                            _veh = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
	                            _veh setDir _dir;
	                            _veh setPosATL _pos;

	                            If(_height > 0) then {_veh setposasl [getposASL _veh select 0, getposASL _veh select 1, _height]; _veh setVelocity [0,0,-1]} else {_veh setPosATL _pos};

	                            if (getNumber(configFile >> "CfgVehicles" >> _type >> "isUav") == 1) then {
	                            	createVehicleCrew _veh;
	                            } else {
	                            	[_veh, _grp] call BIS_fnc_spawnCrew;
	                            };
 							} else {
                                _veh = _veh select 0;
                                _grp = group (driver _veh);
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

                            _c = NEO_radioLogic getVariable format ["NEO_radioCasArray_%1", _side];
                            _c set [count _c, [_veh, _grp, _callsign]];

                            NEO_radioLogic setVariable [format ["NEO_radioCasArray_%1", _side], _c,true];

                        } forEach SUP_CASARRAYS;



                        // ARTY

                        {
                            private ["_pos", "_class", "_callsign", "_unitCount", "_rounds", "_code", "_roundsUnit", "_roundsAvailable", "_canMove", "_units", "_grp", "_vehDir","_tempclass","_side","_artyBatteries"];
                            _pos = _x select 0; _pos set [2, 0];
                            _class = _x select 1;
                            _callsign = toUpper (_x select 2);
                            _unitCount = round (_x select 3); if (_unitCount > 4) then { _unitCount = 4 }; if (_unitCount < 1) then { _unitCount = 1 };
                            _rounds = _x select 4;
                            _code = _x select 5;

                            if (_class in ["BUS_Support_Mort","BUS_MotInf_MortTeam","OIA_MotInf_MortTeam","OI_support_Mort","HAF_MotInf_MortTeam","HAF_Support_Mort"]) then {
                                private "_letter";
                                _letter = _class select [0,1];
                                switch (_letter) do {
                                    case "O" : {_tempclass = "O_Mortar_01_F"};
                                    case "B" : {_tempclass = "B_Mortar_01_F"};
                                    case "H" : {_tempclass = "I_Mortar_01_F"};
                                    default {_tempclass = "B_Mortar_01_F"};
                                };
                                _side = getNumber(configfile >> "CfgVehicles" >> _tempclass >> "side");
                            } else {
                                _side = getNumber(configfile >> "CfgVehicles" >> _class >> "side");
                            };

                            switch (_side) do {
                                case 0 : {_side = EAST};
                                case 1 : {_side = WEST};
                                case 2 : {_side = RESISTANCE};
                                default {_side = EAST};
                            };

                              _roundsUnit = _class call ALiVE_fnc_GetArtyRounds;

                            _roundsAvailable = [];
                            _canMove = if (_class in ["B_MBT_01_arty_F", "O_MBT_02_arty_F", "B_MBT_01_mlrs_F","O_Mortar_01_F", "B_Mortar_01_F","I_Mortar_01_F","BUS_Support_Mort","BUS_MotInf_MortTeam","OIA_MotInf_MortTeam","OI_support_Mort","HAF_MotInf_MortTeam","HAF_Support_Mort"]) then { true } else { false };
                            _units = [];
                            _artyBatteries = [];
                            _vehDir = 0;

                            private ["_veh","_grp"];

                            _veh = nearestObjects [_pos, [_class], 5];

                            if (count _veh > 0) then {_veh = _veh select 0; _grp = group _veh} else {_veh = nil; _grp = createGroup _side};

                            if (isnil "_veh") then {
                                private ["_vehPos","_i"];
                                for "_i" from 1 to _unitCount do
                                {
                                    private ["_veh","_sptarr"];
                                    _vehPos = _pos getPos [15, _vehDir]; _vehPos set [2, 0];

                                    if (isNil "_tempclass") then {
                                        _veh = createVehicle [_class, _vehPos, [], 0, "CAN_COLLIDE"];
                                        _artyBatteries pushback _veh;
                                    } else {
                                        _veh = createVehicle [_tempclass, _vehPos, [], 0, "CAN_COLLIDE"];
                                        _artyBatteries pushback _veh;
                                    };
                                    _veh setDir _vehDir;
                                    _veh setPosATL _vehPos;
                                    _veh lock true;
                                    _vehDir = _vehDir + 90;

                                    // set ownership flag for other modules
                                    _veh setVariable ["ALIVE_CombatSupport", true];

                                    [_veh, _grp] call BIS_fnc_spawnCrew;

                                    if (_i == 1) then {leader _grp setRank "CAPTAIN"};

                                    // Add leader and assistant if a mortar weapon, in order to use BIS pack and unpack functions
                                    if (_class in ["O_Mortar_01_F", "B_Mortar_01_F","I_Mortar_01_F","BUS_Support_Mort","BUS_MotInf_MortTeam","OIA_MotInf_MortTeam","OI_support_Mort","HAF_MotInf_MortTeam","HAF_Support_Mort"]) then {
                                        private ["_tl","_sl","_newgrp","_cars"];
                                        _tl = format ["%1_soldier_TL_F",_class select [0,1]];
                                        _sl = format ["%1_soldier_F",_class select [0,1]];
                                        _newgrp = [_vehPos, _side, [_tl, _sl],[],[],[],[],[],_vehDir] call BIS_fnc_spawnGroup;
                                        (units _newgrp) joinSilent _grp;

                                        _sptarr = _grp getVariable ["supportWeaponArray",[]];
                                        _sptarr pushback _veh;
                                        _grp setvariable ["supportWeaponArray", _sptarr];
                                    };

                                    _units set [count _units, _veh];
                                };
                                if (_class in ["BUS_MotInf_MortTeam","OIA_MotInf_MortTeam","HAF_MotInf_MortTeam"]) then {
                                    _cars = [2, faction (leader _grp),"Car"] call ALiVE_fnc_findVehicleType;
                                    if (count _cars > 0) then {
                                        for "_i" from 1 to ceil((count (units _grp))/4) do {
                                            private "_car";
                                            _car = createVehicle [_cars select 0, [position (leader _grp),1,100,1,0,4,0] call bis_fnc_findSafePos, [], 0, "NONE"];
                                            _grp addVehicle _car;
                                            _artyBatteries pushback _veh;
                                        };
                                    };
                                };
                            } else {
                                _units set [count _units, _veh];
                                _veh lock true;

                                // set ownership flag for other modules
                                _veh setVariable ["ALIVE_CombatSupport", true];
                            };

                            { _x setVariable ["NEO_radioArtyModule", [leader _grp, _callsign], true] } forEach _units;

                            [_grp,0] setWaypointPosition [_pos,0];
                            [[(units _grp select 0),_callsign], "fnc_setGroupID", false, false] spawn BIS_fnc_MP;


                            //[_veh, _grp, _units, units _grp] spawn _code;
                            _codeArray = [_code, ";"] Call CBA_fnc_split;
                            {
                                _vehicle = _x;
                                {
                                    If(_x != "") then {
                                        [_vehicle, _x] spawn {
                                            private ["_vehicle", "_spawn"];
                                            _vehicle = _this select 0;
                                            _spawn = compile(_this select 1);
                                            [_vehicle] spawn _spawn;
                                        };
                                    };
                                } forEach _codeArray;
                            } forEach _artyBatteries;

                            //Validate rounds
                            {
                                if ((_x select 0) in _roundsUnit) then
                                {
                                    _roundsAvailable set [count _roundsAvailable, _x];
                                };
                            } forEach _rounds;


                            leader _grp setVariable ["NEO_radioArtyBatteryRounds", _roundsAvailable, true];

                            //FSM
                            [_units, _grp, _callsign, _pos, _roundsAvailable, _canMove, _class, leader _grp, _code] execFSM "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\alivearty.fsm";

                            _a = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", _side];
                            _a set [count _a, [leader _grp, _grp, _callsign, _units, _roundsAvailable]];

                            NEO_radioLogic setVariable [format ["NEO_radioArtyArray_%1", _side], _a, true];

                        } forEach SUP_ARTYARRAYS;




						for "_i" from 0 to ((count _sides)-1) do {
							_sideIn = _sides select _i;

							{
								if (!(_sideIn == _x) && {(_sideIn getfriend _x >= 0.6)}) then {
									private ["_sideInArray","_xArray"];
									_sideInArray = NEO_radioLogic getVariable format["NEO_radioTrasportArray_%1", _sideIn];
									_xArray = NEO_radioLogic getVariable format["NEO_radioTrasportArray_%1", _x];

                                    if (count _xArray > 0) then {
                                        _add = [];
                                        {
                                            _vehicle = _x select 0;
                                            if (({_vehicle == _x select 0} count _sideInArray) == 0) then {
                                                _add set [count _add,_x];
                                            };
                                        } foreach _xArray;
                                        NEO_radioLogic setVariable [format ["NEO_radioTrasportArray_%1", _sideIn], _sideInArray + _add,true];
                                    };

									private ["_sideInArray","_xArray"];
									_sideInArray = NEO_radioLogic getVariable format["NEO_radioCasArray_%1", _sideIn];
									_xArray = NEO_radioLogic getVariable format["NEO_radioCasArray_%1", _x];

                                    if (count _xArray > 0) then {
                                        _add = [];
                                        {
                                            _vehicle = _x select 0;
                                            if (({_vehicle == _x select 0} count _sideInArray) == 0) then {
                                                _add set [count _add,_x];
                                            };
                                        } foreach _xArray;
                                        NEO_radioLogic setVariable [format ["NEO_radioCasArray_%1", _sideIn], _sideInArray + _add,true];
                                    };

									private ["_sideInArray","_xArray"];
									_sideInArray = NEO_radioLogic getVariable format["NEO_radioArtyArray_%1", _sideIn];
									_xArray = NEO_radioLogic getVariable format["NEO_radioArtyArray_%1", _x];

                                    if (count _xArray > 0) then {
                                        _add = [];
                                        {
                                            _vehicle = _x select 0;
                                            if (({_vehicle == _x select 0} count _sideInArray) == 0) then {
                                                _add set [count _add,_x];
                                            };
                                        } foreach _xArray;
                                        NEO_radioLogic setVariable [format ["NEO_radioArtyArray_%1", _sideIn], _sideInArray + _add,true];
                                    };
								};
							} foreach _sides;
						};

                        //Now PV the logic to all clients indicate its ready
                        _logic setVariable ["init", true,true];
                        publicVariable "NEO_radioLogic";
               	};

                // and wait for game logic to initialise
                // TODO merge into lazy evaluation
                waitUntil {!isNil "NEO_radioLogic"};
                waitUntil {NEO_radioLogic getVariable ["init", false]};

                /*
                VIEW - purely visual
                */
				NEO_radioLogic setVariable ["NEO_radioPlayerActionArray",
                    [
                        [
                            ("<t color=""#700000"">" + ("Talk To Pilot") + "</t>"),
                            {["talk"] call ALIVE_fnc_radioAction},
                            "talk",
                            -1,
                            false,
                            true,
                            "",
                            "
                                ({(_x select 0) == vehicle _this} count (NEO_radioLogic getVariable format ['NEO_radioTrasportArray_%1', playerSide]) > 0)
                                &&
                                {alive (driver (vehicle _this))}
                            "
                        ]
                    ]
                ];

	        	{player addAction _x} foreach (NEO_radioLogic getVariable "NEO_radioPlayerActionArray");
				player addEventHandler ["Respawn", { {(_this select 0) addAction _x } foreach (NEO_radioLogic getVariable "NEO_radioPlayerActionArray") }];

                //if there is a real screen it must be a player so hand out the menu item
				if (hasInterface) then {
					//Initialise Functions and add respawn eventhandler
					waituntil {(!(isnull player) && !(isnil "NEO_radioLogic"))};

					if (isNil "SELF_INTERACTION_KEY") then {SELF_INTERACTION_KEY = [221,[false,false,false]]};

					// if A2 - ACE spectator enabled, seto to allow exit
					if(!isNil "ace_fnc_startSpectator") then {ace_sys_spectator_can_exit_spectator = true};

					// check if player has item defined in module TODO!

                    // initialise main menu
				    [
				            "player",
				            [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
				            -9500,
				            [
				                    "call ALIVE_fnc_CombatSupportMenuDef",
				                    "main"
				            ]
				    ] call ALIVE_fnc_flexiMenu_Add;
                };
            };
        case "destroy": {
                if (isServer) then {
                        // if server
                        _logic setVariable ["super", nil];
                        _logic setVariable ["class", nil];
                        _logic setVariable ["init", nil];
                        // and publicVariable to clients
                        NEO_radioLogic = _logic;
                        publicVariable "NEO_radioLogic";
                };

                if(!isDedicated && !isHC) then {

                };
        };
        default {
                private["_err"];
                _err = format["%1 does not support %2 operation", _logic, _operation];
                ERROR_WITH_TITLE(str _logic,_err);
        };
};
