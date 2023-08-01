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













