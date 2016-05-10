private ["_casConfirmButton", "_casArray", "_veh"];
_casConfirmButton = _display displayCtrl 655585;
_casUnitLb = _display displayCtrl 655582;
_casTaskLb = _display displayCtrl 655587;
_casArray = NEO_radioLogic getVariable format ["NEO_radioCasArray_%1", playerSide];
_veh = _casArray select (lbCurSel _casUnitLb) select 0;

if
(
	!isNil { uinamespace getVariable "NEO_casMarkerCreated" }
	&&
	_veh getVariable "NEO_radioCasUnitStatus" != "KILLED"
	&&
	lbCurSel _casUnitLb != -1
	&&
	lbCurSel _casTaskLb != -1
)
then
{
	_casConfirmButton ctrlEnable true;
}
else
{
	_casConfirmButton ctrlEnable false;
};
