#include "script_component.hpp"

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