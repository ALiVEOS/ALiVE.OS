#include "\x\alive\addons\sys_armour\script_component.hpp"
SCRIPT(armourInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_armourInit

Description:
Applies every armour set whose mod is loaded (any of its anyPatches[]) and whose ALiVE Addon Options
switch is on. Called once per machine when CBA settings are ready.

For each active set:
- the vest and bullet values go into ACE medical (ALIVE_fnc_armourSeed);
- the set's active-protection option is applied (ALIVE_fnc_armourAps).

Parameters:
None

Returns:
Nil

Examples:
(begin example)
[] call ALIVE_fnc_armourInit;
(end)

See Also:
- <ALIVE_fnc_armourSeed>
- <ALIVE_fnc_armourAps>

Author:
Jman
---------------------------------------------------------------------------- */

{
    private _set = _x;
    private _name = getText (_set >> "displayName");

    private _loaded = ((getArray (_set >> "anyPatches")) findIf {isClass (configFile >> "CfgPatches" >> _x)}) > -1;

    if (_loaded) then {
        private _on = missionNamespace getVariable [getText (_set >> "setting"), false];

        if (!_on) then {
            diag_log format ["ALiVE armour: %1 set is off (ALiVE Addon Options), stock values in use", _name];
        } else {
            [_set] call ALIVE_fnc_armourSeed;
            ["init", [_set]] call ALIVE_fnc_armourAps;
        };
    };
} forEach ("true" configClasses (configFile >> "ALiVE_ArmourSets"));
