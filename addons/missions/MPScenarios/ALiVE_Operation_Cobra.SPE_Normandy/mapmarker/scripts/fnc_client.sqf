MM_var_clientRunning = nil;

MM_var_entityRespawnedEhId = -1;
MM_var_drawEhIds = [];
MM_var_uavTerminalLoopScript = scriptNull;

MM_var_colorYellow = [1, 0.83, 0, 1];
MM_var_colorWhite = [1, 1, 1, 1];
MM_var_colorBlack = [0, 0, 0, 1];

{
    missionNamespace setVariable [("MM_var_units" + (str _x)), []];
} forEach [west, east, independent, civilian, sideEmpty, sideLogic, sideAmbientLife, sideUnknown];

MM_fnc_isUavAi = {
    params ["_unit"];
    
    "UAV_AI" in (typeOf _unit)
};

MM_fnc_getSideString = {
    params ["_side"];

    if (_side != sideAmbientLife) then {
        str _side
    } else {
        "AmbientLife"
    }
};

MM_fnc_getTeamMapColor = {
    params ["_side"];

    switch _side do {
        case west: {[0, (4 / 7), 1, 1]};
        case east: {[1, 0, 0, 1]};
        case independent: {[0, 0.8, 0.27, 1]};
        default {[0.75, 0.75, 0.75, 1]};
    }
};

MM_fnc_getIcon = {
    params ["_object"];

    if (_object isKindOf "Car_F") exitWith {"iconCar"};
    if (_object isKindOf "Helicopter_Base_F") exitWith {"iconHelicopter"};
    if (_object isKindOf "Tank_F") exitWith {"iconTank"};
    if (_object isKindOf "Plane_Base_F") exitWith {"iconPlane"};
    if (_object isKindOf "Ship_F") exitWith {"iconShip"};

    "iconStaticAA"
};

MM_fnc_findControlArray = {
    params ["_idd", "_idc"];
    
    disableSerialization;
    ((allDisplays + (uiNamespace getVariable "IGUI_Displays")) select {(ctrlIDD _x) isEqualTo _idd && !(isNull (_x displayCtrl _idc))}) apply {_x displayCtrl _idc}
};

MM_fnc_UAVControlUnits = {
    params ["_vehicle", ["_onlyControlling", false]];

    _UAVControl = UAVControl _vehicle;
    _UAVControls = [_UAVControl select [0, 2]];

    if ((count _UAVControl) == 4) then {
        _UAVControls pushBack (_UAVControl select [2, 2]);
    };

    _UAVControlUnits = [];

    if _onlyControlling then {
        _UAVControlUnits = (_UAVControls select {(_x select 1) != ""}) apply {_x select 0};
    } else {
        _UAVControlUnits = (_UAVControls select {!(isNull (_x select 0))}) apply {_x select 0};
    };

    _UAVControlUnits
};

MM_fnc_getCrew = {
    params ["_vehicle"];

    _crew = [];

    if (unitIsUav _vehicle) then {
        _crew = (crew _vehicle) select {!([_x] call MM_fnc_isUavAi)};
        
        {
            _crew pushBackUnique _x;
        } forEach ([_vehicle] call MM_fnc_UAVControlUnits);
    } else {
        _crew = crew _vehicle;
    };

    _crew
};

MM_fnc_UAVControlUnits = {
    params ["_uav", ["_onlyControlling", false]];

    _UAVControl = UAVControl _uav;
    _UAVControls = [_UAVControl select [0, 2]];

    if ((count _UAVControl) == 4) then {
        _UAVControls pushBack (_UAVControl select [2, 2]);
    };

    _UAVControlUnits = [];

    if _onlyControlling then {
        _UAVControlUnits = (_UAVControls select {(_x select 1) != ""}) apply {_x select 0};
        
    } else {
        _UAVControlUnits = (_UAVControls select {!(isNull (_x select 0))}) apply {_x select 0};
    };

    _UAVControlUnits
};

