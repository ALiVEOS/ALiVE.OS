// #define DEBUG_MODE_FULL
#include "script_component.hpp"

// https://dev-heaven.net/projects/cca/wiki/Extended_Eventhandlers#New-in-19-version-stringtable-and-pre-init-EH-code
// https://dev-heaven.net/projects/cca/wiki/Extended_Eventhandlers#New-in-200-Support-for-ArmA-II-serverInit-and-clientInit-entries

LOG(MSG_INIT);

// Off until the ALiVE Data module reaches the War Room and switches statistics on, as that's the
// only place they can go. Starting them on left every mission without the Data module recording
// for nobody, and throwing script errors on every vehicle hit or kill and whenever a player got
// in or out of a vehicle or fired its weapon. A client's half of the statistics start-up
// (fnc_statisticsInit.sqf) can read this before the server's decision arrives, so a rebuilt War
// Room needs that start-up to wait for the Data module's startupComplete first.
GVAR(ENABLED) = false;
GVAR(DISABLED) = false;

// PREP any functions required during XEH init process


// Handling units firing (for recording player shots)
PREP(firedEH);
PREP(playerfiredEH);

// Units damaged
//PREP(handleDamageEH);
PREP(handleHealEH);
PREP(hitEH);

// Units landing
PREP(landedTouchDownEH);

// Missile Launch!
PREP(incomingMissileEH);

// Handling units killed (for recording player kills/deaths)
PREP(unitKilledEH);

// Handling units getting into and out of vehicles
PREP(getInEH);
PREP(getOutEH);

// Handling Combat Dives
PREP(divingEH);

// What kind of weapon, vehicle and soldier, for the War Room's pictures
PREP(weaponKind);
PREP(vehicleKind);
PREP(roleKind);
PREP(seatKind);
// mission events for the War Room's live feed, from other modules
PREP(feedEvent);

// Arma's own scoreboard (AshTray, 24 Nov): a player's kamikaze drone blowing up scored him as destroying his
// own side's UAV and killing its AI crew, a minus on the scoreboard after every strike. HandleScore runs on the
// server for each player; a score for a UAV of his own side, or for its AI crew, is refused (the whole update:
// score and kill counts). Enemy killed by the blast still score, and a drone shot down by the enemy is not his.
// It does not outlive a respawn, so each new player body gets it. Started here, not with the statistics, so it
// also runs in missions that switch statistics off
if (isServer && {isMultiplayer} && {isNil QGVAR(scoreGuard)}) then {
    GVAR(scoreGuard) = [] spawn {
        private _fnc_own = {
            params ["_unit", "_object"];
            if (isNull _object) exitWith { false };
            private _sideOf = { [east, west, independent, civilian] param [getNumber (configOf _this >> "side"), civilian] };
            private _uav = if (_object isKindOf "Man") then {
                [objNull, _object] select (_object isKindOf "UAV_AI_base_F" || {!isPlayer _object && {unitIsUAV (objectParent _object)}})
            } else {
                [objNull, _object] select (unitIsUAV _object)
            };
            !isNull _uav && {(side group _unit) == (_uav call _sideOf)}
        };
        missionNamespace setVariable [QGVAR(fnc_scoreOwnUAV), _fnc_own];
        while { true } do {
            {
                if !(_x getVariable [QGVAR(scoreEH), false]) then {
                    _x setVariable [QGVAR(scoreEH), true];
                    _x addEventHandler ["HandleScore", {
                        params ["_unit", "_object", "_score"];
                        !([_unit, _object] call (missionNamespace getVariable QGVAR(fnc_scoreOwnUAV)))
                    }];
                };
            } forEach (allPlayers - entities "HeadlessClient_F");
            sleep 5;
        };
    };
};
