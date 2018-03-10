/*
	Author: Karel Moricky

	Description:
	Export list of objects for Community Wiki
	https://community.bistudio.com/wiki/Category:Arma_3:_Assets

	Parameter(s):
		0: NUMBER - duration in seconds for which an objects remains on the screen before its screen is captured (default: 1 s)
		1: ARRAY of STRINGs - list of CfgVehicles classes. Only these objects will be used (default: all classes)
		2: STRING - file path // Added for ALiVE ORBATRON
		3: STRING - prefix // Added for ALiVE ORBATRON
		4: STRING - faction // Added for ALiVE ORBATRON
	Returns:
	Nothing
*/

//#define DEBUG

disableserialization;

_delay = param [0,1,[0]];
_classes = param [1,[],[[]]];
_path = param [2,"",[""]];
_dlc = param [3,"",[""]];
_faction = param [4,"",[""]];
_logic = param [5,objNull,[objNull]];

// diag_log _this;

_product = productversion select 1;
private _allVehicles = 1;

//--- Export pictures ------------------------------------

//--- Prepare the scene
_posZ = 250;
_pos = [1024,1024,_posZ];

_cam = "camera" camcreate _pos;
_cam cameraeffect ["internal","back"];
_cam campreparefocus [-1,-1];
_cam campreparefov 0.4;
_cam camcommitprepared 0;
showcinemaborder false;

_sphereColor = "#(argb,8,8,3)color(0.93,1.0,0.98,0.1)"; //--- VR ground
//_sphereColor = "#(argb,8,8,3)color(0.93,1.0,0.98,0.028)"; //--- VR sky
//_sphereColor = "#(argb,8,8,3)color(1,1,1,1)"; //--- White
_sphereGround = createvehicle ["Sphere_3DEN",_pos,[],0,"none"];
_sphereNoGround = createvehicle ["SphereNoGround_3DEN",_pos,[],0,"none"];
{
	_x setposatl _pos;
	_x setdir 0;
	_x setobjecttexture [0,_sphereColor];
	_x setobjecttexture [1,_sphereColor];
	_x hideobject true;
} foreach [_sphereGround,_sphereNoGround];

setaperture 45;//35;
setdate [2035,5,28,10,0];

//--- Is preview capturing in Eden?
_display = [] call bis_fnc_displayMission;
if (is3DEN) then {
	_display = finddisplay 313;
	["showinterface",false] call bis_fnc_3DENInterface;
};

//--- Prepare the UI
_ctrlInfoW = 0.5;
_ctrlInfoH = 0.2;
_ctrlInfo = _display ctrlcreate ["RscStructuredText",-1];
_ctrlInfo ctrlsetposition [
	safezoneX + 0.1,//safezoneX + safezoneW - _ctrlInfoW - 0.1,
	safezoneY + safezoneH - _ctrlInfoH,
	safezoneW - 0.2,//_ctrlInfoW,
	_ctrlInfoH
];
//_ctrlInfo ctrlsetbackgroundcolor [0,0,0,1];
//_ctrlInfo ctrlsetfontheight (_ctrlInfoH * 0.7);
_ctrlInfo ctrlcommit 0;

_ctrlProgressH = 0.01;
_ctrlProgress = _display ctrlcreate ["RscProgress",-1];
_ctrlProgress ctrlsetposition [
	safezoneX,
	safezoneY + safezoneH - _ctrlProgressH,
	safezoneW,
	_ctrlProgressH
];
_ctrlProgress ctrlcommit 0;

_screenTop = safezoneY;
_screenBottom = safezoneY + safezoneH;
_screenLeft = safezoneX;
_screenRight = safezoneX + safezoneW;

