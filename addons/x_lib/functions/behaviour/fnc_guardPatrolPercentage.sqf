#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(guardPatrolPercentage);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_guardPatrolPercentage

Description:
The share of a garrison that patrols between buildings, for every garrison placed
without a placement module of its own, as a whole number from 0 to 100.

The four placement modules that carry a Garrisoned Building Patrol setting send it with
each garrison they place, so those are not touched by this. Everything else that
garrisons has no module to ask and until now patrolled at fifty whatever the mission's
modules said: the commander ordering a garrison from tacom, the insurgency guards, the
airbase guards, the SPE placement guards (that module has no such setting), the guards a
task spawns with its camp and the garrisons Military Logistics manages. Here the setting
is read off the placement modules the way the occupancy limit is.

The military modules are asked first. Every one of those garrisons commands soldiers, so
a civilian module is the wrong place to be reading their orders from: turning checkpoint
patrolling down should not quietly freeze the commander's reserve. Civilian modules are
read only when no military module carries the setting, so an asymmetric mission built on
civilian placement alone is not left with nothing to go on.

Where the modules asked disagree the smallest wins. None counts and can win: it is the
value the setting exists for, so one module set to None holds every such garrison at its
post. That is unlike the occupancy limit, where zero means off and is left out. The
smallest can also sit above fifty: with every module at High or All these garrisons
patrol more than they did.

A placement module with nothing on it for the setting counts at the setting's default of
fifty, because that is what its own garrisons use. Eden writes the value onto the module
logic at mission start, but a mission saved before the setting existed carries nothing
for it, and there the module's own getter only writes the default back when it places.
Counted here either way, the answer does not depend on which caller asked first.

The answer cannot change after mission start, so it is worked out once and kept.

The value arrives as text, so one that is not a whole number is skipped and reported
rather than read as None.

Parameters:
    None.

Returns:
    NUMBER - the smallest setting the modules asked carry, or 50 when there is no
    placement module, which is what every caller fell to before and leaves them exactly
    as they were.

Examples:
(begin example)
private _guardPatrolPercentage = call ALIVE_fnc_guardPatrolPercentage;
[_group, _position, 200, true, false, 0, _profileID, _guardPatrolPercentage] call ALIVE_fnc_groupGarrison;
(end)

See Also:
- <ALIVE_fnc_garrisonOccupancyLimit>
- <ALIVE_fnc_groupGarrison>

Author:
Jman
---------------------------------------------------------------------------- */

if !(isNil "ALiVE_guardPatrolPercentageCache") exitWith { ALiVE_guardPatrolPercentageCache };

// The modules that carry the setting. One of these with nothing on it yet counts at the
// default, which is what its own garrisons use.
private _carriers = ["ALiVE_mil_placement", "ALiVE_mil_placement_custom", "ALiVE_civ_placement", "ALiVE_civ_placement_custom"];

private _modules = entities "Module_F";
private _military = [];
private _civilian = [];
private _rejected = [];

{
    // Held in its own name because the tests below run a forEach and a findIf of their
    // own, and those inner loops overwrite _x.
    private _module = _x;
    private _raw = _module getVariable ["guardPatrolPercentage", ""];

    if (_raw isEqualTo "" && {(_carriers findIf { _module isKindOf _x }) > -1}) then { _raw = "50" };

    if (_raw isEqualType "" && {_raw != ""}) then {
        // Digits only, the same test the occupancy limit uses. This is what rejects
        // "-1", "1.5" and "50 %" rather than reading a number out of them.
        private _isNumber = true;
        { if (_x < 48 || {_x > 57}) then { _isNumber = false }; } forEach toArray _raw;

        if (_isNumber) then {
            if (((typeOf _module) select [0,10]) == "ALiVE_mil_") then {
                _military pushBack (parseNumber _raw);
            } else {
                _civilian pushBack (parseNumber _raw);
            };
        } else {
            _rejected pushBack [_raw, typeOf _module];
        };
    };
} forEach _modules;

private _settings = if !(_military isEqualTo []) then { _military } else { _civilian };

private _percentage = 50;
if !(_settings isEqualTo []) then {
    _percentage = selectMin _settings;
};

// Reported once. A setting that did nothing reads to the author as a broken feature,
// and two modules disagreeing is worth saying out loud rather than leaving them to
// wonder which one took effect.
if !(_rejected isEqualTo []) then {
    ["ALiVE guardPatrolPercentage - %1 Garrisoned Building Patrol setting(s) not understood and skipped: %2", count _rejected, _rejected] call ALiVE_fnc_dump;
};

private _distinct = [];
{ _distinct pushBackUnique _x; } forEach _settings;
if (count _distinct > 1) then {
    ["ALiVE guardPatrolPercentage - placement modules set different Garrisoned Building Patrol values %1; the smallest, %2, applies to every garrison placed without a module", _distinct, _percentage] call ALiVE_fnc_dump;
};

if (_percentage != 50) then {
    ["ALiVE guardPatrolPercentage - %1 applies to every garrison placed without a module", _percentage] call ALiVE_fnc_dump;
};

// Not kept when no module exists yet, so a call that arrives before the modules do
// answers fifty for itself without fixing fifty for the mission.
if !(_modules isEqualTo []) then {
    ALiVE_guardPatrolPercentageCache = _percentage;
};

_percentage
