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
 		ALiVE_Helper_logisticsEventListener = compile preprocessFileLineNumbers "logisticsEventListener.sqf";
    logisticsEventListener = [nil,"create", ["ALiVE_Helper_logisticsEventListener"]] call ALiVE_Helper_logisticsEventListener;
};