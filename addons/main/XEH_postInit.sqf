#include "script_component.hpp"

// Advance the shared ALiVE simulation clock only while the game is running.
// On resume, establish a fresh baseline without counting the paused interval.
[{
    private _now = diag_tickTime;

    if (isGamePaused) then {
        ALiVE_isGamePaused = true;
    } else {
        if (!ALiVE_isGamePaused) then {
            ALiVE_simulationTime = ALiVE_simulationTime + (_now - ALiVE_simulationTimeLastUpdate);
        };

        ALiVE_isGamePaused = false;
    };

    ALiVE_simulationTimeLastUpdate = _now;
}, 0, []] call CBA_fnc_addPerFrameHandler;

//To be enabled when ZEUS is stable
PREPMAIN(ZEUSinit);
[] call ALIVE_fnc_ZEUSinit;

// 3DEN faction-sync validator registration lives in XEH_preInit - postInit
// doesn't fire in pure Eden-editor mode (no scenario = no post-init).

// HC naked-unit workaround (issue #604). When ALIVE_fnc_AI_Distributor
// transfers a group to a headless client via setGroupOwner, the engine
// occasionally resets affected units' loadouts to their config default -
// visibly stripping 3rd-party faction uniforms / gear back to vanilla.
// The server side snapshots each unit's loadout into the public variable
// ALiVE_HC_SavedLoadout before the transfer; this handler reapplies the
// snapshot on the receiving machine when the unit becomes local and
// appears naked (uniform == ""). Falls back to the class config default
// if no snapshot is available. Registered with the JIP flag so it
// attaches to every machine, including headless clients that join
// mid-mission. Mirrors the pattern in ACEX's acex_headless postInit.
["CAManBase", "Local", {
    params ["_unit", "_local"];
    if (_local && {uniform _unit == ""}) then {
        _unit setUnitLoadout (_unit getVariable ["ALiVE_HC_SavedLoadout", typeOf _unit]);
    };
}, true] call CBA_fnc_addClassEventHandler;

// Work out where every airfield's runways, taxiways and parking are, once, on
// the server, and broadcast the result, so that aircraft are not later parked or
// routed across an active runway. Parking in particular is inferred rather than
// declared by the game, and on some terrains it will resolve to nothing, which is
// why each airfield reports what was actually found.
//
// Only worth doing if ALiVE is actually running the mission. Everything that reads
// this comes from an ALiVE module, so on a mission with none placed the survey was
// pure cost, and on a map with several airfields that was seconds of stutter while
// loading for people who were only previewing terrain from the editor.
//
// Waits for the mission to start so terrain objects and any mission-authored
// runway tags exist to be found.
// The isNil guard matters here: this file is picked up live under file
// patching, but the function it calls only exists once the config carrying its
// CfgFunctions entry has been rebuilt. Without the guard, every mission started
// between the source edit and the rebuild throws an undefined variable error.
if (isServer) then {
    [] spawn {
        waitUntil {time > 0};
        if (isNil "ALiVE_fnc_buildAirsideCache") exitWith {
            diag_log "ALiVE airside: buildAirsideCache not compiled yet, airside exclusion inactive (addons/main needs a rebuild)";
        };
        // Modules are placed in the editor, so they exist long before the mission starts
        // running. Reading placement rather than waiting on their own start-up avoids
        // racing them. isKindOf walks the class hierarchy, so this finds any ALiVE module
        // whatever it is, without needing to know their names.
        if (((entities "Module_F") findIf {_x isKindOf "ModuleAliveBase"}) < 0) exitWith {
            diag_log "ALiVE airside: no ALiVE module placed, skipping the airfield survey";
        };
        
        // some external callers build the cache before this code is reached
        // gracefully exit if this has happened
        if (missionNamespace getVariable ["ALiVE_airsideCacheReady", false]) exitWith {};
        if (!isNil "ALiVE_airsideCacheBuilding") exitWith {};
        [] call ALiVE_fnc_buildAirsideCache;
    };
};

