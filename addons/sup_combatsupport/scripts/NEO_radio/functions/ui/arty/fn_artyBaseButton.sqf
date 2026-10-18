private ["_display", "_artyUnitLb", "_artyArray", "_battery", "_callsign", "_callSignPlayer"];
_display = findDisplay 655555;
_artyUnitLb = _display displayCtrl 655594;

  	    _has_SPE_leFH18 = false;
  	    {
  	    	if(_x select 1 == "SPE_leFH18") then {
  	    		_has_SPE_leFH18 = true;
  	    	}
  	    } forEach SUP_ARTYARRAYS;
  
        _artyArray = []; 
        _artyArray append (NEO_radioLogic getVariable [format ["NEO_radioArtyArray_%1", playerSide], []]);
 
	      if (_has_SPE_leFH18) then { 
	      	if (playerSide != WEST) then {
	        _artyArray append (NEO_radioLogic getVariable [format ["NEO_radioArtyArray_%1", WEST], []]);
	        };
	      };

// the AI Commander's guns (F509) have no battery to send home
if (["selected"] call NEO_fnc_artyCmdrBoard) exitWith {};
_battery = _artyArray select (lbCurSel _artyUnitLb) select 0; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _battery = ((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 0 };
_callsign = _artyArray select (lbCurSel _artyUnitLb) select 2; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _callsign = ((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 1 };
_callSignPlayer = (format ["%1", group player]) call NEO_fnc_callsignFix;

// Idle, the button relocates the battery to the spot clicked on the map (#1089); on the move, it calls it back
if ((_battery getVariable ["NEO_radioArtyUnitStatus", ""]) == "NONE") exitWith {
    if (isNil { uinamespace getVariable "NEO_artyMarkerCreated" }) exitWith { hint localize "STR_ALIVE_CS_UI_RELOCATE_CLICK" };
    private _pos = getMarkerPos (NEO_radioLogic getVariable "NEO_supportMarker");
    _pos set [2, 0];
    if (surfaceIsWater _pos) exitWith { hint localize "STR_ALIVE_CS_UI_RELOCATE_WATER" };
    _battery setVariable ["NEO_radioArtyRelocate", [_pos, _callSignPlayer, player], true];
    [player, ["STR_ALIVE_CS_MSG_RELOCATE", _callsign, _callSignPlayer, mapGridPosition _pos], "side"] call NEO_fnc_messageBroadcast;
    [lbCurSel 655565] call NEO_fnc_radioRefreshUi;
};

_battery setVariable ["NEO_radioArtyGoToBase", true, true];
[player, ["STR_ALIVE_CS_MSG_47", _callsign, _callSignPlayer], "side"] call NEO_fnc_messageBroadcast;

//Interface
[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
