// COMPONENT should be defined in the script_component.hpp and included BEFORE this hpp
#define PREFIX ALiVE

// TODO: Consider Mod-wide or Component-narrow versions (or both, depending on wishes!)
#define MAJOR 3
#define MINOR 2
#define PATCHLVL 0
// BUILD should be YYMMDDR eg 1311211. Stamped by the packing step on every
// build, so a log identifies exactly which one an install came from.
#define BUILD 2604133
// DEV between releases, RELEASE when one is cut. Moves at the same moment MINOR
// or PATCHLVL does, and back again straight after. Reported at startup so a
// report says which kind of build it came from without anyone having to ask.
#define BUILDTYPE "DEV"

#define CLUSTERBUILD "Arma 3","Arma3",222,153995,"Stable"

#define VERSION MAJOR.MINOR.PATCHLVL.BUILD
#define VERSION_AR MAJOR,MINOR,PATCHLVL,BUILD

// MINIMAL required version for the Mod. Components can specify others..
#define REQUIRED_VERSION 2.14

/*
 // Defined DEBUG_MODE_NORMAL in a few CBA_fncs to prevent looped logging :)
 #ifndef DEBUG_MODE_NORMAL
 #define DEBUG_MODE_FULL
 #endif
*/

// Set a default debug mode for the component here (See documentation on how to default to each of the modes).
//    #define DEBUG_ENABLED_MAIN
//    #define DEBUG_ENABLED_SYS_ADMINACTIONS
//    #define DEBUG_ENABLED_FNC_STRATEGIC
//    #define DEBUG_ENABLED_mil_cqb
//    #define DEBUG_ENABLED_SYS_NEWSFEED
//    #define DEBUG_ENABLED_SYS_LOGISTICS
//    #define DEBUG_ENABLED_SYS_DATA
//    #define DEBUG_ENABLED_SYS_DATA_COUCHDB
//    #define DEBUG_ENABLED_SYS_STATISTICS
//    #define DEBUG_ENABLED_MIL_STRATEGIC
//    #define DEBUG_ENABLED_SYS_PROFILE
//    #define DEBUG_ENABLED_SYS_SIMULATION
//    #define DEBUG_ENABLED_SYS_PLAYER
//    #define DEBUG_ENABLED_SYS_playeroptions
//    #define DEBUG_ENABLED_SYS_viewdistance
//    #define DEBUG_ENABLED_SYS_playertags
//    #define DEBUG_ENABLED_SYS_crewinfo
//    #define DEBUG_ENABLED_SYS_PERF
//    #define DEBUG_ENABLED_SYS_marker
//    #define DEBUG_ENABLED_SYS_spotrep
//    #define DEBUG_ENABLED_SYS_sitrep
//    #define DEBUG_ENABLED_MIL_C2ISTAR
//    #define DEBUG_ENABLED_SYS_patrolrep
//    #define DEBUG_ENABLED_SUP_GROUP_MANAGER
//    #define DEBUG_ENABLED_SUP_COMMAND
//    #define DEBUG_ENABLED_X_LIB
//    #define DEBUG_ENABLED_mil_ied
//    #define DEBUG_ENABLED_mil_ato

// Set automated tests
// #define AUTOMATED_TESTS QUOTE(MAIN),QUOTE(SYS_LOGISTICS),QUOTE(SYS_GC),QUOTE(MIL_CQB),QUOTE(MIL_OPCOM)

// Enable context zones for the Arma Script Profiler.
#define ALIVE_SCRIPT_PROFILING

#ifdef ALIVE_SCRIPT_PROFILING
    #define PROFILE_SCOPE(ID,NAME) private _aliveProfileScope_##ID = createProfileScope NAME;
    #define PROFILE_SCOPE_END(ID) _aliveProfileScope_##ID = nil;
#else
    #define PROFILE_SCOPE(ID,NAME)
    #define PROFILE_SCOPE_END(ID)
#endif

#define MOD(var1) GVARMAIN(var1)
#define QMOD(var1) QUOTE(GVARMAIN(var1))
#ifdef RECOMPILE
    #undef RECOMPILE
#endif
// Addon functions are compiled when their configs are loaded. Recompiling the
// complete function library at every mission start also recompiles it for the
// main-menu mission, briefly blocking the UI each time the menu is entered.
// Keep hot-reload available for local source-development builds without making
// public development/release builds pay that cost.
#ifdef ALIVE_DEV_RECOMPILE_FUNCTIONS
    #define RECOMPILE recompile = 1
#else
    #define RECOMPILE recompile = 0
#endif
#define MODULE_AUTHOR QUOTE(ALiVE Mod Team)
#define MACRO_ADDITEM(ITEM,COUNT) class _xx_##ITEM { \
    name = #ITEM; \
    count = COUNT; \
}
