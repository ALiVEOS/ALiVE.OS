/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_orderMenu
Description:
    Adds the AdvCiv player order action menu to a civilian unit. Attaches
    addAction entries for all available direct commands: Follow Me, Stay Here,
    Go Home, Hands Up, Get Down, Calm Down, Kneel, and Get In Nearby Vehicle.
    The Get In action uses a dynamic condition evaluated each time the action
    menu is displayed, so it accurately reflects vehicles that arrive, depart,
    or change occupancy after the menu was first attached. If the ALiVE civilian
    interaction handler is present, appends a visual separator and an ALiVE
    Interact dialog option. All actions are range-gated by
    ALiVE_advciv_orderMenuRange and are only visible when the civilian is alive.
Parameters:
    _this select 0: OBJECT - The civilian unit to attach actions to
Returns:
    Nil
See Also:
    ALIVE_fnc_advciv_react, ALIVE_fnc_advciv_initUnit
Author:
    Jman (advanced civs)
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!alive _unit}) exitWith {};
if (_unit getVariable ["ALiVE_advciv_blacklist", false]) exitWith {};
if (_unit getVariable ["ALiVE_advciv_orderMenuAdded", false]) exitWith {};   // Don't double-add

// Skip the eight AdvCiv quick-command addActions unless CLASSIC mode
// is selected. In AUTO / DIALOG / ACE modes these verbs reach the
// player via the dialog's new AdvCiv command row (or the ACE branch
// once sys_acemenu's civilian integration lands), replacing the
// scroll-wheel sprawl with a single interaction entry point.
if ((missionNamespace getVariable ["ALiVE_amb_civ_population_UIMode", "AUTO"]) != "CLASSIC") exitWith {};

_unit setVariable ["ALiVE_advciv_orderMenuAdded", true];

private _range = ALiVE_advciv_orderMenuRange;
private _baseCondition = format ["alive _target && !(_target getVariable ['ALiVE_advciv_blacklist', false]) && _this distance _target < %1", _range];

// --- FOLLOW ME ---
_unit addAction [
    "<t color='#00FF00'>Follow Me</t>",
    {
        params ["_target", "_caller"];
        [_target, "FOLLOW"] call ALiVE_fnc_advciv_react;
    },
    [],
    6,
    true,
    true,
    "",
    _baseCondition,
    _range
];

// --- STAY HERE ---
_unit addAction [
    "<t color='#00FF00'>Stay Here</t>",
    {
        params ["_target", "_caller"];
        [_target, "STAY"] call ALiVE_fnc_advciv_react;
    },
    [],
    6,
    true,
    true,
    "",
    _baseCondition,
    _range
];

// --- GO HOME ---
_unit addAction [
    "<t color='#00FF00'>Go Home</t>",
    {
        params ["_target", "_caller"];
        [_target, "GOHOME"] call ALiVE_fnc_advciv_react;
    },
    [],
    6,
    true,
    true,
    "",
    _baseCondition,
    _range
];

// --- HANDS UP ---
_unit addAction [
    "<t color='#00FF00'>Hands Up</t>",
    {
        params ["_target", "_caller"];
        [_target, "HANDSUP"] call ALiVE_fnc_advciv_react;
    },
    [],
    6,
    true,
    true,
    "",
    _baseCondition,
    _range
];

// --- GET DOWN ---
_unit addAction [
    "<t color='#00FF00'>Get Down</t>",
    {
        params ["_target", "_caller"];
        [_target, "GETDOWN"] call ALiVE_fnc_advciv_react;
    },
    [],
    6,
    true,
    true,
    "",
    _baseCondition,
    _range
];

// --- CALM DOWN ---
_unit addAction [
    "<t color='#00FF00'>Calm Down</t>",
    {
        params ["_target", "_caller"];
        [_target, "CALM"] call ALiVE_fnc_advciv_react;
    },
    [],
    6,
    true,
    true,
    "",
    _baseCondition,
    _range
];

// --- KNEEL ---
_unit addAction [
    "<t color='#00FF00'>Kneel</t>",
    {
        params ["_target", "_caller"];
        [_target, "KNEEL"] call ALiVE_fnc_advciv_react;
    },
    [],
    6,
    true,
    true,
    "",
    _baseCondition,
    _range
];

// --- GET IN NEARBY VEHICLE (dynamic) ---
// The condition string is re-evaluated every time the player's action menu
// is displayed, so the action appears and disappears as vehicles arrive, are
// destroyed, driven off, or become occupied — unlike a static init-time scan
// which goes stale the moment anything changes. The callback picks the closest
// qualifying vehicle at the moment of the click. Qualification criteria are
// kept consistent with the vehicle escape check in fnc_advciv_brainTick.
_unit addAction [
    "<t color='#00FF00'>Get In Nearby Vehicle</t>",
    {
        params ["_target", "_caller"];
        private _vehicles = nearestObjects [_target, ["Car","Truck","Motorcycle","Helicopter","Plane","Ship"], 15];
        _vehicles = _vehicles select {
            alive _x
            && {canMove _x}
            && {locked _x < 2}
            && {isNull driver _x}
            && {speed _x < 1}
            && {fuel _x > 0}
            && {!([_x] call ALiVE_fnc_advciv_isVehicleProtected)}
        };
        if (count _vehicles > 0) then {
            _vehicles = [_vehicles, [], { _target distance _x }, "ASCEND"] call BIS_fnc_sortBy;
            [_target, "GETIN", (_vehicles select 0)] call ALiVE_fnc_advciv_react;
        };
    },
    [],
    6,
    true,
    true,
    "",
    // Condition: visible only when a qualifying vehicle is actually within range
    format [
        "alive _target && {!(_target getVariable ['ALiVE_advciv_blacklist', false])} && {_this distance _target < %1} && {
            private _v = nearestObjects [_target, ['Car','Truck','Motorcycle','Helicopter','Plane','Ship'], 15];
            _v = _v select { alive _x && {canMove _x} && {locked _x < 2} && {isNull driver _x} && {speed _x < 1} && {fuel _x > 0} };
            count _v > 0
        }",
        _range
    ],
    _range
];

// =================================================================
// ALiVE INTERACT OPTION (appended if the interaction handler exists)
// Shown with a gold separator to visually distinguish it from the
// AdvCiv quick commands above
// =================================================================
if (!isNil "ALiVE_civInteractHandler") then {
    _unit addAction [
        "<t color='#FFD700'>────────────────</t>",
        {},
        [],
        5,
        false,
        false,
        "",
        "false",   // Condition always false — purely a visual separator
        _range
    ];

    _unit addAction [
        "<t color='#FFD700'>ALiVE: Interact (Dialog)</t>",
        {
            params ["_target", "_caller"];
            [ALiVE_civInteractHandler, "openMenu", _target] call ALiVE_fnc_civInteract;
        },
        [],
        5,
        true,
        true,
        "",
        _baseCondition,
        _range
    ];
};
