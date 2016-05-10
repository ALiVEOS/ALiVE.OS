#include "script_component.hpp"

//To be enabled when ZEUS is stable
PREPMAIN(ZEUSinit);
[] call ALIVE_fnc_ZEUSinit;


//ALiVE Loading screen
[] spawn {
    //If ALiVE_Require isnt placed or not client exit
    if (!(["ALiVE_require"] call ALiVE_fnc_isModuleAvailable)) exitwith {};

    //Start ALiVE loading screen
	["ALiVE_LOADINGSCREEN"] call BIS_fnc_startLoadingScreen;
    
    //Wait until ALiVE require module has loaded and end loading screen
    waituntil {!isnil "ALiVE_REQUIRE_INITIALISED"};
    ["ALiVE_LOADINGSCREEN"] call BIS_fnc_EndLoadingScreen;
};

//Automated tests (define in script_mod.hpp)
#ifdef AUTOMATED_TESTS
[AUTOMATED_TESTS] spawn {
        
        //Wait for game to run
        waituntil {time > 0};
        
        {
            if !([_x] call ALiVE_fnc_isModuleAvailable) then {
	            _test = execVM format["\x\alive\addons\%1\tests\test.sqf",_x];
	            waituntil {scriptdone _test};
            } else {
                ["ALiVE Automated Tests: %1 already existing! Exiting test...",_x] call ALiVE_fnc_DumpH;
            };
        } foreach _this;
};
#endif