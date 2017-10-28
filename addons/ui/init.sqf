#include "\x\alive\addons\ui\script_component.hpp"

if (isDedicated) exitWith {false};


// list of all menu activation keys and associated types
GVAR(typeMenuSources) = [];
// prevent instant reactivation of menu after selection was made, while key still held down. Value is reset upon key release.
GVAR(optionSelected) = false;
// prevent multiple activations of menu due to key press via keyDown. onLoad can sometimes take a few milliseconds to init.
GVAR(lastAccessTime) = 0;

true
