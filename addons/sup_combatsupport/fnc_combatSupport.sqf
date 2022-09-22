#include "\x\alive\addons\sup_combatSupport\script_component.hpp"
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
#define DEFAULT_TRANSPORT_TASKS ["Pickup", "Land", "Land (Eng off)", "Move", "Circle", "Insertion", "Slingload", "Unhook"]

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
                if !(isnil {_logic getVariable "initGlobal"}) exitwith {["SUP COMBATSUPPORT - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_dump};

                //Start init
                _logic setVariable ["initGlobal", false];

                //Load Functions on all localities and wait for the init to have passed
                call ALiVE_fnc_combatSupportFncInit;

                //Create basics on server
                if (isServer) then {

                        waitUntil {!isnil "ALiVE_STATIC_DATA_LOADED"};

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

                        _audio = NEO_radioLogic getvariable ["combatsupport_audio",true];

                        _transportArrays = [];
                        _casArrays = [];
                        _artyArrays = [];
                        _sides = [WEST,EAST,RESISTANCE,CIVILIAN];

                        private _appendPylonLoadOutCode = {
                            private _entry = param [0, objNull];
                            private _code = param [1, ""];

                            private _pylonMagazines = getPylonMagazines _entry;

                            if (count _pylonMagazines > 0) then {
                                private _codeArray = [_code, ";"] call CBA_fnc_split;
                                _codeArray pushBack (format ["{(_this select 0) setPylonLoadOut [_forEachIndex + 1, _x]} forEach %1", _pylonMagazines]);
                                _code = [_codeArray, ";"] call CBA_fnc_join;
                            };

                            _code;
                        };

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
                                        _code = _entry getvariable ["CS_CODE",""];
                                        _code = [_code,"this","(_this select 0)"] call CBA_fnc_replace;
                                        _code = [_entry, _code] call _appendPylonLoadOutCode;

                                        _position = getposATL _entry;
                                        _id = [_position] call ALiVE_fnc_getNearestAirportID;
                                        _type = typeOf _entry;
                                        _direction =  getDir _entry;

                                        _casArray = [_position,_direction, _type, _callsign, _id,_code,_height];
                                        _casArrays pushback _casArray;
                                    };

                                    case ("transport") : {
                                        private ["_position","_callsign","_type","_slingloading","_containers","_tasks"];

                                        _callsign = _entry getvariable ["CS_CALLSIGN",groupID (group _entry)];
                                        _height = _entry getvariable ["CS_HEIGHT",0];
                                        _code = _entry getvariable ["CS_CODE",""];
                                        _code = [_code,"this","(_this select 0)"] call CBA_fnc_replace;
                                        _code = [_entry, _code] call _appendPylonLoadOutCode;
                                        _slingloading = _entry getvariable ["CS_SLINGLOADING",true];
                                        _containers = _entry getvariable ["CS_CONTAINERS",0];

                                        _position = getposATL _entry;
                                        _id = [_position] call ALiVE_fnc_getNearestAirportID;
                                        _type = typeOf _entry;
                                        _direction =  getDir _entry;

                                        LOG(_slingloading);

                                        if (!_slingloading) then {
                                            _tasks = DEFAULT_TRANSPORT_TASKS - ["Slingload","Unhook"];
                                        } else {
                                            _tasks = DEFAULT_TRANSPORT_TASKS;
                                        };

                                        _transportArray = [_position,_direction,_type, _callsign,_tasks,_code,_height,_slingloading,_containers];
                                        _transportArrays pushback _transportArray;
                                    };
                                    case ("hybrid"): {
                                        private ["_position","_callsign","_type","_slingloading","_containers","_tasks"];

                                        _callsign = _entry getvariable ["CS_CALLSIGN",groupID (group _entry)];
                                        _height = _entry getvariable ["CS_HEIGHT",0];
                                        _code = _entry getvariable ["CS_CODE",""];
                                        _code = [_code,"this","(_this select 0)"] call CBA_fnc_replace;
                                        _code = [_entry, _code] call _appendPylonLoadOutCode;
                                        _slingloading = _entry getvariable ["CS_SLINGLOADING",true];
                                        _containers = _entry getvariable ["CS_CONTAINERS",0];

                                        _position = getposATL _entry;
                                        _id = [_position] call ALiVE_fnc_getNearestAirportID;
                                        _type = typeOf _entry;
                                        _direction =  getDir _entry;

                                        LOG(_slingloading);

                                        if (!_slingloading) then {
                                            _tasks = DEFAULT_TRANSPORT_TASKS - ["Slingload","Unhook"];
                                        } else {
                                            _tasks = DEFAULT_TRANSPORT_TASKS;
                                        };

                                        _transportArray = [_position,_direction,_type, _callsign,_tasks,_code,_height,_slingloading,_containers];
                                        _transportArrays pushback _transportArray;

                                        _casArray = [_position,_direction, _type, _callsign, _id,_code,_height];
                                        _casArrays pushback _casArray;
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
                                        _code = _entry getvariable ["CS_CODE",""];
                                        _code = [_code,"this","(_this select 0)"] call CBA_fnc_replace;
                                        _artyArray = [_position,_class, _callsign,3,_ordnance,_code];
                                        _artyArrays pushback _artyArray;
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
                                    _casArrays pushback _casArray;
                                };
                                case ("ALiVE_SUP_TRANSPORT") : {
                                    private ["_position","_callsign","_type","_slingloading","_containers","_tasks"];

                                    _position = getposATL ((synchronizedObjects _logic) select _i);
                                    _callsign = ((synchronizedObjects _logic) select _i) getvariable ["transport_callsign","FRIZ ONE"];
                                    _type = ((synchronizedObjects _logic) select _i) getvariable ["transport_type","B_Heli_Transport_01_camo_F"];
                                    _heightset = ((synchronizedObjects _logic) select _i) getvariable ["transport_height","0"];
                                    _height = parsenumber(_heightset);
                                    _direction =  getDir ((synchronizedObjects _logic) select _i);
                                    _code = ((synchronizedObjects _logic) select _i) getvariable ["transport_code",""];
                                    _code = [_code,"this","(_this select 0)"] call CBA_fnc_replace;


                                    _slingloading = ((synchronizedObjects _logic) select _i) getvariable ["transport_slingloading",true];
                                    _containers = ((synchronizedObjects _logic) select _i) getvariable ["transport_containers",0];


                                    LOG(_slingloading);

                                    if (!_slingloading) then {
                                        _tasks = DEFAULT_TRANSPORT_TASKS - ["Slingload","Unhook"];
                                    } else {
                                        _tasks = DEFAULT_TRANSPORT_TASKS;
                                    };

                                    _transportArray = [_position,_direction,_type, _callsign,_tasks,_code,_height,_slingloading, _containers];
                                    _transportArrays pushback _transportArray;
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
                                    _artyArrays pushback _artyArray;
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
                            private ["_pos", "_dir", "_type", "_callsign", "_tasks", "_code","_Height","_side","_slingloading","_cont"];
                            _pos = _x select 0; _pos set [2, 0];
                            _dir = _x select 1;
                            _type = _x select 2;
                            _callsign = toUpper (_x select 3);
                            _tasks = _x select 4;
                            _code =  _x select 5;
                            _height = _x select 6;
                            _slingloading = _x select 7;
                            _cont = _x select 8;

                            _transportfsm = "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\transport.fsm";
                            _faction = gettext(configfile >> "CfgVehicles" >> _type >> "faction");
                            _side = getNumber(configfile >> "CfgVehicles" >> _type >> "side");

                            switch (_side) do {
                                case 0 : {_side = EAST};
                                case 1 : {_side = WEST};
                                case 2 : {_side = RESISTANCE};
                                default {_side = EAST};
                            };

                            private ["_veh","_grp","_crew"];

                            _veh = nearestObjects [_pos, [_type], 5];

                            if (count _veh == 0) then {
                                _grp = createGroup _side;
                                _veh = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
                                _veh setDir _dir;
                                _veh setPosATL _pos;

                                If(_height > 0) then {_veh setposasl [getposASL _veh select 0, getposASL _veh select 1, _height]; _veh setVelocity [0,0,-1]} else {_veh setPosATL _pos};

                                createVehicleCrew _veh;
                                _crew = crew _veh;
                                _crew joinSilent _grp;
                                _grp addVehicle _veh;

                             } else {
                                _veh = _veh select 0;
                                _grp = group (driver _veh);
                            };

                            // Exclude CS from VCOM
                            // CS only runs serverside so no PV is needed
                            (driver _veh) setvariable ["VCOM_NOAI", true];

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

                            _codeArray = [_code, ";"] call CBA_fnc_split;
                            {
                                if (_x != "") then {
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

                            // Check vehicle can slingload
                            private "_slingvalue";
                            _slingvalue = [(configFile >> "CfgVehicles" >> _type >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;
                            if (!isNil "_slingvalue" && _slingloading) then {
                                _slingloading = _slingvalue > 0;
                            } else {
                                _slingloading = false;
                            };

                            // Spawn containers and cargo nets if slingloading is enabled?
                            if (_cont > 0) then {
                                private ["_containers"];
                                _containers = [ALIVE_factionDefaultContainers,_faction,[]] call ALIVE_fnc_hashGet;

                                if(count _containers == 0) then {
                                    _containers = [ALIVE_sideDefaultContainers,str(_side),[]] call ALIVE_fnc_hashGet;
                                };

                                If (count _containers > 0) then {

                                    for "_i" from 1 to _cont do {
                                        private ["_veh","_position","_container"];
                                        _container = selectRandom _containers;
                                        _position = [
                                            _pos,
                                            (sizeOf _type),
                                            (sizeOf _type) + (sizeOf _container) * 2,
                                            (sizeOf _container),
                                            0,
                                            0.5,
                                            0,
                                            [],
                                            [_pos getpos [25, random(360)],
                                            _pos getpos [25, random(360)]]
                                        ] call bis_fnc_findSafePos;
                                        _veh = createVehicle [_container, _position, [], 5, "NONE"];
                                    };

                                };

                            };

                            // set ownership flag for other modules
                            _veh setVariable ["ALIVE_CombatSupport", true];
                            _veh setVariable ["NEO_transportAvailableTasks", _tasks, true];

                            private _fsmHandle = [_veh, _grp, _callsign, _pos, _dir, _height, _type, CS_RESPAWN,_code, _audio, _slingloading] execFSM _transportfsm;

                            _t = NEO_radioLogic getVariable format ["NEO_radioTrasportArray_%1", _side];
                            _t pushback ([_veh, _grp, _callsign, _fsmHandle]);

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

                            private ["_veh","_grp","_crew"];

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
                                    createVehicleCrew _veh;
                                    _crew = crew _veh;
                                    _crew joinSilent _grp;
                                    _grp addVehicle _veh;
                                };
                             } else {
                                _veh = _veh select 0;
                                _grp = group (driver _veh);
                            };

                            // Exclude CS from VCOM
                            // CS only runs serverside so no PV is needed
                            (driver _veh) setvariable ["VCOM_NOAI", true];

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


                            _codeArray = [_code, ";"] call CBA_fnc_split;
                            {
                                if (_x != "") then {
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
                            private _fsmHandle = [_veh, _grp, _callsign, _pos, _airport, _dir, _height, _type, CS_RESPAWN, _code, _audio] execFSM _casfsm;

                            _c = NEO_radioLogic getVariable format ["NEO_radioCasArray_%1", _side];
                            _c pushback ([_veh, _grp, _callsign, _fsmHandle]);

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
                                // Force _unitCount to 1 to prevent spawning 3x3 units when _class is from CfgGroups
                                _unitCount = 1;
                                private _letter = _class select [0,1];

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

                            if (!isNil "_tempclass") then {
                                _roundsUnit = _tempclass call ALiVE_fnc_GetArtyRounds;
                            } else {
                                _roundsUnit = _class call ALiVE_fnc_GetArtyRounds;
                            };

                            _roundsAvailable = [];
                            _canMove = if (_class in ["B_MBT_01_arty_F", "O_MBT_02_arty_F", "B_MBT_01_mlrs_F","O_Mortar_01_F", "B_Mortar_01_F","I_Mortar_01_F","BUS_Support_Mort","BUS_MotInf_MortTeam","OIA_MotInf_MortTeam","OI_support_Mort","HAF_MotInf_MortTeam","HAF_Support_Mort"]) then { true } else { false };
                            _units = [];
                            _artyBatteries = [];
                            _vehDir = 0;

                            private ["_veh","_grp","_crew"];

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

                                    createVehicleCrew _veh;
                                    _crew = crew _veh;
                                    _crew joinSilent _grp;
                                    _grp addVehicle _veh;

                                    // set ownership flag for other modules
                                    _veh setVariable ["ALIVE_CombatSupport", true];

                                    // Exclude CS from VCOM
                                    // CS only runs serverside so no PV is needed
                                    (driver _veh) setvariable ["VCOM_NOAI", true];

                                    if (_i == 1) then {leader _grp setRank "CAPTAIN"};

                                    // Add leader and assistant if a mortar weapon, in order to use BIS pack and unpack functions
                                    if (_class in ["O_Mortar_01_F", "B_Mortar_01_F","I_Mortar_01_F","BUS_Support_Mort","BUS_MotInf_MortTeam","OIA_MotInf_MortTeam","OI_support_Mort","HAF_MotInf_MortTeam","HAF_Support_Mort"]) then {
                                        private ["_tl","_sl","_newgrp","_cars"];
                                        private _prefix = _class select [0,1];

                                        if (_prefix == "H") then {
                                            _prefix = "I";
                                        };

                                        _tl = format ["%1_soldier_TL_F", _prefix];
                                        _sl = format ["%1_soldier_F", _prefix];
                                        _newgrp = [_vehPos, _side, [_tl, _sl],[],[],[],[],[],_vehDir] call BIS_fnc_spawnGroup;
                                        (units _newgrp) joinSilent _grp;

                                        _sptarr = _grp getVariable ["supportWeaponArray",[]];
                                        _sptarr pushback _veh;
                                        _grp setvariable ["supportWeaponArray", _sptarr];
                                    };

                                    _units pushback _veh;
                                };
                                if (_class in ["BUS_MotInf_MortTeam","OIA_MotInf_MortTeam","HAF_MotInf_MortTeam"]) then {
                                    _cars = [2, faction (leader _grp),"Car"] call ALiVE_fnc_findVehicleType;
                                    if (count _cars > 0) then {
                                        for "_i" from 1 to ceil((count (units _grp))/4) do {
                                            private "_car";
                                            _car = createVehicle [_cars select 0, [position (leader _grp),1,100,1,0,4,0] call bis_fnc_findSafePos, [], 0, "NONE"];
                                            _grp addVehicle _car;
                                            _artyBatteries pushback _car;
                                        };
                                    };
                                };
                            } else {
                                {
                                    private _v = vehicle _x;
                                    if !(_v in _units) then {
                                        _units pushback _v;
                                        _v lock true;

                                        // set ownership flag for other modules
                                        _v setVariable ["ALIVE_CombatSupport", true];
                                    };
                                } foreach units _grp;
                                _grp setVariable ["supportWeaponCount",count _units];
                            };

                            { _x setVariable ["NEO_radioArtyModule", [leader _grp, _callsign], true] } forEach _units;

                            [_grp,0] setWaypointPosition [_pos,0];
                            [[(units _grp select 0),_callsign], "fnc_setGroupID", false, false] spawn BIS_fnc_MP;


                            _codeArray = [_code, ";"] call CBA_fnc_split;
                            {
                                _vehicle = _x;
                                {
                                    if (_x != "") then {
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
                                    _roundsAvailable pushback _x;
                                };
                            } forEach _rounds;


                            leader _grp setVariable ["NEO_radioArtyBatteryRounds", _roundsAvailable, true];

                            //FSM
                            private _fsmHandle = [_units, _grp, _callsign, _pos, _roundsAvailable, _canMove, _class, leader _grp, _code, _audio, _side] execFSM "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\alivearty.fsm";

                            _a = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", _side];
                            _a pushback ([leader _grp, _grp, _callsign, _units, _roundsAvailable, _fsmHandle]);

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
                                                _add pushback _x;
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
                                                _add pushback _x;
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
                                                _add pushback _x;
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
                waitUntil {!isNil "NEO_radioLogic" && {NEO_radioLogic getVariable ["init", false]}};

                /*
                VIEW - purely visual
                */
                //if there is a real screen it must be a player so hand out the actions and menu items
                if (hasInterface) then {    
                    //Initialise Functions and add respawn eventhandler
                    waituntil {!isnull player};

                    NEO_radioLogic setVariable ["NEO_radioPlayerActionArray",
                        [
                            [
                                ("<t color=""#700000"">" + ("Talk To Pilot") + "</t>"),
                                {
                                    private _caller = _this select 1;
                                    private _vehicle = nil;

                                    if (vehicle _caller != _caller) then {
                                        _vehicle = vehicle _caller;
                                    }
                                    else {
                                        _vehicle = cursorTarget;
                                    };

                                    ["talk"] call ALIVE_fnc_radioAction;
                                    NEO_radioLogic setVariable ["NEO_radioTalkWithPilot", _vehicle];
                                },
                                "talk",
                                -1,
                                false,
                                true,
                                "",
                                "
                                    private _vehicle = nil;
                                    private _vehicle_found = false;

                                    {
                                        if (_x select 0 == cursorTarget && {_this distance cursorTarget <= 50}) exitWith {
                                            _vehicle = _x select 0;
                                        };

                                        if (_x select 0 == vehicle _this) exitWith {
                                            _vehicle = _x select 0;
                                        };

                                    } forEach (NEO_radioLogic getVariable format [""NEO_radioTrasportArray_%1"", playerSide]);

                                    if (!isNil ""_vehicle"" && {alive (driver _vehicle)}) then {
                                        _vehicle_found = true;
                                    };

                                    _vehicle_found;
                                "
                            ]
                        ]
                    ];

                    //Add Neo actions
                    {player addAction _x} foreach (NEO_radioLogic getVariable "NEO_radioPlayerActionArray");
                    player addEventHandler ["Respawn", { {(_this select 0) addAction _x } foreach (NEO_radioLogic getVariable "NEO_radioPlayerActionArray") }];

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
                                    ["main", "alive_flexiMenu_rscPopup"]
                            ]
                    ] call CBA_fnc_flexiMenu_Add;
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

                if(hasInterface) then {

                };
        };
        default {
                private["_err"];
                _err = format["%1 does not support %2 operation", _logic, _operation];
                ERROR_WITH_TITLE(str _logic,_err);
        };
};
