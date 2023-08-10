[player, [missionNamespace, "inventory_var"]] call BIS_fnc_loadInventory;
[] execVM "Scripts\SquadResetInit.sqf";

[] spawn {
	waitUntil {!isNil "SPE_IFS_EM_ID" && time > 20};
	player setVariable ['SPE_IFS_showCall_EM',false];  // does not work!
	[player,SPE_IFS_EM_ID] call BIS_fnc_holdActionRemove; // works!
};