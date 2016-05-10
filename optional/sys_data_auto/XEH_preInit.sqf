// #define DEBUG_MODE_FULL
#include "script_component.hpp"

// https://dev-heaven.net/projects/cca/wiki/Extended_Eventhandlers#New-in-19-version-stringtable-and-pre-init-EH-code
// https://dev-heaven.net/projects/cca/wiki/Extended_Eventhandlers#New-in-200-Support-for-ArmA-II-serverInit-and-clientInit-entries

LOG(MSG_INIT);

// Auto enable the data module
if (isDedicated) then {
	[] call ALiVE_fnc_DataInit;
};
