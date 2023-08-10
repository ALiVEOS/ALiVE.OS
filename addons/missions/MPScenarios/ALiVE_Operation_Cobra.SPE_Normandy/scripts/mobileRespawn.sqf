private ["_HMHQ","_mkr_MHQ","_thisaction","_oldMHQ"];


 ["mobileRespawn.sqf -> this: %1", _this] call ALIVE_fnc_dump;
 
 
//--- MHQ Defines
HMHQ_Teleport_West = [USBASE];
HMHQ_Teleport_Veh = [USMHQ];
MHQ_Fuel_Amount = 1;
INS_MHQ_CAMONET = "CamoNet_BLUFOR_big_F";
INS_MHQ_SUPPLYCRATE = "SPE_AmmoCrate_VehicleAmmo_US";
INS_MHQ_FLAGCLASS = "SPE_FlagCarrier_USA";
PARAMS_MHQ_DeployTime = 10;

_HMHQ = (HMHQ_Teleport_Veh select 0);


	fnc_setFuel = {
	    private ["_veh","_fuel"];
	    _veh = _this select 0;
	    _fuel = _this select 1;
	    if (local _veh) then {
	        _veh setFuel _fuel;
	    } else {
	        PVsetFuel = _this;
	        if (isDedicated) then {
	            (owner _veh) publicVariableClient "PVsetFuel";
	        } else {
	            publicVariableServer "PVsetFuel";
	        };
	    };
	};
	
	"PVsetFuel" addPublicVariableEventHandler {
	    (_this select 1) call fnc_setFuel;
	};



if (USMHQ getVariable ["Respawned", false] || USMHQ_Respawned == 1) then {
	
	 ["mobileRespawn.sqf -> Respawned: %1", USMHQ getVariable ["Respawned", false]] call ALIVE_fnc_dump;
	 [nil,"respawnedText", nil, false] spawn BIS_fnc_MP;
	 
	   if (HMHQ_Deployed_Var == 1) then {
	   	
	   		["mobileRespawn.sqf -> Removing old MHQ"] call ALIVE_fnc_dump;
	         // Remove MHQ USBASE Objects
        deleteVehicle (USMHQ getVariable "CAMO");
        deleteVehicle (USMHQ getVariable "SUPPLY");
        deleteVehicle (USMHQ getVariable "FLAG");

        // Delete Marker Array
        if (count MHQ_marker_array > 0) then {
        {deleteMarker _x} forEach MHQ_marker_array};
        MHQ_marker_array = [];
        publicVariable "MHQ_marker_array";
        
        USMHQ setVariable ["HMHQ_Deployed", false, true];
        HMHQ_Deployed_Var = 0;
        publicVariable "HMHQ_Deployed_Var";
        
        // Delete respawn location from the respawn menu
        _side = resistance;
        _newspawnpos = USMHQ getVariable "alive_respawnpos";
        _newspawnpos call BIS_fnc_removeRespawnPosition;
        
        ["mobileRespawn.sqf -> Old MHQ Removed"] call ALIVE_fnc_dump;
        
         USMHQ setVariable ["Respawed",false,true];  
         USMHQ_Respawned = 0;
         publicVariable "USMHQ_Respawned";
     };
     
     
    USMHQ setVariable ['QS_ST_drawEmptyVehicle',true,true];

    ["mobileRespawn.sqf -> Respawned, Adding actions back, HMHQ_Deployed_Var: %1", HMHQ_Deployed_Var] call ALIVE_fnc_dump;

    [USMHQ, ["<t color='#ffff00'>Deploy HQ</t>", {[_this,"HZE_fnc_deployHQ", false] call BIS_fnc_MP;},[],0,true,true,"","(!(_target getVariable ['HMHQ_Deployed', true])) && ((_this distance _target) < 4)"]] remoteExec ["addAction"]; 	
    [USMHQ, ["<t color='#ffff00'>Pack HQ</t>", {[_this,"HZE_fnc_packHQ", false] call BIS_fnc_MP;},[],0,true,true,"","(_target getVariable ['HMHQ_Deployed', false]) && ((_this distance _target) < 4)"]] remoteExec ["addAction"]; 	


};