//--- Main loop -------------------------------------------
{
	_class = _x;

	//--- Get filename
	_fileName = format ["%1\%2.png", _path, _class];

	//--- Update UI
	_ctrlInfo ctrlsetstructuredtext parsetext format ["Saving screenshot to<br /><t font='EtelkaMonospaceProBold' size='0.875'>[Arma 3 Profile]\Screenshots\%1</t><br />Note: The text overlay will not be saved.",_fileName];
	_ctrlProgress progresssetposition (_foreachindex / count _classes);

	//--- Set position and camera angles (exsception for helipads)
	_camDirH = 135;
	_camDirV = 15;
	_posLocal = +_pos;

	//--- Create object
	_object = [_logic, "displayVehicle", _class] call ALiVE_fnc_orbatCreator;

	if (([_logic,"getRealUnitClass", _class] call ALiVE_fnc_orbatCreator) iskindof "allvehicles") then {_object setdir 90;} else {_object setdir 270;};
	if (primaryweapon _object != "") then {_object switchmove "amovpercmstpslowwrfldnon"} else {_object switchmove "amovpercmstpsnonwnondnon";};
	_object setposatl _posLocal;
	_object switchaction "default";
	_timeCapture = time + _delay;
	if (_object iskindof "FlagCarrierCore") then {
		_object spawn {_this enablesimulation false;}; // Delay freezing to initialize flag
	} else {
		_object enablesimulation false;
	};

	//--- Caulculate bounding box corners
	_bbox = boundingboxreal _object;
	_bbox1 = _bbox select 0;
	_bbox2 = _bbox select 1;
	_worldPositions = [
		_object modeltoworld [_bbox1 select 0,_bbox1 select 1,_bbox1 select 2],
		_object modeltoworld [_bbox1 select 0,_bbox1 select 1,_bbox2 select 2],
		_object modeltoworld [_bbox1 select 0,_bbox2 select 1,_bbox1 select 2],
		_object modeltoworld [_bbox1 select 0,_bbox2 select 1,_bbox2 select 2],
		_object modeltoworld [_bbox2 select 0,_bbox1 select 1,_bbox1 select 2],
		_object modeltoworld [_bbox2 select 0,_bbox1 select 1,_bbox2 select 2],
		_object modeltoworld [_bbox2 select 0,_bbox2 select 1,_bbox1 select 2],
		_object modeltoworld [_bbox2 select 0,_bbox2 select 1,_bbox2 select 2]
	];

	//--- Set background sphere
	_pointLowest = 0;
	_pointHighest = 0;
	{
		_xZ = (_x select 2) - _posZ;
		if (_xZ > _pointHighest) then {_pointHighest = _xZ;};
		if (_xZ < _pointLowest) then {_pointLowest = _xZ;};
	} foreach _worldPositions;
	_sphere = if (abs(_pointLowest) > abs(_pointHighest * 2/3)) then {_sphereNoGround} else {_sphereGround};
	_sphere hideobject false;
	_sphere setpos _pos;

	//--- Set camera
	_camAngle = _camDirV;
	_camDis = (1.5 * ((sizeof ([_logic,"getRealUnitClass", _class] call ALiVE_fnc_orbatCreator)) max 0.1)) min 124 max 0.2; //--- 125 m is a sphere diameter
	_camPos = [_posLocal,_camDis,_camDirH] call bis_fnc_relpos;
	_camPos set [2,/*_posZ*/((_object modeltoworld [0,0,0]) select 2) + (tan _camAngle * _camDis)];
	_cam campreparepos _camPos;
	_cam campreparetarget (_object modeltoworld [0,0,0]);
	_cam campreparefocus [-1,-1];
	_cam campreparefov 0.7;
	_cam camcommitprepared 0;
	sleep 0.01; //--- Delay for camera to load

	if (([_logic,"getRealUnitClass", _class] call ALiVE_fnc_orbatCreator) iskindof "man" && !(([_logic,"getRealUnitClass", _class] call ALiVE_fnc_orbatCreator) iskindof "animal")) then {
		//--- Zoom in to character's torso to make inventory more apparent
		_cam campreparetarget (_object modeltoworld [0,0,1.25]);
		_cam campreparefov 0.075;
		_cam camcommitprepared 0;
	} else {
		//--- Calculate target
		_extremes = [0.5,0.5,0.5,0.5]; //--- Left, Right, Top, Bottom
		{
			_screenPos = worldtoscreen _x;
			if (count _screenPos > 0) then {
				_screenPosX = _screenPos select 0;
				_screenPosY = _screenPos select 1;
				if (_screenPosX < (_extremes select 0)) then {_extremes set [0,_screenPosX];};
				if (_screenPosX > (_extremes select 1)) then {_extremes set [1,_screenPosX];};
				if (_screenPosY > (_extremes select 3)) then {_extremes set [3,_screenPosY];};
				if (_screenPosY < (_extremes select 2)) then {_extremes set [2,_screenPosY];};
			};
		} foreach _worldPositions;
		_cam campreparetarget screentoworld [
			(_extremes select 0) + ((_extremes select 1) - (_extremes select 0)) / 2,
			(_extremes select 2) + ((_extremes select 3) - (_extremes select 2)) / 2
		];

		//--- Calculate zoom - get the closest zoom where all bounding box corners are still visible
		_fovStart = if (_camDis < 0.35) then {0.4} else {0.1}; //--- When camera is too close, it cuts into the model itself
		for "_f" from _fovStart to 0.7 step 0.01 do {
			_cam campreparefov _f;
			_cam camcommitprepared 0;
			sleep 0.01; //--- Delay for camera to load
			_onScreen = true;
			{
				_screenPos = worldtoscreen _x;
				if (count _screenPos == 0) then {_screenPos = [10,10];};
				if (abs (linearconversion [_screenLeft,_screenRight,_screenPos select 0,-1,1]) > 1) exitwith {_onScreen = false;};
				if (abs (linearconversion [_screenTop,_screenBottom,_screenPos select 1,-1,1]) > 1) exitwith {_onScreen = false;};
			} foreach _worldPositions;
			if (_onScreen) exitwith {};
		};
	};

	//--- Wait for model to load and take a screenshot
	waituntil {time > _timeCapture};
	screenshot _fileName;
	sleep 0.01;

	//--- Delete the object
	_object setpos [10,10,10];
	deletevehicle _object;
	_sphere hideobject true;

} foreach _classes;



//--- Reset the scene
_cam cameraeffect ["terminate","back"];
camdestroy _cam;
deletevehicle _sphereGround;
deletevehicle _sphereNoGround;
setaperture -1;
ctrldelete _ctrlInfo;
ctrldelete _ctrlProgress;

if (is3DEN) then {
	get3dencamera cameraeffect ["internal","back"];
	["showinterface",true] call bis_fnc_3DENInterface;
};

#ifdef DEBUG
	{deletevehicle _x;} foreach _helpers;
#endif