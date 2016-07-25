private _objects = param [0, []];

private _newLine = toString [13,10];
private _factions = "";

{
    private _faction = faction _x;
    if (_forEachIndex != 0) then {_factions = _factions + _newLine};
    _factions = _factions + _faction;
} forEach _objects;

copyToClipboard _factions;
