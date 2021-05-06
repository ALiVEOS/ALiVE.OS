/* 
* Filename:
* mapMarkers.sqf
*
* Description:
* Player map markers
* 
* Created by Jman
* Creation date: 05/04/2021
* 
* */
// ====================================================================================
if (isDedicated || !hasInterface) exitWith {};
private [
	'_side','_sides','_QS_ST_X','_QS_ST_map_enableUnitIcons','_QS_ST_gps_enableUnitIcons',	'_QS_ST_enableGroupIcons','_QS_ST_faction','_QS_ST_friendlySides_EAST',
	'_QS_ST_friendlySides_WEST','_QS_ST_friendlySides_RESISTANCE','_QS_ST_friendlySides_CIVILIAN','_QS_ST_friendlySides_Dynamic','_QS_ST_iconColor_EAST','_QS_ST_iconColor_WEST',
	'_QS_ST_iconColor_RESISTANCE','_QS_ST_iconColor_CIVILIAN','_QS_ST_iconColor_UNKNOWN','_QS_ST_showMedicalWounded','_QS_ST_MedicalSystem','_QS_ST_MedicalIconColor','_QS_ST_iconShadowMap',
	'_QS_ST_iconShadowGPS','_QS_ST_iconTextSize_Map','_QS_ST_iconTextSize_GPS','_QS_ST_iconTextOffset','_QS_ST_iconSize_Man','_QS_ST_iconSize_LandVehicle',	
	'_QS_ST_iconSize_Ship','_QS_ST_iconSize_Air','_QS_ST_iconSize_StaticWeapon','_QS_ST_GPSDist','_QS_ST_GPSshowNames','_QS_ST_GPSshowGroupOnly',	'_QS_ST_showAIGroups',			
	'_QS_ST_showGroupMapIcons','_QS_ST_showGroupHudIcons','_QS_ST_groupInteractiveIcons','_QS_ST_groupInteractiveIcons_showClass','_QS_ST_dynamicGroupID',			
	'_QS_ST_showGroupMapText','_QS_ST_groupIconScale','_QS_ST_groupIconOffset','_QS_ST_groupIconText','_QS_ST_autonomousVehicles','_QS_fnc_iconColor','_QS_fnc_iconType',				
	'_QS_fnc_iconSize','_QS_fnc_iconPosDir','_QS_fnc_iconText','_QS_fnc_iconUnits','_QS_fnc_onMapSingleClick','_QS_fnc_mapVehicleShowCrew','_QS_fnc_iconDrawMap',			
	'_QS_fnc_iconDrawGPS','_QS_fnc_groupIconText','_QS_fnc_groupIconType','_QS_fnc_configGroupIcon','_QS_fnc_onGroupIconClick','_QS_fnc_onGroupIconOverLeave',	
	'_QS_ST_iconMapClickShowDetail','_QS_ST_showFriendlySides','_QS_fnc_onGroupIconOverEnter','_QS_ST_showCivilianGroups','_QS_ST_iconTextFont','_QS_ST_showAll','_QS_ST_showFactionOnly',		
	'_QS_ST_showAI','_QS_ST_showMOS','_QS_ST_showGroupOnly','_QS_ST_iconUpdatePulseDelay','_QS_ST_iconMapText','_QS_ST_showMOS_range',
	'_QS_ST_iconTextFonts','_QS_fnc_isIncapacitated','_QS_ST_htmlColorMedical','_QS_ST_R','_QS_ST_showAINames','_QS_ST_AINames',
	'_QS_ST_groupTextFactionOnly','_QS_ST_showCivilianIcons','_QS_ST_showOnlyVehicles','_QS_ST_showOwnGroup','_QS_ST_iconColor_empty',
	'_QS_ST_iconSize_empty','_QS_ST_showEmptyVehicles','_QS_ST_colorInjured','_QS_ST_htmlColorInjured','_QS_fnc_iconColorGroup','_QS_ST_otherDisplays','_QS_ST_MAPrequireGPSItem',
	'_QS_ST_GPSrequireGPSItem','_QS_ST_GRPrequireGPSItem','_QS_ST_admin'
];

_QS_ST_map_enableUnitIcons = TRUE;						
_QS_ST_gps_enableUnitIcons = FALSE;	
_QS_ST_enableGroupIcons = FALSE;

_QS_ST_admin = FALSE;	
_QS_ST_showAll = 0;
	
_QS_ST_friendlySides_Dynamic = TRUE;					
_QS_ST_friendlySides_EAST = [3];
_QS_ST_friendlySides_WEST = [2];
_QS_ST_friendlySides_RESISTANCE = [0];
_QS_ST_friendlySides_CIVILIAN = [0];

_QS_ST_iconColor_EAST = [0.5,0,0,0.65];
_QS_ST_iconColor_WEST = [0,0.3,0.6,0.65];
_QS_ST_iconColor_RESISTANCE = [0,0.5,0,0.65];
_QS_ST_iconColor_CIVILIAN = [0.4,0,0.5,0.65];
_QS_ST_iconColor_UNKNOWN = [0.7,0.6,0,0.5];

_QS_ST_showMedicalWounded = FALSE;
_QS_ST_MedicalSystem = [];
_QS_ST_MedicalIconColor = [1,0.41,0,1];
_QS_ST_colorInjured = [0.75,0.55,0,0.75];

_QS_ST_showFactionOnly = FALSE;
_QS_ST_showAI = FALSE;
_QS_ST_AINames = FALSE;
_QS_ST_showCivilianIcons = FALSE;
_QS_ST_iconMapText = TRUE;
_QS_ST_showMOS = TRUE;
_QS_ST_showMOS_range = 3500;
_QS_ST_showGroupOnly = FALSE;
_QS_ST_showOnlyVehicles = FALSE;
_QS_ST_iconMapClickShowDetail = TRUE;
_QS_ST_iconUpdatePulseDelay = 0;
_QS_ST_iconShadowMap = 1;
_QS_ST_iconTextSize_Map = 0.05;
_QS_ST_iconTextOffset = 'right';
_QS_ST_iconSize_Man = 22;
_QS_ST_iconSize_LandVehicle = 26;
_QS_ST_iconSize_Ship = 24;
_QS_ST_iconSize_Air = 24;
_QS_ST_iconSize_StaticWeapon = 22;
_QS_ST_iconTextFonts = ['TahomaB'];
_QS_ST_otherDisplays = TRUE;
_QS_ST_MAPrequireGPSItem = FALSE;

_QS_ST_GPSDist = 300;
_QS_ST_GPSshowNames = FALSE;
_QS_ST_GPSshowGroupOnly = FALSE;
_QS_ST_iconTextSize_GPS = 0.05;
_QS_ST_iconShadowGPS = 1;
_QS_ST_GPSrequireGPSItem = FALSE;

_QS_ST_showGroupMapIcons = TRUE;
_QS_ST_showGroupHudIcons = FALSE;
_QS_ST_showAIGroups = FALSE;
_QS_ST_showAINames = FALSE;
_QS_ST_groupInteractiveIcons = TRUE;
_QS_ST_groupInteractiveIcons_showClass = TRUE;
_QS_ST_dynamicGroupID = TRUE;
_QS_ST_showGroupMapText = TRUE;
_QS_ST_groupIconScale = 0.75;
_QS_ST_groupIconOffset = [0.65,0.65];
_QS_ST_groupTextFactionOnly = TRUE;
_QS_ST_showCivilianGroups = FALSE;
_QS_ST_showOwnGroup = FALSE;
_QS_ST_GRPrequireGPSItem = FALSE;

_QS_ST_showEmptyVehicles = FALSE;
_QS_ST_iconColor_empty = [0.7,0.6,0,0.5];
_QS_ST_iconSize_empty = 20;

QS_ST_STR_text1 = 'Click to show group details';
QS_ST_STR_text2 = 'This group is not in your faction!';

