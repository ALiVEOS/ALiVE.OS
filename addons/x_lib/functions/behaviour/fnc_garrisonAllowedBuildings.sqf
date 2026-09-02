#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(garrisonAllowedBuildings);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_garrisonAllowedBuildings

Description:
Drops the buildings no garrison may use from a list of them.

The seating pass and the passes that size a garrison before it exists both sweep for
the same classes, so both have to exclude the same ones. When they disagree the count
says there is room the seating pass then refuses, which is how men end up standing
outside a camp that was sized to hold them.

Returns the list untouched when nothing is excluded, which is the ordinary case, so a
mission with no blacklist pays one array test rather than a classname lookup per
building.

Parameters:
    ARRAY - buildings, as returned by nearestObjects.

Returns:
    ARRAY - the same buildings without the excluded classes.

Examples:
(begin example)
private _props = [nearestObjects [_pos, ALIVE_garrisonPositions select 1, _radius]] call ALIVE_fnc_garrisonAllowedBuildings;
(end)

See Also:
- <ALIVE_fnc_garrisonBuildingBlacklist>

Author:
Jman
---------------------------------------------------------------------------- */

params [["_buildings", [], [[]]]];

private _blacklist = call ALIVE_fnc_garrisonBuildingBlacklist;
if (_blacklist isEqualTo []) exitWith { _buildings };

_buildings select { !((toLower typeOf _x) in _blacklist) }
