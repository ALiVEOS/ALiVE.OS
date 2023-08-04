// SquadReset by Atlas
// Teleports AI to group leader on radio command. 
// Ignores players within the group and available to leader only.
// Exec via "true" radio trigger with: execVM "Scripts\SquadReset.sqf"; 

_nonPlayableInGroup = units group player - playableUnits;
if (leader player != player) exitWith 
{
Hint "You are not a group leader!";
};
 {
    _resetPosition = getPos player; 
    _x setPos _resetPosition; 
    _x setBehaviour "AWARE";
    _x setFormation "WEDGE";
    _x setUnitPos "AUTO";
 hint "Squad Reset Complete"; 
 
}forEach _nonPlayableInGroup; 