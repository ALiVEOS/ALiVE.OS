// COMPONENT should be defined in the script_component.hpp and included BEFORE this hpp
#define PREFIX ALiVE

// TODO: Consider Mod-wide or Component-narrow versions (or both, depending on wishes!)
#define MAJOR 1
#define MINOR 3
#define PATCHLVL 7
// BUILD should be YYMMDDR eg 1311211
#define BUILD 0000000

#define CLUSTERBUILD "Arma 3","Arma3",172,142223,"Stable"

#define VERSION MAJOR.MINOR.PATCHLVL.BUILD
#define VERSION_AR MAJOR,MINOR,PATCHLVL,BUILD

// MINIMAL required version for the Mod. Components can specify others..
#define REQUIRED_VERSION 1.70

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

#define MOD(var1) GVARMAIN(var1)
#define QMOD(var1) QUOTE(GVARMAIN(var1))
#ifdef RECOMPILE
    #undef RECOMPILE
#endif
#define RECOMPILE recompile = 1
#define MODULE_AUTHOR QUOTE(ALiVE Mod Team)
#define MACRO_ADDITEM(ITEM,COUNT) class _xx_##ITEM { \
    name = #ITEM; \
    count = COUNT; \
}