MM_fnc_getGroupUnits = {
    params ["_unit"];

    (units (group _unit))
};

MM_fnc_posVisibleOnGPS = {
    params ["_ctrlGPS", "_posWorld"];

    (ctrlMapPosition _ctrlGPS) params ["_posXGPSMap", "_posYGPSMap", "_widthGPSMap", "_heightGPSMap"];
    (_ctrlGPS ctrlMapWorldToScreen _posWorld) params ["_posXGui", "_posYGui"];

    _posXOnGPS = 0.012771 - ((_posXGPSMap - _posXGui) / _widthGPSMap);
    _posYOnGPS = ((_posYGPSMap - _posYGui) / _heightGPSMap) + 1.128351;

    (
        _posXOnGPS >= 0 &&
        {_posXOnGPS <= 1} &&
        {_posYOnGPS >= 0} &&
        {_posYOnGPS <= 1}
    )
};

MM_fnc_drawIcons = {
    params ["_disp", "_mousePos", "_isGps"];

    disableSerialization;

    _isInSpectator = (!(isNil "BIS_EGSpectator_initialized") || {!(isNil "SPECTATE_THREAD")});
    _group = group player;
    _groupUnits = [player] call MM_fnc_getGroupUnits;
    _side = player getVariable ["MM_var_side", (side _group)];
    _ctrlMapScale = ctrlMapScale _disp;

    _sides = [_side];

    if (MM_var_ShowAllSides || {_isInSpectator && {MM_var_ShowAllSidesOnSpectator}}) then {
        _sides = [west, east, independent, civilian];
    };

    _units = [];
    _vehicles = [];
    _parachutes = [];

    {
        {
            if ((simulationEnabled _x) && {!_isGps || {[_disp, (getPosWorld _x)] call MM_fnc_posVisibleOnGPS}} && {MM_var_showGroupUnits || {_x isEqualTo player} || {!(_x in _groupUnits)}}) then {
                _parX = objectParent _x;

                if (isNull _parX) then {
                    if !(isObjectHidden _x) then {
                        _units pushBack _x;
                    };
                } else {
                    if !(isObjectHidden _x) then {
                        if (_parX isKindOf "Steerable_Parachute_F") then {
                            _parachutes pushBack _parX;
                        } else {
                            _vehicles pushBackUnique _parX;
                        };
                    } else {
                        if (([_x] call MM_fnc_isUavAi) && {_x isEqualTo (driver _parX)}) then {
                            _vehicles pushBack _parX;
                        };
                    };
                };
            };
        } forEach (call (compile (["MM_var_units", [_x] call MM_fnc_getSideString] joinString "")));
    } forEach _sides;

    {
        _pos = getPosATLVisual _x;
        _dir = getDirVisual _x;
        _icon = "";
        _size = -1;
        _color = [];

        if (alive _x) then {
            _icon = "iconManVirtual";
            _size = 20;

            if (_x in _groupUnits) then {
                if (_x isEqualTo player) then {
                    _color = MM_var_colorYellow;
                } else {
                    _color = MM_var_colorWhite;
                }
            } else {
                _color = [_x getVariable ["MM_var_side", sideUnknown]] call MM_fnc_getTeamMapColor;
            };
        } else {
            _icon = "iconExplosiveGP";
            _size = 30;
            _color = MM_var_colorBlack;
        };

        _disp drawicon [_icon, _color, _pos, _size, _size, _dir, "", 1];

        if (!_isGps && {MM_var_showUnitNames} && {!MM_var_showUnitNamesOnlyOnHover || {!(isNil "_mousePos") && {((_disp ctrlMapWorldToScreen _pos) distance _mousePos) < 0.02}}}) then {
            _textPos = _pos vectorAdd [(44 * _ctrlMapScale * MM_var_mapScaleFactor), 0, 0];
            _name = _x getVariable ["MM_var_name", ""];

            _disp drawicon ["iconManVirtual", [1, 1, 1, 1], _textPos, 0, 0, 0, _name, 2, 0.033];
        };
    } forEach _units;

    {
        _veh = _x;
        _size = 16 * ((getMass _veh) ^ 0.04);
        _pos = getPosATLVisual _veh;
        _icon = [_veh] call MM_fnc_getIcon;
        _dir = getDirVisual _veh;
        _crew = [_veh] call MM_fnc_getCrew;
        _crewInPerson = crew _veh;
        _crewAlive = [];
        _crewDead = [];

        {
            if (alive _x) then {
                _crewAlive pushBack _x;
            } else {
                _crewDead pushBack _x;
            };
        } forEach _crew;

        _color = if (alive _veh) then {
            _groupUnitsInCrew = _crew arrayIntersect _groupUnits;

            if (_groupUnitsInCrew isEqualTo []) then {
                [if (_crew isEqualTo []) then {side (group ((crew _veh) select 0))} else {(_crew select 0) getVariable ["MM_var_side", sideUnknown]}] call MM_fnc_getTeamMapColor
            } else {
                if (player in _groupUnitsInCrew) then {
                    MM_var_colorYellow
                } else {
                    MM_var_colorWhite
                }
            }
        } else {
            MM_var_colorBlack
        };

        _disp drawicon [_icon, _color, _pos, _size, _size, _dir, "", 1];

        if (!_isGps && {MM_var_showUnitNames} && {!MM_var_showUnitNamesOnlyOnHover || {!(isNil "_mousePos") && {((_disp ctrlMapWorldToScreen _pos) distance _mousePos) < 0.02}}}) then {
            _crewFirstTwo = _crew select [0, 2];

            {
                if (alive _x) then {
                    _crewAlive deleteAt 0;
                } else {
                    _crewDead deleteAt 0;
                };
            } forEach _crewFirstTwo;

            _text = [
                (getText (configfile >> "CfgVehicles" >> (typeOf _veh) >> "displayName")),
                (if (unitIsUav _veh) then {" (AI)"} else {""}),
                (
                    if ((count _crew) > 0) then {
                        [" [", "]"] joinString (
                            (
                                (
                                    (_crewFirstTwo apply {
                                        [(_x getVariable ["MM_var_name", ""]),
                                        (
                                            if (alive _x) then {
                                                if ((getConnectedUAV _x) isEqualTo _veh) then {
                                                    if (_x in _crewInPerson) then {
                                                        " (crew + remote)"
                                                    } else {
                                                        " (remote)"
                                                    }
                                                    
                                                } else {
                                                    ""
                                                }
                                            } else {
                                                " (dead)"
                                            }
                                        )
                                        ] joinString ""
                                    }) +
                                    [
                                        (if !(_crewAlive isEqualTo []) then {["+ ", (str (count _crewAlive)), " alive"] joinString ""} else {""}),
                                        (if !(_crewDead isEqualTo []) then {["+ ", (str (count _crewDead)), " dead"] joinString ""} else {""})
                                    ]
                                ) select {
                                    (count _x) > 0
                                }
                            ) joinString ", "
                        )
                    } else {
                        ""
                    }
                )
            ] joinString "";

            _textPos = _pos vectorAdd [(2.4 * _ctrlMapScale * MM_var_mapScaleFactor * _size), 0, 0];
            _disp drawicon [_icon, MM_var_colorWhite, _textPos, 0, 0, 0, _text, 2, 0.033];
        };
    } forEach _vehicles;

    {
        _pos = getPosATLVisual _x;
        _driver = driver _x;
        _color = if (alive _driver) then {
            if (_driver in _groupUnits) then {
                if (_driver == player) then {
                    MM_var_colorYellow
                } else {
                    MM_var_colorWhite
                }
            } else {
                [_driver getVariable ["MM_var_side", sideUnknown]] call MM_fnc_getTeamMapColor
            }
        } else {
            MM_var_colorBlack
        };

        _disp drawicon ["iconParachute", _color, _pos, 16, 16, 0, "", 1];

        if (!_isGps && {MM_var_showUnitNames} && {!MM_var_showUnitNamesOnlyOnHover || {!(isNil "_mousePos") && {((_disp ctrlMapWorldToScreen _pos) distance _mousePos) < 0.02}}}) then {
            _textPos = _pos vectorAdd [(38.4 * _ctrlMapScale * MM_var_mapScaleFactor), 0, 0];
            _name = _driver getVariable ["MM_var_name", ""];

            _disp drawicon ["iconParachute", MM_var_colorWhite, _textPos, 0, 0, 0, _name, 2, 0.033];
        };
    } forEach _parachutes;
};

