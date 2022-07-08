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

// Start task FSM
[] call vn_alivems_fnc_coalive_alpha;

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
