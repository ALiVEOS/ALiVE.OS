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
- Build Menu, inside an active FOB's build range: the build window (ALiVE_fnc_buildMenu).
- Recycle, looking at something built at a FOB from within 8 m: takes it down for half its
  price back.
- Repair FOB, within 25 m of one of the side's FOBs whose headquarters was destroyed: the
  server works out the price and rebuilds it.
- Upgrade FOB, within 25 m of an active FOB below tier 3: the next tier, paid from its supply.
- Unload Supplies, within 8 m of a supply crate inside a FOB's build range.
- Request FOB Kit and Request Supply Crate, looking at a Field HQ (an object synced to the
  module) from within 8 m.
The module's Interface setting puts them on the scroll wheel, in the ACE interaction menu
(a Player FOBs entry in the self menu; Recycle and the Field HQ requests on the objects), or
both; Auto uses ACE when it is loaded.

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
            ALiVE_FOB_buildFob = [];
            ALiVE_FOB_nearCrate = objNull;
            ALiVE_FOB_cacheLoop = [] spawn {
                while { true } do {
                    if (alive player) then {
                        private _side = str (side group player);
                        private _kits = (nearestObjects [player, ["All"], 8]) select {
                            private _t = _x getVariable "ALiVE_FOB_kit";
                            !isNil "_t" && {_t isEqualTo true || {_t isEqualTo _side}}
                        };
                        ALiVE_FOB_nearKit = _kits param [0, objNull];
                        // a supply crate within 8 m
                        ALiVE_FOB_nearCrate = ((nearestObjects [player, ["All"], 8]) select { (_x getVariable ["ALiVE_FOB_crate", 0]) isEqualType 0 && {(_x getVariable ["ALiVE_FOB_crate", 0]) > 0} }) param [0, objNull];
                        private _mine = (missionNamespace getVariable ["ALiVE_FOB_registryMirror", []]) select {
                            (_x select 1) == _side && {player distance2D (_x select 3) <= 25}
                        };
                        ALiVE_FOB_nearFob = _mine param [0, []];
                        // the side's FOB whose build range the player is in
                        private _inRange = (missionNamespace getVariable ["ALiVE_FOB_registryMirror", []]) select {
                            (_x select 1) == _side && {(_x select 4) == "active"} && {player distance2D (_x select 3) <= (_x select 8)}
                        };
                        ALiVE_FOB_buildFob = _inRange param [0, []];
                    };
                    sleep 0.5;
                };
            };
        };

        // Scroll wheel, ACE interaction menu, or both: the module's Interface setting. Auto uses ACE
        // when it is loaded and the scroll wheel when it isn't; ACE without ACE loaded falls back
        // to the scroll wheel.
        private _ui = toUpper str (missionNamespace getVariable ["ALiVE_sup_fob", objNull] getVariable ["fob_interface", "AUTO"]);
        private _hasAce = isClass (configFile >> "CfgPatches" >> "ace_interact_menu");
        private _useAce = _hasAce && {(_ui find "SCROLL") < 0};
        private _useScroll = !_hasAce || {(_ui find "SCROLL") >= 0} || {(_ui find "BOTH") >= 0};
        if (_useAce && {isNil "ALiVE_FOB_aceAdded"}) then { [] spawn { ["ace"] call ALiVE_fnc_fobActions } };

        private _ids = player getVariable ["ALiVE_FOB_actionIDs", []];
        { player removeAction _x } forEach _ids;
        if (!_useScroll) exitWith { player setVariable ["ALiVE_FOB_actionIDs", []]; ALiVE_FOB_scroll = false };
        ALiVE_FOB_scroll = true;
        _ids = [
            player addAction [localize "STR_ALIVE_FOB_ACTION_DEPLOY", { ["deploy"] call ALiVE_fnc_fobActions }, nil, 1.5, true, true, "",
                "!isNull ALiVE_FOB_nearKit && {vehicle _this == _this}"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_STATUS", { ["status"] call ALiVE_fnc_fobActions }, nil, 1.4, false, true, "",
                "ALiVE_FOB_nearFob isNotEqualTo []"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_DISMANTLE", { ["dismantle"] call ALiVE_fnc_fobActions }, nil, 0.5, false, true, "",
                "ALiVE_FOB_nearFob isNotEqualTo [] && {vehicle _this == _this}"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_REPAIR", { ["repair", [ALiVE_FOB_nearFob select 0]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, nil, 1.46, false, true, "",
                "ALiVE_FOB_nearFob isNotEqualTo [] && {(ALiVE_FOB_nearFob select 4) == 'damaged'} && {vehicle _this == _this}"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_UPGRADE", { ["upgrade", [ALiVE_FOB_nearFob select 0]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, nil, 1.42, false, true, "",
                "ALiVE_FOB_nearFob isNotEqualTo [] && {(ALiVE_FOB_nearFob select 4) == 'active'} && {(ALiVE_FOB_nearFob select 5) < 3} && {vehicle _this == _this}"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_UNLOAD", { ["unload", [ALiVE_FOB_nearCrate, ALiVE_FOB_buildFob select 0]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, nil, 1.47, false, true, "",
                "!isNull ALiVE_FOB_nearCrate && {ALiVE_FOB_buildFob isNotEqualTo []} && {vehicle _this == _this}"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_HQ_KIT", { ["fieldHQ", [cursorObject, "KIT"]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, nil, 1.3, false, true, "",
                "cursorObject getVariable ['ALiVE_FOB_fieldHQ', false] && {_this distance cursorObject < 8}"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_HQ_CRATE", { ["fieldHQ", [cursorObject, "CRATE"]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, nil, 1.29, false, true, "",
                "cursorObject getVariable ['ALiVE_FOB_fieldHQ', false] && {_this distance cursorObject < 8}"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_BUILD", { ["open", ALiVE_FOB_buildFob] call ALiVE_fnc_buildMenu }, nil, 1.45, false, true, "",
                "ALiVE_FOB_buildFob isNotEqualTo [] && {vehicle _this == _this} && {!(missionNamespace getVariable ['ALiVE_FOB_placing', false])}"],
            player addAction [localize "STR_ALIVE_FOB_ACTION_RECYCLE", { ["recycle", [cursorObject]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, nil, 0.6, false, true, "",
                "vehicle _this == _this && {_this distance cursorObject < 8} && {['canRecycle', cursorObject] call ALiVE_fnc_fobActions}"]
        ];
        player setVariable ["ALiVE_FOB_actionIDs", _ids];

        if (isNil "ALiVE_FOB_respawnEH") then {
            ALiVE_FOB_respawnEH = player addEventHandler ["Respawn", { ["init"] call ALiVE_fnc_fobActions }];
        };
    };

    // Something built at one of the player's side's FOBs that can be recycled: a tagged object,
    // or a static weapon or vehicle inside the side's FOB build range (the server checks it was
    // built there)
    case "canRecycle": {
        private _o = _this param [1, objNull];
        !isNull _o && {(_o getVariable ["ALiVE_FOB_object", ""]) != ""
            || {ALiVE_FOB_buildFob isNotEqualTo [] && {_o isKindOf "StaticWeapon" || {_o isKindOf "LandVehicle"} || {_o isKindOf "Ship"}}}}
    };

    // The same actions in the ACE interaction menu: a Player FOBs entry in the self-interaction
    // menu with the player's own FOB actions, and Recycle and the Field HQ requests on the
    // objects themselves. Added once; ACE keeps class actions across respawns.
    case "ace": {
        waitUntil { sleep 1; !isNil "ace_interact_menu_fnc_createAction" && {!isNull player} };
        if (!isNil "ALiVE_FOB_aceAdded") exitWith {};
        ALiVE_FOB_aceAdded = true;
        private _mk = { params ["_id", "_key", "_code", "_cond"]; [_id, localize _key, "", _code, _cond] call ace_interact_menu_fnc_createAction };
        private _root = ["ALiVE_FOB", "STR_ALIVE_FOB", {}, { ALiVE_FOB_nearFob isNotEqualTo [] || {!isNull ALiVE_FOB_nearKit} || {ALiVE_FOB_buildFob isNotEqualTo []} || {!isNull ALiVE_FOB_nearCrate} }] call _mk;
        ["CAManBase", 1, ["ACE_SelfActions"], _root, true] call ace_interact_menu_fnc_addActionToClass;
        {
            ["CAManBase", 1, ["ACE_SelfActions", "ALiVE_FOB"], _x call _mk, true] call ace_interact_menu_fnc_addActionToClass;
        } forEach [
            ["ALiVE_FOB_Deploy", "STR_ALIVE_FOB_ACTION_DEPLOY", { ["deploy"] call ALiVE_fnc_fobActions }, { !isNull ALiVE_FOB_nearKit && {vehicle _player == _player} }],
            ["ALiVE_FOB_Status", "STR_ALIVE_FOB_ACTION_STATUS", { ["status"] call ALiVE_fnc_fobActions }, { ALiVE_FOB_nearFob isNotEqualTo [] }],
            ["ALiVE_FOB_Build", "STR_ALIVE_FOB_ACTION_BUILD", { ["open", ALiVE_FOB_buildFob] call ALiVE_fnc_buildMenu }, { ALiVE_FOB_buildFob isNotEqualTo [] && {!(missionNamespace getVariable ["ALiVE_FOB_placing", false])} }],
            ["ALiVE_FOB_Unload", "STR_ALIVE_FOB_ACTION_UNLOAD", { ["unload", [ALiVE_FOB_nearCrate, ALiVE_FOB_buildFob select 0]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, { !isNull ALiVE_FOB_nearCrate && {ALiVE_FOB_buildFob isNotEqualTo []} }],
            ["ALiVE_FOB_Upgrade", "STR_ALIVE_FOB_ACTION_UPGRADE", { ["upgrade", [ALiVE_FOB_nearFob select 0]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, { ALiVE_FOB_nearFob isNotEqualTo [] && {(ALiVE_FOB_nearFob select 4) == "active"} && {(ALiVE_FOB_nearFob select 5) < 3} }],
            ["ALiVE_FOB_Repair", "STR_ALIVE_FOB_ACTION_REPAIR", { ["repair", [ALiVE_FOB_nearFob select 0]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, { ALiVE_FOB_nearFob isNotEqualTo [] && {(ALiVE_FOB_nearFob select 4) == "damaged"} }],
            ["ALiVE_FOB_Dismantle", "STR_ALIVE_FOB_ACTION_DISMANTLE", { ["dismantle"] call ALiVE_fnc_fobActions }, { ALiVE_FOB_nearFob isNotEqualTo [] }]
        ];
        private _recycle = ["ALiVE_FOB_Recycle", "STR_ALIVE_FOB_ACTION_RECYCLE", { ["recycle", [_target]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, { ["canRecycle", _target] call ALiVE_fnc_fobActions }] call _mk;
        private _kit = ["ALiVE_FOB_HQKit", "STR_ALIVE_FOB_ACTION_HQ_KIT", { ["fieldHQ", [_target, "KIT"]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, { _target getVariable ["ALiVE_FOB_fieldHQ", false] }] call _mk;
        private _crate = ["ALiVE_FOB_HQCrate", "STR_ALIVE_FOB_ACTION_HQ_CRATE", { ["fieldHQ", [_target, "CRATE"]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, { _target getVariable ["ALiVE_FOB_fieldHQ", false] }] call _mk;
        {
            private _cls = _x;
            { [_cls, 0, ["ACE_MainActions"], _x, true] call ace_interact_menu_fnc_addActionToClass } forEach [_recycle, _kit, _crate];
        } forEach ["Static", "Thing", "StaticWeapon", "LandVehicle", "Ship"];
    };

    // The headquarters is placed like a built item: a copy stands in front of the player, green
    // where it can go, and Deploy FOB Here, Rotate or Cancel from the scroll menu
    case "deploy": {
        if (isNull ALiVE_FOB_nearKit) exitWith {};
        private _side = str (side group player);
        private _class = [missionNamespace getVariable ["ALiVE_sup_fob", objNull], "perSide", ["fob_hubs", _side]] call ALiVE_fnc_FOB;
        if !(isClass (configFile >> "CfgVehicles" >> _class)) exitWith {
            ["deploy", [ALiVE_FOB_nearKit, player getPos [8, getDir player], getDir player]] remoteExecCall ["ALiVE_fnc_fobRequest", 2];
        };
        // a row like the Build Menu's, and the kit standing in for the FOB: placed within 40 m of it
        ["start", [[_class, localize "STR_ALIVE_FOB_HQ_NAME", "DEPLOY", 0], ["", _side, "", getPosATL ALiVE_FOB_nearKit, "", 1, 0, 0, 40], ALiVE_FOB_nearKit]] call ALiVE_fnc_fobPlacement;
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
