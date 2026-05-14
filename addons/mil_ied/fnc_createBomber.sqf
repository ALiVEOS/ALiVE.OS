#include "\x\alive\addons\mil_IED\script_component.hpp"
SCRIPT(createBomber);

// Suicide Bomber - create Suicide Bomber at location
private ["_location","_debug","_victim","_size","_faction","_bomber"];

if !(isServer) exitWith {diag_log "Suicide Bomber Not running on server!";};

_victim = objNull;

if (typeName (_this select 0) == "ARRAY") then {
    _location = (_this select 0) select 0;
    _size = (_this select 0) select 1;
    _faction = (_this select 0) select 2;
} else {
    _bomber = _this select 0;
};

_victim = (_this select 1) select 0;

_debug = ADDON getVariable ["debug", false];

if(isnil "_debug") then {_debug = false};

// Create suicide bomber
private ["_grp","_side","_pos","_time","_marker","_class","_btype"];

if (isNil "_bomber") then {
    _pos = [_location, 0, _size - 10, 3, 0, 0, 0] call BIS_fnc_findSafePos;
    _side = _faction call ALiVE_fnc_factionSide;
    _grp = createGroup _side;
    _btype = ADDON getVariable ["Bomber_Type", ""];
    if ( isNil "_btype" || _btype == "") then {
        _class = ([[_faction], 1, ALiVE_MIL_CQB_UNITBLACKLIST, false] call ALiVE_fnc_chooseRandomUnits) select 0;
        if (isNil "_class") then {
            _class = ([[_faction], 1, ALiVE_MIL_CQB_UNITBLACKLIST, true] call ALiVE_fnc_chooseRandomUnits) select 0;
        };
    } else {
        _class = (selectRandom (parseSimpleArray (ADDON getVariable "Bomber_Type")));
    };
    if (isNil "_class") exitWith {diag_log "No bomber class defined."};
    _bomber = _grp createUnit [_class, _pos, [], _size, "NONE"];

    // ["SURFACE %1, %2", surfaceIsWater (position _bomber), (position _bomber)] call ALiVE_fnc_dump;
    if (surfaceIsWater (position _bomber)) exitWith { deleteVehicle _bomber; diag_log "Bomber pos was in water, aborting";};
};

if (isNil "_bomber") exitWith {};

// Flag nearby civilians with ALiVE_CivPop_InsurgentContact for the
// amb_civ_population "Pressure" dialog question (read in
// fnc_questionHandler.sqf to drive the "yes, someone's been pressuring
// me" branch). Specific-event slice complementing mil_opcom's
// installation-ambient sweep (commit 047ec753): mil_opcom flags civs
// near INS-controlled installations (ambient presence); this flags
// civs near a discrete bomber event ("a bomber was lurking here just
// before the strike").
//
// 25m sweep matches the typical urban civilian crowd radius. nearEntities
// returns only physical (spawned) Man entities -- virtualised civilians
// aren't present in the world and correctly excluded; they didn't
// witness the bomber.
//
// isNil getVariable check preserves the earliest flag-time semantics
// (no overwrites). public=true so the per-client dialog handler sees
// the flag.
private _civFlagged = 0;
{
    if (
        side _x == civilian
        && {!isPlayer _x}
        && {!(_x getVariable ["ALiVE_CivPop_InsurgentContact", false])}
    ) then {
        _x setVariable ["ALiVE_CivPop_InsurgentContact", true, true];
        _civFlagged = _civFlagged + 1;
    };
} forEach ((getPos _bomber) nearEntities ["CAManBase", 25]);

if (_debug) then {
    diag_log format ["ALIVE-%1 Suicide Bomber InsurgentContact sweep: %2 civilian(s) flagged within 25m of %3",
        time, _civFlagged, getPos _bomber];
};

// Exclude bomber from AdvCiv brain loop so the ambient civilian AI
// does not override the pursuit behaviour set below.
// ALiVE_advciv_blacklist is the established mechanism used by both
// isMissionCritical and isValidCiv - setting it prevents registration.
_bomber setVariable ["ALiVE_advciv_blacklist", true, true];
// Also remove from active units list if already registered before this ran
if (!isNil "ALiVE_advciv_activeUnits") then {
    ALiVE_advciv_activeUnits = ALiVE_advciv_activeUnits - [_bomber];
};

// Add radio, suicide vest and charge
// Vest class is configurable via Bomber_Vest module parameter; falls back to default.
// Accepts either a single classname or a comma-separated list e.g.
// "V_ALiVE_Suicide_Vest,V_Chestrig_khk,V_BandollierBag_cbr"
// When multiple classes are provided one is chosen at random per bomber.
private _vestRaw = ADDON getVariable ["Bomber_Vest", "V_ALiVE_Suicide_Vest"];
if (isNil "_vestRaw" || _vestRaw == "") then { _vestRaw = "V_ALiVE_Suicide_Vest"; };
private _vestList = [_vestRaw, " ", ""] call CBA_fnc_replace;   // strip spaces
_vestList = [_vestList, ","] call CBA_fnc_split;               // split on comma
private _vestClass = selectRandom _vestList;
_bomber addweapon (selectRandom ["ItemRadio","ItemALiVEPhoneOld"]);
removeVest _bomber;
_bomber addVest _vestClass;
_bomber addItemToVest "DemoCharge_Remote_Mag";

