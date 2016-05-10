disableSerialization;

private ["_display", "_supportLb", "_supportIndex"];
_display = findDisplay 655555;
_supportLb = _display displayCtrl 655565;
_supportIndex = _this select 0;

lbSetCurSel [655565, _supportIndex];

