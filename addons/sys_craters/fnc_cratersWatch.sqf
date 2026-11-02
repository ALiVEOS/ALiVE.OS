#include "\x\alive\addons\sys_craters\script_component.hpp"
SCRIPT(cratersWatch);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_cratersWatch

Description:
Watches for shells, rockets and bombs going off. A round belongs to the machine that fired
it (a player's, a headless client's, the server's), so every machine watches its own and
tells the server where each one went off. Bullets, smoke, flares and anything with too small
a blast are skipped the moment they are fired, from a per-class answer worked out once.

Parameters:
String - The operation ("" to start watching)
Array - Its arguments

Returns:
"" - nothing; starts watching once per machine
score - [ammo class] -> the blast score (indirect hit x its range), -1 for a round that never
        leaves a crater; cached per class
attach - [projectile] -> nothing; watches the round when it is big enough

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", "", [""]], ["_args", [], [[]]]];

private _result = nil;

switch (_operation) do {

    case "": {
        if (!isNil "ALiVE_craters_watching") exitWith {};
        ALiVE_craters_watching = true;
        if (isNil "ALiVE_craters_scores") then { ALiVE_craters_scores = createHashMap };
        // fired for every round, bullets included, so the common answer (skip) costs one lookup
        addMissionEventHandler ["ProjectileCreated", {
            params ["_p"];
            private _s = ALiVE_craters_scores getOrDefault [typeOf _p, -2];
            if (_s == -2 || {_s >= 40}) then { ["attach", [_p]] call ALiVE_fnc_cratersWatch };
        }];
        ["ALiVE Persistent Craters - watching for hits on machine %1 (server %2, headless %3)", clientOwner, isServer, !hasInterface && !isServer] call ALiVE_fnc_dump;
    };

    case "score": {
        _args params [["_ammo", "", [""]]];
        if (isNil "ALiVE_craters_scores") then { ALiVE_craters_scores = createHashMap };
        _result = ALiVE_craters_scores getOrDefault [_ammo, -2];
        if (_result != -2) exitWith {};
        private _cfg = configFile >> "CfgAmmo" >> _ammo;
        private _sim = toLower getText (_cfg >> "simulation");
        _result = if (!isClass _cfg
            || {_sim in ["shotbullet", "shotsmokex", "shotsmoke", "shotilluminating", "shotcm", "shotlaser", "shotspread", "shotnvgoggle", "shotdeploy"]}
            || {getNumber (_cfg >> "explosive") < 0.5}) then {
            -1
        } else {
            (getNumber (_cfg >> "indirectHit")) * (getNumber (_cfg >> "indirectHitRange"))
        };
        ALiVE_craters_scores set [_ammo, _result];
    };

    case "attach": {
        _args params [["_p", objNull, [objNull]]];
        // a round is watched where it was fired; where it is only a copy it says nothing, so
        // one hit is never reported twice
        if (isNull _p || {!local _p}) exitWith {};
        if ((["score", [typeOf _p]] call ALiVE_fnc_cratersWatch) < 40) exitWith {};
        _p addEventHandler ["Explode", {
            params ["_p", "_posASL"];
            private _r = [_posASL, typeOf _p, clientOwner, diag_tickTime];
            if (isServer) then {
                ["queue", [_r]] call ALiVE_fnc_cratersReport;
            } else {
                [_r] remoteExecCall ["ALiVE_fnc_cratersReport", 2];
            };
        }];
    };
};

if (!isNil "_result") then { _result } else { nil }
