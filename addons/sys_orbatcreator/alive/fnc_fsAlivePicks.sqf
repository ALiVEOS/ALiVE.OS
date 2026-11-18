#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsAlivePicks);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsAlivePicks

Description:
Every list the faction declares to ALiVE, as refs: a vehicle id ("v3") or an
outside class ("#Class"). A list set by hand is used as it is; one still in
alive.auto is worked out from the faction's vehicles:
    supplies     - the crates (ALiVE_fnc_fsAliveCrates), then alive.suppliesExtra
    transport    - unarmed trucks and cars with 2 or more seats, trucks first
    airTransport - helicopters with 2 or more seats
    supports     - ammo, fuel, repair and medical vehicles
    aa           - anti-air vehicles
    containers   - never worked out: alive.containers, usually empty
A list that comes out empty is not written, so ALiVE keeps using its side's.

Parameters:
    _faction - HASHMAP - the studio faction
    _crates  - ARRAY - optional, the crates from ALiVE_fnc_fsAliveCrates

Returns:
    HASHMAP - list name to refs, for supplies, transport, airTransport,
              supports, aa and containers

Examples:
    (begin example)
    private _transport = ([_faction] call ALiVE_fnc_fsAlivePicks) get "transport";
    (end)

See Also:
    ALiVE_fnc_fsAliveCrates, ALiVE_fnc_fsAutoKind

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_faction", createHashMap, [createHashMap]], ["_crates", nil, [[]]]];

private _alive = _faction getOrDefault ["alive", createHashMap];
private _auto = _alive getOrDefault ["auto", FS_ALIVE_LISTS];
if (isNil "_crates") then { _crates = ([_faction] call ALiVE_fnc_fsAliveCrates) select 0 };

private _vehicles = _faction getOrDefault ["vehicles", createHashMap];
private _kinds = (_faction getOrDefault ["vehicleOrder", []]) apply { [_x, [_vehicles get _x] call ALiVE_fnc_fsAutoKind] };
private _base = { (_vehicles get _this) getOrDefault ["base", ""] };
// a top-level turret with a weapon, not a passenger seat
private _armed = {
    private _cfg = configFile >> "CfgVehicles" >> (_this call _base);
    ("true" configClasses (_cfg >> "Turrets")) findIf {
        getNumber (_x >> "isPersonTurret") == 0 && {(getArray (_x >> "weapons")) findIf { !((toLower _x) find "horn" >= 0) && {!((toLower _x) find "smoke" >= 0)} } >= 0}
    } >= 0
};

private _out = createHashMap;
_out set ["supplies", (_crates apply { "#" + (_x getOrDefault ["class", ""]) }) + ((_alive getOrDefault ["suppliesExtra", []]) apply { "#" + _x })];
_out set ["containers", (_alive getOrDefault ["containers", []]) apply { "#" + _x }];

private _worked = createHashMapFromArray [
    ["transport", {
        private _list = (_kinds select {
            (_x select 1 select 1) >= 2 && {(_x select 1 select 0) in ["carrier_soft", "car"]} && {!((_x select 0) call _armed)}
        }) apply { _x select 0 };
        (_list select { ((_x call _base) isKindOf ["Truck_F", configFile >> "CfgVehicles"]) }) + (_list select { !((_x call _base) isKindOf ["Truck_F", configFile >> "CfgVehicles"]) })
    }],
    ["airTransport", { (_kinds select { (_x select 1 select 0) isEqualTo "heli" && {(_x select 1 select 1) >= 2} }) apply { _x select 0 } }],
    ["supports", { (_kinds select { (_x select 1 select 0) isEqualTo "support" }) apply { _x select 0 } }],
    ["aa", { (_kinds select { (_x select 1 select 0) isEqualTo "aa" }) apply { _x select 0 } }]
];
{
    _out set [_x, if (_x in _auto) then { call (_worked get _x) } else { +(_alive getOrDefault [_x, []]) }];
} forEach FS_ALIVE_REFLISTS;

_out
