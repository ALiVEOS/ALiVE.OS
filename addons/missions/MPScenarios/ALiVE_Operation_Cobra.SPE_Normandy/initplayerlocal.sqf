/* 
* Filename:
* initPlayerLocal.sqf 
* 
* Arguments:
* [player:Object, didJIP:Boolean]
*
* Description:
* Executed locally when player joins mission (includes both mission start and JIP).
* 
* Creation date: 05/04/2021
* 
* */
// ====================================================================================

_player = _this select 0;
_didJIP = _this select 1;


// --- Enable full spectator in respawn screen
{
	missionNamespace setVariable [_x,true];
} forEach [
//		"BIS_respSpecAi",			// Allow spectating of AI
//		"BIS_respSpecShowFocus",		// Show info about the selected unit (dissapears behind the respawn UI)
//		"BIS_respSpecShowCameraButtons",	// Show buttons for switching between free camera, 1st and 3rd person view (partially overlayed by respawn UI)
	"BIS_respSpecShowControlsHelper",	// Show the controls tutorial box
	"BIS_respSpecShowHeader",		// Top bar of the spectator UI including mission time
	"BIS_respSpecLists"			// Show list of available units and locations on the left hand side
];
missionNamespace setVariable ["BIS_EGSpectator_allowAiSwitch",false];
missionNamespace setVariable ["BIS_respSpecAllowFreeCamera",SPE_CadetMode];// Allow moving the camera independent from units (players)
missionNamespace setVariable ["BIS_respSpecAllow3PPCamera",(difficultyOption "thirdPersonView") isEqualTo 1];// Allow 3rd person camera


// Shut up AI!
{_x setVariable ["BIS_noCoreConversations", true]} forEach allUnits; 
0 fadeRadio 0;
enableSentences false;


// overide default player radio's enabling SPE IFS Module!
SPE_fnc_IFS_hasRadio = 
{ 
    private _hasRadioItem = false; 
    _hasRadioItem 
};


// save loadout
[missionnamespace,"arsenalClosed", {[player, [missionNamespace, "inventory_var"]] call BIS_fnc_saveInventory;
	diag_log format["%1: initPlayerLocal.sqf -> %2 inventory_var saved", missionName, missionNamespace]; 
}] call bis_fnc_addScriptedEventhandler;


// Remove 'Emergency Call' action on player
[] spawn {
	waitUntil {!isNil "SPE_IFS_EM_ID" && time > 20};
	player setVariable ['SPE_IFS_showCall_EM',false];  // does not work!
	[player,SPE_IFS_EM_ID] call BIS_fnc_holdActionRemove; // works!
};


// JIP stuff!
if (_didJIP) then {
	 diag_log format["%1: initPlayerLocal.sqf -> JIP: %2, Running jip stuff", missionName, _didJIP]; 
   if !(isNil "Deployed_Flag") then {
     if !(isNull Deployed_Flag) then {
     	 Deployed_Flag addAction ["<t color='#FF8C00'>Recruit Infantry</t>", "bon_recruit_units\open_dialog.sqf"];	
       diag_log format["%1: initPlayerLocal.sqf -> JIP -> Recruit Infantry -> Deployed_Flag: %2", missionName, Deployed_Flag]; 
       Deployed_Flag addAction ["<t color='#00FF37'>Return to Base</t>", {[] execVM "scripts\teleport_base.sqf";}];	
       diag_log format["%1: initPlayerLocal.sqf -> JIP -> Return to Base -> Deployed_Flag: %2", missionName, Deployed_Flag];  
     };
   };

   if !(isNil "Deployed_Supply") then {
     if !(isNull Deployed_Supply) then {
     	Deployed_Supply addAction ["<t color='#0099FF'>Arsenal</t>", {["Open",true] spawn SPE_Arsenal_fnc_arsenal;}];
     	diag_log format["%1: initPlayerLocal.sqf -> JIP -> Arsenal -> Deployed_Supply: %2", missionName, Deployed_Supply]; 
     	};
   };

   if !(isNil "MHQ_marker_array") then {
    if (count MHQ_marker_array > 0) then {
    	(MHQ_marker_array select 0) setMarkerShadow true; 
    	(MHQ_marker_array select 0) setMarkerShadowLocal true;
    	diag_log format["%1: initPlayerLocal.sqf -> JIP -> MHQ Marker Shadow -> MHQ_marker: %2", missionName, (MHQ_marker_array select 0)]; 
    };
   };
};
[] execVM "ETHICSMinefields\fn_ETH_playerLocal.sqf";

["InitializePlayer", [player, true]] call BIS_fnc_dynamicGroups;

(group player) addEventHandler ["UnitJoined", {
    params ["_group", "_newUnit"];

    [_newUnit] call SPE_MissionUtilityFunctions_fnc_ReviveToksaInit;
}];
