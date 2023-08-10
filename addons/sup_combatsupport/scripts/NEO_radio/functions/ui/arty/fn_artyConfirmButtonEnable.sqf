private
[
    "_display", "_artyArray", "_artyConfirmButton", "_artyUnitLb", "_artyOrdnanceTypeLb", "_artyRateOfFireLb",
    "_artyRoundCountLb", "_battery", "_status"
];
_display = findDisplay 655555;

  	    _has_SPE_leFH18 = false;
  	    {
  	    	if(_x select 1 == "SPE_leFH18") then {
  	    		_has_SPE_leFH18 = true;
  	    	}
  	    } forEach SUP_ARTYARRAYS;
  
        _artyArray = []; 
        _artyArray append (NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", playerSide]);
 
	      if (_has_SPE_leFH18) then { 
	      	if (playerSide != WEST) then {
	        _artyArray append (NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", WEST]);
	        };
	      };

_artyConfirmButton = _display displayCtrl 655597;
_artyUnitLb = _display displayCtrl 655594;
_artyOrdnanceTypeLb = _display displayCtrl 655601;
_artyRateOfFireLb = _display displayCtrl 655603;
_artyRoundCountLb = _display displayCtrl 655605;
_battery = _artyArray select (lbCurSel _artyUnitLb) select 0; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _battery = ((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 0 };
_status = _battery getVariable "NEO_radioArtyUnitStatus";

if
(
    !isNil { uinamespace getVariable "NEO_artyMarkerCreated" }
    &&
    _status != "KILLED"
    &&
    _status != "MISSION"
    &&
    _status != "RTB"
    &&
    lbCurSel _artyUnitLb != -1
    &&
    lbCurSel _artyOrdnanceTypeLb != -1
    &&
    lbCurSel _artyRateOfFireLb != -1
    &&
    lbCurSel _artyRoundCountLb != -1
)
then
{
    _artyConfirmButton ctrlEnable true;
}
else
{
    _artyConfirmButton ctrlEnable false;
};
