#include <script_component.hpp>

LOG(MSG_INIT);

//Set ALiVE Interaction menu on custom userkey 20 and if none is defined fallback to 221 App key
if ((count ActionKeys "User20") > 0) then {
	SELF_INTERACTION_KEY = [(ActionKeys "User20" select 0),[false,false,false]];
} else {
	SELF_INTERACTION_KEY = [221,[false,false,false]];
};

["ALiVE","openMenu", "Open Menu (Requires Restart)", {playsound "HintCollapse"}, {}, SELF_INTERACTION_KEY] call CBA_fnc_addKeybind;
