/*
    Author: Jman
    Date: 11-04-2021

    Description: Fetches and handles map markers parameter.

    Parameter(s):
        _paramValue - Value of the parameter [NUMBER, defaults to 0]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_paramValue", 0, [0]]
];

if (hasInterface && {_paramValue == 1}) then {
	
	_diary =
	{
		if (isNull player) exitWith {false};
		if(!(player diarySubjectExists "playergroupMarkers")) then
		{};
		true
	};
	
playermarker_customIcon = "\a3\ui_f\data\GUI\Rsc\RscDisplayMultiplayerSetup\flag_opfor_ca.paa";
playermarker_nameColor = [1,1,1,1];
playermarker_iconColor = [0.0,0.5,0,1];
playermarker_iconDistance = (viewDistance);
playermarker_nameDistance = 50;
player setVariable ['playermarker_customName',profileName,true];

		// diary stuff
		0 = _diary spawn
		{
			waitUntil {!(isNull player)};
			waitUntil {player==player};
			0 = [] call _this;
		};


[] spawn {
  addMissionEventHandler ["Draw3D", {
    {
      if (alive _x) then {
        drawIcon3D [
          if (player distance _x < playermarker_iconDistance) then {playermarker_customIcon}else{""},
          playermarker_iconColor,
          _x modelToWorldVisual [0,0,(ASLToAGL eyePos _x # 2)+0.3],
          2/2.5,
          1/2.5,
          0,
          "",
          2,
          0.028,
          "PuristaBold"
          ];
        drawIcon3D [
          if (player distance _x < playermarker_iconDistance) then {playermarker_customIcon}else{""},
          playermarker_nameColor,
          _x modelToWorldVisual [0,0,(ASLToAGL eyePos _x # 2)+0.25],
          0,
          0,
          0,
          if (player distance _x < playermarker_nameDistance) then {_x getVariable ['playermarker_customName',name _x]}else{""},
          2,
          0.029,
          "PuristaMedium"
          ];
      };
    }forEach(units group player) - [player];
    if !(isNull (findDisplay 56000)) then {
      ((findDisplay 56000) displayCtrl 1108) ctrlSetBackgroundColor playermarker_iconColor;
      ((findDisplay 56000) displayCtrl 1108) ctrlCommit 0;
      ((findDisplay 56000) displayCtrl 1106) ctrlSetBackgroundColor playermarker_nameColor;
      ((findDisplay 56000) displayCtrl 1106) ctrlCommit 0;
    };
  }];
  waitUntil{!(isNull (findDisplay 46))};
  (findDisplay 46) displayAddEventHandler ["KeyDown", "if (_this select 1 isEqualto 59 && _this select 2 && _this select 3) then {createDialog ""PlayerMarker_Settings""; {_x ctrlSetFade 1; _x ctrlCommit 0;}forEach(allcontrols (findDisplay 56000)); [] spawn {uiSleep 0.1; {_x ctrlSetFade 0; _x ctrlCommit 0.5;}forEach(allcontrols (findDisplay 56000))};};"];

};


};

true