// A player who takes a Wallet (ID) from someone a task or a commander is about (ALiVE_fnc_giveTargetPapers),
// from his body or from him as a prisoner, is told who he was
if (hasInterface) then {
    ["CAManBase", "Take", {
        params ["_unit", "_container", "_item"];
        if (_item != "Wallet_ID" || {_unit != player}) exitWith {};
        // the container is his body, his uniform or vest, or the ground by him: the owner is the man there who
        // carries an identity and no longer has his wallet
        private _from = [_container, objectParent _container] + (nearestObjects [_unit, ["CAManBase"], 6]);
        private _i = _from findIf { !isNull _x && {_x != _unit} && {!isNil {_x getVariable "ALiVE_targetIdentity"}} && {!("Wallet_ID" in magazines _x)} };
        if (_i < 0) exitWith {};
        ((_from select _i) getVariable "ALiVE_targetIdentity") params ["_name", "_role", ["_arg", ""]];
        [localize "STR_ALIVE_TARGETID_TITLE", format [localize "STR_ALIVE_TARGETID_TEXT", _name, format [localize _role, _arg]]] call ALIVE_fnc_sendHint;
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

// Wider task list (Jman, 30 Oct): the map screen's list of tasks and diary pages is 10 grid units wide, so a task name
// such as "Intercept Communications near Kavala" was cut off. While the map is open, the list (and the Players page's
// header row in the same column) is kept 4 units wider and the text pane beside it 4 units further right. Checked twice
// a second, as the game may lay the screen out again when a page is opened. ALiVE > Game > Wider task list turns it off.
if (hasInterface) then {
    addMissionEventHandler ["Map", {
        params ["_open"];
        if (!_open || {!(missionNamespace getVariable ["ALiVE_prefWideTaskList", true])}) exitWith {};
        if (!isNil "ALiVE_wideTaskListLoop" && {!scriptDone ALiVE_wideTaskListLoop}) exitWith {};
        ALiVE_wideTaskListLoop = [] spawn {
            waitUntil { visibleMap || {!isNull findDisplay 12} };
            private _w = ((safezoneW / safezoneH) min 1.2) / 40;
            private _more = 4;
            // [idc, x in grid units from the left of the safe zone or -1 to keep, width in grid units or -1 to keep]
            private _layout = [
                [1022, -1, 10 + _more], [1002, -1, 10 + _more], [117, -1, 8.6 + _more],
                [118, 15 + _more, -1], [119, 15.8 + _more, -1],
                [1023, 17.4 + _more, -1], [1013, 17.4 + _more, -1]
            ];
            while { visibleMap && {missionNamespace getVariable ["ALiVE_prefWideTaskList", true]} } do {
                private _d = findDisplay 12;
                if (!isNull _d) then {
                    {
                        _x params ["_idc", "_gx", "_gw"];
                        private _c = _d displayCtrl _idc;
                        if (!isNull _c) then {
                            private _p = ctrlPosition _c;
                            private _x0 = if (_gx < 0) then { _p select 0 } else { safezoneX + _gx * _w };
                            private _w0 = if (_gw < 0) then { _p select 2 } else { _gw * _w };
                            if (abs ((_p select 0) - _x0) > 0.0005 || {abs ((_p select 2) - _w0) > 0.0005}) then {
                                _c ctrlSetPosition [_x0, _p select 1, _w0, _p select 3];
                                _c ctrlCommit 0;
                            };
                        };
                    } forEach _layout;
                };
                sleep 0.5;
            };
        };
    }];
};

//Automated tests (define in script_mod.hpp)
#ifdef AUTOMATED_TESTS
[AUTOMATED_TESTS] spawn {

        //Wait for game to run
        waituntil {time > 0};

        {
            if !([_x] call ALiVE_fnc_isModuleAvailable) then {
                private _test = execVM format["\x\alive\addons\%1\tests\test.sqf",_x];
                waituntil {scriptdone _test};
            } else {
                ["Automated Tests: %1 already existing! Exiting test...",_x] call ALiVE_fnc_dumpH;
            };
        } foreach _this;
};
#endif
