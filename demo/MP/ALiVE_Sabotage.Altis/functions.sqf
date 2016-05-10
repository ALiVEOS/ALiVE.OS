SABOTAGE_fnc_compileList = {
    		private ["_list"];
                   
            _list = str(_this);
	        _list = [_list, "[", ""] call CBA_fnc_replace;
	        _list = [_list, "]", ""] call CBA_fnc_replace;
            _list = [_list, "'", ""] call CBA_fnc_replace;
            _list = [_list, """", ""] call CBA_fnc_replace;
            _list = [_list, ",", ", "] call CBA_fnc_replace;
            _list;
};

SABOTAGE_fnc_canSee = {
    		private ["_unit","_target"];

			_target = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
			_unit = [_this, 1, objNull, [objNull]] call BIS_fnc_param;
			
            if !(alive _unit) exitwith {false};
            
			_dir = ([_target, _unit] call BIS_fnc_dirTo) - (getDir _target);
            
			(_dir < 60 || {_dir > 300}) && {!(lineIntersects [eyePos _unit, eyePos _target , _unit, _target])};
};

SABOTAGE_fnc_masquerade = {

	private ["_unit","_target"];
	
	_unit = _this select 0;
	_target = _this select 1;
    
    _clear = ({((side _x) getFriend (side _unit)) < 0.6 && {!([_x,_unit] call Sabotage_fnc_canSee)}} count ((getposATL _unit) nearEntities [["CAManBase"], 100])) == 0;

	if (uniform _target == "") exitwith {
		_title = "<t size='1.5' color='#68a7b7' shadow='1'>IMPERSONATION</t><br/>";
        _text = format["%1<t>The chosen unit does not wear a uniform!</t>",_title];

        ["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
	};
    
    if !(_clear) exitwith {
		_title = "<t size='1.5' color='#68a7b7' shadow='1'>IMPERSONATION</t><br/>";
        _text = format["%1<t>There are more enemy units nearby that could spot you during masquerading!</t>",_title];

        ["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
	};

    _unit forceAddUniform (uniform _target); removeUniform _target;
    
    [_unit] spawn {
        _unit = _this select 0;
        
        _uniform = uniform _unit;
        _side = (faction _unit) call ALiVE_fnc_FactionSide;
        _time = time;

        _unit setcaptive true;
        _unit setvariable ["SABOTAGE_DETECTIONRATE",0];

        _detector = _unit addEventHandler ["fired",{
            
            if !((_this select 4) isKindOf "TimeBombCore") then {
    			_target = cursortarget; if (!isnull _target && {_target isKindOf "AllVehicles"}) then {(_this select 0) setvariable ["SABOTAGE_DETECTIONRATE",100]};
            };
		}];
                        
        waituntil {
            private ["_detectionRate"];
            
            sleep 5;

            _enemyunits = []; {if (((side _x) getfriend _side) < 0.6) then {_enemyUnits set [count _enemyUnits,_x]}} foreach ((getposATL _unit) nearEntities [["CAmanBase"],50]);
            _enemyunits = _enemyunits - [_unit];
            _detectionRate = _unit getvariable ["SABOTAGE_DETECTIONRATE",0];
            
            if (count _enemyunits > 0) then {
                if (_unit == vehicle _unit && {speed _unit > 10}) then {_detectionRate = _detectionRate + 1};
                
                if ({_x distance _unit < 3} count _enemyunits > 0) then {_detectionRate = _detectionRate + 30} else {
                     if ({_x distance _unit < 15} count _enemyunits > 0) then {_detectionRate = _detectionRate + 5};
                };
            } else {
		        if (_detectionRate > 0) then {_detectionRate = _detectionRate - 1};
            };
            
			/* 
			// Don't show detection rate to make it more thrilling?

			_title = "<t size='1.5' color='#68a7b7' shadow='1'>IMPERSONATION</t><br/>";
			_text = format["%1<t>You are impersonating an enemy! Your identity has been revealed to %2 percent!</t>",_title,ceil((_detectionRate/30)*100)];
			
			["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
			["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
			*/

			_unit setvariable ["SABOTAGE_DETECTIONRATE",_detectionRate];
            
            uniform _unit != _uniform || {_detectionRate > 30};
        };
        
        _unit removeEventHandler ["fired",_detector];
        
        _unit setcaptive false;
        _unit setvariable ["SABOTAGE_DETECTIONRATE",nil];
    };
};

SABOTAGE_fnc_establishHideout = {
    private ["_unit","_pos","_hideouts","_building"];
    
    _unit = _this select 0;
    
    _pos = getposATL _unit;
    _building = (nearestobjects [_pos, ['House_F'],20]) select 0;
    _hideOuts = (_unit getvariable ["SABOTAGE_HIDEOUTS",[]]);
    _nearestTown = [_pos] call ALIVE_fnc_taskGetNearestLocationName;
    _limit = 20;
    
    if (isnil "_building" || {_building in _hideOuts}) exitwith {_hideOuts};
    
	_total = 0; {_total = _total + (count (weaponcargo _x) + (count (itemcargo _x)))} foreach (nearestobjects [getPosATL _building, ['GroundWeaponHolder','ReammoBox_F'],20]); 

	if (_total < _limit) exitwith {
        
		_title = "<t size='1.5' color='#68a7b7' shadow='1'>SAFEHOUSE</t><br/>";
        _text = format["%1<t>Bring %3 more weapons to this location to establish a safehouse!</t>",_title,_total,_limit - _total];
		
		["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
		
		_hideOuts
	};

    _trigger = createTrigger ["EmptyDetector",getPosATL _building];
    _trigger setTriggerArea [500,500,0,false];
    _trigger setTriggerActivation ["WEST", "GUER D", false];
    _trigger setTriggerStatements ["this", "
			_text = format['<t>Safehouse at %1 has been detected! An assault is to be expected within the next 30 minutes!</t>',(((getposATL thisTrigger) call BIS_fnc_posToGrid) select 0) + (((getposATL thisTrigger) call BIS_fnc_posToGrid) select 1)];
			[['openSideSmall',0.3],'ALIVE_fnc_displayMenu',true,false,false] call BIS_fnc_MP;
			[['setSideSmallText',_text],'ALIVE_fnc_displayMenu',true,false,false] call BIS_fnc_MP;
    		[[[getposATL thisTrigger],{{[_x,'addObjective',[str(time), _this select 0, 50]] call ALiVE_fnc_OPCOM} foreach OPCOM_INSTANCES}],'BIS_fnc_spawn',false,false] call BIS_fnc_MP;
    	", "
    "];
    
    _unit setvariable ["SABOTAGE_HIDEOUTS",_hideOuts + [_building],true];
    _building setvariable ["SABOTAGE_OWNER",_unit,true];
    _building setvariable ["SABOTAGE_DETECTOR",_trigger];
    
    //Add to store
    [[getplayerUID _unit,"SABOTAGE_HIDEOUTS",[[typeOf _building,getposATL _building]]],"Sabotage_fnc_SaveData",false,false] call BIS_fnc_MP;
    
	_building addEventhandler ["killed",{
        _building = _this select 0;
        _unit = _building getvariable ["SABOTAGE_OWNER",objNull];
        _trigger = _building getvariable ["SABOTAGE_DETECTOR",objNull];
        
        _hideOuts = (_unit getvariable ["SABOTAGE_HIDEOUTS",[]]) - [_building];
		_respawn = format["ALiVE_SUP_MULTISPAWN_RESPAWNBUILDING_%1",faction _unit];
    	_respawnBackUp = format["RESPAWN_%1",side _unit];
        _data = []; {_data set [count _data,[typeOf _x,getposATL _x]]} foreach _hideouts;

	    if ([_respawn] call ALiVE_fnc_markerExists) then {_respawn setMarkerPosLocal (getmarkerPos _respawnBackUp)};
        
        _unit setvariable ["SABOTAGE_HIDEOUTS",_hideOuts,true];
        _building setvariable ["SABOTAGE_DETECTOR",nil];
       
		[[getplayerUID _unit,"SABOTAGE_DESTROYED",[[typeOf _building,getposATL _building]]],"Sabotage_fnc_SaveData",false,false] call BIS_fnc_MP;
        [[getplayerUID _unit,"SABOTAGE_HIDEOUTS",_data,true],"Sabotage_fnc_SaveData",false,false] call BIS_fnc_MP;
        
        deletevehicle _trigger;
        {_x setDamage 1} foreach (nearestobjects [getposATL (_this select 0), ['GroundWeaponHolder','ReammoBox_F'],20]);

        _pos = getposATL _building;

        _nearestTown = [_pos] call ALIVE_fnc_taskGetNearestLocationName;
		
		_title = "<t size='1.5' color='#68a7b7'  shadow='1'>ALERT!</t><br/>";
        _text = format["%1<t>Your safehouse %2 near %3 has been destroyed!</t>",_title,_this select 0, _nearestTown];
		
		[["openSideSmall",0.3],"ALIVE_fnc_displayMenu",true,false,false] call BIS_fnc_MP;
		[["setSideSmallText",_text],"ALIVE_fnc_displayMenu",true,false,false] call BIS_fnc_MP;
	}];
    
    _title = "<t size='1.5' color='#68a7b7' shadow='1'>SAFEHOUSE</t><br/>";
    _text = format["%1<t>You established a safehouse near %2 successfully!</t>",_title,_nearestTown];

    ["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
    ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
        
    _unit getvariable ["SABOTAGE_HIDEOUTS",[]];
};

SABOTAGE_fnc_destroyHideoutsServer = {
    private ["_side","_profileIDs","_killedTotal","_radius"];
    
    _side = _this select 0;
    _radius = _this select 1;
    
    _profileIDs = [ALiVE_ProfileHandler, "getProfilesBySide", _side] call ALIVE_fnc_profileHandler;
    _killedTotal = [];
    _hideOutsTotal = [];
    
    {
        _unit = _x;
        
        _hideouts = _unit getvariable ["SABOTAGE_HIDEOUTS",[]];
        _hideOutsTotal = _hideOutsTotal + _hideouts;
        _killed = [];
        
		{
		    _hideOut = _x;
		        
			{
		        private ["_profile","_pos"];
		
				_profile = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;
				_exit = false;
				
				if !(isnil "_profile") then {
					_type = [_profile,"type","entity"] call ALiVE_fnc_HashGet;
                    _isPlayer = [_profile,"isPlayer",false] call ALiVE_fnc_HashGet;
					
					if ((_type == "entity") && {!_isPlayer}) then {
						_pos = [_profile,"position",[0,0,0]] call ALiVE_fnc_HashGet;
						
		                if (_pos distance _hideOut < _radius) exitwith {_killed set [count _killed,_hideOut]; _exit = true};
					};
				};
	            
				if (_exit) exitwith {};
			} foreach _profileIDs;
		} foreach _hideouts;
	
	    if (count _killed > 0) then {
            _killedTotal = _killedTotal + _killed;
            _hideouts = _hideouts - _killed;
            
            _data = []; {_data set [count _data,[typeOf _x,getposATL _x]]} foreach _hideouts;
            
            _unit setvariable ["SABOTAGE_HIDEOUTS",_hideouts, true];
            [getplayerUID _unit,"SABOTAGE_HIDEOUTS",_data,true] call Sabotage_fnc_SaveData; 
        };
    } foreach ([] call BIS_fnc_listPlayers);
    
    if ((count _hideOutsTotal > 0) && {count _killedTotal == count _hideOutsTotal}) then {
		["All hideouts %1 destroyed!",_hideOutsTotal call SABOTAGE_fnc_compileList] call ALiVE_fnc_Dump;
    };

    {_objects = nearestObjects [_x, ["House_F","Reammobox_F","GroundWeaponHolder"], 20]; {_x setdamage 1} foreach _objects} foreach _killedTotal;
	_killedTotal;
};

SABOTAGE_fnc_selectRespawnHideout = {
    private ["_unit","_hideouts","_pos","_nearestTown"];
    
    _unit = _this select 0;
    
    _pos = getposATL _unit;
    _hideOuts = _unit getvariable ["SABOTAGE_HIDEOUTS",[]];
    _respawn = format["ALiVE_SUP_MULTISPAWN_RESPAWNBUILDING_%1",faction _unit];
    _respawnBackUp = format["RESPAWN_%1",side _unit];

    _hideOuts = [_hideOuts,[_pos],{_Input0 distance (getposATL _x)},"ASCEND"] call BIS_fnc_sortBy;

	if ([_respawn] call ALiVE_fnc_markerExists) then {
        _respawn setMarkerPosLocal (getposATL (_hideOuts select 0));
    } else {
        _respawnBackUp setMarkerPosLocal (getposATL (_hideOuts select 0));
    };

    _nearestTown = [_pos] call ALIVE_fnc_taskGetNearestLocationName;

    _title = "<t size='1.5' color='#68a7b7' shadow='1'>SAFEHOUSE</t><br/>";
    _text = format["%1<t>Your safehouse near %2 will now be used as a respawn point.</t>",_title,_nearestTown];

    ["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
    ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

    _hideOuts select 0;
};

Sabotage_fnc_SaveServer = {
	if !(isServer) exitwith {};
    
	_mission = format["SABOTAGE_%1",missionName];
	_allMissions = profileNamespace getVariable ["SABOTAGE_ALLMISSIONS",[]];
    
    if (isnil "SABOTAGE_STORE") exitwith {};
	
	if !(_mission in _allmissions) then {_allMissions set [count _allmissions,_mission]};

	profileNamespace setVariable [_mission, SABOTAGE_STORE];
	saveProfileNamespace;
	profileNamespace setVariable ["SABOTAGE_ALLMISSIONS", _allMissions];
	saveProfileNamespace;
    _mission
};

Sabotage_fnc_LoadServer = {
    if !(isServer) exitwith {};
    
	_mission = format["SABOTAGE_%1",missionName];

	profileNamespace getVariable _mission;
};

Sabotage_fnc_ClearProfileNameSpace = {
    if !(isServer) exitwith {};

	_allMissions = profileNamespace getVariable ["SABOTAGE_ALLMISSIONS", []];
	
    {
        profileNamespace setVariable [_x,nil];
        saveProfileNamespace
    } foreach _allMissions;
    
    profileNamespace setVariable ["SABOTAGE_ALLMISSIONS", nil];
    saveProfileNamespace
};

Sabotage_fnc_RequestData = {
    if !(isServer) exitwith {};
    
    private ["_playerUID","_type","_data"];

	_playerUID = [_this, 0, "", [""]] call BIS_fnc_param;
	_type = [_this, 1, "", [""]] call BIS_fnc_param;
    
    _unit = [_playerUID] call ALiVE_fnc_getPlayerByUID;
    
    if (isnil "SABOTAGE_STORE" || {isnull _unit}) exitwith {};

    _data = [_type,[[SABOTAGE_STORE,_playerUID] call ALiVE_fnc_HashGet,_type] call ALiVE_fnc_HashGet] call Sabotage_fnc_convertData;

    if (isnil "_data") exitwith {};
    
    _unit setvariable [_type,_data,true];
};

Sabotage_fnc_convertData = {
    
    private ["_playerUID","_type","_data","_unit"];

	_type = [_this, 0, "", [""]] call BIS_fnc_param;
    _data = [_this, 1, [], [[]]] call BIS_fnc_param;
    
    //Safety
    if !(!(_type == "") && {count _data > 0}) exitwith {};

    _dataConverted = [];
    
    switch (_type) do {
        case ("SABOTAGE_HIDEOUTS") : {
            {_dataConverted set [count _dataConverted,((_x select 1)) nearestObject ((_x select 0))]} foreach _data;
        };
        default {_dataConverted = _data};
    };
    
    if (isnil "_dataConverted") exitwith {};

	_dataConverted;
};

Sabotage_fnc_SaveData = {
    if !(isServer) exitwith {};
    
    private ["_playerUID","_type","_data","_playerdata"];

	_playerUID = [_this, 0, "", [""]] call BIS_fnc_param;
	_type = [_this, 1, "", [""]] call BIS_fnc_param;
    _data = [_this, 2, [], [[]]] call BIS_fnc_param;
    _override = [_this, 3, false, [true]] call BIS_fnc_param;
    
    //Safety
    if !(!(_playerUID == "") && {!(_type == "")} && {count _data > 0}) exitwith {};

	//Create Store in case it isnt available already
    if (isnil "SABOTAGE_STORE") then {SABOTAGE_STORE = [] call ALiVE_fnc_HashCreate};

	//Get/Create playerdata
	_playerdata = [SABOTAGE_STORE,_playerUID,[] call ALiVE_fnc_HashCreate] call ALiVE_fnc_HashGet;
    
    //Store data
    if (_override) then {
        [_playerdata,_type,_data] call ALiVE_fnc_HashSet;
    } else {
        [_playerdata,_type,([_playerdata,_type,[]] call ALiVE_fnc_HashGet) + _data] call ALiVE_fnc_HashSet;
    };
    
    [SABOTAGE_STORE,_playerUID,_playerdata] call ALiVE_fnc_HashSet;
};

SABOTAGE_fnc_handleSabotageLocal = {
    private ["_targets","_explosive","_unit","_objects","_collected","_killed","_points","_list"];
    
	_unit = _this select 0;
	_ammo = _this select 4;
    _killed = [];
    
	if !(_ammo isKindOf "TimeBombCore") exitwith {_killed};
        
    _explosive = (position _unit) nearestObject _ammo;

    waituntil {
        sleep 1 + (random 1);
        
        if (alive _explosive) then {
            
            _collected = _unit getvariable ["SABOTAGE_TARGETS",[]];
            
        	_objects = nearestObjects [_explosive, ["AllVehicles","House_F","Reammobox_F","Reammobox"], 20];
    		_targets = []; {if (!isnull _x && {alive _x} && {!(_x in _collected)}) then {_unit setvariable ["SABOTAGE_TARGETS",_collected + [_x]]}} foreach _objects; _targets = _targets - [_unit,_explosive];
            false;
        } else {
            true;
        };
    };

	{if (isnull _x || {!(alive _x)}) then {_killed set [count _killed,_x]}} foreach (_unit getvariable ["SABOTAGE_TARGETS",[]]);
    _unit setvariable ["SABOTAGE_TARGETS",(_unit getvariable ["SABOTAGE_TARGETS",[]]) - _killed];
    
    _points = 0;
    _list = [];
    _objectsSave = [];
    {
        private ["_object"];
        
        _object = _x;
        
        if (!(isnil "_object") && {!isNull _x}) then {
            
            _objectsSave set [count _objectsSave,[typeOf _object,getposATL _object]];
            
			{
			    _type = _x select 0;
			    _typeText = _x select 1;
                _reward = _x select 2;

			    if (
                	!(isnil {call compile _type}) &&
                	{{([toLower (typeOf _object), toLower _x] call CBA_fnc_find) > -1} count (call compile _type) > 0}
                ) exitwith {
                    _buildingType = _typeText;
                    _list set [count _list, _object];
                    _points = _points + _reward;
                };
                
                _buildingType = "location";
                _list set [count _list, _object];
                _points = _points + 10;
			    
			} foreach [
				["ALIVE_militaryHQBuildingTypes","HQ building",50],
                ["ALIVE_militarySupplyBuildingTypes","military supply building",30],
                ["ALIVE_militaryBuildingTypes","military building",20],
                ["ALIVE_airBuildingTypes","air installation",30],
				["ALIVE_militaryAirBuildingTypes","military air installation",30],
				["ALIVE_civilianAirBuildingTypes","civilian air installation",20],
				["ALIVE_militaryHeliBuildingTypes","military rotary-wing installation",20],
				["ALIVE_civilianHeliBuildingTypes","civilian helicopter installation",20],
                ["ALIVE_militaryParkingBuildingTypes","military logistics building",20],
                ["ALIVE_civilianCommsBuildingTypes","communications site",30],
				["ALIVE_civilianHQBuildingTypes","civilian HQ building",50],
				["ALIVE_civilianPowerBuildingTypes","power supply building",30],
				["ALIVE_civilianMarineBuildingTypes","marine installation",20],
                ["ALIVE_civilianFuelBuildingTypes","fuel supply building",30],
                ["ALIVE_civilianPopulationBuildingTypes","civilian population building",10],
				["ALIVE_civilianRailBuildingTypes","rail constructions",30],
				["ALIVE_civilianConstructionBuildingTypes","construction site",10],
				["ALIVE_civilianSettlementBuildingTypes1","civilian settlement building",10]
			];
        };
    } foreach _killed;

    if (_points > 0) then {
        
        //Store killed
    	[[getplayerUID _unit,"SABOTAGE_DESTROYED",_objectsSave],"Sabotage_fnc_SaveData",false,false] call BIS_fnc_MP;
        
        _whitelist = [];
        _blacklist = [];
        {

            _object = typeOf _x;
            
            if !(_object in _blacklist) then {
                _blacklist set [count _blacklist,_object];
	            _whitelist set [count _whitelist,format["%1x %2",{(typeOf _x) == _object} count _list,getText(configfile >> "CfgVehicles" >> _object >> "displayName")]];
            };
        } foreach _list;

		_list = _whitelist call SABOTAGE_fnc_compileList;

		_title = "<t size='1.5' color='#68a7b7'  shadow='1'>REINFORCEMENTS</t><br/>";
        _text = format["%1<t>Your factions forces received %2 reinforcements for destruction of %3!</t>",_title,ceil(_points/10),_list];
		
		[["openSideSmall",0.3],"ALIVE_fnc_displayMenu",true,false,false] call BIS_fnc_MP;
		[["setSideSmallText",_text],"ALIVE_fnc_displayMenu",true,false,false] call BIS_fnc_MP;
        
        _unit setvariable ["SABOTAGE_POINTS",(_unit getvariable ["SABOTAGE_POINTS",0]) + _points,true];
        [[[ceil(_points/10),_unit],{if (!isnil "ALIVE_globalForcePool") then {[ALIVE_globalForcePool,faction (_this select 1),([ALIVE_globalForcePool,faction (_this select 1),0] call ALIVE_fnc_hashGet) + (_this select 0)] call ALIVE_fnc_hashSet}}],"BIS_fnc_spawn",false,false] call BIS_fnc_MP;
    };

    _killed;
};

SABOTAGE_fnc_initServer = {
    if !(isServer) exitwith {};
    
    //Spawn Destroy Loop - 5 secs
    [] spawn {waitUntil {sleep 5; ["GUER",50] call SABOTAGE_fnc_destroyHideoutsServer; false}};

    //Spawn Save Loop - 60 secs
    [] spawn {waitUntil {sleep 60; call Sabotage_fnc_SaveServer; false}};
        
    //Load persistent Data from ProfileNameSpace
    SABOTAGE_STORE = call Sabotage_fnc_LoadServer;
    
    //Restore mission relevant state if there is data
    if !(isNil "SABOTAGE_STORE") then {
	    [] spawn {
	    	waituntil {time > 0};

		    {
		        _playerdata = _x;
		        _killed = [_playerdata,"SABOTAGE_DESTROYED",[]] call ALiVE_fnc_HashGet;
		        
                //Destroy buildings
		        {
		            _objects = (nearestObjects [_x select 1,[_x select 0],20]);
		            if (count _objects > 0) then {(_objects select 0) setdamage 1};
		        } foreach _killed;
		    } foreach (SABOTAGE_STORE select 2);
	    };
    };
    
    //Indicate Server is ready
    SABOTAGE_SERVERINIT = true; PublicVariable "SABOTAGE_SERVERINIT";
};

SABOTAGE_fnc_initPlayer = {
    private ["_unit","_pos"];
    
    _unit = _this;
	_pos = getposATL _unit;
    
    [[getPlayerUID _unit,"SABOTAGE_HIDEOUTS"],"Sabotage_fnc_RequestData",false,false] call BIS_fnc_MP;
    [[getPlayerUID _unit,"SABOTAGE_DESTROYED"],"Sabotage_fnc_RequestData",false,false] call BIS_fnc_MP;
    
	_id = _unit addAction [
		"Establish safehouse",
		{_vars = _this select 3; [_vars select 0, _vars select 1] call SABOTAGE_fnc_establishHideout},
		[_unit, getposATL _unit],
		1,
		false,
		true,
		"",
		"private ['_building']; _building = (nearestobjects [_this, ['House_F'],20]) select 0; !(isnil '_building') && {({((getposATL _this) distance (getposATL _x)) < 500} count (_this getvariable ['SABOTAGE_HIDEOUTS',[]])) == 0}"
	];
    
    ["ALiVE | SABOTAGE - Added clientside establish safehouse action! ID %1...",_id] call ALiVE_fnc_Dump;
    
    _id = _unit addAction [
		"Use safehouse as respawn",
		{_vars = _this select 3; [_vars select 0] spawn SABOTAGE_fnc_selectRespawnHideout},
		[_unit],
		1,
		false,
		true,
		"",
		"({((getposATL _this) distance (getposATL _x)) < 15} count (_this getvariable ['SABOTAGE_HIDEOUTS',[]])) > 0 && {(getmarkerpos (format['ALiVE_SUP_MULTISPAWN_RESPAWNBUILDING_%1',faction _this])) distance _this > 50}"
	];
    
    ["ALiVE | SABOTAGE - Added safehouse as respawn action! ID %1...",_id] call ALiVE_fnc_Dump;
	
	_id = _unit addAction [
		"Repair and Refuel",
		{_vars = _this select 3; _unit = _vars select 0; vehicle _unit setdamage 0; vehicle _unit setfuel 1},
		[_unit],
		1,
		false,
		true,
		"",
		"vehicle _this != _this && {damage (vehicle _this) > 0.01 || {!canMove (vehicle _this)} || {fuel vehicle _this < 0.9}} && {({(getposATL _x) distance _this < 25} count (_this getvariable ['SABOTAGE_HIDEOUTS',[]])) > 0}"
	];
	
    ["ALiVE | SABOTAGE - Added Repair and Refuel action! ID %1...",_id] call ALiVE_fnc_Dump;
    
	_id = _unit addAction [
		"Impersonate",
		{[player,cursortarget] call SABOTAGE_fnc_masquerade},
		[],
		1,
		false,
		true,
		"",
		"isnil {_this getvariable 'SABOTAGE_DETECTIONRATE'} && {!alive cursortarget} && {cursortarget distance _this < 5} && {cursortarget isKindOf 'CAManBase'} && {(((typeOf cursortarget) call ALiVE_fnc_classSide) getfriend ((typeOf _this) call ALiVE_fnc_classSide)) < 0.6}"
	];
    
    ["ALiVE | SABOTAGE - Added Impersonate action! ID %1...",_id] call ALiVE_fnc_Dump;
};