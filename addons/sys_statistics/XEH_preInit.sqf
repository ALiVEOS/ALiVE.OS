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