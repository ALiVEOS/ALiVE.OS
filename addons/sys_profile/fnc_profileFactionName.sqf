#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileFactionName);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileFactionName

Description:
A faction's name as its CfgFactionClasses class spells it. Arma reads class names in any case, so a
faction's units and groups may write faction = "b_araf" for the class B_ARAF; profiles kept that
spelling and were filed under it, so an AI Commander (or anything else) asking for B_ARAF found
none of them. A name that is no faction class is given back as it is.

Parameters:
String - faction name, in any case

Returns:
String - the faction class's own spelling, or the name as given

Examples:
(begin example)
_faction = "b_araf" call ALIVE_fnc_profileFactionName; // "B_ARAF"
(end)

See Also:

Author:
Jman
---------------------------------------------------------------------------- */

if !(_this isEqualType "") exitWith { _this };
if (_this == "") exitWith { _this };
if (isNil "ALiVE_profileFactionNames") then { ALiVE_profileFactionNames = createHashMap };
private _key = toLower _this;
private _name = ALiVE_profileFactionNames getOrDefault [_key, ""];
if (_name == "") then {
    private _cfg = configFile >> "CfgFactionClasses" >> _this;
    if !(isClass _cfg) then { _cfg = missionConfigFile >> "CfgFactionClasses" >> _this };
    _name = [_this, configName _cfg] select (isClass _cfg);
    ALiVE_profileFactionNames set [_key, _name];
};
_name
