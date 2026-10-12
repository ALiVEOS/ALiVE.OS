#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobActions);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobActions

Description:
The player's FOB actions, on the scroll menu:
- Deploy FOB, standing within 8 m of a FOB kit for the player's side. The FOB goes 8 m in
  front of the player, facing the way they face.
- FOB Status, within 25 m of one of the side's FOBs: its name, state, tier and supply.
- Dismantle FOB, in the same place. It asks to be chosen again within 10 s before anything
  happens; the supply in the FOB is lost.

The conditions read a cache refreshed every half second, never the world, so an action
showing costs nothing per frame. The server checks everything again.

Parameters:
String - "init" to add the actions (again after a respawn), or an action name

Returns:
Nothing

Author:
Jman
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {};

params [["_op", "", [""]]];

switch (_op) do {

    case "init": {
        // The cache: the nearest kit for this side within 8 m, the nearest own FOB within 25 m
        if (isNil "ALiVE_FOB_cacheLoop") then {
            ALiVE_FOB_nearKit = objNull;
            ALiVE_FOB_nearFob = [];
            ALiVE_FOB_cacheLoop = [] spawn {
                while { true } do {
                    if (alive player) then {
                        private _side = str (side group player);
                        private _kits = (nearestObjects [player, ["All"], 8]) select {
                            private _t = _x getVariable "ALiVE_FOB_kit";
                            !isNil "_t" && {_t isEqualTo true || {_t isEqualTo _side}}
                        };
                        ALiVE_FOB_nearKit = _kits param [0, objNull];
                        private _mine = (missionNamespace getVariable ["ALiVE_FOB_registryMirror", []]) select {
                            (_x select 1) == _side && {player distance2D (_x select 3) <= 25}
                        };
                        ALiVE_FOB_nearFob = _mine param [0, []];
                    };
                    sleep 0.5;
                };
            };
        };

        private _ids = player getVariable ["ALiVE_FOB_actionIDs", []];
        { player removeAction _x } forEach _ids;
        _ids = [
            player addAction [localize "STR_ALIVE_FOB_ACTION_DEPLOY", { ["deploy"] call ALiVE_fnc_fobActions }, nil, 1.5, true, true, "",
                "!isNull ALiVE_FOB_nearKit && {vehicle _this == _this}"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_STATUS", { ["status"] call ALiVE_fnc_fobActions }, nil, 1.4, false, true, "",
                "ALiVE_FOB_nearFob isNotEqualTo []"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_DISMANTLE", { ["dismantle"] call ALiVE_fnc_fobActions }, nil, 0.5, false, true, "",
                "ALiVE_FOB_nearFob isNotEqualTo [] && {vehicle _this == _this}"]
        ];
        player setVariable ["ALiVE_FOB_actionIDs", _ids];

        if (isNil "ALiVE_FOB_respawnEH") then {
            ALiVE_FOB_respawnEH = player addEventHandler ["Respawn", { ["init"] call ALiVE_fnc_fobActions }];
        };
    };

    case "deploy": {
        if (isNull ALiVE_FOB_nearKit) exitWith {};
        private _pos = player getPos [8, getDir player];
        ["deploy", [ALiVE_FOB_nearKit, _pos, getDir player]] remoteExecCall ["ALiVE_fnc_fobRequest", 2];
    };

    case "status": {
        if (ALiVE_FOB_nearFob isEqualTo []) exitWith {};
        ALiVE_FOB_nearFob params ["", "", "_name", "", "_status", "_tier", "_supply", "_cap"];
        private _supplyText = if (_supply < 0) then { localize "STR_ALIVE_FOB_SUPPLY_FREE" } else { format ["%1 / %2", round _supply, round _cap] };
        [localize "STR_ALIVE_FOB", format [localize "STR_ALIVE_FOB_STATUS", _name, localize (format ["STR_ALIVE_FOB_STATE_%1", toUpper _status]), _tier, _supplyText]] call ALIVE_fnc_sendHint;
    };

    case "dismantle": {
        if (ALiVE_FOB_nearFob isEqualTo []) exitWith {};
        private _id = ALiVE_FOB_nearFob select 0;
        private _armed = missionNamespace getVariable ["ALiVE_FOB_dismantleArmed", ["", -100]];
        if ((_armed select 0) == _id && {time - (_armed select 1) <= 10}) then {
            ALiVE_FOB_dismantleArmed = ["", -100];
            ["dismantle", [_id]] remoteExecCall ["ALiVE_fnc_fobRequest", 2];
        } else {
            ALiVE_FOB_dismantleArmed = [_id, time];
            [localize "STR_ALIVE_FOB", format [localize "STR_ALIVE_FOB_DISMANTLE_CONFIRM", ALiVE_FOB_nearFob select 2]] call ALIVE_fnc_sendHint;
        };
    };
};
