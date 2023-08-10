private ["_display", "_button", "_artyMoveButton", "_artyDontMoveButton", "_artyUnitLb", "_artyArray", "_battery"];
_display = findDisplay 655555;
_button = _this select 0;
_artyMoveButton = _display displayCtrl 655606;
_artyDontMoveButton = _display displayCtrl 655607;
_artyUnitLb = _display displayCtrl 655594;

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

_battery = _artyArray select (lbCurSel _artyUnitLb) select 0; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _battery = ((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 0 };

if (_button == _artyMoveButton) then
{
    _battery setVariable ["NEO_radioArtyMove", true, true];
    [player, "Copy that, move into a good fire position. Over.", "group"] call NEO_fnc_messageBroadcast;
}
else
{
    _battery setVariable ["NEO_radioArtyDontMove", true, true];
    [player, "Negative, hold position. Over.", "group"] call NEO_fnc_messageBroadcast;
};

//Interface
[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
