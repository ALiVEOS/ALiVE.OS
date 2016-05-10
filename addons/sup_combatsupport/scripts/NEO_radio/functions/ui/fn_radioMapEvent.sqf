private ["_display", "_lb", "_map", "_button", "_pos", "_marker"];
_display = findDisplay 655555;
_lb = _display displayCtrl 655565;
_map = _this select 0;
_button = _this select 1; if (_button == 1) exitWith {};
_pos = _map ctrlMapScreenToWorld [_this select 2, _this select 3];
_marker = NEO_radioLogic getVariable "NEO_supportMarker";

ctrlMapAnimClear _map;
_map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _pos];
ctrlMapAnimCommit _map;

_marker setMarkerPosLocal _pos;
_marker setMarkerAlphaLocal 1;

switch (toUpper (_lb lbText (lbCurSel _lb))) do
{
	case "TRANSPORT" :
	{
		_marker setMarkerTextLocal "Transport";
		_marker setMarkerTypeLocal "hd_Pickup";
		
		uinamespace setVariable ["NEO_transportMarkerCreated", _marker];
		[] call NEO_fnc_transportConfirmButtonEnable;
	};
	
	case "CAS" : 
	{
		_marker setMarkerTextLocal "CAS";
		_marker setMarkerTypeLocal "hd_Destroy";
		
		uinamespace setVariable ["NEO_casMarkerCreated", _marker];
		[] call NEO_fnc_casConfirmButtonEnable;
	};
	
	case "ARTY" :
	{
		_marker setMarkerTextLocal "STRIKE";
		_marker setMarkerTypeLocal "hd_Destroy";
		
		uinamespace setVariable ["NEO_artyMarkerCreated", _marker];
		[] call NEO_fnc_artyConfirmButtonEnable;
	};
};
