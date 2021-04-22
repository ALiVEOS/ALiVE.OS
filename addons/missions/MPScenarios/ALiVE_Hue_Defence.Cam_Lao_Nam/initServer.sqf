/* 
* Filename:
* initServer.sqf
*
* Description:
* Executed only on server when mission is started.
* 
* Created by Jman
* Creation date: 05/04/2021
* 
* */
// ====================================================================================


// Start the force pool
["ALiVE | The Battle of Hue - alive_forcepool_cycleTime: %1",alive_forcepool_cycleTime] call ALiVE_fnc_dump;
[alive_forcepool_cycleTime] call vn_alivems_fnc_coalive_forcepool;


waitUntil {
  !isnil { [ALIVE_globalForcePool,"O_PAVN"] call ALIVE_fnc_hashGet };
  !isnil { [ALIVE_globalForcePool,"O_VC"] call ALIVE_fnc_hashGet };
};

[ALIVE_globalForcePool,"O_PAVN", alive_forcepool_pavn] call ALIVE_fnc_hashSet;
[ALIVE_globalForcePool,"O_VC", alive_forcepool_vc] call ALIVE_fnc_hashSet;

// Start task FSM
[] call vn_alivems_fnc_coalive_xray;


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

[] spawn {
    waitUntil {!isNil "ALiVE_REQUIRE_INITIALISED" && time > 120};
    ALiVE_Helper_opcomEventListener = compile preprocessFileLineNumbers "opcomEventListener.sqf";
    opcomEventListener = [nil,"create", ["ALiVE_Helper_opcomEventListener"]] call ALiVE_Helper_opcomEventListener;

};