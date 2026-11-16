#include "\x\alive\addons\sys_armour\script_component.hpp"
SCRIPT(armourAps);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_armourAps

Description:
The armour set's option for the RHS T-14 and T-15 active protection.

RHS keeps every T-14/T-15 in the list rhs_aps_vehicles (one copy per machine,
filled by the tank's init on each machine), and destroys any rocket or missile
fired towards a tank on that list once it is within 40 m, with no limit.

- "rhs": RHS behaviour, nothing changes.
- "off": the tanks are taken off the list, so rockets and missiles reach them.
- "limited": each tank stops a set number of rockets or missiles, then is
  taken off the list until it is rearmed.

RHS's own script is not changed: a rocket already in flight when a tank runs
out of charges can still be stopped, because RHS picks its tanks at launch.

Parameters:
STRING - operation
ARRAY - arguments for the operation:
  "init"    [CONFIG set]                 apply the set's option on this machine
  "vehicle" [OBJECT tank]                apply the option to one tank here
  "fired"   [FiredMan arguments]         watch a rocket or missile
  "count"   [OBJECT tank]                one stopped rocket; spend a charge (server)
  "spend"   [OBJECT tank, BOOL spent]    take the tank off (or back on) the list here
  "watch"   [OBJECT tank]                wait for the tank to be rearmed (server)

Returns:
Nil

Examples:
(begin example)
["init", [configFile >> "ALiVE_ArmourSets" >> "RHS"]] call ALIVE_fnc_armourAps;
(end)

See Also:
- <ALIVE_fnc_armourInit>

Author:
Jman
---------------------------------------------------------------------------- */

params ["_operation", ["_args", []]];

switch (_operation) do {

    case "init": {
        _args params ["_set"];

        private _mode = missionNamespace getVariable [getText (_set >> "apsSetting"), "rhs"];
        ALiVE_armour_apsMode = _mode;
        ALiVE_armour_apsCharges = round (missionNamespace getVariable [getText (_set >> "apsChargesSetting"), 4]);
        ALiVE_armour_apsBases = getArray (_set >> "apsBases");

        if (_mode == "rhs") exitWith {};

        // tanks that already exist; later ones come through their InitPost
        {
            ["vehicle", [_x]] call ALIVE_fnc_armourAps;
        } forEach (entities [ALiVE_armour_apsBases, [], false, true]);

        if (_mode == "limited") then {
            ["CAManBase", "FiredMan", {
                ["fired", _this] call ALIVE_fnc_armourAps;
            }] call CBA_fnc_addClassEventHandler;
        };

        diag_log format ["ALiVE armour: T-14/T-15 active protection set to '%1' (%2 charges)", _mode, ALiVE_armour_apsCharges];
    };

    case "vehicle": {
        _args params ["_tank"];
        private _mode = missionNamespace getVariable ["ALiVE_armour_apsMode", "rhs"];

        if (_mode == "off" || {_mode == "limited" && {_tank getVariable ["ALiVE_armour_apsSpent", false]}}) then {
            ["spend", [_tank, true]] call ALIVE_fnc_armourAps;
        };
    };

    case "fired": {
        _args params ["_unit", "", "", "", "_ammo", "", "_projectile"];

        // counted once, where the shot is fired
        if (isNull _projectile || {!local _unit}) exitWith {};
        if ((missionNamespace getVariable ["rhs_aps_vehicles", []]) isEqualTo []) exitWith {};

        private _cfgAmmo = configFile >> "CfgAmmo";
        if !(_ammo isKindOf ["RocketBase", _cfgAmmo] || {_ammo isKindOf ["MissileBase", _cfgAmmo]}) exitWith {};

        // a rocket that explodes, hits something or releases a warhead was not
        // stopped; each rocket gets a number, kept here once it has done so
        private _id = (missionNamespace getVariable ["ALiVE_armour_apsSeq", 0]) + 1;
        ALiVE_armour_apsSeq = _id;
        if (isNil "ALiVE_armour_apsHits") then {ALiVE_armour_apsHits = []};
        private _mark = compile format ["ALiVE_armour_apsHits pushBackUnique %1", _id];
        {
            _projectile addEventHandler [_x, _mark];
        } forEach ["Explode", "HitPart", "SubmunitionCreated"];

        // RHS deletes a stopped rocket within 40 m of the tank. The rocket is
        // followed each frame while it flies, because once deleted it no longer
        // has a position to measure from
        [{
            params ["_args", "_handle"];
            _args params ["_projectile", "_lastPos", "_from", "_id"];

            if (!isNull _projectile) exitWith {_args set [1, getPosASL _projectile]};
            [_handle] call CBA_fnc_removePerFrameHandler;

            if (_id in ALiVE_armour_apsHits) exitWith {ALiVE_armour_apsHits = ALiVE_armour_apsHits - [_id]};

            // the protected tank nearest where the rocket was last seen, never
            // the shooter's own vehicle
            private _tank = objNull;
            private _best = 45;
            {
                if (!isNull _x && {alive _x} && {_x != _from}) then {
                    private _d = (getPosASL _x) distance _lastPos;
                    if (_d < _best) then {_best = _d; _tank = _x};
                };
            } forEach (missionNamespace getVariable ["rhs_aps_vehicles", []]);
            if (isNull _tank) exitWith {};

            // counted on the server, so shots from several machines add up
            ["count", [_tank]] remoteExecCall ["ALIVE_fnc_armourAps", 2];
        }, 0, [_projectile, getPosASL _projectile, vehicle _unit, _id]] call CBA_fnc_addPerFrameHandler;
    };

    case "count": {
        _args params ["_tank"];
        if (!isServer || {isNull _tank}) exitWith {};

        private _used = (_tank getVariable ["ALiVE_armour_apsUsed", 0]) + 1;
        _tank setVariable ["ALiVE_armour_apsUsed", _used, true];

        if (_used >= ALiVE_armour_apsCharges && {!(_tank getVariable ["ALiVE_armour_apsSpent", false])}) then {
            _tank setVariable ["ALiVE_armour_apsSpent", true, true];
            // every machine, and machines that join later (one queue entry per
            // tank, dropped when the tank is deleted)
            ["spend", [_tank, true]] remoteExecCall ["ALIVE_fnc_armourAps", 0, _tank];
            ["watch", [_tank]] call ALIVE_fnc_armourAps;
            diag_log format ["ALiVE armour: %1 has used its %2 active protection charges", typeOf _tank, ALiVE_armour_apsCharges];
        };
    };

    case "spend": {
        _args params ["_tank", "_spent"];
        if (isNull _tank) exitWith {};

        private _list = missionNamespace getVariable ["rhs_aps_vehicles", []];
        if (_spent) then {
            _list = _list - [_tank];
        } else {
            if (alive _tank) then {_list pushBackUnique _tank};
        };
        missionNamespace setVariable ["rhs_aps_vehicles", _list];
    };

    case "watch": {
        _args params ["_tank"];

        private _ammoNow = {
            params ["_tank"];
            private _total = 0;
            {_total = _total + (_x select 2)} forEach magazinesAllTurrets _tank;
            _total
        };

        // checked every 10 s on the server, only while this tank's charges are
        // spent; magazinesAllTurrets reads a tank owned by any machine
        [{
            params ["_args", "_handle"];
            _args params ["_tank", "_spentAmmo", "_ammoNow"];

            if (!alive _tank) exitWith {[_handle] call CBA_fnc_removePerFrameHandler};

            if ([_tank] call _ammoNow > _spentAmmo) then {
                [_handle] call CBA_fnc_removePerFrameHandler;
                _tank setVariable ["ALiVE_armour_apsUsed", 0, true];
                _tank setVariable ["ALiVE_armour_apsSpent", false, true];
                ["spend", [_tank, false]] remoteExecCall ["ALIVE_fnc_armourAps", 0, _tank];
                diag_log format ["ALiVE armour: %1 rearmed, active protection charges restored", typeOf _tank];
            } else {
                // ammo spent after the charges ran out lowers the mark
                _args set [1, [_tank] call _ammoNow];
            };
        }, 10, [_tank, [_tank] call _ammoNow, _ammoNow]] call CBA_fnc_addPerFrameHandler;
    };
};
