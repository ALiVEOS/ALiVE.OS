[nil, nil, "per", rSPAWN, _this,
{
	private ["_veh", "_text", "_type", "_color"];
	_veh = _this select 0;
	_text = _this select 1;
	_type = switch (_this select 2) do
	{
		case "TRANSPORT" : { "b_air" };
		case "CAS" : { "b_plane" };
		case "ARTY" : { "b_armor" };
	};
	_color = switch (side _veh) do
	{
		case WEST : { "ColorBlue" };
		case EAST : { "ColorRed" };
		case RESISTANCE : { "ColorGreen" };
		case CIVILIAN : { "ColorWhite" };
		case DEFAULT { "ColorWhite" };
	};
	
	private ["_mkr"];
	_mkr = createMarkerLocal [format ["NEO_mkr_radioDebugMarker_%1_%2", getPosATL _veh, random 9999], getPosATL _veh];
	_mkr setMarkerTextLocal _text;
	_mkr setMarkerTypeLocal _type;
	_mkr setMarkerColorLocal _color;
	_mkr setMarkerSizeLocal [1, 1];
	
	while { alive _veh } do
	{
		_mkr setMarkerPosLocal (getPosATL _veh);
		_mkr setMarkerDirLocal (getDir _veh);
		sleep 1;
	};
	
	deleteMarkerLocal _mkr;
	
}] call RE;

true;
