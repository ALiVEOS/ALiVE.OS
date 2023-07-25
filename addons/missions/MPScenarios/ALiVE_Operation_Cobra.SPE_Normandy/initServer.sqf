/* 
* Filename:
* initServer.sqf
*
* Description:
* Executed only on server when mission is started.
* 
* Creation date: 05/04/2021
* 
* */
// ====================================================================================

if (isDedicated) then  { 
	disableRemoteSensors true; 
};

[] spawn {
     while {true} do {
          {
               if (!isNull (getAssignedCuratorUnit _x)) then {
                    _x addCuratorEditableObjects [allUnits + vehicles,true];
               };
          } count allCurators;
          sleep 10;
     };
};

Jersey setGroupId ["Jersey Squad"];

[US_AMMOBOX, ["Arsenal", {["Open",true] spawn SPE_Arsenal_fnc_arsenal; }]] remoteExec ["addAction"]; 	
[US_AMMOBOX_1, ["Arsenal", {["Open",true] spawn SPE_Arsenal_fnc_arsenal; }]] remoteExec ["addAction"]; 	
[US_AMMOBOX_2, ["Arsenal", {["Open",true] spawn SPE_Arsenal_fnc_arsenal; }]] remoteExec ["addAction"]; 	

SPE_CadetMode = false;
SPE_HardcoreMode = true;

0 setOvercast 0.2; 
0 setRain 0; 
0 setfog 0.03;
forceWeatherChange;




    




