/*
 * Filename:
 * system.sqf
 *
 * Description:
 * function scripts
 * Runs on server and client
 
 * Created by [KH]Jman
 * Creation date: 05/04/2021
 *
 * */
 
// ====================================================================================
//  SYSTEM HANDLERS
// ====================================================================================
 
#define INC(var) var = (var) + 1

#define VN_MS_AUDIBLE_FIRE_COEF     30
// global limit of tracks markers
#define VN_MS_TRACKS_LIMIT          200
// min velocity magnitude at which player leaves tracks
#define VN_MS_TRACKS_MAGNITUDE      2
// delay between tracks
#define VN_MS_TRACKS_DELAY          5
// distance between tracks for each individual player
#define VN_MS_TRACKS_SPACING        80
// track marker size
#define VN_MS_TRACKS_A              35
#define VN_MS_TRACKS_B              50

#define QUOTE(var) #var

// #define ORDNANCES_ARRAY ["vn_bomb_500_blu1b_fb_ammo", "vn_bomb_500_mk82_se_open_ammo", "vn_bomb_500_mk20_cb_ammo"]
#define ORDNANCES_ARRAY ["vn_bomb_500_blu1b_fb_ammo", "vn_bomb_500_mk82_se_open_ammo"]
#define ORDNANCES_RANDOM (selectRandom ORDNANCES_ARRAY)

#define DIFFICULTY_EASY 1
#define DIFFICULTY_NORMAL 2
#define DIFFICULTY_HARD 3
#define DIFFICULTY_GREENHELL 4

#define ALERT_SENTRIES 0
#define ALERT_STALKERS 1
#define ALERT_PATROLS 2
#define ALERT_AVALANCHE 3

// Units
#define O_RIFLEMAN_SKS_BAYO "vn_o_men_nva_03"
#define O_RIFLEMAN_T56_BAYO "vn_o_men_nva_05"
#define O_RIFLEMAN_K50 "vn_o_men_nva_06"
#define O_RIFLEMAN_RTO "vn_o_men_nva_13"
#define O_GRENADIER_SKS "vn_o_men_nva_07"
#define O_MARKSMAN_SKS "vn_o_men_nva_10"
#define O_ANTITANK_SKS "vn_o_men_nva_14"
#define O_MACHINEGUNNER_RPD "vn_o_men_nva_11"
#define O_SAPPER_K50 "vn_o_men_nva_09"
#define O_MEDIC_K50 "vn_o_men_nva_08"

#define FNC_ENSURE_SCHEDULED \
    if (!canSuspend) exitWith { \
        _this spawn (missionNamespace getVariable _fnc_scriptName); \
    }

#define VN_CAMPAIGN_VERSION 7580069
#define VN_CAMPAIGN_VERSION_STR #VN_CAMPAIGN_VERSION

 