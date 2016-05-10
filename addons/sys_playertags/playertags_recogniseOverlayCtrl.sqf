#include <\x\alive\addons\sys_playertags\script_component.hpp>
	private ["_display", "_unit", "_tmpText", "_scrPos", "_lineCount","_ctrl","_absolutePos","_distMod","_overlayWidth","_ctrls","_display"];

#define PLAYERTAGSOVERLAY_TEXT0_IDC 991
  
[(_this select 0)] spawn {
	private ['_display', '_ctrl'];
	disableSerialization;
	_display = (_this select 0);
	_overlayWidth = 0.7;

	_ctrls = [];
	_i = 0;
	while { _i < 10 } do {
		_ctrls set [_i, _display displayCtrl (PLAYERTAGSOVERLAY_TEXT0_IDC + _i)];
		_i = _i + 1;
	};

	while { true } do {
		[] call ALIVE_fnc_playertagsRecognise;
		_i = 0;
		while {_i < foundUnitsCount} do {
			_ctrl = _ctrls select _i;
			_unit = foundUnitsCount - _i - 1;
			_tmpText = (foundUnitsText select _unit) select 0;	
			_scrPos = (foundUnitsText select _unit) select 1;
			_lineCount = (foundUnitsText select _unit) select 2;
			_distMod = (foundUnitsText select _unit) select 3;
			_absolutePos = (foundUnitsText select _unit) select 4;

			if !(_absolutePos) then {
				_scrPos set [0, (_scrPos select 0) - _overlayWidth / 2.0 * playertags_scale * _distMod / 2.0];
			};
			_scrPos set [2, _overlayWidth];
			_scrPos set [3, (0.005 + 0.06 * _lineCount)];
			_ctrl ctrlSetBackgroundColor [1, 1, 1, 0];
			_ctrl ctrlSetScale (playertags_scale * _distMod / 2.0);
			_ctrl ctrlSetStructuredText parseText _tmpText;
			_ctrl ctrlSetPosition _scrPos;
			_ctrl ctrlCommit 0;
			_ctrl ctrlShow true;
			_i = _i + 1;
		};

		while {_i < 10} do {
			_ctrl = _ctrls select _i;
			_ctrl ctrlShow false;
			_i = _i + 1;
		};

		sleep 0.05;
	};

};
