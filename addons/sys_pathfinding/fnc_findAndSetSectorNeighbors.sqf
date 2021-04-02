params ["_grid"];

private _sectors = [_grid,"sectors"] call ALiVE_fnc_hashGet;

{
    _x params ["_sectorX","_sectorY"];

    private _spots = [
        [_sectorX - 1, _sectorY],           // left
        [_sectorX - 1, _sectorY + 1],       // top left
        [_sectorX, _sectorY + 1],           // top
        [_sectorX + 1, _sectorY + 1],       // top right
        [_sectorX + 1, _sectorY + 1],       // right
        [_sectorX + 1, _sectorY - 1],       // bot right
        [_sectorX, _sectorY - 1],           // bot
        [_sectorX - 1, _sectorY - 1]        // bot left
    ];
    private _abcd = _spots select {
        !isnil {_sectors get _x}
    };

    _y set [5, _abcd];
} foreach _sectors;