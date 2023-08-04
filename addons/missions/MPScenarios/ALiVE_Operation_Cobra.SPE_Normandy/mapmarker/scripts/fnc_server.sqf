MM_var_serverRunning = nil;
MM_var_remoteExecId = "";

_centerPos = getArray (configfile >> "CfgWorlds" >> worldname >> "centerPosition");

MM_var_mapScaleFactor = sqrt ((_centerPos select 0) * (_centerPos select 1)) * 10 ^ -3;
publicVariable "MM_var_mapScaleFactor";

MM_var_ShowAllSides = false;
MM_var_ShowAllSidesOnSpectator = true;
MM_var_showUnitNames = true;
MM_var_showUnitNamesOnlyOnHover = false;
MM_var_showGroupUnits = true;

publicVariable "MM_var_ShowAllSides";
publicVariable "MM_var_ShowAllSidesOnSpectator";
publicVariable "MM_var_showUnitNames";
publicVariable "MM_var_showUnitNamesOnlyOnHover";
publicVariable "MM_var_showGroupUnits";

MM_fnc_getConfigEntry = {
    params ["_typeName"];

    _entryStr = switch true do {
        case (_typeName isKindOf [_typeName, (configFile >> "CfgMagazines")]): {"CfgMagazines"};
        case (_typeName isKindOf [_typeName, (configFile >> "CfgAmmo")]): {"CfgAmmo"};
        case (_typeName isKindOf [_typeName, (configFile >> "CfgVehicles")]): {"CfgVehicles"};
        case (_typeName isKindOf [_typeName, (configFile >> "CfgWeapons")]): {"CfgWeapons"};
        default {""};
    };

    if (_entryStr == "") then {objNull} else {
        (configfile >> _entryStr >> _typeName)
    }
};

MM_fnc_GetDisplayName = {
    params ["_typeName"];

    _configEntry = [_typeName] call MM_fnc_getConfigEntry;

    if (isNull _configEntry) then {""} else {getText (_configEntry >> "displayName")}
};

MM_fnc_getName = {
    params ["_unit"];

    _name = "";

    if (unitIsUAV _unit) then {
        _name = [([typeOf _unit] call MM_fnc_GetDisplayName), "(AI)"] joinString " ";
    } else {
        _name = name _unit;

        if (isPlayer _unit) then {_name} else {
            _ss = _name splitString " ";

			if ((count _ss) > 1) then {
                _sss = (_ss select 0) splitString "-";

                if ((count _sss) > 1) then {
                    _name = ((_sss select 0) select [0,1]) + ".-" + ((_sss select 1) select [0,1]) + ". " + (_ss select 1);
                } else {
                    _name = ((_ss select 0) select [0,1]) + ". " + (_ss select 1);
                };
			};
            
			_name = _name + " (AI)";
        };
    };

    _name
};

MM_fnc_entityInitServer = {
    params ["_entity"];

    _startTime = time;
    waitUntil {(isNil "_entity") || {!(isNull _entity)} || {(time - _startTime) > 3}};
    if ((isNil "_entity") || {isNull _entity}) exitWith {};

	_this call {
        params ["_entity"];

		_entity setVariable ["MM_var_name", ([_entity] call MM_fnc_getName), true];
		_entity setVariable ["MM_var_side", (side (group _entity)), true];
		[[_entity], {if !(isNil "MM_var_clientInitDone") then {_this call MM_fnc_entityInitClient};}] remoteExecCall ["call", 0];
	};
};

MM_fnc_startMapMarkerServer = {
	call {
		if !isMultiplayer then {
			call MM_fnc_startMapMarkerClient;
		} else {
			if (isNil "MM_var_serverRunning") then {
                {
                    [_x] call MM_fnc_entityInitServer;
                } forEach (entities [["CAManBase"], [""], true, false]);

				MM_var_serverRunning = true;
				MM_var_remoteExecId = [[], {if hasInterface then {waitUntil {!(isNil "MM_var_clientInitDone")}; call MM_fnc_startMapMarkerClient;};}] remoteExecCall ["spawn", 0, true];
			};
		};
	};
};

MM_fnc_stopMapMarkerServer = {
	call {
		if !isMultiplayer then {
			call MM_fnc_stopMapMarkerClient;
		} else {
			if !(isNil "MM_var_serverRunning") then {
				MM_var_serverRunning = nil;

				remoteExecCall ["", MM_var_remoteExecId];
				MM_var_remoteExecId = "";

				[[], {if hasInterface then {waitUntil {!(isNil "MM_var_clientInitDone")}; call MM_fnc_stopMapMarkerClient;};}] remoteExecCall ["spawn", 0];
			};
		};
	};
};

MM_var_serverInitDone = true;
publicVariable "MM_var_serverInitDone";