_QS_fnc_isIncapacitated = {
	params ['_u','_med'];
	if ((lifeState _u) isEqualTo 'INCAPACITATED') exitWith {TRUE};
	private _r = FALSE;
	if (_med isEqualTo 'BTC') then {
		if (!isNil {_u getVariable 'BTC_need_revive'}) then {
			if ((_u getVariable 'BTC_need_revive') isEqualTo 1) then {
				_r = TRUE;
			};
		};
	} else {
		if (_med isEqualTo 'FAR') then {
			if (!isNil {_u getVariable 'FAR_isUnconscious'}) then {
				if ((_u getVariable 'FAR_isUnconscious') isEqualTo 1) then {
					_r = TRUE;
				};
			};
		} else {
			if (_med isEqualTo 'AIS') then {
				if (!isNil {_u getVariable 'unit_is_unconscious'}) then {
					if ((_u getVariable 'unit_is_unconscious')) then {
						_r = TRUE;
					};
				};
			} else {
				if (_med isEqualTo 'AWS') then {
					if (!isNil {_u getVariable 'tcb_ais_agony'}) then {
						if ((_u getVariable 'tcb_ais_agony')) then {
							_r = TRUE;
						};
					};
				} else {
					if (_med isEqualTo 'ACE') then {
						if (!isNil {_u getVariable 'ACE_isUnconscious'}) then {
							if ((_u getVariable 'ACE_isUnconscious')) then {
								_r = TRUE;
							};
						};
					};
				};
			};
		};
	};
	_r;
};
_QS_fnc_iconColor = {
	params [['_v',objNull],['_ds',1],'_QS_ST_X',['_ms',1]];
	_u = effectiveCommander _v;
	_s = side (group _u);
	private _exit = FALSE;
	private _c = _QS_ST_X select 13;
	private _a = 0;
	if (!(_v isKindOf 'Man')) then {
		if (_v getVariable ['QS_ST_drawEmptyVehicle',FALSE]) then {
			if ((count (crew _v)) isEqualTo 0) then {
				_exit = TRUE;
				_c = _QS_ST_X select 78;
				_c set [3,0.65];
				if (_ms > 0.80) then {
					if (_ds isEqualTo 1) then {
						_c set [3,0];
					};
				};
			};
		};
	};
	if (_exit) exitWith {_c;};
	private _useTeamColor = FALSE;
	if ((group _u) isEqualTo (group player)) then {
		_useTeamColor = TRUE;
		_a = 0.85;
	} else {
		_a = 0.65;
	};
	if (_QS_ST_X select 14) then {
		if ([_u,((_QS_ST_X select 15) select 0)] call (_QS_ST_X select 69)) then {
			_exit = TRUE;
			_c = _QS_ST_X select 16;
			_c set [3,_a];
			if (_ms > 0.80) then {
				if (_ds isEqualTo 1) then {
					_c set [3,0];
				};
			};
		};
	} else {
		if ([_u,((_QS_ST_X select 15) select 0)] call (_QS_ST_X select 69)) then {
			_exit = TRUE;
			_c = _QS_ST_X select 16;
			_c set [3,0];
		};
	};
	if (_exit) exitWith {_c;};
	if (_useTeamColor) then {
		if (isNull (objectParent _u)) then {
			private _teamID = 0;
			if (!isNil {assignedTeam _u}) then {
				_teamID = ['MAIN','RED','GREEN','BLUE','YELLOW'] find (assignedTeam _u);
				if (_teamID isEqualTo -1) then {
					_teamID = 0;
				};
			};
			if (_s isEqualTo EAST) then {_c = _QS_ST_X select 9;};
			if (_s isEqualTo WEST) then {_c = _QS_ST_X select 10;};
			if (_s isEqualTo RESISTANCE) then {_c = _QS_ST_X select 11;};
			if (_s isEqualTo CIVILIAN) then {_c = _QS_ST_X select 12;};
			_c = [_c,[1,0,0,1],[0,1,0.5,1],[0,0.5,1,1],[1,1,0,1]] select _teamID;
			_c set [3,_a];
			if (_ms > 0.80) then {
				if (_ds isEqualTo 1) then {
					_c set [3,0];
				};
			};
			_exit = TRUE;
		};
	};
	if (_exit) exitWith {_c;};
	if (_s isEqualTo EAST) exitWith {_c = _QS_ST_X select 9; _c set [3,_a];if (_ds isEqualTo 1) then {if (_ms > 0.80) then {_c set [3,0];};};_c;};
	if (_s isEqualTo WEST) exitWith {_c = _QS_ST_X select 10;_c set [3,_a];if (_ds isEqualTo 1) then {if (_ms > 0.80) then {_c set [3,0];};};_c;};
	if (_s isEqualTo RESISTANCE) exitWith {_c = _QS_ST_X select 11;_c set [3,_a];if (_ds isEqualTo 1) then {if (_ms > 0.80) then {_c set [3,0];};};_c;};
	if (_s isEqualTo CIVILIAN) exitWith {_c = _QS_ST_X select 12;_c set [3,_a];if (_ds isEqualTo 1) then {if (_ms > 0.80) then {_c set [3,0];};};_c;};
	_c = _QS_ST_X select 13;if (_ds isEqualTo 1) then { if (_ms > 0.80) then {_c set [3,0];};};_c;
};
_QS_fnc_iconType = {
	params ['_u'];
	private _vt = typeOf (vehicle _u);
	private _i = missionNamespace getVariable [format ['QS_ST_iconType#%1',_vt],''];
	if (_i isEqualTo '') then {
		if ((vehicle _u) isKindOf 'CAManBase') then {
			if (_u getUnitTrait 'medic') then {
				_vt = 'B_medic_F';
			} else {
				if (_u getUnitTrait 'engineer') then {
					_vt = 'B_engineer_F';
				} else {
					if (_u getUnitTrait 'explosiveSpecialist') then {
						_vt = 'B_soldier_exp_F';
					};
				};
			};
		};
		_i = getText (configFile >> 'CfgVehicles' >> _vt >> 'icon');
		missionNamespace setVariable [format ['QS_ST_iconType#%1',_vt],_i];
	};
	_i;
};
_QS_fnc_iconSize = {
	params ['_v','','_QS_ST_X'];
	private _i = missionNamespace getVariable [(format ['QS_ST_iconSize#%1',(typeOf _v)]),0];
	if (_i isEqualTo 0) then {
		if (_v isKindOf 'Man') then {_i = _QS_ST_X select 22;_i;};
		if (_v isKindOf 'LandVehicle') then {_i = _QS_ST_X select 23;_i;};
		if (_v isKindOf 'Air') then {_i = _QS_ST_X select 25;_i;};
		if (_v isKindOf 'StaticWeapon') then {_i = _QS_ST_X select 26; _i;};
		if (_v isKindOf 'Ship') then {_i = _QS_ST_X select 24;_i;};
		missionNamespace setVariable [(format ['QS_ST_iconSize#%1',(typeOf _v)]),_i,FALSE];
	};
	_i;
};
_QS_fnc_iconPosDir = {
	params ['_v','_ds','_dl'];
	private _posDir = [[0,0,0],0];
	if (_ds isEqualTo 1) then {
		if (_dl > 0) then {
			if (diag_tickTime > (missionNamespace getVariable 'QS_ST_iconUpdatePulseTimer')) then {
				_posDir = [getPosASLVisual _v,getDirVisual _v];
				_v setVariable ['QS_ST_lastPulsePos',_posDir,FALSE];
			} else {
				if (!isNil {_v getVariable 'QS_ST_lastPulsePos'}) then {
					_posDir = _v getVariable 'QS_ST_lastPulsePos';
				} else {
					_posDir = [getPosASLVisual _v,getDirVisual _v];
					_v setVariable ['QS_ST_lastPulsePos',_posDir,FALSE];
				};		
			};
		} else {
			_posDir = [getPosASLVisual _v,getDirVisual _v];
		};
	} else {
		_posDir = [getPosASLVisual _v,getDirVisual _v];
	};
	_posDir;
};
_QS_fnc_iconText = {
	params ['_v','_ds','_QS_ST_X',['_ms',1]];
	if ((_ds isEqualTo 2) || {(!(_QS_ST_X select 67))}) exitWith {
		''
	};
	_showMOS = _QS_ST_X select 64;
	_showAINames = _QS_ST_X select 71;
	private _t = '';
	private _n = 0;
	private _vt = missionNamespace getVariable [format ['QS_ST_iconVehicleDN#%1',(typeOf _v)],''];
	if (_vt isEqualTo '') then {
		_vt = getText (configFile >> 'CfgVehicles' >> (typeOf _v) >> 'displayName');
		missionNamespace setVariable [format ['QS_ST_iconVehicleDN#%1',(typeOf _v)],_vt];
	};
	if (!(_QS_ST_X select 64)) then {
		_vt = '';
	};
	private _vn = name ((crew _v) select 0);
	if (!isPlayer ((crew _v) select 0)) then {
		if (!(_showAINames)) then {
			_vn = '[AI]';
		};
	};
	_isAdmin = (((call (missionNamespace getVariable 'BIS_fnc_admin')) isEqualTo 2) && (_QS_ST_X select 86));
	if (((_v distance2D player) < (_QS_ST_X select 68)) || {(_isAdmin)}) then {
		if ((_ms < 0.75) || {(_isAdmin)}) then {
			if ((_ms > 0.25) || {(_isAdmin)}) then {
				if (_showMOS) then {
					_t = format ['%1 [%2]',_vn,_vt];
				} else {
					_t = format ['%1',_vn];
				};
			} else {
				if (_ms < 0.006) then {
					if (_showMOS) then {
						_t = format ['%1 [%2]',_vn,_vt];
					} else {
						_t = format ['%1',_vn];
					};
				} else {
					_t = '';
				};
			};
		} else {
			_t = '';
		};
	} else {
		if (_ms < 0.75) then {
			if (_ms > 0.25) then {
				_t = format ['%1',_vn];
			} else {
				if (_ms < 0.006) then {
					_t = format ['%1',_vn];
				} else {
					_t = '';
				};
			};
		} else {
			_t = '';
		};
	};
	if ((_v isKindOf 'LandVehicle') || {(_v isKindOf 'Air')} || {(_v isKindOf 'Ship')}) then {
		_n = 0;
		_n = (count (crew _v)) - 1;
		if (_n > 0) then {
			if (!isNil {_v getVariable 'QS_ST_mapClickShowCrew'}) then {
				if (_v getVariable 'QS_ST_mapClickShowCrew') then {
					_t = '';
					private _crewIndex = 0;
					private _na = '';
					_crewCount = (count (crew _v)) - 1;
					{
						_na = name _x;
						if (!(_showAINames)) then {
							if (!isPlayer _x) then {
								_na = '[AI]';
							};
						};
						if (!(['error',_na,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString'))) then {
							if (!(_crewIndex isEqualTo _crewCount)) then {
								_t = _t + _na + ', ';
							} else {
								_t = _t + _na;
							};
						};
						_crewIndex = _crewIndex + 1;
					} count (crew _v);
				} else {
					if (!isNull driver _v) then {
						if (_ms < 0.75) then {
							if (_ms > 0.25) then {
								if (_showMOS) then {
									_t = format ['%1 [%2] +%3',_vn,_vt,_n];
								} else {
									_t = format ['%1 +%2',_vn,_n];
								};
							} else {
								if (_ms < 0.006) then {
									if (_showMOS) then {
										_t = format ['%1 [%2] +%3',_vn,_vt,_n];
									} else {
										_t = format ['%1 +%2',_vn,_n];
									};
								} else {
									_t = format ['+%1',_n];
								};
							};
						} else {
							_t = format ['+%1',_n];
						};
					} else {
						if (_ms < 0.75) then {
							if (_ms > 0.25) then {
								if (_showMOS) then {
									_t = format ['[%1] %2 +%3',_vt,_vn,_n];
								} else {
									_t = format ['%1 +%2',_vn,_n];
								};
							} else {
								if (_ms < 0.006) then {
									if (_showMOS) then {
										_t = format ['[%1] %2 +%3',_vt,_vn,_n];
									} else {
										_t = format ['%1 +%2',_vn,_n];
									};
								} else {
									_t = format ['+%1',_n];
								};
							};
						} else {
							_t = format ['+%1',_n];
						};
					};
				};
			} else {
				if (!isNull driver _v) then {
					if (_ms < 0.75) then {
						if (_ms > 0.25) then {
							if (_showMOS) then {
								_t = format ['%1 [%2] +%3',_vn,_vt,_n];
							} else {
								_t = format ['%1 +%2',_vn,_n];
							};
						} else {
							if (_ms < 0.006) then {
								if (_showMOS) then {
									_t = format ['%1 [%2] +%3',_vn,_vt,_n];
								} else {
									_t = format ['%1 +%2',_vn,_n];
								};
							} else {
								_t = format ['+%1',_n];
							};
						};
					} else {
						_t = format ['+%1',_n];
					};
				} else {
					if (_ms < 0.75) then {
						if (_ms > 0.25) then {
							if (_showMOS) then {
								_t = format ['[%1] %2 +%3',_vt,_vn,_n];
							} else {
								_t = format ['%1 +%2',_vn,_n];
							};
						} else {
							if (_ms < 0.006) then {
								if (_showMOS) then {
									_t = format ['[%1] %2 +%3',_vt,_vn,_n];
								} else {
									_t = format ['%1 +%2',_vn,_n];
								};
							} else {
								_t = format ['+%1',_n];
							};
						};
					} else {
						_t = format ['+%1',_n];
					};
				};
			};
		} else {
			if (!isNull driver _v) then {
				if (_ms < 0.75) then {
					if (_ms > 0.25) then {
						if (_showMOS) then {
							_t = format ['%1 [%2]',_vn,_vt];
						} else {
							_t = format ['%1',_vn];
						};
					} else {
						if (_ms < 0.006) then {
							if (_showMOS) then {
								_t = format ['%1 [%2]',_vn,_vt];
							} else {
								_t = format ['%1',_vn];
							};
						} else {
							_t = '';
						};
					};
				} else {
					_t = '';
				};
			} else {
				if (_ms < 0.75) then {
					if (_ms > 0.25) then {
						if (_showMOS) then {
							_t = format ['[%1] %2',_vt,_vn];
						} else {
							_t = format ['%1',_vn];
						};
					} else {
						if (_ms < 0.006) then {
							if (_showMOS) then {
								_t = format ['[%1] %2',_vt,_vn];
							} else {
								_t = format ['%1',_vn];
							};
						} else {
							_t = '';
						};
					};
				} else {
					_t = '';
				};
			};
		};
		if (unitIsUAV _v) then {
			if (isUavConnected _v) then {
				_y = (UAVControl _v) select 0;
				if (_ms < 0.75) then {
					if (_ms > 0.25) then {
						if (_showMOS) then {
							_t = format ['%1 [%2]',name _y,_vt]; _t;
						} else {
							_t = format ['%1',name _y]; _t;
						};
					} else {
						if (_ms < 0.006) then {
							if (_showMOS) then {
								_t = format ['%1 [%2]',name _y,_vt]; _t;
							} else {
								_t = format ['%1',name _y]; _t;
							};
						} else {
							_t = '';
						};
					};
				} else {
					_t = '';
				};
			} else {
				if (_ms < 0.75) then {
					if (_ms > 0.25) then {
						if (_showMOS) then {
							_t = format ['[AUTO] [%1]',_vt]; _t;
						} else {
							_t = '[AUTO]'; _t;
						};
					} else {
						if (_ms < 0.006) then {
							if (_showMOS) then {
								_t = format ['[AUTO] [%1]',_vt]; _t;
							} else {
								_t = '[AUTO]'; _t;
							};
						} else {
							_t = '';
						};
					};
				} else {
					_t = '';
				};
			};
		};
	};
	_t;
};
_QS_fnc_iconUnits = {
	params ['_di','_QS_ST_X'];
	private _exit = FALSE;
	private _si = [EAST,WEST,RESISTANCE,CIVILIAN];
	private _as = [];
	private _au = [];
	_isAdmin = (((call (missionNamespace getVariable 'BIS_fnc_admin')) isEqualTo 2) && (_QS_ST_X select 86));
	if (!(playerSide isEqualTo CIVILIAN)) then {
		if (!(_QS_ST_X select 74)) then {
			_si = [EAST,WEST,RESISTANCE];
		};
	};
	if ((_QS_ST_X select 61) > 0) exitWith {
		if ((_QS_ST_X select 61) isEqualTo 1) then {
			_au = allUnits + vehicles;
		};
		if ((_QS_ST_X select 61) isEqualTo 2) then {
			_au = entities [[],[],TRUE,TRUE];
		};
		_au;
	};
	if (((_di isEqualTo 1) && ((_QS_ST_X select 65))) && {(!(_QS_ST_X select 75))}) then {
		_exit = TRUE;
		_au = units (group player);
		if ((_QS_ST_X select 80)) then {
			{
				if (!(_x in _au)) then {
					if (_x getVariable ['QS_ST_drawEmptyVehicle',FALSE]) then {
						if ((crew _x) isEqualTo []) then {
							0 = _au pushBack _x;
						};
					};
				};
			} count vehicles;
		};
		_au;
	};
	if ((_di isEqualTo 2) && ((_QS_ST_X select 29))) then {
		_exit = TRUE;
		_au = units (group player);
		_au;
	};
	if (_exit) exitWith {_au;};
	if ((_QS_ST_X select 62)) then {
		_as pushBack (_si select (_QS_ST_X select 3));
	} else {
		if (isMultiplayer) then {
			if (_isAdmin) then {
				{
					0 = _as pushBack _x;
				} count _si;
			} else {
				if ((_QS_ST_X select 8)) then {
					_as pushBack (_si select (_QS_ST_X select 3));
					{
						if (((_si select (_QS_ST_X select 3)) getFriend _x) > 0.6) then {
							0 = _as pushBack _x;
						};
					} count _si;
				} else {
					_as pushBack (_si select (_QS_ST_X select 3));
					{
						0 = _as pushBack (_si select _x);
					} count (_QS_ST_X select 57);
				};
			};
		} else {
			if ((_QS_ST_X select 8)) then {
				_as pushBack (_si select (_QS_ST_X select 3));
				{
					if (((_si select (_QS_ST_X select 3)) getFriend _x) > 0.6) then {
						0 = _as pushBack _x;
					};
				} count _si;
			} else {
				_as pushBack (_si select (_QS_ST_X select 3));
				{
					0 = _as pushBack (_si select _x);
				} count (_QS_ST_X select 57);
			};
		};		
	};
	if (!(_QS_ST_X select 63)) then {
		if (isMultiplayer) then {
			if (_isAdmin) then {
				{
					if (_x isEqualTo ((crew (vehicle _x)) select 0)) then {
						0 = _au pushBack _x;
					};
				} count allUnits;
			} else {
				{
					if (((side _x) in _as) || {(captive _x)}) then {
						if (isPlayer _x) then {
							if (_di isEqualTo 2) then {
								if ((_x distance2D player) < (_QS_ST_X select 27)) then {
									if (_x isEqualTo ((crew (vehicle _x)) select 0)) then {
										0 = _au pushBack _x;
									};
								};
							} else {
								if (_x isEqualTo ((crew (vehicle _x)) select 0)) then {
									0 = _au pushBack _x;
								};
							};
						};
					};
				} count (allPlayers + allUnitsUav);
			};
		} else {
			{
				if (((side _x) in _as) || {(captive _x)}) then {
					if (isPlayer _x) then {
						if (_di isEqualTo 2) then {
							if ((_x distance2D player) < (_QS_ST_X select 27)) then {
								if (_x isEqualTo ((crew (vehicle _x)) select 0)) then {
									0 = _au pushBack _x;
								};
							};
						} else {
							if (_x isEqualTo ((crew (vehicle _x)) select 0)) then {
								0 = _au pushBack _x;
							};
						};
					};
				};
			} count (allPlayers + allUnitsUav);
		};
	} else {
		{
			if (((side _x) in _as) || {(captive _x)}) then {
				if (_di isEqualTo 2) then {
					if ((_x distance2D player) < (_QS_ST_X select 27)) then {
						if (_x isEqualTo ((crew (vehicle _x)) select 0)) then {
							0 = _au pushBack _x;
						};
					};
				} else {
					if (_x isEqualTo ((crew (vehicle _x)) select 0)) then {
						0 = _au pushBack _x;
					};
				};
			};
		} count allUnits;
	};
	if ((_di isEqualTo 1) && (_QS_ST_X select 75)) exitWith {
		_auv = [];
		{
			if (!((vehicle _x) isKindOf 'Man')) then {
				0 = _auv pushBack _x;
			};
		} count _au;
		if ((_QS_ST_X select 80)) then {
			{
				if (!(_x in _auv)) then {
					if (_x getVariable ['QS_ST_drawEmptyVehicle',FALSE]) then {
						if ((crew _x) isEqualTo []) then {
							0 = _auv pushBack _x;
						};
					};
				};
			} count vehicles;
		};
		if ((_QS_ST_X select 65)) then {
			{
				0 = _auv pushBack _x;
			} count (units (group player));
		};
		_auv;
	};
	if ((_di isEqualTo 1) && (_QS_ST_X select 80)) exitWith {
		{
			if (!(_x in _au)) then {
				if (_x getVariable ['QS_ST_drawEmptyVehicle',FALSE]) then {
					if ((crew _x) isEqualTo []) then {
						0 = _au pushBack _x;
					};
				};
			};
		} count vehicles;
		_au;
	};
	_au;
};
_QS_fnc_onMapSingleClick = {
	params ['_units','_position','_alt','_shift'];
	if ((!(_alt)) && (!(_shift))) then {
		if (player getVariable 'QS_ST_mapSingleClick') then {
			player setVariable ['QS_ST_mapSingleClick',FALSE,FALSE];
			if (alive (player getVariable ['QS_ST_map_vehicleShowCrew',objNull])) then {
				(player getVariable ['QS_ST_map_vehicleShowCrew',objNull]) setVariable ['QS_ST_mapClickShowCrew',FALSE,FALSE];
			};
		};
		comment "player setVariable ['QS_ST_map_vehicleShowCrew',objNull,FALSE];";
		player setVariable ['QS_ST_mapSingleClick',TRUE,FALSE];
		private _vehicle = objNull;
		_vehicles = (nearestObjects [_position,['Air','LandVehicle','Ship'],250,TRUE]) select {(alive _x)};
		if ((count _vehicles) > 0) then {
			if ((count _vehicles) > 1) then {
				private _dist = 999999;
				{
					if ((_x distance2D _position) < _dist) then {
						_dist = _x distance2D _position;
						_vehicle = _x;
					};
				} forEach _vehicles;
			} else {
				_vehicle = _vehicles select 0;
			};
		};
		_QS_ST_X = [] call (missionNamespace getVariable 'QS_ST_X');
		if (alive _vehicle) then {
			if ((count (crew _vehicle)) > 1) then {
				if ((side (effectiveCommander _vehicle)) isEqualTo playerSide) then {
					if (!(_vehicle isEqualTo (player getVariable ['QS_ST_map_vehicleShowCrew',objNull]))) then {
						player setVariable ['QS_ST_map_vehicleShowCrew',_vehicle,FALSE];
						_vehicle setVariable ['QS_ST_mapClickShowCrew',TRUE,FALSE];
					} else {
						(player getVariable ['QS_ST_map_vehicleShowCrew',objNull]) setVariable ['QS_ST_mapClickShowCrew',FALSE,FALSE];
						player setVariable ['QS_ST_map_vehicleShowCrew',objNull,FALSE];
						player setVariable ['QS_ST_mapSingleClick',FALSE,FALSE];
					};
				} else {
					(player getVariable ['QS_ST_map_vehicleShowCrew',objNull]) setVariable ['QS_ST_mapClickShowCrew',FALSE,FALSE];
					player setVariable ['QS_ST_map_vehicleShowCrew',objNull,FALSE];
					player setVariable ['QS_ST_mapSingleClick',FALSE,FALSE];
				};
			} else {
				(player getVariable ['QS_ST_map_vehicleShowCrew',objNull]) setVariable ['QS_ST_mapClickShowCrew',FALSE,FALSE];
				player setVariable ['QS_ST_map_vehicleShowCrew',objNull,FALSE];
				player setVariable ['QS_ST_mapSingleClick',FALSE,FALSE];
			};
		} else {
			(player getVariable ['QS_ST_map_vehicleShowCrew',objNull]) setVariable ['QS_ST_mapClickShowCrew',FALSE,FALSE];
			player setVariable ['QS_ST_map_vehicleShowCrew',objNull,FALSE];
			player setVariable ['QS_ST_mapSingleClick',FALSE,FALSE];
		};
	};
	if (_shift) then {
		if (player isEqualTo (leader (group player))) then {
			private _nearUnit = objNull;
			_nearUnits = (nearestObjects [_position,['CAManBase'],250,TRUE]) select {((alive _x) && ((group _x) isEqualTo (group player)) && (isNull (objectParent _x)))};
			if ((count _nearUnits) > 0) then {
				if ((count _nearUnits) > 1) then {
					private _dist = 999999;
					{
						if ((_x distance2D _position) < _dist) then {
							_dist = _x distance2D _position;
							_nearUnit = _x;
						};
					} forEach _nearUnits;
				} else {
					_nearUnit = _nearUnits select 0;
				};
			};
			if (alive _nearUnit) then {
				player groupSelectUnit [_nearUnit,(!(_nearUnit in _units))];
			};
		};
	};
};
_QS_fnc_mapVehicleShowCrew = {};
_QS_fnc_iconDrawMap = {
	_m = _this select 0;
	_QS_ST_X = [] call (missionNamespace getVariable 'QS_ST_X');
	if ((_QS_ST_X select 83) && (!('ItemGPS' in (assignedItems player)))) exitWith {};
	if (diag_tickTime > (missionNamespace getVariable 'QS_ST_updateDraw_map')) then {
		missionNamespace setVariable ['QS_ST_updateDraw_map',(diag_tickTime + 3),FALSE];
		missionNamespace setVariable ['QS_ST_drawArray_map',([1,_QS_ST_X] call (_QS_ST_X select 46)),FALSE];
	};
	_sh = _QS_ST_X select 17;
	_ts = _QS_ST_X select 19;
	_tf = _QS_ST_X select 60;
	_to = _QS_ST_X select 21;
	_de = _QS_ST_X select 66;
	_player = player;
	_ms = ctrlMapScale _m;
	private _ve = objNull;
	private _po = [[0,0,0],0];
	private _is = 0;
	if (!((missionNamespace getVariable 'QS_ST_drawArray_map') isEqualTo [])) then {
		{
			if (!isNull _x) then {
				_ve = vehicle _x;
				if (alive _ve) then {
					_po = [_ve,1,_de] call (_QS_ST_X select 44);
					_is = [_ve,1,_QS_ST_X] call (_QS_ST_X select 43);
					if (_ve isEqualTo (vehicle _player)) then {
						_m drawIcon ['a3\ui_f\data\igui\cfg\islandmap\iconplayer_ca.paa',[1,0,0,0.75],(_po select 0),24,24,(_po select 1),'',0,0.03,_tf,_to];
					};
					_m drawIcon [
						([_ve,1,_QS_ST_X] call (_QS_ST_X select 42)),
						([_ve,1,_QS_ST_X,_ms] call (_QS_ST_X select 41)),
						(_po select 0),
						_is,
						_is,
						(_po select 1),
						([_ve,1,_QS_ST_X,_ms] call (_QS_ST_X select 45)),
						_sh,
						_ts,
						_tf,
						_to
					];
				};
			};
		} count (missionNamespace getVariable ['QS_ST_drawArray_map',[]]);
	};
	if (_player isEqualTo (leader (group _player))) then {
		if (!((groupSelectedUnits _player) isEqualTo [])) then {
			{
				_m drawLine [(getPosASLVisual _player),(getPosASLVisual (vehicle _x)),[0,1,1,0.5]];
			} count (groupSelectedUnits _player);
		};
	} else {
		if (isNull (objectParent _player)) then {
			if (isNull (objectParent (leader (group _player)))) then {
				if (((leader (group _player)) distance2D _player) < (_QS_ST_X select 27)) then {
					_m drawLine [(getPosASLVisual _player),(getPosASLVisual (leader (group _player))),[0,1,1,0.5]];
				};
			};
		};
	};
	if (_de > 0) then {
		if (diag_tickTime > (missionNamespace getVariable 'QS_ST_iconUpdatePulseTimer')) then {
			missionNamespace setVariable ['QS_ST_iconUpdatePulseTimer',(diag_tickTime + _de)];
		};
	};
};
_QS_fnc_iconDrawGPS = {
	if (
		(!('MinimapDisplay' in ((infoPanel 'left') + (infoPanel 'right')))) ||
		{(visibleMap)} ||
		{((_QS_ST_X select 84) && (!('ItemGPS' in (assignedItems player))))}
	) exitWith {};
	_m = _this select 0;
	_QS_ST_X = [] call (missionNamespace getVariable 'QS_ST_X');
	if (diag_tickTime > (missionNamespace getVariable 'QS_ST_updateDraw_gps')) then {
		missionNamespace setVariable ['QS_ST_updateDraw_gps',(diag_tickTime + 3),FALSE];
		missionNamespace setVariable ['QS_ST_drawArray_gps',([2,_QS_ST_X] call (_QS_ST_X select 46)),FALSE];
	};
	if (!((missionNamespace getVariable 'QS_ST_drawArray_gps') isEqualTo [])) then {
		_sh = _QS_ST_X select 18;
		_ts = _QS_ST_X select 20;
		_tf = _QS_ST_X select 60;
		_to = _QS_ST_X select 21;
		_de = _QS_ST_X select 66;
		private _ve = objNull;
		private _po = [[0,0,0],0];
		private _is = 0;
		{
			if (!isNull _x) then {
				_ve = vehicle _x;
				if (alive _ve) then {
					_po = [_ve,2,_de] call (_QS_ST_X select 44);
					_is = [_ve,2,_QS_ST_X] call (_QS_ST_X select 43);
					_m drawIcon [
						([_ve,2,_QS_ST_X] call (_QS_ST_X select 42)),
						([_ve,2,_QS_ST_X] call (_QS_ST_X select 41)),
						(_po select 0),
						_is,
						_is,
						(_po select 1),
						([_ve,2,_QS_ST_X] call (_QS_ST_X select 45)),
						_sh,
						_ts,
						_tf,
						_to
					];
				};
			};
		} count (missionNamespace getVariable ['QS_ST_drawArray_gps',[]]);
	};
	if (player isEqualTo (leader (group player))) then {
		if (!((groupSelectedUnits player) isEqualTo [])) then {
			{
				_m drawLine [(getPosASLVisual player),(getPosASLVisual (vehicle _x)),[0,1,1,0.5]];
			} count (groupSelectedUnits player);
		};
	} else {
		if (isNull (objectParent player)) then {
			if (isNull (objectParent (leader (group player)))) then {
				if (((leader (group player)) distance2D player) < (_QS_ST_X select 27)) then {
					_m drawLine [(getPosASLVisual player),(getPosASLVisual (leader (group player))),[0,1,1,0.5]];
				};
			};
		};
	};
};
_QS_fnc_groupIconText = {
	params ['_grp','_QS_ST_X','_di'];
	private _text = '';
	if (_di isEqualTo 1) then {
		if (_QS_ST_X select 36) then {
			_text = groupId _grp;
		};
	};
	_text;
};
_QS_fnc_groupIconType = {
	params ['_grp','_grpSize','_grpVehicle','_grpSide'];
	_grpVehicle_type = typeOf _grpVehicle;
	_vehicleClass = _grpVehicle getVariable ['QS_ST_groupVehicleClass',''];
	if (_vehicleClass isEqualTo '') then {
		_vehicleClass = getText (configFile >> 'CfgVehicles' >> _grpVehicle_type >> 'vehicleClass');
		_grpVehicle setVariable ['QS_ST_groupVehicleClass',_vehicleClass];
	};
	private _iconType = _grpVehicle getVariable ['QS_ST_groupVehicleIconType',''];
	if (!(_iconType isEqualTo '')) exitWith {
		_iconType;
	};
	_iconTypes_EAST = ['o_inf','o_motor_inf','o_mech_inf','o_armor','o_recon','o_air','o_plane','o_uav','o_med','o_art','o_mortar','o_hq','o_support','o_maint','o_service','o_naval','o_unknown'];
	_iconTypes_WEST = ['b_inf','b_motor_inf','b_mech_inf','b_armor','b_recon','b_air','b_plane','b_uav','b_med','b_art','b_mortar','b_hq','b_support','b_maint','b_service','b_naval','b_unknown'];
	_iconTypes_RESISTANCE = ['n_inf','n_motor_inf','n_mech_inf','n_armor','n_recon','n_air','n_plane','n_uav','n_med','n_art','n_mortar','n_hq','n_support','n_maint','n_service','n_naval','n_unknown'];
	_iconTypes_CIVILIAN = ['c_air','c_car','c_plane','c_ship','c_unknown'];
	private _iconTypes = [];
	if (_grpSide isEqualTo EAST) then {
		_iconTypes = _iconTypes_EAST;
	};
	if (_grpSide isEqualTo WEST) then {
		_iconTypes = _iconTypes_WEST;
	};
	if (_grpSide isEqualTo RESISTANCE) then {
		_iconTypes = _iconTypes_RESISTANCE;
	};
	if (_grpSide isEqualTo CIVILIAN) exitWith {
		_iconTypes = _iconTypes_CIVILIAN;
		if (_grpVehicle isKindOf 'Helicopter') then {
			_iconType = _iconTypes select 0;
		};
		if (_grpVehicle isKindOf 'LandVehicle') then {
			_iconType = _iconTypes select 1;
		};
		if (_grpVehicle isKindOf 'Plane') then {
			_iconType = _iconTypes select 2;
		};
		if (_grpVehicle isKindOf 'Ship') then {
			_iconType = _iconTypes select 3;
		};
		if (_grpVehicle isKindOf 'Man') then {
			_iconType = _iconTypes select 4;
		};
		_grpVehicle setVariable ['QS_ST_groupVehicleIconType',_iconType,FALSE];
		_iconType;
	};
	if ((_vehicleClass isEqualTo 'Ship') || {(_vehicleClass isEqualTo 'Submarine')}) exitWith {
		_iconType = _iconTypes select 15; _iconType;
	};
	if (_vehicleClass in ['Men','MenRecon','MenSniper','MenDiver','MenSupport','MenUrban','MenStory']) exitWith {
		_iconType = _iconTypes select 0;
		if (_vehicleClass isEqualTo 'Men') then {
			_iconType = _iconTypes select 0;
		};
		if (_vehicleClass in ['MenRecon','MenSniper','MenDiver']) then {
			_iconType = _iconTypes select 4;
		};
		if (['medic',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString')) then {
			_iconType = _iconTypes select 8;
		};
		_grpVehicle setVariable ['QS_ST_groupVehicleIconType',_iconType,FALSE];
		_iconType;
	};
	if (_vehicleClass isEqualTo 'Static') exitWith {
		if (['mortar',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString')) then {
			_iconType = _iconTypes select 10; 
		} else {
			_iconType = _iconTypes select 12; 
		};
		_grpVehicle setVariable ['QS_ST_groupVehicleIconType',_iconType,FALSE];
		_iconType;
	};
	if (_vehicleClass isEqualTo 'Autonomous') exitWith {
		if (['UAV',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString')) then {
			_iconType = _iconTypes select 7; 
		} else {
			if (['UGV',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString')) then {
				_iconType = _iconTypes select 12; 
			};
		};
		_grpVehicle setVariable ['QS_ST_groupVehicleIconType',_iconType,FALSE];
		_iconType;
	};
	if (_vehicleClass isEqualTo 'Air') exitWith {
		if (_grpVehicle isKindOf 'Helicopter') then {
			_iconType = _iconTypes select 5; 
		} else {
			_iconType = _iconTypes select 6; 
		};
		_grpVehicle setVariable ['QS_ST_groupVehicleIconType',_iconType,FALSE];
		_iconType;
	};
	if (_vehicleClass isEqualTo 'Armored') exitWith {
		if (['apc',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString')) then {
			_iconType = _iconTypes select 2; 
		} else {
			if ((['arty',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString')) || {(['mlrs',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString'))}) then {
				_iconType = _iconTypes select 9; 
			} else {
				if (['mbt',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString')) then {
					_iconType = _iconTypes select 3; 
				};
			};
		};
		_grpVehicle setVariable ['QS_ST_groupVehicleIconType',_iconType,FALSE];
		_iconType;
	};
	if (_vehicleClass isEqualTo 'Car') exitWith {
		_iconType = _iconTypes select 1; 
		_grpVehicle setVariable ['QS_ST_groupVehicleIconType',_iconType,FALSE];
		_iconType;
	};
	if (_vehicleClass isEqualTo 'Support') exitWith {
		if (['medical',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString')) then {
			_iconType = _iconTypes select 8; 
		} else {
			if ((['ammo',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString')) || {(['box',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString'))} || {(['fuel',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString'))} || {(['CRV',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString'))} || {(['repair',_grpVehicle_type,FALSE] call (missionNamespace getVariable 'BIS_fnc_inString'))}) then {
				_iconType = _iconTypes select 14; 
			};
		};
		_grpVehicle setVariable ['QS_ST_groupVehicleIconType',_iconType,FALSE];
		_iconType;
	};
	_iconType = _iconTypes select 16;
	_grpVehicle setVariable ['QS_ST_groupVehicleIconType',_iconType,FALSE];
	_iconType;
};
_QS_fnc_configGroupIcon = {
	params ['_grp','_type','_QS_ST_X'];
	private _scale = 0;
	private _text = '';
	private _visibility = TRUE;
	private _grpIconColor = [0,0,0,0];
	private _iconID = -1;
	private _grpIconType = 'c_unknown';
	_grpLeader = leader _grp;
	_grpLeader_vehicle = vehicle _grpLeader;
	_grpLeader_vType = typeOf _grpLeader_vehicle;
	_grpSize = count (units _grp);
	_grpSide = side _grpLeader;
	if (_type isEqualTo 0) then {
		_grpIconType = [_grp,_grpSize,_grpLeader_vehicle,_grpSide] call (_QS_ST_X select 52);		
		_grp setVariable ['QS_ST_Group',1,FALSE];
		_iconID = _grp addGroupIcon [_grpIconType,(_QS_ST_X select 38)];
		_grp setGroupIcon [_iconID,_grpIconType];
		_grpIconColor = [_grpLeader,_QS_ST_X] call (_QS_ST_X select 77);
		_text = [_grp,_QS_ST_X,1] call (_QS_ST_X select 51);
		_scale = (_QS_ST_X select 37);
		_visibility = TRUE;
		_grp setGroupIconParams [_grpIconColor,_text,_scale,_visibility];
		_grp setVariable ['QS_ST_Group_Icon',[_iconID,_grpIconType,_grpLeader_vType,_grpIconColor,_text,_scale,_visibility],FALSE];
	};
	if (_type isEqualTo 1) then {
		private _update = FALSE;
		private _updateIcon = FALSE;
		private _updateParams = FALSE;
		_iconDetail = _grp getVariable 'QS_ST_Group_Icon';
		_iconDetail params ['_iconID','_grpIconType','_grpLeaderType','','_text','_scale','_visibility'];
		if (!(_grpLeaderType isEqualTo (typeOf _grpLeader_vehicle))) then {
			_update = TRUE;
			_updateIcon = TRUE;
		};
		if (!(_text isEqualTo ([_grp,_QS_ST_X,1] call (_QS_ST_X select 51)))) then {
			_update = TRUE;
			_updateParams = TRUE;
		};
		if (_update) then {
			_grpIconColor = [_grpLeader_vehicle,_QS_ST_X] call (_QS_ST_X select 77);
			if (_updateIcon) then {
				_grpIconType = [_grp,_grpSize,_grpLeader_vehicle,_grpSide] call (_QS_ST_X select 52);	
				_grp setGroupIcon [_iconID,_grpIconType];
			};
			if (_updateParams) then {
				_text = [_grp,_QS_ST_X,1] call (_QS_ST_X select 51);
				_grp setGroupIconParams [_grpIconColor,_text,_scale,_visibility];
			};
			_grp setVariable ['QS_ST_Group_Icon',[_iconID,_grpIconType,_grpLeader_vType,_grpIconColor,_text,_scale,_visibility],FALSE];
		};
	};
	if (_type isEqualTo 2) then {
		_grpIconArray = _grp getVariable 'QS_ST_Group_Icon';
		_grpID = _grpIconArray select 0;
		clearGroupIcons _grp;
		_grp setVariable ['QS_ST_Group_Icon',nil,FALSE];
		_grp setVariable ['QS_ST_Group',nil,FALSE];
	};
	true;
};
_QS_fnc_iconColorGroup = {
	params ['_v','_QS_ST_X'];
	_u = effectiveCommander _v;
	_ps = side _u;
	private _c = [0,0,0,0];
	if (_ps isEqualTo EAST) exitWith {_c = _QS_ST_X select 9; _u setVariable ['QS_ST_groupIconColor',[_c,_ps],FALSE];_c;};
	if (_ps isEqualTo WEST) exitWith {_c = _QS_ST_X select 10; _u setVariable ['QS_ST_groupIconColor',[_c,_ps],FALSE];_c;};
	if (_ps isEqualTo RESISTANCE) exitWith {_c = _QS_ST_X select 11; _u setVariable ['QS_ST_groupIconColor',[_c,_ps],FALSE];_c;};
	if (_ps isEqualTo CIVILIAN) exitWith {_c = _QS_ST_X select 12; _u setVariable ['QS_ST_groupIconColor',[_c,_ps],FALSE];_c;};
	_c = _QS_ST_X select 13;
	_u setVariable ['QS_ST_groupIconColor',[_c,_ps],FALSE];
	_c;
};
_QS_fnc_onGroupIconClick = {
	scriptName 'QS_ST_onGroupIconClick';
	params ['_is3D','_group','_wpID','_button','_posx','_posy','_shift','_ctrl','_alt'];
	if (!((side _group) isEqualTo playerSide)) exitWith {hintSilent QS_ST_STR_text2;0 spawn {uiSleep 3;hintSilent '';};};
	_QS_ST_X = [] call (missionNamespace getVariable 'QS_ST_X');
	private _lifeState = '';
	private _unitMOS = '';
	private _unitName = '';
	private _color = [0,0,0,1];
	private _colorIncapacitated = [1,0.41,0,1];
	private _colorInjured = [0,0,0,1];
	private _colorDead = [0.4,0,0.5,0.65];
	_text = [_group,_QS_ST_X,1] call (_QS_ST_X select 51);
	_groupCount = count (units _group);
	private _unitNameList = '';
	_leader = TRUE;
	if ((_QS_ST_X select 14)) then {
		_colorIncapacitated = _QS_ST_X select 70;
		_colorInjured = _QS_ST_X select 81;
		_colorDead = [0.4,0,0.5,0.65];
	} else {
		_colorIncapacitated = [1,0.41,0,1];
		_colorInjured = [0,0,0,1];
		_colorDead = [0.4,0,0.5,0.65];	
	};
	_showClass = _QS_ST_X select 34;
	_AINames = _QS_ST_X select 72;
	{
		_color = [0,0,0,1];
		_lifeState = lifeState _x;
		if (_lifeState isEqualTo 'INJURED') then {
			_color = _colorInjured;
		} else {
			if (_lifeState isEqualTo 'INCAPACITATED') then {
				_color = _colorIncapacitated;
			} else {
				if (_lifeState isEqualTo 'DEAD') then {
					_color = _colorDead;
				};
			};
		};
		if ([_x,((_QS_ST_X select 15) select 0)] call (_QS_ST_X select 69)) then {_color = _colorIncapacitated;};
		_unitMOS = getText (configFile >> 'CfgVehicles' >> (typeOf _x) >> 'displayName');
		_unitName = name _x;
		if (!isPlayer _x) then {
			if (!(_AINames)) then {
				_unitName = '[AI]';
			};
		};
		if (_leader) then {
			_leader = FALSE;
			if (_showClass) then {
				_unitNameList = _unitNameList + format ["<t align='left'><t size='1.2'><t color='%2'>%1</t></t></t>",_unitName,_color] + format ["<t align='right'><t size='0.75'><t color='%2'>[%1]</t></t></t>",_unitMOS,_color] + '<br/>';
			} else {
				_unitNameList = _unitNameList + format ["<t align='left'><t size='1.2'><t color='%2'>%1</t></t></t>",_unitName,_color] + '<br/>';				
			};
		} else {
			if (_showClass) then {
				_unitNameList = _unitNameList + format ["<t align='left'><t color='%2'>%1</t></t>",_unitName,_color] + format ["<t align='right'><t size='0.75'><t color='%2'>[%1]</t></t></t>",_unitMOS,_color] + '<br/>';
			} else {
				_unitNameList = _unitNameList + format ["<t align='left'><t color='%2'>%1</t></t>",_unitName,_color] + '<br/>';				
			};
		};
	} count (units _group);
	hintSilent parseText format [
		"
			<t align='left'><t size='2'>%1</t></t><t align='right'>%2</t><br/><br/>
			%3
		",
		_text,
		_groupCount,
		_unitNameList
	];
};
_QS_fnc_onGroupIconOverEnter = {
	if (!((side (_this select 1)) isEqualTo playerSide)) exitWith {};
};
_QS_fnc_onGroupIconOverLeave = {
	hintSilent '';
};
scriptName 'Soldier Tracker by Quiksilver - (Init)';
_side = playerSide;
_sides = [EAST,WEST,RESISTANCE,CIVILIAN];
uiSleep 0.1;
_QS_ST_faction = _sides find _side;
if (_side isEqualTo EAST) then {
	_QS_ST_showFriendlySides = _QS_ST_friendlySides_EAST;
};
if (_side isEqualTo WEST) then {
	_QS_ST_showFriendlySides = _QS_ST_friendlySides_WEST;
};
if (_side isEqualTo RESISTANCE) then {
	_QS_ST_showFriendlySides = _QS_ST_friendlySides_RESISTANCE;
};
if (_side isEqualTo CIVILIAN) then {
	_QS_ST_showFriendlySides = _QS_ST_friendlySides_CIVILIAN;
};
_QS_ST_autonomousVehicles = [];
if (!(_QS_ST_iconShadowMap in [0,1,2])) then {
	_QS_ST_iconShadowMap = 1;
};
if (!(_QS_ST_iconShadowGPS in [0,1,2])) then {
	_QS_ST_iconShadowGPS = 1;
};
if (_QS_ST_iconUpdatePulseDelay > 0) then {
	missionNamespace setVariable ['QS_ST_iconUpdatePulseTimer',diag_tickTime];
};
_QS_ST_iconTextFont = _QS_ST_iconTextFonts select 0;
if (_QS_ST_enableGroupIcons) then {
	if (!(_QS_ST_map_enableUnitIcons)) then {
		_QS_ST_groupIconOffset = [0,0];
	};
};
_QS_ST_groupIconText = FALSE;
_QS_ST_htmlColorMedical = [_QS_ST_MedicalIconColor select 0,_QS_ST_MedicalIconColor select 1,_QS_ST_MedicalIconColor select 2,_QS_ST_MedicalIconColor select 3] call (missionNamespace getVariable 'BIS_fnc_colorRGBtoHTML');
_QS_ST_htmlColorInjured = [_QS_ST_colorInjured select 0,_QS_ST_colorInjured select 1,_QS_ST_colorInjured select 2,_QS_ST_colorInjured select 3] call (missionNamespace getVariable 'BIS_fnc_colorRGBtoHTML');

_QS_ST_R = [
	_QS_ST_map_enableUnitIcons,
	_QS_ST_gps_enableUnitIcons,
	_QS_ST_enableGroupIcons,
	_QS_ST_faction,
	_QS_ST_friendlySides_EAST,
	_QS_ST_friendlySides_WEST,
	_QS_ST_friendlySides_RESISTANCE,
	_QS_ST_friendlySides_CIVILIAN,
	_QS_ST_friendlySides_Dynamic,
	_QS_ST_iconColor_EAST,
	
	_QS_ST_iconColor_WEST,
	_QS_ST_iconColor_RESISTANCE,
	_QS_ST_iconColor_CIVILIAN,
	_QS_ST_iconColor_UNKNOWN,
	_QS_ST_showMedicalWounded,
	_QS_ST_MedicalSystem,
	_QS_ST_MedicalIconColor,
	_QS_ST_iconShadowMap,
	_QS_ST_iconShadowGPS,
	_QS_ST_iconTextSize_Map,
	
	_QS_ST_iconTextSize_GPS,
	_QS_ST_iconTextOffset,
	_QS_ST_iconSize_Man,
	_QS_ST_iconSize_LandVehicle,
	_QS_ST_iconSize_Ship,
	_QS_ST_iconSize_Air,
	_QS_ST_iconSize_StaticWeapon,
	_QS_ST_GPSDist,
	_QS_ST_GPSshowNames,
	_QS_ST_GPSshowGroupOnly,
	
	_QS_ST_showAIGroups,
	_QS_ST_showGroupMapIcons,
	_QS_ST_showGroupHudIcons,
	_QS_ST_groupInteractiveIcons,
	_QS_ST_groupInteractiveIcons_showClass,
	_QS_ST_dynamicGroupID,
	_QS_ST_showGroupMapText,
	_QS_ST_groupIconScale,
	_QS_ST_groupIconOffset,
	_QS_ST_groupIconText,
	
	_QS_ST_autonomousVehicles,
	_QS_fnc_iconColor,
	_QS_fnc_iconType,
	_QS_fnc_iconSize,
	_QS_fnc_iconPosDir,
	_QS_fnc_iconText,
	_QS_fnc_iconUnits,
	_QS_fnc_onMapSingleClick,
	_QS_fnc_mapVehicleShowCrew,
	_QS_fnc_iconDrawMap,
	
	_QS_fnc_iconDrawGPS,
	_QS_fnc_groupIconText,
	_QS_fnc_groupIconType,
	_QS_fnc_configGroupIcon,
	_QS_fnc_onGroupIconClick,
	_QS_fnc_onGroupIconOverLeave,
	_QS_ST_iconMapClickShowDetail,
	_QS_ST_showFriendlySides,
	_QS_fnc_onGroupIconOverEnter,
	_QS_ST_showCivilianGroups,
	
	_QS_ST_iconTextFont,
	_QS_ST_showAll,
	_QS_ST_showFactionOnly,
	_QS_ST_showAI,
	_QS_ST_showMOS,
	_QS_ST_showGroupOnly,
	_QS_ST_iconUpdatePulseDelay,
	_QS_ST_iconMapText,
	_QS_ST_showMOS_range,
	_QS_fnc_isIncapacitated,
	
	_QS_ST_htmlColorMedical,
	_QS_ST_AINames,
	_QS_ST_showAINames,
	_QS_ST_groupTextFactionOnly,
	_QS_ST_showCivilianIcons,
	_QS_ST_showOnlyVehicles,
	_QS_ST_showOwnGroup,
	_QS_fnc_iconColorGroup,
	_QS_ST_iconColor_empty,
	_QS_ST_iconSize_empty,
	
	_QS_ST_showEmptyVehicles,
	_QS_ST_htmlColorInjured,
	_QS_ST_otherDisplays,
	_QS_ST_MAPrequireGPSItem,		// 83
	_QS_ST_GPSrequireGPSItem,		// 84
	_QS_ST_GRPrequireGPSItem,		// 85
	_QS_ST_admin					// 86
];
{
	missionNamespace setVariable _x;
} forEach [
	['QS_ST_X',(compileFinal (str _QS_ST_R)),FALSE],
	['QS_ST_updateDraw_map',(diag_tickTime + 2),FALSE],
	['QS_ST_updateDraw_gps',(diag_tickTime + 1),FALSE],
	['QS_ST_drawArray_map',[],FALSE],
	['QS_ST_drawArray_gps',[],FALSE]
];
waitUntil {
	uiSleep 0.1; 
	!(isNull (findDisplay 12))
};
_QS_ST_X = [] call (missionNamespace getVariable 'QS_ST_X');
if (_QS_ST_X select 0) then {
	((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ['Draw',(format ['_this call %1',(_QS_ST_X select 49)])];
	if (_QS_ST_X select 82) then {
		[_QS_ST_X] spawn {
			scriptName 'Soldier Tracker by Quiksilver - Artillery Computer and UAV Terminal support';
			private ['_QS_display1Opened','_QS_display2Opened'];
			_QS_ST_X = _this select 0;
			_QS_display1Opened = FALSE;
			_QS_display2Opened = FALSE;
			disableSerialization;
			for '_x' from 0 to 1 step 0 do {
				if (!(_QS_display1Opened)) then {
					if (!isNull ((findDisplay 160) displayCtrl 51)) then {
						_QS_display1Opened = TRUE;
						((findDisplay 160) displayCtrl 51) ctrlAddEventHandler ['Draw',(format ['_this call %1',(_QS_ST_X select 49)])];
					};
				} else {
					if (isNull ((findDisplay 160) displayCtrl 51)) then {
						_QS_display1Opened = FALSE;
					};		
				};
				if (!(_QS_display2Opened)) then {
					if (!isNull((findDisplay -1) displayCtrl 500)) then {
						_QS_display2Opened = TRUE;
						((findDisplay -1) displayCtrl 500) ctrlAddEventHandler ['Draw',(format ['_this call %1',(_QS_ST_X select 49)])];
					};
				} else {
					if (isNull ((findDisplay -1) displayCtrl 500)) then {
						_QS_display2Opened = FALSE;
					};		
				};
				uiSleep 0.25;
			};
		};
	};
	if (_QS_ST_X select 56) then {
		player setVariable ['QS_ST_map_vehicleShowCrew',objNull,FALSE];
		player setVariable ['QS_ST_mapSingleClick',FALSE,FALSE];
		{
			addMissionEventHandler _x;
		} forEach [
			['MapSingleClick',(_QS_ST_X select 47)],
			[
				'Map',
				{
					params ['_mapIsOpened','_mapIsForced'];
					if (!(_mapIsOpened)) then {
						if (alive (player getVariable ['QS_ST_map_vehicleShowCrew',objNull])) then {
							player setVariable ['QS_ST_mapSingleClick',FALSE,FALSE];
							(player getVariable ['QS_ST_map_vehicleShowCrew',objNull]) setVariable ['QS_ST_mapClickShowCrew',FALSE,FALSE];
							player setVariable ['QS_ST_map_vehicleShowCrew',objNull,FALSE];
						};
					};
				}
			]
		];
	};
};

if (_QS_ST_X select 1) then {
	[_QS_ST_X] spawn {
		scriptName 'Soldier Tracker (GPS Icons) by Quiksilver - Waiting for GPS display';
		params ['_QS_ST_X'];
		disableSerialization;
		private _gps = controlNull;
		private _exit = FALSE;
		for '_x' from 0 to 1 step 0 do {
			{
				if (['311',(str _x),FALSE] call BIS_fnc_inString) then {
					if (!isNull (_x displayCtrl 101)) exitWith {
						_gps = (_x displayCtrl 101);
						_gps ctrlRemoveAllEventHandlers 'Draw';
						_gps ctrlAddEventHandler ['Draw',(format ['_this call %1',(_QS_ST_X select 50)])];
						_exit = TRUE;
					};
				};
			} forEach (uiNamespace getVariable 'IGUI_displays');
			uiSleep 0.25;
			if (_exit) exitWith {};
		};
	};
};
if (_QS_ST_X select 2) then {
	setGroupIconsVisible [(_QS_ST_X select 31),(_QS_ST_X select 32)];
	setGroupIconsSelectable (_QS_ST_X select 33);
	if (_QS_ST_X select 33) then {
		{
			addMissionEventHandler _x;
		} forEach [
			['GroupIconClick',(_QS_ST_X select 54)],
			['GroupIconOverEnter',(_QS_ST_X select 58)],
			['GroupIconOverLeave',(_QS_ST_X select 55)]
		];
	};
	[_QS_ST_X] spawn {
		scriptName 'Soldier Tracker (Group Icons) by Quiksilver';
		params ['_QS_ST_X'];
		_showMapUnitIcons = _QS_ST_X select 0;
		_dynamicDiplomacy = _QS_ST_X select 8;
		_showFriendlySides = _QS_ST_X select 57;
		_playerFaction = _QS_ST_X select 3;
		_showAIGroups = _QS_ST_X select 30;
		_configGroupIcon = _QS_ST_X select 53;
		_showCivilianGroups = _QS_ST_X select 59;
		_groupIconsVisibleMap = _QS_ST_X select 31;
		_showOwnGroup = _QS_ST_X select 76;
		_gpsRequired = _QS_ST_X select 85;
		private _sidesFriendly = [];
		private _grp = grpNull;
		private _sides = [EAST,WEST,RESISTANCE,CIVILIAN];
		private _grpLeader = objNull;
		private _refreshGroups = FALSE;
		if (!(_showCivilianGroups)) then {
			_sides deleteAt 3;
		};
		_groupUpdateDelay_timer = 5;
		private _groupUpdateDelay = diag_tickTime + _groupUpdateDelay_timer;
		private _checkDiplomacy_delay = 10;
		private _checkDiplomacy = diag_tickTime + _checkDiplomacy_delay;
		if (_dynamicDiplomacy) then {
			_sidesFriendly = _sides;
		};
		private _as = [];
		_as pushBack (_sides select _playerFaction);
		{
			0 = _as pushBack (_sides select _x);
		} count _showFriendlySides;
		for '_x' from 0 to 1 step 0 do {
			if (_dynamicDiplomacy) then {
				if (diag_tickTime > _checkDiplomacy) then {
					_as = [];
					{
						if (((_sides select _playerFaction) getFriend _x) > 0.6) then {
							0 = _as pushBack _x;
						};
					} count _sides;
					_checkDiplomacy = diag_tickTime + _checkDiplomacy_delay;
				};
			};
			if (diag_tickTime > _groupUpdateDelay) then {
				{
					_grp = _x;
					if ((_showOwnGroup) || {((!(_showOwnGroup)) && (!(_grp isEqualTo (group player))))} || {(!(_showMapUnitIcons))}) then {
						if (({(alive _x)} count (units _grp)) > 0) then {
							if ((side _grp) in _as) then {
								_grpLeader = leader _grp;
								if (_showAIGroups) then {
									if (isNil {_grp getVariable 'QS_ST_Group'}) then {
										if (!isNull _grp) then {
											if (!isNull _grpLeader) then {
												[_grp,0,_QS_ST_X] call _configGroupIcon;
											};
										};
									} else {
										if (!isNull _grp) then {
											if (!isNull _grpLeader) then {
												[_grp,1,_QS_ST_X] call _configGroupIcon;
											};
										};
									};
								} else {
									if (isPlayer _grpLeader) then {
										if (isNil {_grp getVariable 'QS_ST_Group'}) then {
											if (!isNull _grp) then {
												if (!isNull _grpLeader) then {
													[_grp,0,_QS_ST_X] call _configGroupIcon;
												};
											};
										} else {
											if (!isNull _grp) then {
												if (!isNull _grpLeader) then {
													[_grp,1,_QS_ST_X] call _configGroupIcon;
												};
											};
										};
									};
								};
							} else {
								if (!isNil {_grp getVariable 'QS_ST_Group_Icon'}) then {
									[_grp,2,_QS_ST_X] call _configGroupIcon;
								};
							};
						} else {
							if (!isNil {_grp getVariable 'QS_ST_Group_Icon'}) then {
								[_grp,2,_QS_ST_X] call _configGroupIcon;
							};
						};
					};
					uiSleep ([0.05,0.01] select _refreshGroups);
				} count allGroups;
				if (_refreshGroups) then {
					_refreshGroups = FALSE;
				};
				_groupUpdateDelay = diag_tickTime + _groupUpdateDelay_timer;
			};
			if (_gpsRequired) then {
				if (!('ItemGPS' in (assignedItems player))) then {
					setGroupIconsVisible [FALSE,FALSE];
					waitUntil {
						uiSleep 0.25;
						('ItemGPS' in (assignedItems player))
					};
				};
			};
			if ((!(visibleMap)) && (isNull ((findDisplay 160) displayCtrl 51)) && (isNull ((findDisplay -1) displayCtrl 500))) then {
				waitUntil {
					uiSleep 0.25;
					((visibleMap) || {(!isNull ((findDisplay 160) displayCtrl 51))} || {(!isNull ((findDisplay -1) displayCtrl 500))})
				};
				_refreshGroups = TRUE;
			};
			if ((visibleMap) || {(!isNull ((findDisplay 160) displayCtrl 51))} || {(!isNull ((findDisplay -1) displayCtrl 500))}) then {
				if ((ctrlMapScale ((findDisplay 12) displayCtrl 51)) isEqualTo 1) then {
					if (groupIconsVisible select 0) then {
						setGroupIconsVisible [FALSE,(groupIconsVisible select 1)];
					};
				} else {
					if (_groupIconsVisibleMap) then {
						if (!(groupIconsVisible select 0)) then {
							setGroupIconsVisible [TRUE,(groupIconsVisible select 1)];
						};
					};
				};
			} else {
				if (_groupIconsVisibleMap) then {
					if (groupIconsVisible select 0) then {
						setGroupIconsVisible [FALSE,(groupIconsVisible select 1)];
					};
				};
			};
			uiSleep 0.1;
		};
	};
};