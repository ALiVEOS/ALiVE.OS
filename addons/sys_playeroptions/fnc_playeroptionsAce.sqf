#include "\x\alive\addons\sys_playeroptions\script_component.hpp"
SCRIPT(playeroptionsAce);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_playeroptionsAce
Description:
The fatigue and sway part of Player Options: a player lightens their own fatigue and their
own weapon sway, when the mission allows it (Player Options module, Allow Fatigue And Sway
Options). Client only. With ACE's fatigue or sway running, ACE's are used; without ACE, or with
ACE's own switched off, the game's stamina and weapon sway are.

ACE's own on/off switches for fatigue and sway are server-wide and only take effect after
a mission restart, so they are not offered. What is offered works on the player's soldier
only, through what ACE gives for it:
- fatigue: ACE's per-unit fitness value (ace_advanced_fatigue_performanceFactor, the same
  one ACE's Eden unit attribute sets), applied by ACE's own player-changed handler
- sway: one multiplier added through ACE's public ace_common_fnc_addSwayFactor

A value the server or mission chose for these always wins: the menu items are disabled and
a choice already made falls back to normal.

Without ACE's fatigue or sway:
- stamina: off for the player's soldier (enableStamina false), or back to what it was. A mission
  that turned stamina off itself keeps it off: only the player's own "off" is undone
- sway: the soldier's aim coefficient (setCustomAimCoef) times the multiplier, so a mission's own
  value is the base and the player's choice only lessens it
Both are put on again on a new soldier after a respawn or a unit switch, a frame after the
switch, over whatever the mission's own respawn script set.

Parameters:
String - operation: "available", "forced", "fatigueOn", "swayOn", "fatigue", "stamina",
         "sway", "swayValue", "apply", "applyGame", "init"
Any - arguments for the operation

Returns:
Depends on the operation

Examples:
(begin example)
["fatigue", true] call ALiVE_fnc_playeroptionsAce;   // light fatigue
["sway", 0.5] call ALiVE_fnc_playeroptionsAce;       // half sway
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", "", [""]], ["_args", []]];

#define ACE_FATIGUE_VAR "ace_advanced_fatigue_performanceFactor"
#define ACE_FATIGUE_LIGHT 10

private _result = nil;

