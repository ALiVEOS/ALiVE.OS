#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileSpacialGrid);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileSpacialGrid

Description:
Creates a profile-aware spatial grid with a side-partitioned combat index.

Parameters:
    Nil
    String - "create"
    Array - Origin, grid size, and sector size

Returns:
    HashMapObject - Profile spatial grid instance

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

if (isNil "ALiVE_spacialGridClass") then {
    [] call ALiVE_fnc_spacialGrid;
};

if (isNil "ALiVE_profileSpacialGridClass") then {
    ALiVE_profileSpacialGridClass = [
        ["#base", ALiVE_spacialGridClass],
        ["#type", "ALiVE_ProfileSpacialGrid"],
        ["#flags", ["sealed"]],

        ["combatSectors", []],
        ["profileSectors", []],

        ["#create", {
            private _sectors = _self get "sectors";
            private _combatSectors = [];

            for "_i" from 0 to ((count _sectors) - 1) do {
                // Profiles are indexed by ID. This gives movement/removal a
                // direct lookup while keeping the outer sector array dense.
                _sectors set [_i, createHashMap];
                _combatSectors pushBack [createHashMap,createHashMap,createHashMap];
            };

            _self set ["combatSectors", _combatSectors];
            _self set ["profileSectors", createHashMap];
            (_self get "queryState") pushBack _combatSectors;
        }],

        ["insert", {
            PROFILE_SCOPE(INSERT, "ALiVE_sys_profile_fnc_profileSpacialGrid: insert")

            private _points = _this;
            private _sectorsInColumn = (_self get "maxSector") select 0;
            private _sectors = _self get "sectors";

            {
                private _position = _x select 0;
                private _profile = _x select 1;
                private _coords = _self call ["posToCoords", _position];

                if !(_coords isEqualTo [-1,-1]) then {
                    private _sectorIndex = (_coords select 0) + ((_coords select 1) * _sectorsInColumn);
                    private _profileID = _profile select 2 select 4;
                    (_sectors select _sectorIndex) set [_profileID, _profile];
                };
            } forEach _points;

            if ("onInsert" in _self) then {
                _self call ["onInsert", _points];
            };

            PROFILE_SCOPE_END(INSERT)
        }],

        ["onInsert", {
            PROFILE_SCOPE(ONINSERT, "ALiVE_sys_profile_fnc_profileSpacialGrid: onInsert")

            private _points = _this;
            private _sectorsInColumn = (_self get "maxSector") select 0;
            private _combatSectors = _self get "combatSectors";

            {
                private _position = _x select 0;
                private _profile = _x select 1;
                private _profileData = _profile select 2;
                private _coords = _self call ["posToCoords", _position];

                if !(_coords isEqualTo [-1,-1]) then {
                    private _sectorsInColumn = (_self get "maxSector") select 0;
                    private _sectorIndex = (_coords select 0) + ((_coords select 1) * _sectorsInColumn);
                    (_self get "profileSectors") set [_profileData select 4, _sectorIndex];
                };

                if ((_profileData select 5) == "entity" && {!(_profileData select 30)}) then {
                    if !(_coords isEqualTo [-1,-1]) then {
                        private _sideIndex = switch (_profileData select 3) do {
                            case "EAST": {0};
                            case "WEST": {1};
                            case "GUER": {2};
                            default {-1};
                        };

                        if (_sideIndex != -1) then {
                            private _sectorIndex = (_coords select 0) + ((_coords select 1) * _sectorsInColumn);
                            ((_combatSectors select _sectorIndex) select _sideIndex) set [
                                _profileData select 4,
                                _profile
                            ];
                        };
                    };
                };
            } forEach _points;

            PROFILE_SCOPE_END(OPERATION)
        }],

        ["onRemove", {
            PROFILE_SCOPE(ONREMOVE, "ALiVE_sys_profile_fnc_profileSpacialGrid: onRemove")

            private _position = _this select 0;
            private _profile = _this select 1;
            private _profileData = _profile select 2;
            private _mappedSectorIndex = _this param [2, -1];

            if ((_profileData select 5) == "entity" && {!(_profileData select 30)}) then {
                if (_mappedSectorIndex == -1 && {count _this < 3}) then {
                    private _coords = _self call ["posToCoords", _position];

                    if !(_coords isEqualTo [-1,-1]) then {
                        private _sectorsInColumn = (_self get "maxSector") select 0;
                        _mappedSectorIndex = (_coords select 0) + ((_coords select 1) * _sectorsInColumn);
                    };
                };

                if (_mappedSectorIndex != -1) then {
                    private _sideIndex = switch (_profileData select 3) do {
                        case "EAST": {0};
                        case "WEST": {1};
                        case "GUER": {2};
                        default {-1};
                    };

                    if (_sideIndex != -1) then {
                        private _combatSector = ((_self get "combatSectors") select _mappedSectorIndex) select _sideIndex;
                        _combatSector deleteAt (_profileData select 4);
                    };
                };
            };

            PROFILE_SCOPE_END(ONREMOVE)
        }],

        ["onMove", {
            PROFILE_SCOPE(ONMOVE, "ALiVE_sys_profile_fnc_profileSpacialGrid: onMove")

            private _profile = _this select 2;
            private _updated = _this select 3;
            private _oldSectorIndex = _this param [6, -1];
            private _newSectorIndex = _this param [7, -1];

            if (!_updated) exitWith {};

            private _profileData = _profile select 2;
            if ((_profileData select 5) != "entity" || {_profileData select 30}) exitWith {};

            private _sideIndex = switch (_profileData select 3) do {
                case "EAST": {0};
                case "WEST": {1};
                case "GUER": {2};
                default {-1};
            };

            if (_sideIndex == -1) exitWith {};

            private _combatSectors = _self get "combatSectors";
            private _profileID = _profileData select 4;

            if (_oldSectorIndex != -1) then {
                ((_combatSectors select _oldSectorIndex) select _sideIndex) deleteAt _profileID;
            };

            if (_newSectorIndex != -1) then {
                ((_combatSectors select _newSectorIndex) select _sideIndex) set [_profileID, _profile];
            };

            PROFILE_SCOPE_END(ONMOVE)
        }],

        ["remove", {
            PROFILE_SCOPE(REMOVE, "ALiVE_sys_profile_fnc_profileSpacialGrid: remove")

            private _point = _this;
            private _profile = _point select 1;
            private _profileID = _profile select 2 select 4;
            private _profileSectors = _self get "profileSectors";
            private _sectorIndex = _profileSectors getOrDefault [_profileID, -1];
            private _result = false;

            if (_sectorIndex != -1) then {
                private _sector = (_self get "sectors") select _sectorIndex;
                _sector deleteAt _profileID;
                _result = true;
            };

            if ("onRemove" in _self) then {
                _self call ["onRemove", [_point select 0, _profile, _sectorIndex]];
            };

            _profileSectors deleteAt _profileID;

            PROFILE_SCOPE_END(REMOVE)
            
            _result
        }],

        ["move", {
            PROFILE_SCOPE(MOVEOP, "ALiVE_sys_profile_fnc_profileSpacialGrid: move")

            private _oldPos = _this select 0;
            private _newPos = _this select 1;
            private _profile = _this select 2;
            private _profileID = _profile select 2 select 4;
            private _profileSectors = _self get "profileSectors";
            private _oldSectorIndex = _profileSectors getOrDefault [_profileID, -1];

            if (_oldSectorIndex == -1) exitWith {};

            private _newCoords = _self call ["posToCoords", _newPos];
            private _newSectorIndex = -1;
            private _updated = false;

            if !(_newCoords isEqualTo [-1,-1]) then {
                private _sectorsInColumn = (_self get "maxSector") select 0;
                _newSectorIndex = (_newCoords select 0) + ((_newCoords select 1) * _sectorsInColumn);
            };

            if (_oldSectorIndex != _newSectorIndex) then {
                ((_self get "sectors") select _oldSectorIndex) deleteAt _profileID;

                if (_newSectorIndex != -1) then {
                    ((_self get "sectors") select _newSectorIndex) set [_profileID, _profile];
                    _profileSectors set [_profileID, _newSectorIndex];
                } else {
                    _profileSectors deleteAt _profileID;
                };

                _updated = true;
            };

            if ("onMove" in _self) then {
                _self call ["onMove", [_oldPos,_newPos,_profile,_updated,[-1,-1],_newCoords,_oldSectorIndex,_newSectorIndex]];
            };

            PROFILE_SCOPE_END(MOVEOP)
        }],

        ["clear", {
            private _sectors = _self get "sectors";
            private _combatSectors = _self get "combatSectors";

            for "_i" from 0 to ((count _sectors) - 1) do {
                _sectors set [_i, createHashMap];
                _combatSectors set [_i, [createHashMap,createHashMap,createHashMap]];
            };

            if ("onClear" in _self) then {
                _self call ["onClear"];
            };
        }],

        ["onClear", {
            PROFILE_SCOPE(ONCLEAR, "ALiVE_sys_profile_fnc_profileSpacialGrid: onClear")

            _self set ["profileSectors", createHashMap];

            PROFILE_SCOPE_END(ONCLEAR)
        }],

        ["findInRange", {
            PROFILE_SCOPE(FINDINRANGE, "ALiVE_sys_profile_fnc_profileSpacialGrid: findInRange")

            private _center = _this select 0;
            private _radius = _this select 1;
            private _filter2D = _this param [2, false];
            private _returnItem = _this param [3, false];
            private _preciseDistance = _this param [4, true];
            private _queryState = _self get "queryState";
            private _originX = _queryState select 0;
            private _originY = _queryState select 1;
            private _maxBoundX = _queryState select 2;
            private _maxBoundY = _queryState select 3;
            private _inverseSectorSize = _queryState select 4;
            private _sectorsInColumn = _queryState select 5;
            private _sectors = _queryState select 6;
            private _originOffsetX = _queryState select 7;
            private _originOffsetY = _queryState select 8;
            private _centerX = _center select 0;
            private _centerY = _center select 1;
            private _queryMinX = _centerX - _radius;
            private _queryMinY = _centerY - _radius;
            private _queryMaxX = _centerX + _radius;
            private _queryMaxY = _centerY + _radius;
            private _result = [];

            if (
                _queryMaxX >= _originX &&
                {_queryMaxY >= _originY} &&
                {_queryMinX < _maxBoundX} &&
                {_queryMinY < _maxBoundY}
            ) then {
                private _minX = floor (((_queryMinX max _originX) + _originOffsetX) * _inverseSectorSize);
                private _minY = floor (((_queryMinY max _originY) + _originOffsetY) * _inverseSectorSize);
                private _maxX = floor (((_queryMaxX min (_maxBoundX - 1)) + _originOffsetX) * _inverseSectorSize);
                private _maxY = floor (((_queryMaxY min (_maxBoundY - 1)) + _originOffsetY) * _inverseSectorSize);

                for "_y" from _minY to _maxY do {
                    for "_x" from _minX to _maxX do {
                        _result append (values (_sectors select (_x + (_y * _sectorsInColumn))));
                    };
                };

                if (_preciseDistance) then {
                    if (!_filter2D) then {
                        _result = _result select {(((_x select 2) select 2) distance _center) <= _radius};
                    } else {
                        _result = _result select {(((_x select 2) select 2) distance2D _center) <= _radius};
                    };
                };

                if (!_returnItem) then {
                    _result = _result apply {[(_x select 2) select 2, _x]};
                };
            };

            PROFILE_SCOPE_END(FINDINRANGE)

            _result
        }],

        ["findCombatTargets", {
            PROFILE_SCOPE(FINDCOMBATTARGETS, "ALiVE_sys_profile_fnc_profileSpacialGrid: findCombatTargets")

            private _center = _this select 0;
            private _radius = _this select 1;
            private _enemySides = _this select 2;
            private _queryState = _self get "queryState";
            private _originX = _queryState select 0;
            private _originY = _queryState select 1;
            private _maxBoundX = _queryState select 2;
            private _maxBoundY = _queryState select 3;
            private _inverseSectorSize = _queryState select 4;
            private _sectorsInColumn = _queryState select 5;
            private _originOffsetX = _queryState select 7;
            private _originOffsetY = _queryState select 8;
            private _combatSectors = _queryState select 9;
            private _centerX = _center select 0;
            private _centerY = _center select 1;
            private _queryMinX = _centerX - _radius;
            private _queryMinY = _centerY - _radius;
            private _queryMaxX = _centerX + _radius;
            private _queryMaxY = _centerY + _radius;
            private _candidates = [];
            private _enemySideIndices = [];

            {
                private _sideIndex = switch (_x) do {
                    case "EAST": {0};
                    case "WEST": {1};
                    case "GUER": {2};
                    default {-1};
                };

                if (_sideIndex != -1) then {
                    _enemySideIndices pushBack _sideIndex;
                };
            } forEach _enemySides;

            if (
                _queryMaxX >= _originX &&
                {_queryMaxY >= _originY} &&
                {_queryMinX < _maxBoundX} &&
                {_queryMinY < _maxBoundY}
            ) then {
                private _minX = floor (((_queryMinX max _originX) + _originOffsetX) * _inverseSectorSize);
                private _minY = floor (((_queryMinY max _originY) + _originOffsetY) * _inverseSectorSize);
                private _maxX = floor (((_queryMaxX min (_maxBoundX - 1)) + _originOffsetX) * _inverseSectorSize);
                private _maxY = floor (((_queryMaxY min (_maxBoundY - 1)) + _originOffsetY) * _inverseSectorSize);

                for "_y" from _minY to _maxY do {
                    for "_x" from _minX to _maxX do {
                        private _sectorIndex = _x + (_y * _sectorsInColumn);
                        private _combatSector = _combatSectors select _sectorIndex;

                        {
                            _candidates append (values (_combatSector select _x));
                        } forEach _enemySideIndices;
                    };
                };
            };

            private _targets = _candidates select {
                !((_x select 2) select 1)
                && {(((_x select 2) select 2) distance2D _center) <= _radius}
            };

            private _result = _targets apply {_x select 2 select 4};

            PROFILE_SCOPE_END(FINDCOMBATTARGETS)

            _result
        }]
    ];
};

private _operation = _this param [1, ""];

if (_operation != "create") exitWith {nil};

private _args = _this param [2, []];
createHashMapObject [ALiVE_profileSpacialGridClass, _args]
