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


[west,"B_Rifleman"] call bis_fnc_addrespawninventory;
[west,["B_Grenadier",2]] call bis_fnc_addrespawninventory;
[west,["B_Marksman",2]] call bis_fnc_addrespawninventory;
[west,["B_Autorifleman",2]] call bis_fnc_addrespawninventory;
[west,["B_Engineer",2]] call bis_fnc_addrespawninventory;
[west,["B_RTO",1]] call bis_fnc_addrespawninventory;
[west,["B_ReconScout",2]] call bis_fnc_addrespawninventory;
[west,["B_ReconMarksman",2]] call bis_fnc_addrespawninventory;
[west,["B_Sharpshooter",2]] call bis_fnc_addrespawninventory;
[west,["B_Sniper",2]] call bis_fnc_addrespawninventory;
[west,["B_HeavyGunner",2]] call bis_fnc_addrespawninventory;
[west,["B_ExplosiveSpecialist",2]] call bis_fnc_addrespawninventory;
[west,["B_CombatLifesaver",2]] call bis_fnc_addrespawninventory;