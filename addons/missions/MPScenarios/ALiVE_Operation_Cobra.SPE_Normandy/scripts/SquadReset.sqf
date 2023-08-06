// SquadReset by Atlas
// Teleports alive AI to group leader using addaction. 
// Ignores players within the group and available to leader only.
// Exec via init.sqf "player addAction ["<t color='#FF0000'>Reset Squad AI</t>", "Scripts\SquadReset.sqf"];"

private _nonPlayableInGroup = units group player - playableUnits;

if (leader player != player) exitWith 
{
Hint "You are not a group leader!";
};
 {
    if (alive _x) then
	{
    _resetPosition = getPos player; 
    _x setPos _resetPosition; 
    _x setBehaviour "AWARE";
    _x setFormation "WEDGE";
    _x setUnitPos "AUTO";
 hint "Squad Reset Complete"; 
 }
 
}forEach _nonPlayableInGroup; 