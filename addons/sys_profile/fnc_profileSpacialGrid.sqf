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

        ["#create", {
            private _combatSectors = [];

            for "_i" from 1 to (count (_self get "sectors")) do {
                _combatSectors pushBack [[],[],[]];
            };

            _self set ["combatSectors", _combatSectors];
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

                if ((_profileData select 5) == "entity" && {!(_profileData select 30)}) then {
                    private _coords = _self call ["posToCoords", _position];

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

            if ((_profileData select 5) == "entity" && {!(_profileData select 30)}) then {
                private _coords = _self call ["posToCoords", _position];

                if !(_coords isEqualTo [-1,-1]) then {
                    private _sideIndex = switch (_profileData select 3) do {
                        case "EAST": {0};
                        case "WEST": {1};
                        case "GUER": {2};
                        default {-1};
                    };

                    if (_sideIndex != -1) then {
                        private _sectorsInColumn = (_self get "maxSector") select 0;
                        private _sectorIndex = (_coords select 0) + ((_coords select 1) * _sectorsInColumn);
                        private _combatSector = ((_self get "combatSectors") select _sectorIndex) select _sideIndex;
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

            if (_oldCoords isEqualTo _newCoords) then {
                if !(_oldCoords isEqualTo [-1,-1]) then {
                    private _sectorIndex = (_oldCoords select 0) + ((_oldCoords select 1) * _sectorsInColumn);
                    private _combatSector = (_combatSectors select _sectorIndex) select _sideIndex;
                    private _combatIndex = _combatSector findIf {(_x select 1) == _profileID};

                    if (_combatIndex != -1) then {
                        _combatSector set [_combatIndex, [_newPos,_profileID,_profile]];
                    };
                };
            } else {
                if !(_oldCoords isEqualTo [-1,-1]) then {
                    private _oldSectorIndex = (_oldCoords select 0) + ((_oldCoords select 1) * _sectorsInColumn);
                    private _oldCombatSector = (_combatSectors select _oldSectorIndex) select _sideIndex;
                    private _combatIndex = _oldCombatSector findIf {(_x select 1) == _profileID};

                    if (_combatIndex != -1) then {
                        _oldCombatSector deleteAt _combatIndex;
                    };
                };

                if !(_newCoords isEqualTo [-1,-1]) then {
                    private _newSectorIndex = (_newCoords select 0) + ((_newCoords select 1) * _sectorsInColumn);
                    ((_combatSectors select _newSectorIndex) select _sideIndex) pushBack [_newPos,_profileID,_profile];
                };
            };
        }],

        ["onClear", {
            {
                {
                    _x resize 0;
                } forEach _x;
            } forEach (_self get "combatSectors");
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