if (isServer) then {
    USMHQ setVariable ["HMHQ_Deployed", false, true];

    USMHQ_Respawned = 0;
    publicVariable "USMHQ_Respawned";
    HMHQ_Deployed_Var = 0;
    publicVariable "HMHQ_Deployed_Var";
    MHQ_marker_array = [];
    publicVariable "MHQ_marker_array";

    HZE_fnc_deployHQ = {
        private ["_magazinesList","_namelist","_camocover","_supply","_flag","_cfgmagazines","_magazine","_mCName","_mDName","_mModel","_mType","_mscope","_mPic","_mDesc"];
        _magazinesList = [];
        _namelist = [];
       _HMHQ = _this select 0;

        // Set Fuel for deploy.
        [USMHQ, 0] call fnc_setFuel;

        [nil,"deployingText", nil, false] spawn BIS_fnc_MP;
        sleep PARAMS_MHQ_DeployTime;


        // Create the CamoNet
        _camocover = createVehicle [INS_MHQ_CAMONET, getPosATL USMHQ, [], 0, "CAN_COLLIDE"];
        USMHQ setVariable ["CAMO", _camocover];
        _camocover allowDamage false;

        // Create Supply Crate
        _supply = createVehicle [INS_MHQ_SUPPLYCRATE,[ (getPos USMHQ select 0)-2, (getPos USMHQ select 1)-6,(getPos USMHQ select 2)+0.1], [], 0, "CAN_COLLIDE"];
        USMHQ setVariable ["SUPPLY", _supply];
        _supply allowDamage false;
        Deployed_Supply = _supply;
        publicVariable "Deployed_Supply";
        [Deployed_Supply, ["<t color='#0099FF'>Arsenal</t>", {["Open",true] spawn SPE_Arsenal_fnc_arsenal; }]] remoteExec ["addAction"];
        
        // Create the Marker
        _mkr_MHQ = createMarker [format ["box%1",random 1000],getposATL USMHQ];
        _mkr_MHQ setMarkerShape "ICON";
        _mkr_MHQ setMarkerText format["Deployed US MHQ"];
        _mkr_MHQ setMarkerType "SPE_n_Icon_Insignia_Generic_US";
        _mkr_MHQ setMarkerShadow true;
       //  _mkr_MHQ setMarkerColor "ColorBlack";
        MHQ_marker_array set [count MHQ_marker_array, _mkr_MHQ];
        publicVariable "MHQ_marker_array";
        [(MHQ_marker_array select 0),true] remoteExec ["setMarkerShadowLocal",0];
        

        // Create the MHQ USBASE Flag
        _flag = createVehicle [INS_MHQ_FLAGCLASS,[ (getPos USMHQ select 0)-2, (getPos USMHQ select 1)-10, (getPos USMHQ select 2)+0], [], 0, "CAN_COLLIDE"];
        USMHQ setVariable ["FLAG", _flag];
        _flag allowDamage false;
        Deployed_Flag = _flag;
        publicVariable "Deployed_Flag";
        [Deployed_Flag, ["<t color='#ffff00'>Recruit Infantry</t>", {[Deployed_Flag] execVM "bon_recruit_units\open_dialog.sqf";},[],0,true,true,"",""]] remoteExec ["addAction"]; 	
        [Deployed_Flag, ["<t color='#00FF37'>Return to Base</t>", {[] execVM "scripts\teleport_base.sqf";},[],0,true,true,"",""]] remoteExec ["addAction"]; 	
          
        // Create a new respawn position for the respawn menu
        _side = resistance;
        _newspawnpos = [_side,getposATL _flag] call BIS_fnc_addRespawnPosition;
         USMHQ setVariable ["alive_respawnpos", _newspawnpos];

        sleep 1;

        _camocover allowDamage true;
        USMHQ setVariable ["HMHQ_Deployed", true, true];
        HMHQ_Deployed_Var = 1;
        publicVariable "HMHQ_Deployed_Var";
        [nil,"deployedText", true, false] spawn BIS_fnc_MP;
    };

    HZE_fnc_packHQ = {
        private ["_newspawnpos","_side"];
        _HMHQ = _this select 0;

        [nil,"packingText", nil, false] spawn BIS_fnc_MP;
        sleep PARAMS_MHQ_DeployTime;

        // Remove MHQ USBASE Objects
        deleteVehicle (USMHQ getVariable "CAMO");
        deleteVehicle (USMHQ getVariable "SUPPLY");
        deleteVehicle (USMHQ getVariable "FLAG");

        // Delete Marker Array
        if (count MHQ_marker_array > 0) then {
        {deleteMarker _x} forEach MHQ_marker_array};
        MHQ_marker_array = [];
        publicVariable "MHQ_marker_array";

        USMHQ setVariable ["HMHQ_Deployed", false, true];
        HMHQ_Deployed_Var = 0;
        publicVariable "HMHQ_Deployed_Var";
        [nil,"packedText", nil, false] spawn BIS_fnc_MP;

        // Set Fuel for back for moving again.
        [USMHQ, 1] call fnc_setFuel;

        // Delete respawn location from the respawn menu
        _side = resistance;
        _newspawnpos = USMHQ getVariable "alive_respawnpos";
        _newspawnpos call BIS_fnc_removeRespawnPosition;

    };
};

