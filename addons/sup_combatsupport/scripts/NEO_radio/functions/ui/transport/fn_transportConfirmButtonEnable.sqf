private ["_transportConfirmButton", "_transportTaskLb", "_transportArray", "_chopper"];
_transportConfirmButton = _display displayCtrl 655574;
_transportUnitLb = _display displayCtrl 655568;
_transportTaskLb = _display displayCtrl 655569;
_transportArray = NEO_radioLogic getVariable format ["NEO_radioTrasportArray_%1", playerSide];
_chopper = _transportArray select (lbCurSel _transportUnitLb) select 0; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithPilot" }) then { _chopper = vehicle player };

if
(
	!isNil { uinamespace getVariable "NEO_transportMarkerCreated" }
	&&
	_chopper getVariable "NEO_radioTrasportUnitStatus" != "KILLED"
	&&
	lbCurSel _transportUnitLb != -1
	&&
	lbCurSel _transportTaskLb != -1
)
then
{
	_transportConfirmButton ctrlEnable true;
}
else
{
	_transportConfirmButton ctrlEnable false;
};
