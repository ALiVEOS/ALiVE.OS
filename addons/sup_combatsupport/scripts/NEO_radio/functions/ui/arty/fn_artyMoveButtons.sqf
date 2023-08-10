private ["_display", "_button", "_artyMoveButton", "_artyDontMoveButton", "_artyUnitLb", "_artyArray", "_battery"];
_display = findDisplay 655555;
_button = _this select 0;
_artyMoveButton = _display displayCtrl 655606;
_artyDontMoveButton = _display displayCtrl 655607;
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
