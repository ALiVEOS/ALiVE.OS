params ["_grid"];

private _sectors = [_grid,"sectors"] call ALiVE_fnc_hashGet;
private _gridWidth = [_grid,"gridWidth"] call ALiVE_fnc_hashGet;
private _gridHeight = _gridWidth;

{
    _x params ["_index","_sector"];

    _index params ["_sectorX","_sectorY"];
    
    private _sectorNeighbors = _sector select 5;

    if (_sectorX > 0) then {
        // left
        _neighbors pushback (_sectors get [_sectorX - 1, _sectorY]);

        // bot left corner
        if (_sectorY > 0) then {
            _neighbors pushback (_sectors get [_sectorX - 1, _sectorY - 1]);
        };

        // top left corner
        if (_sectorY < _gridHeight - 1) then {
            _neighbors pushback (_sectors get [_sectorX - 1, _sectorY + 1]);
        };
    };

    if (_sectorX < _gridWidth - 1) then {
        // right
        _neighbors pushback (_sectors get [_sectorX + 1, _sector select 1]);

        // bot right corner
        if (_sectorY > 0) then {
            _neighbors pushback (_sectors get [_sectorX + 1, _sectorY - 1]);
        };

        // top right corner
        if (_sectorY < _gridHeight - 1) then {
            _neighbors pushback (_sectors get [_sectorX + 1, _sectorY + 1]);
        };
    };

    // bot
    if (_sectorY > 0) then {
        _neighbors pushback (_sectors get [_sectorX, _sectorY - 1]);
    };

    // top
    if (_sectorY < _gridHeight - 1) then {
        _neighbors pushback (_sectors get [_sectorX, _sectorY + 1]);
    };
} foreach _sectors;