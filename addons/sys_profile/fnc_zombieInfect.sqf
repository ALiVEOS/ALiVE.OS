#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(zombieInfect);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_zombieInfect

Description:
Outbreak game mode: anyone a zombie kills gets up again as a zombie. Civilians, soldiers
of any side and players alike: a few seconds after the death a zombie of the dead man's
class, in his clothes, stands up where he fell and the body goes. A player respawns as the
mission sets up; the zombie is a new unit on the server, so it can go after other players.

"start" runs on every machine (each sees the deaths of its own units, a player's included)
and sends each death caused by a zombie to the server, which raises the zombie ("rise").
Risen zombies join a nearby risen group or start one, are driven by the zombie mod and the
zombie hunt, and are not Virtual AI profiles: the Infection Cap on the Virtual AI module
limits how many stand at once.

Parameters:
String - "start" or "rise"
Array - for "rise": [body, class, position ATL, direction, loadout]

Returns:
Nothing

Examples:
(begin example)
["start"] call ALiVE_fnc_zombieInfect;
(end)

See Also:
ALiVE_fnc_zombieHunt, ALiVE_fnc_profileSystemInit

Author:
Jman
---------------------------------------------------------------------------- */

params [["_mode", "start"], ["_args", []]];

switch (_mode) do {

    case "start": {
        if (!isNil "ALiVE_zombieInfectEH") exitWith {};
        if !(missionNamespace getVariable ["ALiVE_zombieInfection", false]) exitWith {};

        ALiVE_zombieInfectEH = addMissionEventHandler ["EntityKilled", {
            params ["_victim", "_killer", "_instigator"];
            if (!local _victim || {!(_victim isKindOf "CAManBase")}) exitWith {};
            if (_victim getVariable ["ALiVE_zombie", false] || {_victim getVariable ["WBK_AI_isZombie", false]}) exitWith {};
            if (_victim getVariable ["ALiVE_zombieRisen", false]) exitWith {};
            if !(isNull objectParent _victim) exitWith {};

            private _isZombie = { !isNull _this && {_this getVariable ["ALiVE_zombie", false] || {_this getVariable ["WBK_AI_isZombie", false]}} };
            private _byZombie = (_killer call _isZombie) || {_instigator call _isZombie};
            // The zombie mod's own blows name the victim as his own killer, so a death with no
            // other killer next to a zombie counts as a zombie's.
            if (!_byZombie && {isNull _killer || {_killer == _victim}}) then {
                _byZombie = ((_victim nearEntities [["CAManBase"], 4]) findIf { alive _x && {_x call _isZombie} }) >= 0;
            };
            if (!_byZombie) exitWith {};

            _victim setVariable ["ALiVE_zombieRisen", true, true];
            ["rise", [_victim, typeOf _victim, getPosATL _victim, getDir _victim, getUnitLoadout _victim]] remoteExecCall ["ALiVE_fnc_zombieInfect", 2];
        }];
    };

    case "rise": {
        if (!isServer) exitWith {};
        ALiVE_zombieRisen = (missionNamespace getVariable ["ALiVE_zombieRisen", []]) select { alive _x };
        // Those still waiting to rise count too, so a burst of deaths can't all slip under the cap
        private _pending = missionNamespace getVariable ["ALiVE_zombieRisePending", 0];
        if (count ALiVE_zombieRisen + _pending >= (missionNamespace getVariable ["ALiVE_zombieInfectionCap", 40])) exitWith {};
        ALiVE_zombieRisePending = _pending + 1;

        _args spawn {
            params ["_body", "_class", "_pos", "_dir", "_loadout"];
            sleep (6 + random 6);

            // Into a risen group close by with room, or a new one. Never a Virtual AI group: its
            // profile doesn't know about the newcomer.
            private _zombieSide = [east, west, resistance] select ((["EAST", "WEST", "GUER"] find (toUpper (missionNamespace getVariable ["ALiVE_ZOMBIESIDE", "EAST"]))) max 0);
            private _group = grpNull;
            {
                if (local _x && {_x getVariable ["ALiVE_zombieRisenGroup", false]} && {count units _x < 12} && {!isNull leader _x} && {(leader _x) distance _pos < 60}) exitWith { _group = _x };
            } forEach allGroups;
            if (isNull _group) then {
                _group = createGroup [_zombieSide, true];
                _group setVariable ["ALiVE_zombieRisenGroup", true, true];
                _group setVariable ["ALiVE_zombieHunt", true, true];
            };

            private _zombie = _group createUnit [_class, _pos, [], 0, "CAN_COLLIDE"];
            if (isNull _zombie) exitWith { ALiVE_zombieRisePending = (ALiVE_zombieRisePending - 1) max 0 };
            // A man of another side's class keeps that side until he joins the group again (measured)
            [_zombie] joinSilent _group;
            _zombie setDir _dir;
            _zombie setUnitLoadout _loadout;
            _zombie setVariable ["ALiVE_zombie", true, true];
            ALiVE_zombieRisen pushBack _zombie;
            ALiVE_zombieRisePending = ((missionNamespace getVariable ["ALiVE_zombieRisePending", 1]) - 1) max 0;

            // The body goes, so there aren't two. A player's body is only hidden while he waits to
            // respawn, since he is still looking out of it, and goes once he has left it.
            if (!isNull _body) then {
                if (isPlayer _body) then {
                    hideObjectGlobal _body;
                    _body spawn {
                        private _until = time + 600;
                        waitUntil { sleep 2; isNull _this || {!isPlayer _this} || {time > _until} };
                        if (!isNull _this && {!isPlayer _this}) then { deleteVehicle _this };
                    };
                } else { deleteVehicle _body };
            };

            if (isClass (configFile >> "CfgPatches" >> "WBK_ZombieCreatures") && {!isNil "WBK_LoadAIThroughEden"}) then {
                [_zombie, [4, 2] selectRandomWeighted [0.7, 0.3]] call WBK_LoadAIThroughEden;
            } else {
                removeAllWeapons _zombie;
            };
        };
    };
};
