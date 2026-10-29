#include "script_component.hpp"

// Zeus lists a module only when the curator has its addon. Nothing from this addon is placed in
// Eden, so a Game Master limited to the mission's own addons would never offer these modules.
// The server adds the addon to every curator, including ones made or assigned later.
if (isServer) then {
    [] spawn {
        while {true} do {
            { if ((curatorAddons _x) findIf {_x == QUOTE(ADDON)} == -1) then { _x addCuratorAddons [QUOTE(ADDON)] } } forEach allCurators;
            sleep 15;
        };
    };
};
