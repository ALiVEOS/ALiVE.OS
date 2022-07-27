params ["_support","_array"];

private _sides = [WEST,EAST,RESISTANCE,CIVILIAN];
switch (_support) do
{
    case "TRANSPORT" :
    {
        _array params ["_pos","_dir","_type","_callsign","_code","_height","_slingloading","_containerCount"];

        _pos set [2, 0];
        _callsign = toupper _callsign;
        _height = parsenumber _height;

        private _tasks = ["Pickup", "Land", "land (Eng off)", "Move", "Circle", "Insertion", "Slingload", "Unhook"];

        private _transportfsm = "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\transport.fsm";
        private _faction = gettext(configfile >> "CfgVehicles" >> _type >> "faction");
        private _side = getNumber(configfile >> "CfgVehicles" >> _type >> "side");

        _side = [[_side] call ALIVE_fnc_sideNumberToText] call ALIVE_fnc_sideTextToObject;

        private _veh = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
        _veh setDir _dir;
        _veh setPosATL _pos;

        if (_height > 0) then {
            _veh setposasl [getposASL _veh select 0, getposASL _veh select 1, _height];
            _veh setVelocity [0,0,-1];
        } else {
            _veh setPosATL _pos;
        };

        private _grp = createGroup _side;
        createVehicleCrew _veh;
        _crew = crew _veh;
        _crew joinSilent _grp;
        _grp addVehicle _veh;

        // Exclude CS from VCOM
        // CS only runs serverside so no PV is needed
        (driver _veh) setvariable ["VCOM_NOAI", true];

        private _ffvTurrets = [_type,true,true,false,true] call ALIVE_fnc_configGetVehicleTurretPositions;
        private _gunnerTurrets = [_type,false,true,true,true] call ALIVE_fnc_configGetVehicleTurretPositions;
        _ffvTurrets = _ffvTurrets - _gunnerTurrets;

        if (count _ffvTurrets > 0) then
        {
            for "_i" from 0 to (count _ffvTurrets)-1 do
            {
                private _turretPath = _ffvTurrets call BIS_fnc_arrayPop;
                [_veh turretUnit _turretPath] join grpNull;
                deleteVehicle (_veh turretUnit _turretPath);
            };
        };

        _veh lockDriver true;
        [_grp,0] setWaypointPosition [(getPos _veh),0];

        private _codeArray = [_code, ";"] Call CBA_fnc_split;
        {
            if (_x != "") then {
                [_veh] spawn (compile _x);
            };
        } forEach _codeArray;

        //Set Group ID
        [[(units _grp select 0),_callsign], "fnc_setGroupID", false, false] spawn BIS_fnc_MP;

        // Check vehicle can slingload
        private _slingvalue = [(configFile >> "CfgVehicles" >> _type >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;
        if (!isNil "_slingvalue" && _slingloading) then {
            _slingloading = _slingvalue > 0;
        } else {
            _slingloading = false;
        };

        // Spawn containers and cargo nets if slingloading is enabled?
        if (_containerCount > 0) then {
            private _containers = [ALIVE_factionDefaultContainers,_faction,[]] call ALIVE_fnc_hashGet;

            if (count _containers == 0) then {
                _containers = [ALIVE_sideDefaultContainers,str(_side),[]] call ALIVE_fnc_hashGet;
            };

            if (count _containers > 0) then {
                for "_i" from 1 to _containerCount do {
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

        private _audio = NEO_radioLogic getvariable ["combatsupport_audio",true];

        private _fsmHandle = [_veh, _grp, _callsign, _pos, _dir, _height, _type, CS_RESPAWN,_code, _audio, _slingloading] execFSM _transportfsm;

        private _transportArray = NEO_radioLogic getVariable format ["NEO_radioTrasportArray_%1", _side];
        _transportArray pushback ([_veh, _grp, _callsign, _fsmHandle]);
        NEO_radioLogic setVariable [format ["NEO_radioTrasportArray_%1", _side], _transportArray, true];
    };

    case "CAS" :
    {
        _array params ["_pos","_dir","_type","_callsign","_code","_height"];

        private _airport = [_pos] call ALiVE_fnc_getNearestAirportID;
        _pos set [2, 0];
        _callsign = toupper _callsign;
        _height = parsenumber _height;

        private _casfsm = "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\cas.fsm";
        private _faction = gettext(configfile >> "CfgVehicles" >> _type >> "faction");
        private _side = getNumber(configfile >> "CfgVehicles" >> _type >> "side");

        _side = [[_side] call ALIVE_fnc_sideNumberToText] call ALIVE_fnc_sideTextToObject;

        private _veh = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
        _veh setDir _dir;
        _veh setPosATL _pos;

        if (_height > 0) then {
            _veh setposasl [getposASL _veh select 0, getposASL _veh select 1, _height];
            _veh setVelocity [0,0,-1];
        } else {
            _veh setPosATL _pos;
        };

        private _grp = createGroup _side;
        if (getNumber(configFile >> "CfgVehicles" >> _type >> "isUav") == 1) then {
            createVehicleCrew _veh;
        } else {
            createVehicleCrew _veh;
            _crew = crew _veh;
            _crew joinSilent _grp;
            _grp addVehicle _veh;
        };

        // Exclude CS from VCOM
        // CS only runs serverside so no PV is needed
        (driver _veh) setvariable ["VCOM_NOAI", true];

        private _ffvTurrets = [_type,true,true,false,true] call ALIVE_fnc_configGetVehicleTurretPositions;
        private _gunnerTurrets = [_type,false,true,true,true] call ALIVE_fnc_configGetVehicleTurretPositions;
        _ffvTurrets = _ffvTurrets - _gunnerTurrets;

        if (count _ffvTurrets > 0) then
        {
            for "_i" from 0 to (count _ffvTurrets)-1 do
            {
                private _turretPath = _ffvTurrets call BIS_fnc_arrayPop;
                [_veh turretUnit _turretPath] join grpNull;
                deleteVehicle (_veh turretUnit _turretPath);
            };
        };

        _veh lockDriver true;
        [_grp,0] setWaypointPosition [(getPos _veh),0];

        private _codeArray = [_code, ";"] Call CBA_fnc_split;
        {
            if (_x != "") then {
                [_veh] spawn (compile _x);
            };
        } forEach _codeArray;

        // Set Group ID
        [[(units _grp select 0),_callsign], "fnc_setGroupID", false, false] spawn BIS_fnc_MP;

        // set ownership flag for other modules
        _veh setVariable ["ALIVE_CombatSupport", true];

        private _audio = NEO_radioLogic getvariable ["combatsupport_audio",true];

        //FSM
        private _fsmHandle = [_veh, _grp, _callsign, _pos, _airport, _dir, _height, _type, CS_RESPAWN, _code, _audio] execFSM _casfsm;

        private _casArray = NEO_radioLogic getVariable format ["NEO_radioCasArray_%1", _side];
        _casArray pushback ([_veh, _grp, _callsign, _fsmHandle]);
        NEO_radioLogic setVariable [format ["NEO_radioCasArray_%1", _side], _casArray, true];
    };

    case "ARTY" :
    {
        _array params ["_pos","_class","_callsign","_unitCount","_rounds","_code"];

        _pos set [2, 0];
        _callsign = toupper _callsign;

        _unitCount = round _unitCount;
        if (_unitCount > 4) then { _unitCount = 4 };
        if (_unitCount < 1) then { _unitCount = 1 };

        private ["_tempclass","_side"];
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

        _side = [[_side] call ALIVE_fnc_sideNumberToText] call ALIVE_fnc_sideTextToObject;

        private _canMove = if (_class in ["B_MBT_01_arty_F", "O_MBT_02_arty_F", "B_MBT_01_mlrs_F","O_Mortar_01_F", "B_Mortar_01_F","I_Mortar_01_F","BUS_Support_Mort","BUS_MotInf_MortTeam","OIA_MotInf_MortTeam","OI_support_Mort","HAF_MotInf_MortTeam","HAF_Support_Mort"]) then { true } else { false };
        private _units = [];
        private _artyBatteries = [];
        private _vehDir = 0;

        private "_veh";
        private _grp = createGroup _side;

        for "_i" from 1 to _unitCount do
        {
            private _vehPos = _pos getPos [15, _vehDir];
            _vehPos set [2, 0];

            private _veh = if (isNil "_tempclass") then {
                createVehicle [_class, _vehPos, [], 0, "CAN_COLLIDE"];
            } else {
                createVehicle [_tempclass, _vehPos, [], 0, "CAN_COLLIDE"];
            };

            _artyBatteries pushback _veh;

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
                private _prefix = _class select [0,1];

                if (_prefix == "H") then {
                    _prefix = "I";
                };

                private _tl = format ["%1_soldier_TL_F", _prefix];
                private _sl = format ["%1_soldier_F", _prefix];
                private _newgrp = [_vehPos, _side, [_tl, _sl],[],[],[],[],[],_vehDir] call BIS_fnc_spawnGroup;
                (units _newgrp) joinSilent _grp;

                private _sptarr = _grp getVariable ["supportWeaponArray",[]];
                _sptarr pushback _veh;
                _grp setvariable ["supportWeaponArray", _sptarr];
            };

            _units pushback _veh;
        };
        if (_class in ["BUS_MotInf_MortTeam","OIA_MotInf_MortTeam","HAF_MotInf_MortTeam"]) then {
            private _cars = [2, faction (leader _grp),"Car"] call ALiVE_fnc_findVehicleType;
            if (count _cars > 0) then {
                for "_i" from 1 to ceil((count (units _grp))/4) do {
                    private "_car";
                    _car = createVehicle [_cars select 0, [position (leader _grp),1,100,1,0,4,0] call bis_fnc_findSafePos, [], 0, "NONE"];
                    _grp addVehicle _car;
                    _artyBatteries pushback _car;
                };
            };
        };

        { _x setVariable ["NEO_radioArtyModule", [leader _grp, _callsign], true] } forEach _units;

        [_grp,0] setWaypointPosition [_pos,0];
        [[(units _grp select 0),_callsign], "fnc_setGroupID", false, false] spawn BIS_fnc_MP;

        private _codeArray = [_code, ";"] call CBA_fnc_split;
        {
            private _vehicle = _x;

            {
                if (_x != "") then {
                    [_vehicle] spawn (compile _x);
                };
            } forEach _codeArray;
        } forEach _artyBatteries;

        //Validate rounds
        private _roundsUnit = if (!isNil "_tempclass") then { _tempclass call ALiVE_fnc_GetArtyRounds } else { _class call ALiVE_fnc_GetArtyRounds };
        private _roundsAvailable = _rounds select { (_x select 0) in _roundsUnit };

        leader _grp setVariable ["NEO_radioArtyBatteryRounds", _roundsAvailable, true];

        //FSM
        private _fsmHandle = [_units, _grp, _callsign, _pos, _roundsAvailable, _canMove, _class, leader _grp, _code, _audio, _side] execFSM "\x\alive\addons\sup_combatSupport\scripts\NEO_radio\fsms\alivearty.fsm";

        private _artyArray = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", _side];
        _artyArray pushback ([leader _grp, _grp, _callsign, _units, _roundsAvailable, _fsmHandle]);

        NEO_radioLogic setVariable [format ["NEO_radioArtyArray_%1", _side], _artyArray, true];
    };
};
