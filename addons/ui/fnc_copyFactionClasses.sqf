private _objects = param [0, []];
private _factions = [];

{
    private _faction = faction _x;
    _factions pushbackunique _faction;
} forEach _objects;

copyToClipboard str _factions;

// Say something. This was the one clipboard function here that reported nothing
// at all, which is why nobody noticed it had stopped working: a menu entry that
// silently does nothing and one that silently succeeds look identical.
//
// hint is not used, because the editor does not draw hints, and this is called
// from the editor's right click menu.
["ALiVE - copied %1 faction class(es) to the clipboard from %2 selected object(s): %3",
    count _factions, count _objects, _factions] call ALiVE_fnc_dump;

if (is3DEN) then {
    private _msg = if (_factions isEqualTo []) then {
        "ALiVE: nothing selected has a faction, so nothing was copied."
    } else {
        format ["ALiVE: %1 faction class(es) copied to the clipboard. %2", count _factions, _factions joinString ", "]
    };
    [_msg, [0, 1] select (_factions isEqualTo []), 20] call BIS_fnc_3DENNotification;
};