if (!isDedicated) then {

 ["mobileRespawn.sqf -> !isDedicated, Adding actions"] call ALIVE_fnc_dump;

    USMHQ addAction ["<t color='#ffff00'>Deploy HQ</t>",{
            [_this,"HZE_fnc_deployHQ", false] call BIS_fnc_MP;
        }
        ,[],0,true,true,"","(!(_target getVariable ['HMHQ_Deployed', true])) && ((_this distance _target) < 4)"];

    USMHQ addAction ["<t color='#ffff00'>Pack HQ</t>",{
            [_this,"HZE_fnc_packHQ", false] call BIS_fnc_MP;
        },[],0,true,true,"","(_target getVariable ['HMHQ_Deployed', false]) && ((_this distance _target) < 4)"];


		[] spawn {
			
	   ["mobileRespawn.sqf -> USBASE Teleport Action Status: %1", USBASE getVariable ["Pole", false]] call ALIVE_fnc_dump;
	   
			if !(USBASE getVariable ["Pole", false]) then {
			  private ["_veh_name", "_spawn"];
			 _veh_name = str(USMHQ);
       _thisaction = USBASE addAction [("<t color=""#ffff00"">") + ("Teleport to Mobile Respawn Vehicle") + "</t>", {[_this select 1, _this select 3] call HZE_fnc_teleport}, _veh_name];
       USBASE setVariable ["Teleport", _thisaction, true];
       USBASE setVariable ["Pole", true,false];
       ["mobileRespawn.sqf -> USBASE Teleport Action Status: %1", USBASE getVariable ["Pole", false]] call ALIVE_fnc_dump;
      };
    };
};

