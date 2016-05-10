//==================================================================CP_fnc_setGroupID======================================================================================
//Set group ID - SERVER ONLY
// Example: [[group,groupID], "CP_fnc_setGroupID", false, false] spawn BIS_fnc_MP;
// Params: 
//==============================================================================================================================================================================	
private ["_group","_groupID"];
	
_group 		= _this select 0;
_groupID 	= _this select 1;

_group setGroupId [_groupID,"GroupColor0"];

