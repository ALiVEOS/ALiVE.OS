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

[west,"B_Rifleman"] call bis_fnc_addrespawninventory;
[west,["B_Grenadier",1]] call bis_fnc_addrespawninventory;
[west,["B_Marksman",1]] call bis_fnc_addrespawninventory;
[west,["B_Autorifleman",1]] call bis_fnc_addrespawninventory;
[west,["B_Engineer",1]] call bis_fnc_addrespawninventory;
[west,["B_RTO",1]] call bis_fnc_addrespawninventory;
[west,["B_ReconScout",1]] call bis_fnc_addrespawninventory;
[west,["B_ReconMarksman",1]] call bis_fnc_addrespawninventory;
[west,["B_Sharpshooter",1]] call bis_fnc_addrespawninventory;
[west,["B_Sniper",1]] call bis_fnc_addrespawninventory;
[west,["B_HeavyGunner",1]] call bis_fnc_addrespawninventory;
[west,["B_ExplosiveSpecialist",1]] call bis_fnc_addrespawninventory;
[west,["B_CombatLifesaver",1]] call bis_fnc_addrespawninventory;