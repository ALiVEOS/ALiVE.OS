/*
    NEO_fnc_artyCmdrBoard
    Commander's guns (F509): the tablet's read of the AI Commander's batteries for the player's side,
    as the server publishes them on NEO_radioLogic (fnc_combatSupport.sqf, every 10 s). Client side,
    reads only. Each board entry: [position, reach, minimum reach, kind, ordnance, rounds per mission, ready].

    ["board"]                -> the entries, or [] when the setting is Off or nothing is published
    ["available"]            -> true when there is at least one entry
    ["selected"]             -> true when the tablet's Artillery list has the Commander's guns row selected
    ["ordnance"]             -> the ordnance any entry can fire, HE, SMOKE, ILLUM order
    ["roundsCap"]            -> the most rounds any entry fires in one mission
    ["inRange", [pos, ord]]  -> true when a ready entry can fire that ordnance at pos
    ["inReach", [pos]]       -> true when any entry, ready or not, reaches pos
    ["nearest", [pos]]       -> the entry nearest pos, or []

    Author: Jman
*/
params [["_op", ""], ["_args", []]];

private _fnc_board = {
    if (isNil "NEO_radioLogic") exitWith { [] };
    if ((NEO_radioLogic getVariable ["combatsupport_artycommander", 0]) isEqualTo 0) exitWith { [] };
    NEO_radioLogic getVariable [format ["NEO_radioCmdrArtyBoard_%1", playerSide], []]
};
private _fnc_reaches = {
    params ["_e", "_pos"];
    private _d = _pos distance2D (_e select 0);
    _d < (_e select 1) && {_d > (_e select 2)}
};

switch (_op) do {
    case "board": { call _fnc_board };
    case "available": { (call _fnc_board) isNotEqualTo [] };
    case "selected": {
        private _d = findDisplay 655555;
        if (isNull _d) exitWith { false };
        private _lb = _d displayCtrl 655594;
        private _sel = lbCurSel _lb;
        _sel >= 0 && {(_lb lbData _sel) == "CMDR"}
    };
    case "ordnance": {
        private _all = [];
        { _all append (_x select 4) } forEach (call _fnc_board);
        ["HE", "SMOKE", "ILLUM"] select { _x in _all }
    };
    case "roundsCap": {
        private _cap = 0;
        { _cap = _cap max (_x select 5) } forEach (call _fnc_board);
        _cap
    };
    case "inRange": {
        _args params [["_pos", [0,0,0]], ["_ord", "HE"]];
        ((call _fnc_board) findIf { (_x select 6) && {_ord in (_x select 4)} && {[_x, _pos] call _fnc_reaches} }) > -1
    };
    case "inReach": {
        _args params [["_pos", [0,0,0]]];
        ((call _fnc_board) findIf { [_x, _pos] call _fnc_reaches }) > -1
    };
    case "nearest": {
        _args params [["_pos", [0,0,0]]];
        private _best = [];
        private _bestD = 1e9;
        {
            private _d = _pos distance2D (_x select 0);
            if (_d < _bestD) then { _best = _x; _bestD = _d };
        } forEach (call _fnc_board);
        _best
    };
    default { nil };
};
