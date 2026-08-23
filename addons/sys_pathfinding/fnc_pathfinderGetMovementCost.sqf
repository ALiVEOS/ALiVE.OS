    private _args = _this;
    private "_result";
    _args params ["_currentSector","_goalSector","_size"];
    if (
        ((_currentSector select 0) select 0) != ((_goalSector select 0) select 0) &&
        { ((_currentSector select 0) select 1) != ((_goalSector select 0) select 1) }
    ) then {
        _result = 1.414 * _size;
    } else {
        _result = 1.0 * _size;
    };
    _result
