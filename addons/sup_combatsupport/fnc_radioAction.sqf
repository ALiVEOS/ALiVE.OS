#include "script_component.hpp"

//Action Variable
uinamespace setVariable ["NEO_radioCurrentAction", (_this select 0)];

//Open Interface

["NEO_resourceRadio"] call ALiVE_fnc_tabletOpen;

// Back only means something where there is a C2ISTAR menu to go back to
((findDisplay 655555) displayCtrl 655598) ctrlShow !(isNil "ALiVE_c2istar_fnc_backToMenu");
