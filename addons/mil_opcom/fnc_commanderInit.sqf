private _logic = _this select 0;

if (isnil "ALiVE_COMMANDERS") then {
    ALiVE_COMMANDERS = [];
};

private _moduleID = [_logic, true] call ALiVE_fnc_dumpModuleInit;
glogic = _logic;
private _commander = [_logic,"init"] call ALiVE_fnc_commander;

if (isnil "ALiVE_commanderHandler") then {
    ALiVE_commanderHandler = [nil,"create"] call ALiVE_fnc_commanderHandler;
    [ALiVE_commanderHandler,"init"] call ALiVE_fnc_commanderHandler;
};

[ALiVE_commanderHandler,"registerCommander", _commander] call ALiVE_fnc_commanderHandler;

[_logic, false, _moduleID] call ALiVE_fnc_dumpModuleInit;