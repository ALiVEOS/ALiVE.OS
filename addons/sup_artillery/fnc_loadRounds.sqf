#include "\x\alive\addons\sup_artillery\commonInclude.hpp"

params ["_ctrlGroup", "_value"];

private _display = ctrlParent _ctrlGroup;

private _rounds = parseSimpleArray _value;
systemchat format ["_rounds = %1", _rounds];

_ctrlGroup ctrlSetPositionY (2 * CTRL_DEFAULT_H);
_ctrlGroup ctrlSetPositionH ((count _rounds max 1) * (CTRL_DEFAULT_H + 5 * pixelH));
_ctrlGroup ctrlCommit 0;

{
	_x params ["_round","_roundCount"];

	systemchat format ["Loading %1", _round];

	private _ctrlLabel = _display ctrlCreate ["ALiVE_modules_AttributeTitle", 723100 + _forEachIndex, _ctrlGroup];
	_ctrlLabel ctrlSetPosition [
		0,
		CTRL_DEFAULT_H * _forEachIndex + 5 * pixelH * _forEachIndex,
		ATTRIBUTE_TITLE_W * GRID_W, 
		CTRL_DEFAULT_H
	];
	_ctrlLabel ctrlsettext _round;
	_ctrlLabel ctrlsettooltip _round;
	_ctrllabel ctrlCommit 0;

	private _ctrlEdit = _display ctrlCreate ["ALiVE_modules_AttributeEdit", 723200 + _forEachIndex, _ctrlGroup];
	_ctrlEdit ctrlSetPosition [
		ATTRIBUTE_TITLE_W * GRID_W,
		CTRL_DEFAULT_H * _forEachIndex + 5 * pixelH * _forEachIndex,
		ATTRIBUTE_CONTENT_W * 0.5 * GRID_W,
		CTRL_DEFAULT_H
	];
	_ctrlEdit ctrlSetText (str _roundCount);
	_ctrlEdit ctrlCommit 0;
} foreach _rounds;