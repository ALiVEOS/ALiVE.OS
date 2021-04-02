private ["_var","_type"];

_var = _this select 0;
_type = _this select 1;

["MenuButton: %1", _var] call ALiVE_fnc_dump;
["_type: %1", _type] call ALiVE_fnc_dump;

switch _type do
{
    case "text":
    {
    _return = getText(configfile >> "ALiVE_UserConfig" >> _var)

    };
["MenuButton: %1", _return] call ALiVE_fnc_dump;
    case "number":
    {
    _return = getNumber(configfile >> "ALiVE_UserConfig" >> _var)
    };
    missionNamespace setVariable [_var,_return];
    //call compile format ["%1 = %2", _var,_return];
_return
}
