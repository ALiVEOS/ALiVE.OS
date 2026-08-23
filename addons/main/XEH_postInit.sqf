#include "script_component.hpp"

// Advance the shared ALiVE simulation clock only while the game is running.
// On resume, establish a fresh baseline without counting the paused interval.
[{
    private _now = diag_tickTime;

    if (isGamePaused) then {
        ALiVE_simulationTimeHandler set ["paused", true];
    } else {
        private _wasPaused = ALiVE_simulationTimeHandler get "paused";
        if (!_wasPaused) then {
            private _timeLastUpdate = ALiVE_simulationTimeHandler get "timeLastUpdate";
            private _simulationTime = ALiVE_simulationTimeHandler get "tickTime";
            ALiVE_simulationTimeHandler set ["tickTime", _simulationTime + (_now - _timeLastUpdate)];
        };

        ALiVE_simulationTimeHandler set ["paused", false];
    };

    ALiVE_simulationTimeHandler set ["timeLastUpdate", _now];
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
        [] call ALiVE_fnc_buildAirsideCache;
    };
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
