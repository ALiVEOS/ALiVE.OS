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
    waitUntil {!isNil "ALiVE_REQUIRE_INITIALISED"};
    
    ALiVE_Helper_opcomEventListener = compile preprocessFileLineNumbers "opcomEventListener.sqf";
    opcomEventListener = [nil,"create", ["ALiVE_Helper_opcomEventListener"]] call ALiVE_Helper_opcomEventListener;
};