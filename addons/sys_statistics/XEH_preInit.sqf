// #define DEBUG_MODE_FULL
#include "script_component.hpp"

// https://dev-heaven.net/projects/cca/wiki/Extended_Eventhandlers#New-in-19-version-stringtable-and-pre-init-EH-code
// https://dev-heaven.net/projects/cca/wiki/Extended_Eventhandlers#New-in-200-Support-for-ArmA-II-serverInit-and-clientInit-entries

LOG(MSG_INIT);

// Enable the module
GVAR(ENABLED) = true;
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


