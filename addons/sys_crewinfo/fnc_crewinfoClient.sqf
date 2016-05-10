_vehArray = ["O_SDV_01_F","B_SDV_01_F","I_G_Offroad_01_armed_F","B_G_Offroad_01_armed_F"];

disableSerialization;

["ALiVE CrewInfo - Clientside process started!"] call ALiVE_fnc_Dump;

while {true} do {
    
    private ["_ui","_HudNames","_vehicleID","_picture","_vehicle","_vehname","_weapname","_weap","_wepdir","_Azimuth","_sleep"];
    
	if (CREWINFO_UILOC == 1) then {
	    1000 cutRsc ["HudNamesRight","PLAIN"]; _ui = uiNameSpace getVariable "HudNamesRight";
	} else {
	    1000 cutRsc ["HudNamesLeft","PLAIN"]; _ui = uiNameSpace getVariable "HudNamesLeft";
	};
    
    _sleep = 2;
	
	_HudNames = _ui displayCtrl 99999;
	
	if (player != vehicle player && !visibleMap) then {
        
        private ["_weap"];
        
		_name = "";
		_vehicleID = "";
		_picture = "";
		_vehicle = assignedVehicle player;
		_vehname = getText (configFile >> "CfgVehicles" >> (typeOf vehicle player) >> "DisplayName");
		_weapname = getarray (configFile >> "CfgVehicles" >> typeOf (vehicle player) >> "Turrets" >> "MainTurret" >> "weapons");
		_sleep = 0.05;
         
	     if (count (_weapname) > 0) then {_weap = _weapname select 0};
	     
		_name = format ["<t size='1.25' color='#424242'>%1</t><br/>", _vehname];
	    
		{
		    if((driver _vehicle == _x) || (gunner _vehicle == _x)) then {
		
		        if(driver _vehicle == _x) then {
                    _name = format ["<t size='0.85' color='#999999'>%1 %2</t> <img size='0.7' color='#424242' image='a3\ui_f\data\IGUI\Cfg\Actions\getindriver_ca.paa'/><br/>", _name, (name _x)];
		        } else {
		        	_target = cursorTarget;
		            
		            if (_target isKindOf "Car" || _target isKindOf "Motorcycle" || _target isKindOf "Tank" || _target isKindOf "Air" || _target isKindOf "Ship") then {
		            	_vehicleID = getText (configFile >> "cfgVehicles" >> typeOf _target >> "displayname");
		            	_picture = getText (configFile >> "cfgVehicles" >> typeOf _target >> "picture");
		            };
		            
		            if ((typeOf vehicle player) in _vehArray) then {
		            	if (!isNil "_weap") then {
		                	_wepdir =  (vehicle player) weaponDirection _weap;
		                    _Azimuth = round  (((_wepdir select 0) ) atan2 ((_wepdir select 1) ) + 360) % 360;
		                    _name = format ["<t size='0.85' color='#999999'>%1 %2</t> <img size='0.7' color='#424242' image='a3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/><br/> <t size='0.85' color='#999999'>Heading :<t/> <t size='0.85' color='#3b1111'>%3</t><br/><t size='0.85' color='#999999'> Target :<t/> <t size='0.85' color='#3b1111'>%4</t><br/><t size='0.85' color='#999999'> Display : </t><t size='0.85' color='#999999'><img size='1' image='%5'/></t><br/>", _name, (name _x), _Azimuth,_vehicleID, _picture];
		                } else {
		                	_name = format ["<t size='0.85' color='#999999'>%1 %2</t> <img size='0.7' color='#424242' image='a3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/><br/>", _name, (name _x)];
		            	}
		            } else {
		            	if (!isNil "_weap") then {
		                	_wepdir =  (vehicle player) weaponDirection _weap;
		                    _Azimuth = round  (((_wepdir select 0) ) atan2 ((_wepdir select 1) ) + 360) % 360;
		                	_name = format ["<t size='0.85' color='#999999'>%1 %2</t> <img size='0.7' color='#424242' image='a3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/><br/> <t size='0.85' color='#999999'>Heading :<t/> <t size='0.85' color='#3b1111'>%3</t><br/><t size='0.85' color='#999999'> Target :<t/> <t size='0.85' color='#3b1111'>%4</t><br/><t size='0.85' color='#999999'> Display : </t><t size='0.85' color='#999999'><img size='1' image='%5'/></t><br/>", _name, (name _x), _Azimuth,_vehicleID, _picture];
		                } else {
		                	_name = format ["<t size='0.85' color='#999999'>%1 %2</t> <img size='0.7' color='#424242' image='a3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/><br/>", _name, (name _x)];
		                }
		         	};
		         };
		    } else {
		      _name = format ["<t size='0.85' color='#999999'>%1 %2</t> <img size='0.7' color='#424242' image='a3\ui_f\data\IGUI\Cfg\Actions\getincargo_ca.paa'/><br/>", _name, (name _x)];
		    };
		
		} forEach crew _vehicle;
	
	    _HudNames ctrlSetStructuredText parseText  _name;
	    _HudNames ctrlCommit 0;
	};
	    
	sleep _sleep;
};

["ALiVE CrewInfo - Clientside process ended!"] call ALiVE_fnc_Dump;
