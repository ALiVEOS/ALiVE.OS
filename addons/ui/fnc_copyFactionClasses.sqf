private _objects = param [0, []];
private _factions = [];

{
    private _faction = faction _x;
    _factions pushbackunique _faction;
} forEach _objects;

copyToClipboard str _factions;