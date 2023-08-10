private ["_display", "_artyUnitLb", "_artyArray", "_battery", "_callsign", "_callSignPlayer"];
_display = findDisplay 655555;
_artyUnitLb = _display displayCtrl 655594;

        private ["_artyArray","_count"];
        _newArtyArray = [];
        _artyArray = []; 
        _count = 0;       
        {
         _thisPlayerSide = playerSide;
         if (_x find "SPE_leFH18" != -1) then { 
         	if (playerSide != WEST) then {
         		_thisPlayerSide = WEST; 
         		};
         };
        _artyArray append (NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", _thisPlayerSide]);
        _newArtyArray append ([_artyArray select _count]);
         _count = _count +1;
        } forEach SUP_ARTYARRAYS;
				_artyArray = _newArtyArray;

_battery = _artyArray select (lbCurSel _artyUnitLb) select 0; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _battery = ((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 0 };
_callsign = _artyArray select (lbCurSel _artyUnitLb) select 2; if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then { _callsign = ((NEO_radioLogic getVariable "NEO_radioTalkWithArty") getVariable "NEO_radioArtyModule") select 1 };
_callSignPlayer = (format ["%1", group player]) call NEO_fnc_callsignFix;

_battery setVariable ["NEO_radioArtyGoToBase", true, true];
[player, format ["%1. Abort fire mission and return to base. Over.", _callsign, _callSignPlayer], "side"] call NEO_fnc_messageBroadcast;

//Interface
[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
