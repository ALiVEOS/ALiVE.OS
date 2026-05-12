#include "\x\alive\addons\sys_factioncompiler\script_component.hpp"
SCRIPT(factionCompilerFindVehicleType);

params [
    ["_cargoslots", 0, [0]],
    ["_fac", nil],
    ["_type", nil],
    ["_noWeapons", false, [true]],
    ["_minScope", 1, [0]]
];

private _factions = if (_fac isEqualType []) then {_fac} else {[_fac]};
private _result = [];
private _typeDefined = !(isNil "_type") && {!(_type isEqualTo "")};

{
    if (_x isEqualType "" && {[_x] call ALIVE_fnc_factionCompilerIsCompiledFaction}) then {
        private _factionData = [_x] call ALIVE_fnc_factionCompilerGetFactionData;
        if !(isNil "_factionData") then {
            {
                private _class = _x;
                private _cfg = configFile >> "CfgVehicles" >> _class;

                if (isClass _cfg) then {
                    if (getNumber (_cfg >> "scope") >= _minScope) then {
                        if (getNumber (_cfg >> "TransportSoldier") >= _cargoslots) then {
                            private _matchesType = true;
                            if (_typeDefined) then {
                                _matchesType = _class isKindOf _type;
                            };

                            if (_matchesType) then {
                                if (_noWeapons) then {
                                    if ([_class] call ALIVE_fnc_isArmed) then {
                                        _result pushBackUnique _class;
                                    };
                                } else {
                                    _result pushBackUnique _class;
                                };
                            };
                        };
                    };
                };
            } forEach (([_factionData, "unitClasses", []] call ALIVE_fnc_hashGet) + ([_factionData, "vehicleClasses", []] call ALIVE_fnc_hashGet));
        };
    };
} forEach _factions;

_result