switch (_operation) do {

    // the menu is offered: a player's machine and the mission allows it (ACE or not)
    case "available": {
        _result = hasInterface
            && {!isNil QMOD(sys_playeroptions)}
            // on unless the mission turned it off: a mission saved without the setting has no value for it
            && {(MOD(sys_playeroptions) getVariable ["allowAceOptions", "true"]) in ["true", true]};
    };

    // a value the server or mission chose for this setting. Both settings used here are
    // server-wide, which CBA reports with a server priority of at least 1 whether forced or
    // not, so a forced server value shows as 2 (force force), a mission one as 1 or more,
    // and a server value set without force as differing from ACE's default.
    case "forced": {
        private _setting = _args;
        if (isNil "CBA_settings_fnc_priority") exitWith { _result = false };
        private _server = [_setting, "server"] call CBA_settings_fnc_priority;
        private _mission = [_setting, "mission"] call CBA_settings_fnc_priority;
        if (_server isEqualType false) then { _server = parseNumber _server };
        if (_mission isEqualType false) then { _mission = parseNumber _mission };
        _result = _server >= 2 || {_mission >= 1}
            || {!(([_setting, "server"] call CBA_settings_fnc_get) isEqualTo ([_setting, "default"] call CBA_settings_fnc_get))};
    };

    // ACE's fatigue or sway running (false without ACE): the game's own are used otherwise
    case "fatigueOn": {
        _result = missionNamespace getVariable ["ace_advanced_fatigue_enabled", false];
    };

    case "swayOn": {
        _result = missionNamespace getVariable ["ace_common_enableSway", false];
    };

    // _args: true for light fatigue, false for normal
    case "fatigue": {
        if !(["available"] call ALiVE_fnc_playeroptionsAce) exitWith {};
        private _light = _args isEqualTo true;
        if (_light && {["forced", "ace_advanced_fatigue_performanceFactor"] call ALiVE_fnc_playeroptionsAce}) exitWith {
            [localize "STR_ALIVE_PLAYEROPTIONS_ACE_FORCED"] call ALiVE_fnc_dump;
        };
        ALiVE_playerOptions_aceFatigue = _light;
        ["apply", ACE_player] call ALiVE_fnc_playeroptionsAce;
        ["Player Options - ACE fatigue set to %1 for %2", ["normal", "light"] select _light, name player] call ALiVE_fnc_dump;
    };

    // puts the fatigue choice on a unit and has ACE take it up. Normal gives the unit back
    // whatever value it had before (the mission maker's own, or none).
    case "apply": {
        private _unit = _args;
        if (isNil "_unit" || {!(_unit isEqualType objNull)} || {isNull _unit} || {!hasInterface}) exitWith {};
        if !(["fatigueOn"] call ALiVE_fnc_playeroptionsAce) exitWith {};
        if (isNil "ace_advanced_fatigue_fnc_handlePlayerChanged") exitWith {};

        private _light = (missionNamespace getVariable ["ALiVE_playerOptions_aceFatigue", false])
            && {!(["forced", "ace_advanced_fatigue_performanceFactor"] call ALiVE_fnc_playeroptionsAce)};

        if (_light) then {
            if (isNil {_unit getVariable "ALiVE_aceFatigueOwn"}) then {
                _unit setVariable ["ALiVE_aceFatigueOwn", [_unit getVariable ACE_FATIGUE_VAR]];
            };
            _unit setVariable [ACE_FATIGUE_VAR, ACE_FATIGUE_LIGHT];
        } else {
            private _own = _unit getVariable "ALiVE_aceFatigueOwn";
            if (isNil "_own") exitWith {};
            _unit setVariable [ACE_FATIGUE_VAR, _own select 0];
            _unit setVariable ["ALiVE_aceFatigueOwn", nil];
        };

        // the same call ACE makes when its own fitness setting changes mid-mission
        if (_unit isEqualTo ACE_player) then {
            [_unit, _unit] call ace_advanced_fatigue_fnc_handlePlayerChanged;
        };
    };

    // _args: sway multiplier, 1 normal, 0.5 half, 0 none
    case "sway": {
        if !(["available"] call ALiVE_fnc_playeroptionsAce) exitWith {};
        private _mult = if (_args isEqualType 0) then { (_args max 0) min 1 } else { 1 };
        if (_mult < 1 && {["swayOn"] call ALiVE_fnc_playeroptionsAce} && {["forced", "ace_common_swayFactor"] call ALiVE_fnc_playeroptionsAce}) exitWith {
            [localize "STR_ALIVE_PLAYEROPTIONS_ACE_FORCED"] call ALiVE_fnc_dump;
        };
        ALiVE_playerOptions_aceSway = _mult;
        if (["swayOn"] call ALiVE_fnc_playeroptionsAce) then {
            if (isNil "ALiVE_playerOptions_aceSwayAdded" && {!isNil "ace_common_fnc_addSwayFactor"}) then {
                ALiVE_playerOptions_aceSwayAdded = true;
                ["multiplier", { ["swayValue"] call ALiVE_fnc_playeroptionsAce }, "alive_playeroptions"] call ace_common_fnc_addSwayFactor;
            };
        } else {
            ["applyGame", player] call ALiVE_fnc_playeroptionsAce;
        };
        ["Player Options - weapon sway set to %1 for %2", _mult, name player] call ALiVE_fnc_dump;
    };

    // _args: true for the game's stamina off, false to give back what the soldier had
    case "stamina": {
        if !(["available"] call ALiVE_fnc_playeroptionsAce) exitWith {};
        ALiVE_playerOptions_staminaOff = _args isEqualTo true;
        ["applyGame", player] call ALiVE_fnc_playeroptionsAce;
        ["Player Options - stamina %1 for %2", ["normal", "off"] select ALiVE_playerOptions_staminaOff, name player] call ALiVE_fnc_dump;
    };

    // the game's stamina and sway choices on a unit, where ACE's own aren't running. What the unit had
    // before is kept on it, so normal gives that back and a new soldier starts from the mission's values.
    case "applyGame": {
        private _unit = _args;
        if (isNil "_unit" || {!(_unit isEqualType objNull)} || {isNull _unit} || {!local _unit}) exitWith {};
        if !(["fatigueOn"] call ALiVE_fnc_playeroptionsAce) then {
            if (missionNamespace getVariable ["ALiVE_playerOptions_staminaOff", false]) then {
                if (isNil {_unit getVariable "ALiVE_staminaOwn"}) then { _unit setVariable ["ALiVE_staminaOwn", isStaminaEnabled _unit] };
                _unit enableStamina false;
                _unit setFatigue 0;
            } else {
                private _own = _unit getVariable "ALiVE_staminaOwn";
                if (!isNil "_own") then { _unit enableStamina _own; _unit setVariable ["ALiVE_staminaOwn", nil] };
            };
        };
        if !(["swayOn"] call ALiVE_fnc_playeroptionsAce) then {
            private _mult = missionNamespace getVariable ["ALiVE_playerOptions_aceSway", 1];
            private _own = _unit getVariable "ALiVE_aimCoefOwn";
            if (_mult < 1) then {
                if (isNil "_own") then { _own = getCustomAimCoef _unit; _unit setVariable ["ALiVE_aimCoefOwn", _own] };
                _unit setCustomAimCoef (_own * _mult);
            } else {
                if (!isNil "_own") then { _unit setCustomAimCoef _own; _unit setVariable ["ALiVE_aimCoefOwn", nil] };
            };
        };
    };

    // read by ACE's sway loop every half second: the player's multiplier, or 1 once the
    // server or mission has chosen the sway factor
    case "swayValue": {
        private _mult = missionNamespace getVariable ["ALiVE_playerOptions_aceSway", 1];
        _result = if (_mult < 1 && {["forced", "ace_common_swayFactor"] call ALiVE_fnc_playeroptionsAce}) then { 1 } else { _mult };
    };

    // client start: a respawned or switched-to soldier takes the fatigue choice again, and a
    // fitness value the server sets later wins over it
    case "init": {
        if !(["available"] call ALiVE_fnc_playeroptionsAce) exitWith {};
        ["unit", {
            params ["_newUnit"];
            if (missionNamespace getVariable ["ALiVE_playerOptions_aceFatigue", false]) then {
                [{ ["apply", _this] call ALiVE_fnc_playeroptionsAce }, _newUnit] call CBA_fnc_execNextFrame;
            };
            if ((missionNamespace getVariable ["ALiVE_playerOptions_staminaOff", false]) || {(missionNamespace getVariable ["ALiVE_playerOptions_aceSway", 1]) < 1}) then {
                [{ ["applyGame", _this] call ALiVE_fnc_playeroptionsAce }, _newUnit] call CBA_fnc_execNextFrame;
            };
        }] call CBA_fnc_addPlayerEventHandler;
        ["CBA_SettingChanged", {
            params ["_setting"];
            if (_setting == "ace_advanced_fatigue_performanceFactor" && {missionNamespace getVariable ["ALiVE_playerOptions_aceFatigue", false]}) then {
                [{ ["apply", ACE_player] call ALiVE_fnc_playeroptionsAce }] call CBA_fnc_execNextFrame;
            };
        }] call CBA_fnc_addEventHandler;
        ["Player Options - fatigue and sway options offered (ACE fatigue %1, ACE sway %2; the game's own otherwise)", ["fatigueOn"] call ALiVE_fnc_playeroptionsAce, ["swayOn"] call ALiVE_fnc_playeroptionsAce] call ALiVE_fnc_dump;
    };
};

if !(isNil "_result") then { _result };
