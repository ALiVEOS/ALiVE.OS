private ["_cb", "_index", "_display", "_transportHeightCombo", "_transportSpeedCombo", "_transportRoeCombo", "_chopper", "_properties", "_height", "_speed", "_roe"];
_cb = _this select 0;
_index = _this select 1;
_display = ctrlParent _cb;
_transportHeightCombo = _display displayCtrl 655630;
_transportSpeedCombo = _display displayCtrl 655631;
_transportRoeCombo = _display displayCtrl 655632;
_chopper = uinamespace getVariable "NEO_radioCbVehicle";
_status = _chopper getVariable "NEO_radioTrasportUnitStatus";
_properties = _chopper getVariable "NEO_radioTrasportUnitFlyingProperties";
_height = _properties select 0;
_speed = _properties select 1;
_roe = _properties select 2;
if (_status == "KILLED") exitWith {};

switch (_cb) do
{
	case _transportHeightCombo : 
	{
		if (_height != _index) then
		{
			//New Properties
			_chopper setVariable ["NEO_radioTrasportUnitFlyingProperties", [_index, _speed, _roe], true];
			
			private ["_h"];
			_h = switch (_index) do
			{
				case 0 : { 100 };
				case 1 : { 300 };
				case DEFAULT { 1000 };
			};
			
			//Set Unit Behaviour Properties where they are local
			//[nil, _chopper, "loc", rSPAWN, [_chopper, _h], { (_this select 0) flyInHeight (_this select 1) }] call RE;
			[[_chopper,_h], "fnc_setFlyInHeight", false, false] spawn BIS_fnc_MP;
			
			//Dialog from player, only if unit is on a mission (flying)
			if (_status != "NONE") then { [player, format ["%1 fly at %2 meters height. Out.", (str group _chopper call NEO_fnc_callsignFix), _h], "side"] call NEO_fnc_messageBroadcast };
		};
	};
	
	case _transportSpeedCombo :
	{
		if (_speed != _index) then
		{
			//New Properties
			_chopper setVariable ["NEO_radioTrasportUnitFlyingProperties", [_height, _index, _roe], true];
			
			private ["_s"];
			_s = switch (_index) do
			{
				case 0 : { "limited" };
				case 1 : { "normal" };
				case DEFAULT { "full" };
			};
			
			//Set Unit Behaviour Properties where they are local
			[[_chopper,_s], "fnc_setSpeed", false, false] spawn BIS_fnc_MP;
			
			//Dialog from player, only if unit is on a mission (flying)
			if (_status != "NONE") then { [player, format ["%1 fly with a %2 speed. Out.", (str group _chopper call NEO_fnc_callsignFix), _s], "side"] call NEO_fnc_messageBroadcast };
		};
	};
	
	case _transportRoeCombo :
	{
		if (_roe != _index) then
		{
			//New Properties
			_chopper setVariable ["NEO_radioTrasportUnitFlyingProperties", [_height, _speed, _index], true];
			
			private ["_r"];
			_r = switch (_index) do
			{
				case 0 : { false };
				case DEFAULT { true };
			};
			
			//Set Unit Behaviour Properties where they are local
			[[_chopper,_r], "fnc_setROE", false, false] spawn BIS_fnc_MP;
			/*
			[nil, _chopper, "loc", rSPAWN, [_chopper, _r], 
			{
				private ["_chopper", "_engage", "_crew"];
				_chopper = _this select 0;
				_engage = _this select 1;
				_crew = crew _chopper;
				
				{
					if (!isPlayer _x && !(_x in assignedCargo _chopper)) then
					{
						if (_engage) then
						{
							_x enableAi "TARGET";
							_x enableAi "AUTOTARGET";
							_x setCombatMode "GREEN";
							group _x enableAttack true;
						}
						else
						{
							_x disableAi "TARGET";
							_x disableAi "AUTOTARGET";
							_x setCombatMode "BLUE";
							group _x enableAttack false;
						};
					};
				} forEach _crew;
			}] call RE;*/
			
			//Dialog from player, only if unit is on a mission (flying)
			if (_r) then
			{
				if (_status != "NONE") then { [player, format ["%1 you are free to engage. Out.", (str group _chopper call NEO_fnc_callsignFix)], "side"] call NEO_fnc_messageBroadcast };
			}
			else
			{
				if (_status != "NONE") then { [player, format ["%1 hold fire. Out.", (str group _chopper call NEO_fnc_callsignFix)], "side"] call NEO_fnc_messageBroadcast };
			};
		};
	};
};