// Select victim - resolve to an actual infantry unit from the triggering group
// _victim at this point is the first unit from thisList (may be a vehicle)
// Unwrap to the actual person and pick a random squadmate
if (isNil "_victim" || {isNull _victim}) exitWith { deleteVehicle _bomber; };
private _victimUnit = if (vehicle _victim != _victim) then { driver (vehicle _victim) } else { _victim };
_victim = selectRandom (units (group _victimUnit));
if (isNil "_victim" || {isNull _victim}) exitWith { deleteVehicle _bomber; };

// Add debug marker
if (_debug) then {
    diag_log format ["ALIVE-%1 Suicide Bomber: created at %2 going after %3", time, _pos, name _victim];
};

[_victim,_bomber, _pos] spawn {

    private["_victim","_bomber","_debug","_marker","_shell","_pos","_time","_timer"];

    _victim = _this select 0;
    _bomber = _this select 1;
    _pos = _this select 2;
    sleep (random 60);

    // Enable combat behaviour so the bomber actively moves
    _bomber setBehaviour "COMBAT";
    _bomber setCombatMode "RED";
    _bomber setUnitPos "MIDDLE";

    // Have bomber go after victim for up to 10 minutes
    _time = time + 600;
    _timer = time;
    waitUntil {

        if (!isNil "_victim" && {!isNull _victim} && {time - _timer > 15}) then {
            // doMove must execute on the machine where the bomber is local.
            // remoteExec ensures the order reaches the correct locality.
            [_bomber, getpos _victim] remoteExecCall ["doMove", _bomber];
            diag_log format ["ALIVE-%1 Suicide Bomber: moving to %2", time, getpos _victim];
            if (ADDON getVariable ["debug",false]) then {
                _marker = _bomber getVariable ["marker", nil];
                if (isNil "_marker" || {!(_marker in allMapMarkers)}) then {
                    private ["_markers"];
                    _marker = [format ["suic_%1", random 1000], position _bomber , "Icon", [1,1], "TEXT:", "Suicide", "TYPE:", "mil_dot", "COLOR:", "ColorRed", "GLOBAL"] call CBA_fnc_createMarker;
                    _bomber setVariable ["marker", _marker];
                } else {
                    _marker setmarkerpos position _bomber;
                };
            } else {
                 _marker = _bomber getVariable ["marker", ""];
                [_marker] call CBA_fnc_deleteEntity;
            };
            _timer = time;
        };

        sleep 1;

        (isNil "_victim") ||
        {isNull _victim} ||
        {!(alive _victim)} ||
        {isNil "_bomber"} ||
        {isNull _bomber} ||
        {!(alive _bomber)} ||
        {_bomber distance _victim < 8} ||
        {time > _time}
    };

    if ((isNil "_bomber") || {isNull _bomber} || {!(alive _bomber)}) exitWith {};
    if ((isNil "_victim") || {isNull _victim} || {!(alive _victim)}) exitWith {deleteVehicle _bomber;};

    // Blow up bomber
    if ((_bomber distance _victim < 8) && (alive _bomber)) then {
        [_bomber, "Alive_Beep", 50] call CBA_fnc_globalSay3d;

        // Immediately lock AI and strip the vest so the player cannot
        // confiscate the charge during the detonation countdown.
        // disableAI must happen before sleep.
        _bomber disableAI "ANIM";
        _bomber disableAI "MOVE";
        _bomber disableAI "FSM";
        removeVest _bomber;

        _bomber playMoveNow "AmovPercMstpSsurWnonDnon";
        sleep 5;

        // Detonate regardless - the vest has already been stripped so
        // there is nothing to confiscate. The 10% dud chance is removed:
        // a bomber who reached the target and armed should always detonate.
        _shell = [["M_Mo_120mm_AT","M_Mo_120mm_AT_LG","M_Mo_82mm_AT_LG","R_60mm_HE","Bomb_04_F","Bomb_03_F"],[8,4,2,1,1,1]] call BIS_fnc_selectRandomWeighted;
        _shell createVehicle [(getpos _bomber) select 0, (getpos _bomber) select 1, 0];
        diag_log format ["ALIVE-%1 Suicide Bomber: DETONATED at %2", time, getpos _bomber];
        sleep 0.3;
        deletevehicle _bomber;

        if (ADDON getVariable ["debug", false]) then {
            diag_log format ["BANG! Suicide Bomber %1", _bomber];
            [_marker] call CBA_fnc_deleteEntity;
        };
    } else {
        sleep 1;
        if (ADDON getVariable ["debug", false]) then {
            diag_log format ["Ending Suicide Bomber %1 as out of time or dead.", _bomber];
            _marker = _bomber getVariable ["marker", ""];
            [_marker] call CBA_fnc_deleteEntity;
        };
        if ((random 100) > 50) then {
            // Dead man switch - bomber timed out or victim died, detonate anyway
            _shell = [["M_Mo_120mm_AT","M_Mo_120mm_AT_LG","M_Mo_82mm_AT_LG","R_60mm_HE","Bomb_04_F","Bomb_03_F"],[8,4,2,1,1,1]] call BIS_fnc_selectRandomWeighted;
            _shell createVehicle [(getpos _bomber) select 0, (getpos _bomber) select 1,0];
            diag_log format ["ALIVE-%1 Suicide Bomber: dead man switch DETONATED at %2", time, getpos _bomber];
            sleep 0.3;
            deletevehicle _bomber;
        } else {
            // Bomb didn't go off - delete the bomber cleanly rather than
            // leaving an armed civilian unit alive in the world indefinitely
            diag_log format ["ALIVE-%1 Suicide Bomber: dead man switch FAILED, removing bomber at %2", time, getpos _bomber];
            deletevehicle _bomber;
        };
    };
};
