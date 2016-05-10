private ["_var","_type"];

_var = _this select 0;
_type = _this select 1;

diag_log format["MenuButton: %1", _var];
diag_log format["_type: %1", _type];

switch _type do
{
	case "text":
	{
	_return = getText(configfile >> "ALiVE_UserConfig" >> _var)

	};
diag_log format["MenuButton: %1", _return];
	case "number":
	{
	_return = getNumber(configfile >> "ALiVE_UserConfig" >> _var)
	};
	call compile format ["%1 = %2", _var,_return];
_return
}