MM_fnc_entityInitClient = {
    params ["_entity"];

    if !isMultiplayer then {
        _entity setVariable ["MM_var_name", ([_entity] call MM_fnc_getName)];
		_entity setVariable ["MM_var_side", (side (group _entity))];
    };

    _entity addEventHandler ["Deleted", {
        params ["_entity"];

        _sideStr = [_entity getVariable ["MM_var_side", sideUnknown]] call MM_fnc_getSideString;
        _entity call (compile (["MM_var_units", _sideStr, " deleteAt (MM_var_units", _sideStr," find _this);"] joinString ""));
    }];

    _varStr = ["MM_var_units", ([side (group _entity)] call MM_fnc_getSideString)] joinString "";
    
    if ((random 1) < 0.01) then {
        call (compile ([_varStr, " = ", _varStr, " - [objNull];"] joinString ""));
    };

    _entity call (compile ([_varStr, " pushBackUnique _this;"] joinString ""));
};

MM_fnc_startMapMarkerClient = {
    call {
        if (MM_var_drawEhIds isEqualTo []) then {
            MM_var_clientRunning = true;

            {
                [_x] call MM_fnc_entityInitClient;
            } forEach (entities [["CAManBase"], [""], true, false]);

            [] spawn {
                waitUntil {!(isNil "MM_var_clientInitDone") && !(isNull player) && {!(isNull (findDisplay 46))}};

                MM_var_entityRespawnedEhId = addMissionEventHandler ["EntityRespawned", {params ["_newEntity"]; [_newEntity] call MM_fnc_entityInitClient;}];
                MM_var_drawEhIds pushBack (((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["Draw", {[(_this select 0), getMousePosition, false] call MM_fnc_drawIcons}]);

                {
                    MM_var_drawEhIds pushBack (_x ctrlAddEventHandler ["Draw", {[(_this select 0), nil, true] call MM_fnc_drawIcons}]);
                } forEach ([311, 101] call MM_fnc_findControlArray);

                MM_var_uavTerminalLoopScript = [] spawn {
                    waitUntil {
                        waitUntil {!(isNull (findDisplay 160))};
                        ((findDisplay 160) displayCtrl 51) ctrlAddEventHandler ["Draw", {[(_this select 0), getMousePosition, false] call MM_fnc_drawIcons}];
                        waitUntil {isNull (findDisplay 160)};
                        false
                    };
                };
            };
        };
    };
};

MM_fnc_stopMapMarkerClient = {
    call {
        if !(MM_var_drawEhIds isEqualTo []) then {
            MM_var_clientRunning = false;

            terminate MM_var_uavTerminalLoopScript;
            MM_var_uavTerminalLoopScript = scriptNull;

            MM_var_unitsWest = [];
            MM_var_unitsEast = [];
            MM_var_unitsGuer = [];
            MM_var_unitsCiv = [];

            removeMissionEventHandler ["EntityRespawned", MM_var_entityRespawnedEhId];
            MM_var_entityRespawnedEhId = -1;

            {
                _x ctrlRemoveEventHandler ["Draw", (MM_var_drawEhIds select _forEachIndex)];
            } forEach ([(findDisplay 12) displayCtrl 51] + ([311, 101] call MM_fnc_findControlArray));
            
            MM_var_drawEhIds = [];
        };
    };
};

MM_var_clientInitDone = true;