//==================================================================CP_fnc_setGroupID======================================================================================
//Set group ID - SERVER ONLY
// Example: [[group,groupID], "CP_fnc_setGroupID", false, false] spawn BIS_fnc_MP;
// Params:
//==============================================================================================================================================================================
private ["_group","_groupID"];

_group = _this param [0, grpNull, [grpNull,objNull]];
_groupID = _this param [1, "none", [""]];

_group = if (typeName _group == "OBJECT") then {group _group} else {_group};

// Global, so every player sees the callsign set on the module: setGroupId only renames the group on the
// server, and players kept seeing names like "Alpha 3-6" (#1096)
_group setGroupIdGlobal [_groupID,"GroupColor0"];

