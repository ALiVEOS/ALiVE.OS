//Starting Init
["ALiVE | SABOTAGE - Executing init.sqf..."] call ALiVE_fnc_Dump; 

//Initialise functions
call compile preprocessFile "functions.sqf";


/////////////////////
// Init server
/////////////////////



if (isServer) then {

	["ALiVE | SABOTAGE - Running ServerInit..."] call ALiVE_fnc_Dump;

	call SABOTAGE_fnc_initServer;
    
    30 setfog [0.05,0.05,80];
};



/////////////////////
// Init clients
/////////////////////



//Wait until server has initialised
waituntil {!isnil "SABOTAGE_SERVERINIT"};

if (hasInterface) then {
    
    ["ALiVE | SABOTAGE - Running ClientInit..."] call ALiVE_fnc_Dump;
    
    //Intro
    [] spawn {
	    titleText ["The ALiVE Team presents...", "BLACK IN",9999];
		0 fadesound 0;
	
		private ["_cam","_camx","_camy","_camz","_object"];
		_start = time;
	
		waituntil {(player getvariable ["alive_sys_player_playerloaded",false]) || ((time - _start) > 20)};
		playmusic "boom";
		sleep 10;
		
		_object = player;
		_camx = getposATL player select 0;
		_camy = getposATL player select 1;
		_camz = getposATL player select 2;
		
		_cam = "camera" CamCreate [_camx -500 ,_camy + 500,_camz+450];
		
		_cam CamSetTarget player;
		_cam CameraEffect ["Internal","Back"];
		_cam CamCommit 0;
		
		_cam camsetpos [_camx -15 ,_camy + 15,_camz+3];
		
		titleText ["A L i V E   |   S A B O T A G E", "BLACK IN",10];
		10 fadesound 0.9;
		_cam CamCommit 20;
		sleep 5;
		sleep 15;
				
		_cam CameraEffect ["Terminate","Back"];
		CamDestroy _cam;
		
		sleep 1;

		_title = "<t size='1.5' color='#68a7b7' shadow='1'>SABOTAGE</t><br/>";
        _text = format["%1<t>Collect and store weapons at buildings to establish safehouses across Altis.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>SABOTAGE</t><br/>";
        _text = format["%1<t>Impersonate dead enemy combatants to gain access to secure installations undetected.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>SABOTAGE</t><br/>";
        _text = format["%1<t>Sabotage key infrastructure to strike at the occupying forces and gain supplies for the resistance.</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
    };
    
    waituntil {!isnull player};
    
    //Persistent EHs
	player addEventHandler ["RESPAWN",{(_this select 1) spawn {waituntil {!isnull player}; player call SABOTAGE_fnc_initPlayer; removeAllWeapons _this; removeAllItems _this; deleteVehicle _this}}];
    player addEventHandler ["FIRED",{_this spawn SABOTAGE_fnc_handleSabotageLocal}];

	//Add Actions on mission start
    player call SABOTAGE_fnc_initPlayer;
};



/////////////////////
// Init global
/////////////////////


["ALiVE | SABOTAGE - Running GlobalInit..."] call ALiVE_fnc_Dump;


// Adjust combat logistics options to restrict resupply
waituntil {!isnil "ALIVE_factionDefaultResupplyVehicleOptions"};

_SABOTAGE_CUSTOM_LOGISTICS_VEHICLES_BLU_G_F = [] call ALIVE_fnc_hashCreate;
[_SABOTAGE_CUSTOM_LOGISTICS_VEHICLES_BLU_G_F, "PR_AIRDROP", [["<< Back"],["<< Back"]]] call ALIVE_fnc_hashSet;
[_SABOTAGE_CUSTOM_LOGISTICS_VEHICLES_BLU_G_F, "PR_HELI_INSERT", [["<< Back"],["<< Back"]]] call ALIVE_fnc_hashSet;
[_SABOTAGE_CUSTOM_LOGISTICS_VEHICLES_BLU_G_F, "PR_STANDARD", [["<< Back"],["<< Back"]]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyVehicleOptions, "BLU_G_F", _SABOTAGE_CUSTOM_LOGISTICS_VEHICLES_BLU_G_F] call ALIVE_fnc_hashSet;

_SABOTAGE_CUSTOM_LOGISTICS_AMMO_BLU_G_F = [] call ALIVE_fnc_hashCreate;
[_SABOTAGE_CUSTOM_LOGISTICS_AMMO_BLU_G_F, "PR_AIRDROP", [["<< Back"],["<< Back"]]] call ALIVE_fnc_hashSet;
[_SABOTAGE_CUSTOM_LOGISTICS_AMMO_BLU_G_F, "PR_HELI_INSERT", [["<< Back"],["<< Back"]]] call ALIVE_fnc_hashSet;
[_SABOTAGE_CUSTOM_LOGISTICS_AMMO_BLU_G_F, "PR_STANDARD", [["<< Back"],["<< Back"]]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyCombatSuppliesOptions, "BLU_G_F", _SABOTAGE_CUSTOM_LOGISTICS_AMMO_BLU_G_F] call ALIVE_fnc_hashSet;

_SABOTAGE_CUSTOM_LOGISTICS_INDIVIDUALS_BLU_G_F  = [] call ALIVE_fnc_hashCreate;
[_SABOTAGE_CUSTOM_LOGISTICS_INDIVIDUALS_BLU_G_F, "PR_AIRDROP", [["<< Back","Men,","MenRecon","MenSniper","MenSupport"],["<< Back","Men,","MenRecon","MenSniper","MenSupport"]]] call ALIVE_fnc_hashSet;
[_SABOTAGE_CUSTOM_LOGISTICS_INDIVIDUALS_BLU_G_F, "PR_HELI_INSERT", [["<< Back","Men,","MenRecon","MenSniper","MenSupport"],["<< Back","Men,","MenRecon","MenSniper","MenSupport"]]] call ALIVE_fnc_hashSet;
[_SABOTAGE_CUSTOM_LOGISTICS_INDIVIDUALS_BLU_G_F, "PR_STANDARD", [["<< Back","Men","MenRecon","MenSniper","MenSupport"],["<< Back","Men","MenRecon","MenSniper","MenSupport"]]] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultResupplyIndividualOptions, "BLU_G_F", _SABOTAGE_CUSTOM_LOGISTICS_INDIVIDUALS_BLU_G_F] call ALIVE_fnc_hashSet;

// Adjust available auto generated tasks
////ALIVE_autoGeneratedTasks = ["MilAssault","MilDefence","CivAssault","Assassination","TransportInsertion","DestroyVehicles","DestroyInfantry","SabotageBuilding"];

waituntil {!isnil "ALIVE_autoGeneratedTasks"};
ALIVE_autoGeneratedTasks = ["SabotageBuilding"];

// Adjust Sabotage Building Task Copy

_options = [];
_tasksData = [] call ALIVE_fnc_hashCreate;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Sabotage in %1"] call ALIVE_fnc_hashSet;
[_taskData,"description","Destroy the %2 in %1!"] call ALIVE_fnc_hashSet;
[_tasksData,"Parent",_taskData] call ALIVE_fnc_hashSet;

_taskData = [] call ALIVE_fnc_hashCreate;
[_taskData,"title","Destroy %1"] call ALIVE_fnc_hashSet;
[_taskData,"description","We received intelligence about a strategically important %3 near %1! Destroy the %2!"] call ALIVE_fnc_hashSet;
[_taskData,"chat_start",[["HQ","We received intelligence about a strategically relevant position near %1! Destroy the objective!"],["PLAYERS","Roger that"]]] call ALIVE_fnc_hashSet;
[_taskData,"chat_success",[["PLAYERS","The objective has been destroyed!"],["HQ","Roger that, well done!"]]] call ALIVE_fnc_hashSet;
[_taskData,"reward",["forcePool",10]] call ALIVE_fnc_hashSet;
[_tasksData,"Destroy",_taskData] call ALIVE_fnc_hashSet;

_options set [count _options,_tasksData];

[ALIVE_generatedTasks, "SabotageBuilding", ["Sabotage installation",_options]] call ALIVE_fnc_hashSet;

["ALiVE | SABOTAGE - Initalisation finished..."] call ALiVE_fnc_Dump;
