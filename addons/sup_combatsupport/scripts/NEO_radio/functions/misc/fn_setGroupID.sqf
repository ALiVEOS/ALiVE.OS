//==================================================================CP_fnc_setGroupID======================================================================================
//Set group ID - SERVER ONLY
// Example: [[group,groupID], "CP_fnc_setGroupID", false, false] spawn BIS_fnc_MP;
// Params:
//==============================================================================================================================================================================
private ["_group","_groupID"];

_group = [_this, 0, grpNull, [grpNull,objNull]] call BIS_fnc_param;
_groupID = [_this, 1, "none", [""]] call BIS_fnc_param;

_group = if (typeName _group == "OBJECT") then {group _group} else {_group};

_group setGroupId [_groupID,"GroupColor0"];