HZE_fnc_teleport = {
    private ["_unit","_player","_var","_veh","_unit_veh","_dir"];
    _unit = _this select 0;
    _player = _unit;
    _var = HMHQ_Deployed_Var;
    _veh = USMHQ;
    _dir = random 359;
    _unit_veh = vehicle _unit;

    if (_unit_veh != _unit) then {
        if(_unit == driver _unit_veh) then {
            _player = _unit_veh;
        };
    };

    if (_var == 0) then {

        private ["_title","_text"];

        _title = "<t size='1.2' align='center' color='#e5b348' shadow='1' shadowColor='#000000'>Mobile HQ</t>
        <img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' /><br/>";
        _text = format["%1
        <t align='center' color='#eaeaea'>Mobile HQ not deployed</t><br/><br/>
        <t align='center' color='#eaeaea'>Unable to use the teleport function at this time..</t>
        <br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' />",_title];

        ["openSideTop",1.4] call ALIVE_fnc_displayMenu;
        ["setSideTopText",_text] call ALIVE_fnc_displayMenu;
    } else {
        if(speed _veh <= 5 && speed _veh >= -3) then {
            titleText ["Traveling to Mobile Respawn Location", "BLACK OUT", 8];
            sleep 10;
            _player SetPos [(getPos _veh select 0)-5*sin(_dir),(getPos _veh select 1)-5*cos(_dir)];
            sleep 2;
            titleText ["", "BLACK IN", 8];
        } else {
            _unit sideChat "Cannot teleport you. The spawn point is currently moving. Wait until it stops";
        };
    };
};

deployingText = {
    private ["_title","_text","_deployTime"];

    _deployTime = PARAMS_MHQ_DeployTime;

    _title = "<t size='1.2' align='center' color='#e5b348' shadow='1' shadowColor='#000000'>Mobile HQ</t>
    <img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' /><br/>";
    _text = format["%1
    <t align='center' color='#eaeaea'>Mobile HQ is deploying</t><br/><br/>
    <t align='center' color='#eaeaea'>ETA %2 Seconds</t>
    <br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' />",_title, _deployTime];

    ["openSideTop",1.4] call ALIVE_fnc_displayMenu;
    ["setSideTopText",_text] call ALIVE_fnc_displayMenu;
};

deployedText = {
    private ["_title","_text"];

    _title = "<t size='1.2' align='center' color='#e5b348' shadow='1' shadowColor='#000000'>Mobile HQ</t>
    <img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' /><br/>";
    _text = format["%1
    <t align='center' color='#eaeaea'>Mobile HQ is deployed</t><br/><br/>
    <t align='center' color='#eaeaea'>You may now use the flag at base to teleport to the frontlines.</t>
    <br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' />",_title];

    ["openSideTop",1.4] call ALIVE_fnc_displayMenu;
    ["setSideTopText",_text] call ALIVE_fnc_displayMenu;
};

packingText = {
    private ["_title","_text","_packTime"];

    _packTime = PARAMS_MHQ_DeployTime;

     _title = "<t size='1.2' align='center' color='#e5b348' shadow='1' shadowColor='#000000'>Mobile HQ</t>
    <img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' /><br/>";
    _text = format["%1
    <t align='center' color='#eaeaea'>Mobile HQ is packing</t><br/><br/>
    <t align='center' color='#eaeaea'>ETA %2 Seconds</t>
    <br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' />",_title, _packTime];

    ["openSideTop",1.4] call ALIVE_fnc_displayMenu;
    ["setSideTopText",_text] call ALIVE_fnc_displayMenu;
};

packedText = {
    private ["_title","_text"];

    _title = "<t size='1.2' align='center' color='#e5b348' shadow='1' shadowColor='#000000'>Mobile HQ</t>
    <img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' /><br/>";
    _text = format["%1
    <t align='center' color='#eaeaea'>Mobile HQ is packed</t><br/><br/>
    <t align='center' color='#eaeaea'>You will be unable to use the teleport at base until re-deployed</t>
    <br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' />",_title];

    ["openSideTop",1.4] call ALIVE_fnc_displayMenu;
    ["setSideTopText",_text] call ALIVE_fnc_displayMenu;
};


respawnedText = {
    private ["_title","_text"];

    _title = "<t size='1.2' align='center' color='#e5b348' shadow='1' shadowColor='#000000'>Mobile HQ</t>
    <img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' /><br/>";
    _text = format["%1
    <t align='center' color='#eaeaea'>Mobile HQ has respawned</t><br/><br/>
    <t align='center' color='#eaeaea'>You will be unable to use the Mobile HQ teleport until it's re-deployed.</t>
    <br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='center' size='0.60' />",_title];

    ["openSideTop",1.4] call ALIVE_fnc_displayMenu;
    ["setSideTopText",_text] call ALIVE_fnc_displayMenu;
};

