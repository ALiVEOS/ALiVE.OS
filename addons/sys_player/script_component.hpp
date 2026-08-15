#define COMPONENT sys_player
#include "\x\alive\addons\main\script_mod.hpp"

#ifdef DEBUG_ENABLED_SYS_PLAYER
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_SYS_PLAYER
    #define DEBUG_SETTINGS DEBUG_SETTINGS_SYS_PLAYER
#endif

#include "\x\cba\addons\main\script_macros.hpp"

// Inferno #885: states that must never be written to the player store.
// HEALTH_DATA round trips damage and lifestate, and playerData.hpp's
// lifestate setter calls setUnconscious true on restore, so persisting any
// of these puts the player straight back into a dead or downed state on
// rejoin. Leave the last good save standing instead.
#define PLAYER_STATE_UNSAVEABLE(var1) (!alive (var1) || {toUpper (lifeState (var1)) in ["DEAD","DEAD-SWITCHING","DEAD-RESPAWN","INCAPACITATED","UNCONSCIOUS","AGONY","AGONY-UNCONSCIOUS"]})
