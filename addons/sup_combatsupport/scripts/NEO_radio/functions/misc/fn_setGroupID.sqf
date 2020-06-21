//==================================================================CP_fnc_setGroupID======================================================================================
//Set group ID - SERVER ONLY
// Example: [[group,groupID], "CP_fnc_setGroupID", false, false] spawn BIS_fnc_MP;
// Params:
//==============================================================================================================================================================================

params [["_group", grpNull, [grpNull,objNull]], ["_groupID", "none", [""]]];

_group = if (typeName _group == "OBJECT") then {group _group} else {_group};

_group setGroupId [_groupID,"GroupColor0"];

