/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_combatSupportAddClientMenu

Description:
Installs the Combat Support client interface on the LOCAL player: the "Talk To
Pilot" action array, the addActions + Respawn re-add, and the main flexiMenu
(the Command Support tablet menu that opens ALIVE_fnc_CombatSupportMenuDef).

Called from two places so EVERY tablet-holder gets the menu, not only the first:
  - the module init (fnc_combatSupport "init" case) for clients present at start;
  - XEH_postInit for JIP / late-join clients, which never run the one-shot
    BIS_fnc_initModules pass and so otherwise never get the menu installed (#940;
    same class as the #937 civilian-interaction JIP fix).

Idempotent: guarded by the client-local ALiVE_CS_menuInstalled flag so the two
callers (or a present-at-start client that also runs the postInit fallback)
never double-install.

Parameters:
none

Returns:
nil

Author:
Gunny
Jman
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {};
if (!isNil "ALiVE_CS_menuInstalled" && {ALiVE_CS_menuInstalled}) exitWith {};
if (isNil "NEO_radioLogic") exitWith {};

// #940 follow-up: publish this client's fixed slot side to the server so the
// single-operator slot (fnc_combatSupport) is keyed by the same playerSide the
// client reads, immune to a transient captive/renegade side flip.
player setVariable ["ALiVE_CS_playerSide", playerSide, true];

waituntil {!isnull player};

NEO_radioLogic setVariable ["NEO_radioPlayerActionArray",
    [
        [
            ("<t color=""#700000"">" + ("Talk To Pilot") + "</t>"),
            {
                private _caller = _this select 1;
                private _vehicle = nil;

                if (vehicle _caller != _caller) then {
                    _vehicle = vehicle _caller;
                }
                else {
                    _vehicle = cursorTarget;
                };

                ["talk"] call ALIVE_fnc_radioAction;
                NEO_radioLogic setVariable ["NEO_radioTalkWithPilot", _vehicle];
            },
            "talk",
            -1,
            false,
            true,
            "",
            "
                private _vehicle = nil;
                private _vehicle_found = false;

                {
                    if (_x select 0 == cursorTarget && {_this distance cursorTarget <= 50}) exitWith {
                        _vehicle = _x select 0;
                    };

                    if (_x select 0 == vehicle _this) exitWith {
                        _vehicle = _x select 0;
                    };

                } forEach (NEO_radioLogic getVariable [format [""NEO_radioTrasportArray_%1"", playerSide], []]);

                if (!isNil ""_vehicle"" && {alive (driver _vehicle)}) then {
                    _vehicle_found = true;
                };

                _vehicle_found;
            "
        ],
        // Medevac (#694): on a helicopter waiting at its landing zone, load the group's wounded
        // within 50 m, and send it off.
        [
            ("<t color=""#700000"">" + ("Load Wounded") + "</t>"),
            {
                private _caller = _this select 1;
                private _heli = if (vehicle _caller != _caller) then { vehicle _caller } else { cursorTarget };
                private _hurt = (units group _caller) select {
                    alive _x && {vehicle _x == _x} && {(_x distance _heli) < 50} && {
                        (damage _x) > 0.1 || {(lifeState _x) == "INCAPACITATED"} || {_x getVariable ["ACE_isUnconscious", false]}
                        || {count (_x getVariable ["ace_medical_openWounds", []]) > 0}
                    }
                };
                private _room = _heli emptyPositions "cargo";
                _hurt = _hurt select [0, _room];
                // moved in without being assigned: a pilot landed to pick men up lifts off by himself
                // once everyone assigned to the aircraft is aboard
                { [_x, _heli] remoteExecCall ["moveInCargo", _x] } forEach _hurt;
                [localize "STR_ALIVE_COMBATSUPPORT", format ["%1 wounded loaded, %2 seats left.", count _hurt, (_room - count _hurt) max 0]] call ALIVE_fnc_sendHint;
            },
            "medevacLoad",
            -1,
            false,
            true,
            "",
            "
                private _heli = if (vehicle _this != _this) then { vehicle _this } else { cursorTarget };
                !isNull _heli && {(_heli getVariable [""NEO_radioMedevacState"", """"]) == ""LZ""} && {(_this distance _heli) < 25}
            "
        ],
        [
            ("<t color=""#700000"">" + ("Clear To Leave") + "</t>"),
            {
                private _caller = _this select 1;
                private _heli = if (vehicle _caller != _caller) then { vehicle _caller } else { cursorTarget };
                _heli setVariable ["NEO_radioMedevacClear", true, true];
            },
            "medevacClear",
            -1,
            false,
            true,
            "",
            "
                private _heli = if (vehicle _this != _this) then { vehicle _this } else { cursorTarget };
                !isNull _heli && {(_heli getVariable [""NEO_radioMedevacState"", """"]) == ""LZ""} && {(_this distance _heli) < 25}
            "
        ]
    ]
];

//Add Neo actions
{player addAction _x} foreach (NEO_radioLogic getVariable "NEO_radioPlayerActionArray");
player addEventHandler ["Respawn", { {(_this select 0) addAction _x } foreach (NEO_radioLogic getVariable "NEO_radioPlayerActionArray") }];

if (isNil "SELF_INTERACTION_KEY") then {SELF_INTERACTION_KEY = [221,[false,false,false]]};

// if A2 - ACE spectator enabled, seto to allow exit
if(!isNil "ace_fnc_startSpectator") then {ace_sys_spectator_can_exit_spectator = true};

// initialise main menu
[
        "player",
        [] call ALiVE_fnc_menuKeys,
        -9500,
        [
                "call ALIVE_fnc_CombatSupportMenuDef",
                ["main", "alive_flexiMenu_rscPopup"]
        ]
] call CBA_fnc_flexiMenu_Add;

ALiVE_CS_menuInstalled = true;
