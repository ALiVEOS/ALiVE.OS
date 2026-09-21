#include "script_component.hpp"
SCRIPT(menuKeys);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_menuKeys

Description:
Every key somebody has bound to an ALiVE action, in the form the menu system
wants, so that binding the ALiVE menu to a combination with Shift, Ctrl or Alt
in it actually works.

This exists because of a long standing complaint that remapping the ALiVE menu
key does nothing, which was reported for years and read as people getting it
wrong. It was not. Every module installed its menu like this:

    [((["ALiVE", "openMenu"] call CBA_fnc_getKeybind) select 5) select 0]

Element 5 is the FIRST keybind only, and select 0 takes the key code and throws
the modifiers away. CBA's menu system then treats a bare code as "this key with
no modifiers", and it matches modifiers exactly
(cba\addons\ui\flexiMenu\fnc_keyDown.sqf), so a menu bound to Ctrl and something
could never open however many times anybody restarted. What made it look like a
setting that half worked is that the keybind's own code plays a sound, and the
sound DOES fire on the combination, so you heard a click and got no menu.

Three more faults came free with that expression, all fixed by reading the whole
list instead of the first element of the first entry:

  - a second key added rather than substituted was ignored, and CBA's own
    dialog invites you to add to a list.
  - clearing the binding left element 5 as [-1, [false, false, false]], so the
    menu was installed on key -1 and could never be pressed, silently.
  - nothing checked whether the action was registered at all.

Parameters:
    _action - STRING - the action name registered with CBA, "openMenu" by default

Returns:
    ARRAY - of [DIK code, [shift, ctrl, alt]], ready for CBA_fnc_flexiMenu_Add.
            Empty when nothing usable is bound, which the caller should treat as
            "install no menu" rather than as a key.

Examples:
    (begin example)
    private _keys = [] call ALiVE_fnc_menuKeys;
    ["player", _keys, -9500, ["call ALIVE_fnc_C2MenuDef", ["main", "..."]]] call CBA_fnc_flexiMenu_Add;
    (end)

See Also:
    CBA_fnc_getKeybind, CBA_fnc_flexiMenu_Add

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_action", "openMenu", [""]]];

// A machine with no screen has no keys, and CBA says so by returning nothing.
// Leaving before the check below keeps a dedicated server's log clear of a
// complaint about a keybind nobody there could press anyway.
if (!hasInterface) exitWith { [] };

private _entry = ["ALiVE", _action] call CBA_fnc_getKeybind;
if (isNil "_entry") exitWith {
    ["ALiVE_fnc_menuKeys - nothing is registered under ALiVE %1, so no key is returned", _action] call ALiVE_fnc_dump;
    []
};

// Element 8 is every binding, each already [code, [shift, ctrl, alt]], which is
// exactly the shape the menu system takes. Element 5, which this used to read,
// is only the first of them.
private _keys = (_entry param [8, []]) select {
    _x isEqualType []
        && {count _x > 0}
        && {(_x select 0) isEqualType 0}
        // Anything at or below Escape is CBA's way of saying nothing is bound.
        && {(_x select 0) > 1}
};

if (count _keys == 0) then {
    ["ALiVE_fnc_menuKeys - ALiVE %1 has no key bound to it, so its menu is not being installed. Set one under Configure Addons, Keybinds, ALiVE.", _action] call ALiVE_fnc_dump;
};

_keys
