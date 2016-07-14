private _objects = param [0, []];
private _factions = [];

{
    private _faction = faction _x;
    if (!(_faction in _factions)) then {
        _factions pushBack _faction;
    };
} forEach _objects;

copyToClipboard (str _factions);
