if (!isNil { NEO_radioLogic getVariable "NEO_radioSatalliteObject" }) then 
{
	private ["_obj"];
	_obj = NEO_radioLogic getVariable "NEO_radioSatalliteObject";
	
	detach _obj;
	deleteVehicle _obj;
	NEO_radioLogic setVariable ["NEO_radioSatalliteObject", nil];
};

if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithPilot" }) then 
{
	NEO_radioLogic setVariable ["NEO_radioTalkWithPilot", nil];
};

if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then 
{
	NEO_radioLogic setVariable ["NEO_radioTalkWithArty", nil];
};

if (!isNil { uinamespace getVariable "NEO_radioCurrentAction" }) then 
{
	uinamespace setVariable ["NEO_radioCurrentAction", nil];
};

if (!isNil { uinamespace getVariable "NEO_radioCbVehicle" }) then 
{
	uinamespace setVariable ["NEO_radioCbVehicle", nil];
};

{
	_x setMarkerAlphaLocal 0;
} forEach (NEO_radioLogic getVariable "NEO_supportArtyMarkers");

(NEO_radioLogic getVariable "NEO_supportMarker") setMarkerAlphaLocal 0;

showGPS true;
