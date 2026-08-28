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
            private _combatSectors = [];

            for "_i" from 1 to (count (_self get "sectors")) do {
                _combatSectors pushBack [[],[],[]];
            };

            _self set ["combatSectors", _combatSectors];
            _self set ["profileSectors", createHashMap];
            (_self get "queryState") pushBack _combatSectors;
        }],

        ["onInsert", {
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
                            ((_combatSectors select _sectorIndex) select _sideIndex) pushBack [
                                _position,
                                _profileData select 4,
                                _profile
                            ];
                        };
                    };
                };
            } forEach _points;
        }],

        ["onRemove", {
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
                        private _profileID = _profileData select 4;
                        private _combatIndex = _combatSector findIf {(_x select 1) == _profileID};

                        if (_combatIndex != -1) then {
                            _combatSector deleteAt _combatIndex;
                        };
                    };
                };
            };
        }],

        ["onMove", {
            private _oldPos = _this select 0;
            private _newPos = _this select 1;
            private _profile = _this select 2;
            private _updated = _this select 3;
            private _oldCoords = _this select 4;
            private _newCoords = _this select 5;
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

            private _sectorsInColumn = (_self get "maxSector") select 0;
            private _combatSectors = _self get "combatSectors";
            private _profileID = _profileData select 4;

            if (count _this < 8) then {
                if (_oldSectorIndex == -1 && {!(_oldCoords isEqualTo [-1,-1])}) then {
                    _oldSectorIndex = (_oldCoords select 0) + ((_oldCoords select 1) * _sectorsInColumn);
                };

                if (_newSectorIndex == -1 && {!(_newCoords isEqualTo [-1,-1])}) then {
                    _newSectorIndex = (_newCoords select 0) + ((_newCoords select 1) * _sectorsInColumn);
                };
            };

            if (_oldSectorIndex == _newSectorIndex) then {
                if (_oldSectorIndex != -1) then {
                    private _combatSector = (_combatSectors select _oldSectorIndex) select _sideIndex;
                    private _combatIndex = _combatSector findIf {(_x select 1) == _profileID};

                    if (_combatIndex != -1) then {
                        _combatSector set [_combatIndex, [_newPos,_profileID,_profile]];
                    };
                };
            } else {
                if (_oldSectorIndex != -1) then {
                    private _oldCombatSector = (_combatSectors select _oldSectorIndex) select _sideIndex;
                    private _combatIndex = _oldCombatSector findIf {(_x select 1) == _profileID};

                    if (_combatIndex != -1) then {
                        _oldCombatSector deleteAt _combatIndex;
                    };
                };

                if (_newSectorIndex != -1) then {
                    ((_combatSectors select _newSectorIndex) select _sideIndex) pushBack [_newPos,_profileID,_profile];
                };
            };
        }],

        ["remove", {
            private _point = _this;
            private _profile = _point select 1;
            private _profileID = _profile select 2 select 4;
            private _profileSectors = _self get "profileSectors";
            private _sectorIndex = _profileSectors getOrDefault [_profileID, -1];
            private _result = false;

            if (_sectorIndex != -1) then {
                private _sector = (_self get "sectors") select _sectorIndex;
                private _index = _sector findIf {((_x select 1) select 2 select 4) == _profileID};

                if (_index != -1) then {
                    _sector deleteAt _index;
                    _result = true;
                };
            };

            if ("onRemove" in _self) then {
                _self call ["onRemove", [_point select 0, _profile, _sectorIndex]];
            };

            _profileSectors deleteAt _profileID;
            _result
        }],

        ["move", {
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

            if (_oldSectorIndex == _newSectorIndex) then {
                private _sector = (_self get "sectors") select _oldSectorIndex;
                private _index = _sector findIf {((_x select 1) select 2 select 4) == _profileID};

                if (_index != -1) then {
                    _sector set [_index, [_newPos,_profile]];
                    _updated = true;
                };
            } else {
                private _oldSector = (_self get "sectors") select _oldSectorIndex;
                private _index = _oldSector findIf {((_x select 1) select 2 select 4) == _profileID};

                if (_index != -1) then {
                    _oldSector deleteAt _index;

                    if (_newSectorIndex != -1) then {
                        ((_self get "sectors") select _newSectorIndex) pushBack [_newPos,_profile];
                        _profileSectors set [_profileID, _newSectorIndex];
                    } else {
                        _profileSectors deleteAt _profileID;
                    };

                    _updated = true;
                };
            };

            if ("onMove" in _self) then {
                _self call ["onMove", [_oldPos,_newPos,_profile,_updated,[-1,-1],_newCoords,_oldSectorIndex,_newSectorIndex]];
            };
        }],

        ["onClear", {
            {
                {
                    _x resize 0;
                } forEach _x;
            } forEach (_self get "combatSectors");

            _self set ["profileSectors", createHashMap];
        }],

        ["findCombatTargets", {
            private _findCombatTargetsScope = createProfileScope "ALiVE spacialGrid: findCombatTargets";
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
                            _candidates append (_combatSector select _x);
                        } forEach _enemySideIndices;
                    };
                };
            };

            private _targets = _candidates select {
                !((_x select 2) select 2 select 1)
                && {((_x select 0) distance2D _center) <= _radius}
            };

            private _result = _targets apply {_x select 1};
            _findCombatTargetsScope = nil;
            _result
        }]
    ];
};

private _operation = _this param [1, ""];

if (_operation != "create") exitWith {nil};

private _args = _this param [2, []];
createHashMapObject [ALiVE_profileSpacialGridClass, _args]
