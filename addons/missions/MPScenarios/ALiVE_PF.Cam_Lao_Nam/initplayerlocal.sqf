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
	missionNamespace setVariable [_x, true];
} forEach [
	"BIS_respSpecAllowFreeCamera",		// Allow moving the camera independent from units (players)
	"BIS_respSpecAllow3PPCamera",		// Allow 3rd person camera
	"BIS_respSpecShowFocus",			// Show info about the selected unit (dissapears behind the respawn UI)
	"BIS_respSpecShowCameraButtons",	// Show buttons for switching between free camera, 1st and 3rd person view (partially overlayed by respawn UI)
	"BIS_respSpecShowControlsHelper",	// Show the controls tutorial box
	"BIS_respSpecShowHeader",			// Top bar of the spectator UI including mission time
	"BIS_respSpecLists"					// Show list of available units and locations on the left hand side
];




