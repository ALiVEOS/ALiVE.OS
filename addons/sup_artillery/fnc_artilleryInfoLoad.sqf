#include "\x\alive\addons\sup_artillery\commonInclude.hpp"

params ["_ctrlGroup","_value"];

_value = parseSimpleArray _value;

_value params ["_artilleryClass","_artilleryRoundCounts"];

systemchat format ["Loading: %1", _value];

private _display = ctrlParent _ctrlGroup;

private _roundsNeedInitialized = _artilleryRoundCounts isequalto [];
if (_roundsNeedInitialized) then {
	private _turrets = [_artilleryClass, false] call BIS_fnc_allTurrets;
	private _weapons = if (_turrets isnotequalto []) then {
		private _turretConfig = [_artilleryClass, _turrets select 0] call BIS_fnc_turretConfig;
		getarray (_turretConfig >> "weapons")
	} else {
		[]
	};
	private _magazines = [];

	private _cfgMagazines = configfile >> "CfgMagazines";

	{
		private _weapon = _x;
		private _weaponMagazines = [_weapon] call BIS_fnc_compatibleMagazines;

		{
			private _weaponMagazine = _x;
			private _weaponMagazineConfig = _cfgMagazines >> _weaponMagazine;

			private _displayName = gettext (_weaponMagazineConfig >> "displayName");
			private _displayNameShort = gettext (_weaponMagazineConfig >> "displayNameShort");
			private _displayNameType = gettext (_weaponMagazineConfig >> "displayNameMFDFormat");
			private _ammo = gettext (_weaponMagazineConfig >> "ammo");

			_magazines pushback [_weaponMagazine, _displayName, _displayNameShort, _displayNameType, _ammo];
		} foreach _weaponMagazines;
	} foreach _weapons;

	// split above into dedicated function
	// for now, parse into necessary format
	_artilleryRoundCounts = _magazines apply {
		[_x select 1, 30]
	};
};

_ctrlGroup ctrlSetPositionY (2 * CTRL_DEFAULT_H);
_ctrlGroup ctrlSetPositionH ((count _artilleryRoundCounts max 1) * (CTRL_DEFAULT_H + 5 * pixelH));
_ctrlGroup ctrlCommit 0;


// create artillery classname edit field

private _ctrlLabel = _display ctrlCreate ["ALiVE_modules_AttributeTitle", 723100, _ctrlGroup];
_ctrlLabel ctrlSetPosition [
	0,
	0,
	ATTRIBUTE_TITLE_W * GRID_W, 
	CTRL_DEFAULT_H
];
_ctrlLabel ctrlsettext "Artillery Classname:";
_ctrllabel ctrlCommit 0;

private _ctrlEdit = _display ctrlCreate ["ALiVE_modules_AttributeEdit", 723200, _ctrlGroup];
_ctrlEdit ctrlSetPosition [
	ATTRIBUTE_TITLE_W * GRID_W,
	0,
	ATTRIBUTE_CONTENT_W * 0.5 * GRID_W,
	CTRL_DEFAULT_H
];
_ctrlEdit ctrlSetText _artilleryClass;
_ctrlEdit ctrlCommit 0;

// create round count fields

private _i = 0;
{
	_x params ["_round","_roundCount"];

	private _ctrlIndex = _i + 1;
	_i = _i + 1;

	private _ctrlLabel = _display ctrlCreate ["ALiVE_modules_AttributeTitle", 723100 + _ctrlIndex, _ctrlGroup];
	_ctrlLabel ctrlSetPosition [
		0,
		CTRL_DEFAULT_H * _ctrlIndex + 5 * pixelH * _ctrlIndex,
		ATTRIBUTE_TITLE_W * GRID_W, 
		CTRL_DEFAULT_H
	];
	_ctrlLabel ctrlsettext _round;
	_ctrllabel ctrlCommit 0;

	private _ctrlEdit = _display ctrlCreate ["ALiVE_modules_AttributeEdit", 723200 + _ctrlIndex, _ctrlGroup];
	_ctrlEdit ctrlSetPosition [
		ATTRIBUTE_TITLE_W * GRID_W,
		CTRL_DEFAULT_H * _ctrlIndex + 5 * pixelH * _ctrlIndex,
		ATTRIBUTE_CONTENT_W * 0.5 * GRID_W,
		CTRL_DEFAULT_H
	];
	_ctrlEdit ctrlSetText (str _roundCount);
	_ctrlEdit ctrlCommit 0;
} foreach _artilleryRoundCounts;