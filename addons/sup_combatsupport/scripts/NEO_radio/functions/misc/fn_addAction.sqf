    private["_object","_args"];
    _object = _this select 0;
    _args = _this select 1;
    
    if(isNull _object) exitWith {};

    _object addaction _args;

