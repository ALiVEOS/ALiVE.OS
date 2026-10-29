#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobActions);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobActions

Description:
The player's FOB actions, on the scroll menu:
- Deploy FOB, standing within 8 m of a FOB kit for the player's side. The FOB goes 8 m in
  front of the player, facing the way they face.
- Manage FOB, within 25 m of one of the side's FOBs: the FOB window (data\ui\fobManage.hpp),
  with its state, tier and supply, and in one place:
  - Rename: the map marker, rally point and respawn point take the new name too.
  - Build Menu: the build window (ALiVE_fnc_buildMenu).
  - Upgrade: the next tier, paid from its supply, while it is active and below tier 3.
  - Repair: when its headquarters was destroyed; the server works out the price.
  - Dismantle: asks to be pressed again within 10 s; the supply in the FOB is lost.
  The server's answer to each shows on the window as well as in the usual message.
  Rename and Dismantle are greyed out for a player the module's Who Can Dismantle doesn't let
  in, and admins get a Permissions button for the Permissions window, which the ALiVE admin
  menu opens too, from anywhere.
- Build Menu, inside an active FOB's build range: the build window.
- FOB Arsenal, within 25 m of one of the side's active FOBs once it reaches the tier the build list's
  FOB Arsenal crate needs: the same arsenal as the crate, opened at the headquarters.
- Recycle, looking at something built at a FOB from within 8 m: takes it down for half its
  price back, for a player Who Can Dismantle lets in.
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
            ALiVE_FOB_mayAt = createHashMap;
            ALiVE_FOB_hqArsenal = false;
            ALiVE_FOB_cacheLoop = [] spawn {
                while { true } do {
                    if (alive player) then {
                        private _side = ["unitSide", [player]] call ALIVE_fnc_hub;
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
                        // the FOB Arsenal at the headquarters (Jman, 29 Oct): the FOB is active and at the
                        // tier the build list's FOB Arsenal crate needs; with no crate in the list, none
                        private _cat = missionNamespace getVariable ["ALiVE_FOB_catalog", []];
                        private _ai = _cat findIf { (_x select 0) == "ALiVE_FOB_Arsenal" };
                        ALiVE_FOB_hqArsenal = _ai >= 0 && {ALiVE_FOB_nearFob isNotEqualTo []} && {missionNamespace getVariable ["ALiVE_FOB_arsenalOn", false]}
                            && {(ALiVE_FOB_nearFob select 4) == "active"} && {(ALiVE_FOB_nearFob select 5) >= ((_cat select _ai) select 5)};
                        // the side's FOB whose build range the player is in
                        private _inRange = (missionNamespace getVariable ["ALiVE_FOB_registryMirror", []]) select {
                            (_x select 1) == _side && {(_x select 4) == "active"} && {player distance2D (_x select 3) <= (_x select 8)}
                        };
                        ALiVE_FOB_buildFob = _inRange param [0, []];
                        // which of the side's FOBs Who Can Dismantle lets this player recycle at
                        private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
                        ALiVE_FOB_mayAt = createHashMapFromArray (((missionNamespace getVariable ["ALiVE_FOB_registryMirror", []]) select { (_x select 1) == _side })
                            apply { [_x select 0, [_logic, "mayManage", [player, _x param [9, ""]]] call ALiVE_fnc_FOB] });
                    };
                    sleep 0.5;
                };
            };
        };

        // Scroll wheel, ACE interaction menu, or both: the module's Interface setting. Auto uses ACE
        // when it is loaded and the scroll wheel when it isn't; ACE without ACE loaded falls back
        // to the scroll wheel.
        private _ui = toUpper str (missionNamespace getVariable ["ALiVE_sup_fob", objNull] getVariable ["fob_interface", "AUTO"]);
        // the player's own choice in Addon Options > ALiVE > Game wins over the module's (#1083); ACE
        // without ACE loaded still falls back to the scroll wheel below
        private _prefUI = missionNamespace getVariable ["ALiVE_prefInterface", "MODULE"];
        if (_prefUI != "MODULE") then { _ui = _prefUI };
        private _hasAce = isClass (configFile >> "CfgPatches" >> "ace_interact_menu");
        private _useAce = _hasAce && {(_ui find "SCROLL") < 0};
        private _useScroll = !_hasAce || {(_ui find "SCROLL") >= 0} || {(_ui find "BOTH") >= 0};
        if (_useAce && {isNil "ALiVE_FOB_aceAdded"}) then { [] spawn { ["ace"] call ALiVE_fnc_fobActions } };

        private _ids = player getVariable ["ALiVE_FOB_actionIDs", []];
        { player removeAction _x } forEach _ids;
        if (!_useScroll) exitWith { player setVariable ["ALiVE_FOB_actionIDs", []]; ALiVE_FOB_scroll = false };
        ALiVE_FOB_scroll = true;
        _ids = [
            player addAction [(localize "STR_ALIVE_FOB_ACTION_DEPLOY") call ALiVE_fnc_actionTitle, { ["deploy"] call ALiVE_fnc_fobActions }, nil, 1.5, true, true, "",
                "!isNull ALiVE_FOB_nearKit && {vehicle _this == _this}"],
            player addAction [(localize "STR_ALIVE_FOB_ACTION_MANAGE") call ALiVE_fnc_actionTitle, { ["manage"] call ALiVE_fnc_fobActions }, nil, 1.4, false, true, "",
                "ALiVE_FOB_nearFob isNotEqualTo [] && {vehicle _this == _this}"],
            player addAction [(localize "STR_ALIVE_FOB_ACTION_UNLOAD") call ALiVE_fnc_actionTitle, { ["unload", [ALiVE_FOB_nearCrate, ALiVE_FOB_buildFob select 0]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, nil, 1.47, false, true, "",
                "!isNull ALiVE_FOB_nearCrate && {ALiVE_FOB_buildFob isNotEqualTo []} && {vehicle _this == _this}"],
            player addAction [(localize "STR_ALIVE_FOB_ACTION_HQ_KIT") call ALiVE_fnc_actionTitle, { ["fieldHQ", [cursorObject, "KIT"]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, nil, 1.3, false, true, "",
                "cursorObject getVariable ['ALiVE_FOB_fieldHQ', false] && {_this distance cursorObject < 8}"],
            player addAction [(localize "STR_ALIVE_FOB_ACTION_HQ_CRATE") call ALiVE_fnc_actionTitle, { ["fieldHQ", [cursorObject, "CRATE"]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, nil, 1.29, false, true, "",
                "cursorObject getVariable ['ALiVE_FOB_fieldHQ', false] && {_this distance cursorObject < 8}"],
            player addAction [(localize "STR_ALIVE_FOB_ACTION_BUILD") call ALiVE_fnc_actionTitle, { ["open", ALiVE_FOB_buildFob] call ALiVE_fnc_buildMenu }, nil, 1.45, false, true, "",
                "ALiVE_FOB_buildFob isNotEqualTo [] && {vehicle _this == _this} && {!(missionNamespace getVariable ['ALiVE_FOB_placing', false])}"],
            player addAction [(localize "STR_ALIVE_FOB_ACTION_RECYCLE") call ALiVE_fnc_actionTitle, { ["recycle", [cursorObject]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, nil, 0.6, false, true, "",
                "vehicle _this == _this && {_this distance cursorObject < (8 max ([0, (sizeOf typeOf cursorObject) / 2] select (cursorObject isKindOf 'Air')))} && {['canRecycle', cursorObject] call ALiVE_fnc_fobActions}"],
            player addAction [(localize "STR_ALIVE_FOB_ACTION_ARSENAL") call ALiVE_fnc_actionTitle, { ["arsenalOpen", [cursorObject, !isNil "ALiVE_FOB_gearList"]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, nil, 1.46, true, true, "",
                "vehicle _this == _this && {_this distance cursorObject < 8} && {cursorObject isKindOf 'ALiVE_FOB_Arsenal'} && {missionNamespace getVariable ['ALiVE_FOB_arsenalOn', false]}"],
            // the same arsenal from the headquarters, next to Build Menu and Manage FOB (Jman, 29 Oct)
            player addAction [(localize "STR_ALIVE_FOB_ACTION_ARSENAL_HQ") call ALiVE_fnc_actionTitle, { ["arsenalOpen", [objNull, !isNil "ALiVE_FOB_gearList", ALiVE_FOB_nearFob param [0, ""]]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, nil, 1.44, false, true, "",
                "ALiVE_FOB_hqArsenal && {vehicle _this == _this}"]
        ];
        player setVariable ["ALiVE_FOB_actionIDs", _ids];

        if (isNil "ALiVE_FOB_respawnEH") then {
            ALiVE_FOB_respawnEH = player addEventHandler ["Respawn", { ["init"] call ALiVE_fnc_fobActions }];
        };
    };

    // Something built at one of the player's side's FOBs that can be recycled: a tagged object,
    // or a static weapon or vehicle inside the side's FOB build range (the server checks it was
    // built there), where Who Can Dismantle lets this player recycle
    case "canRecycle": {
        private _o = _this param [1, objNull];
        if (isNull _o) exitWith { false };
        // read from the cache the half-second loop keeps, as this runs every frame; a FOB the cache
        // doesn't hold still shows the action, and the server says why it can't
        private _fid = _o getVariable ["ALiVE_FOB_object", ""];
        if (_fid != "") exitWith { ALiVE_FOB_mayAt getOrDefault [_fid, true] };
        // made at a Logistics Hub: recycled near one of the side's hubs (the server checks the rest)
        if (!isNil {_o getVariable "ALiVE_hub_made"}) exitWith {
            private _side = ["unitSide", [player]] call ALIVE_fnc_hub;
            (missionNamespace getVariable ["ALiVE_hub_list", []]) findIf { !isNull _x && {((_x getVariable ["ALiVE_hub", []]) param [0, ""]) == _side} && {_o distance2D _x < 100} } > -1
        };
        ALiVE_FOB_buildFob isNotEqualTo [] && {_o isKindOf "StaticWeapon" || {_o isKindOf "LandVehicle"} || {_o isKindOf "Ship"} || {_o isKindOf "Air"}}
            && {ALiVE_FOB_mayAt getOrDefault [ALiVE_FOB_buildFob select 0, true]}
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
            ["ALiVE_FOB_Manage", "STR_ALIVE_FOB_ACTION_MANAGE", { ["manage"] call ALiVE_fnc_fobActions }, { ALiVE_FOB_nearFob isNotEqualTo [] && {vehicle _player == _player} }],
            ["ALiVE_FOB_ArsenalHQ", "STR_ALIVE_FOB_ACTION_ARSENAL_HQ", { ["arsenalOpen", [objNull, !isNil "ALiVE_FOB_gearList", ALiVE_FOB_nearFob param [0, ""]]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, { ALiVE_FOB_hqArsenal && {vehicle _player == _player} }],
            ["ALiVE_FOB_Build", "STR_ALIVE_FOB_ACTION_BUILD", { ["open", ALiVE_FOB_buildFob] call ALiVE_fnc_buildMenu }, { ALiVE_FOB_buildFob isNotEqualTo [] && {!(missionNamespace getVariable ["ALiVE_FOB_placing", false])} }],
            ["ALiVE_FOB_Unload", "STR_ALIVE_FOB_ACTION_UNLOAD", { ["unload", [ALiVE_FOB_nearCrate, ALiVE_FOB_buildFob select 0]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, { !isNull ALiVE_FOB_nearCrate && {ALiVE_FOB_buildFob isNotEqualTo []} }]
        ];
        private _recycle = ["ALiVE_FOB_Recycle", "STR_ALIVE_FOB_ACTION_RECYCLE", { ["recycle", [_target]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, { ["canRecycle", _target] call ALiVE_fnc_fobActions }] call _mk;
        private _kit = ["ALiVE_FOB_HQKit", "STR_ALIVE_FOB_ACTION_HQ_KIT", { ["fieldHQ", [_target, "KIT"]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, { _target getVariable ["ALiVE_FOB_fieldHQ", false] }] call _mk;
        private _crate = ["ALiVE_FOB_HQCrate", "STR_ALIVE_FOB_ACTION_HQ_CRATE", { ["fieldHQ", [_target, "CRATE"]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, { _target getVariable ["ALiVE_FOB_fieldHQ", false] }] call _mk;
        {
            private _cls = _x;
            { [_cls, 0, ["ACE_MainActions"], _x, true] call ace_interact_menu_fnc_addActionToClass } forEach [_recycle, _kit, _crate];
        } forEach ["Static", "Thing", "StaticWeapon", "LandVehicle", "Ship", "Air"];
        // the FOB Arsenal
        ["ALiVE_FOB_Arsenal", 0, ["ACE_MainActions"], ["ALiVE_FOB_OpenArsenal", "STR_ALIVE_FOB_ACTION_ARSENAL", { ["arsenalOpen", [_target, !isNil "ALiVE_FOB_gearList"]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] }, { missionNamespace getVariable ["ALiVE_FOB_arsenalOn", false] }] call _mk, true] call ace_interact_menu_fnc_addActionToClass;
    };

    // The headquarters is placed like a built item: a copy stands in front of the player, green
    // where it can go, and Deploy FOB Here, Rotate or Cancel from the scroll menu
    case "deploy": {
        if (isNull ALiVE_FOB_nearKit) exitWith {};
        private _side = str (side group player);
        // the FOB type: the one last shown, which Next FOB Type steps through, from those this player may deploy now
        private _offer = ["typeOffer"] call ALiVE_fnc_fobActions;
        if (_offer isEqualTo []) exitWith { [localize "STR_ALIVE_FOB", localize "STR_ALIVE_FOB_TYPE_NONE_FREE", true] call ALIVE_fnc_sendHint };
        private _ids = _offer apply { _x select 0 };
        ALiVE_FOB_deployType = missionNamespace getVariable ["ALiVE_FOB_deployType", ""];
        if !(ALiVE_FOB_deployType in _ids) then { ALiVE_FOB_deployType = _ids select 0 };
        // one of the type's (or the side's) headquarters buildings: the one last shown, which Next Headquarters steps through
        private _hubs = [missionNamespace getVariable ["ALiVE_sup_fob", objNull], "hubChoicesFor", [_side, ALiVE_FOB_deployType]] call ALiVE_fnc_FOB;
        private _class = _hubs select ((missionNamespace getVariable ["ALiVE_FOB_hubIndex", 0]) mod (count _hubs));
        if !(isClass (configFile >> "CfgVehicles" >> _class)) exitWith {
            ["deploy", [ALiVE_FOB_nearKit, player getPos [8, getDir player], getDir player, "", ALiVE_FOB_deployType]] remoteExecCall ["ALiVE_fnc_fobRequest", 2];
        };
        // a row like the Build Menu's, and the kit standing in for the FOB: placed within 40 m of it
        ["start", [[_class, localize "STR_ALIVE_FOB_HQ_NAME", "DEPLOY", 0], ["", _side, "", getPosATL ALiVE_FOB_nearKit, "", 1, 0, 0, 40], ALiVE_FOB_nearKit]] call ALiVE_fnc_fobPlacement;
    };

    // The FOB types this player may deploy now: the module's list less those who-may-deploy
    // shuts them out of and those at their own limit, as the last FOB list showed it. The server
    // checks again.
    case "typeOffer": {
        private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
        private _side = str (side group player);
        private _mine = (missionNamespace getVariable ["ALiVE_FOB_registryMirror", []]) select { (_x select 1) == _side };
        // the case's value is what this function returns, as canRecycle's is
        ([_logic, "types", []] call ALiVE_fnc_FOB) select {
            private _t = _x select 0;
            [_logic, "mayDeployType", [player, _t]] call ALiVE_fnc_FOB
                && {(_x select 11) <= 0 || {({ (_x param [10, ""]) == _t } count _mine) < (_x select 11)}}
        };
    };

    // The next FOB type, while placing a headquarters
    case "nextType": {
        private _ids = (["typeOffer"] call ALiVE_fnc_fobActions) apply { _x select 0 };
        if (_ids isEqualTo []) exitWith {};
        ALiVE_FOB_deployType = _ids select (((_ids find (missionNamespace getVariable ["ALiVE_FOB_deployType", ""])) + 1) mod (count _ids));
        ALiVE_FOB_hubIndex = 0;
        ["cancel"] call ALiVE_fnc_fobPlacement;
        ["deploy"] call ALiVE_fnc_fobActions;
    };

    // The next of the side's headquarters buildings, while placing one (Lenahan, 20 Oct)
    case "nextHub": {
        ALiVE_FOB_hubIndex = (missionNamespace getVariable ["ALiVE_FOB_hubIndex", 0]) + 1;
        ["cancel"] call ALiVE_fnc_fobPlacement;
        ["deploy"] call ALiVE_fnc_fobActions;
    };

    // The FOB window for the side's FOB the player stands at (data\ui\fobManage.hpp)
    case "manage": {
        if (ALiVE_FOB_nearFob isEqualTo [] || {!createDialog "ALiVE_FobWindow"}) exitWith {};
        uiNamespace setVariable ["ALiVE_FOB_manageId", ALiVE_FOB_nearFob select 0];
        ALiVE_FOB_dismantleArmed = ["", -100];
        ((findDisplay 9283) displayCtrl 92842) ctrlSetText (ALiVE_FOB_nearFob select 2);
        ["manageRefresh"] call ALiVE_fnc_fobActions;
    };

    // The window filled from the FOB list: when it opens, and each time the server sends the list
    case "manageRefresh": {
        ["permFill"] call ALiVE_fnc_fobActions;
        private _d = findDisplay 9283;
        if (isNull _d) exitWith {};
        private _id = uiNamespace getVariable ["ALiVE_FOB_manageId", ""];
        private _row = ((missionNamespace getVariable ["ALiVE_FOB_registryMirror", []]) select { (_x select 0) == _id }) param [0, []];
        // dismantled, lost or taken while the window was open
        if (_row isEqualTo [] || {(_row select 1) != str (side group player)}) exitWith { closeDialog 0 };
        _row params ["", "", "_name", "", "_status", "_tier", "_supply", "_cap", "", ["_deployer", ""], ["_type", ""]];
        private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
        private _may = [_logic, "mayManage", [player, _deployer]] call ALiVE_fnc_FOB;
        private _supplyText = if (_supply < 0) then { localize "STR_ALIVE_FOB_SUPPLY_FREE" } else { if (_cap < 0) then { format [localize "STR_ALIVE_FOB_SUPPLY_POOL", round _supply] } else { format ["%1 / %2", round _supply, round _cap] } };
        (_d displayCtrl 92840) ctrlSetText _name;
        private _status2 = format [localize "STR_ALIVE_FOB_STATUS", _name, localize (format ["STR_ALIVE_FOB_STATE_%1", toUpper _status]), _tier, _supplyText];
        // FOB Types (Jman, 29 Oct): the FOB's type on the status, and the types it can change to
        private _hasTypes = (missionNamespace getVariable ["ALiVE_FOB_types", []]) isNotEqualTo [];
        if (_hasTypes) then {
            _status2 = _status2 + "<br/>" + format [localize "STR_ALIVE_FOB_STATUS_TYPE", ([_logic, "typeSpec", [_type]] call ALiVE_fnc_FOB) param [1, _type]];
        };
        (_d displayCtrl 92841) ctrlSetStructuredText parseText _status2;
        { (_d displayCtrl _x) ctrlShow _hasTypes } forEach [92862, 92863, 92864];
        if (_hasTypes) then {
            private _list = _d displayCtrl 92862;
            // keep what the player has picked while the list is filled again
            private _picked = if (lbCurSel _list < 0) then { _type } else { _list lbData (lbCurSel _list) };
            uiNamespace setVariable ["ALiVE_FOB_typeFilling", true];
            lbClear _list;
            {
                private _id = _x select 0;
                if (_id == _type || {[_logic, "mayDeployType", [player, _id]] call ALiVE_fnc_FOB}) then {
                    private _i = _list lbAdd (_x select 1);
                    _list lbSetData [_i, _id];
                    if (_id == _picked) then { _list lbSetCurSel _i };
                };
            } forEach ([_logic, "types"] call ALiVE_fnc_FOB);
            if (lbCurSel _list < 0 && {lbSize _list > 0}) then { _list lbSetCurSel 0 };
            uiNamespace setVariable ["ALiVE_FOB_typeFilling", false];
            _list ctrlEnable (_may && {_status == "active"});
            ["manageTypePicked"] call ALiVE_fnc_fobActions;
        };
        private _up = _d displayCtrl 92845;
        if (_tier >= 3) then {
            _up ctrlSetText localize "STR_ALIVE_FOB_UI_TOP_TIER";
        } else {
            private _cost = [missionNamespace getVariable ["ALiVE_sup_fob", objNull], "attribute", [format ["fob_tier%1_cost", _tier + 1]]] call ALiVE_fnc_FOB;
            _up ctrlSetText format [localize "STR_ALIVE_FOB_UI_UPGRADE_TO", _tier + 1, _cost];
        };
        _up ctrlEnable (_status == "active" && {_tier < 3});
        (_d displayCtrl 92844) ctrlEnable (_status == "active");
        (_d displayCtrl 92846) ctrlEnable (_status == "damaged");
        // a damaged FOB is repaired or lost, not packed up; and only who Who Can Dismantle lets in
        (_d displayCtrl 92847) ctrlEnable (_may && {_status != "damaged"});
        { (_d displayCtrl _x) ctrlEnable _may } forEach [92842, 92843];
        (_d displayCtrl 92843) ctrlSetTooltip (["", localize "STR_ALIVE_FOB_REFUSED_NOTALLOWED"] select !_may);
        (_d displayCtrl 92847) ctrlSetTooltip (["", localize "STR_ALIVE_FOB_REFUSED_NOTALLOWED"] select !_may);
        // admins get the Permissions button, which opens the Permissions window
        (_d displayCtrl 92860) ctrlShow ([_logic, "isAdmin", [player]] call ALiVE_fnc_FOB);
    };

    // A button on the window. The server checks everything again and its answer shows on the
    // window's last line (ALiVE_fnc_fobClient "notify").
    case "manageDo": {
        private _d = findDisplay 9283;
        if (isNull _d) exitWith {};
        private _id = uiNamespace getVariable ["ALiVE_FOB_manageId", ""];
        (_d displayCtrl 92848) ctrlSetStructuredText parseText "";
        switch (_this param [1, ""]) do {
            case "RENAME": { ["rename", [_id, ctrlText (_d displayCtrl 92842)]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] };
            case "UPGRADE": { ["upgrade", [_id]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] };
            case "REPAIR": { ["repair", [_id]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] };
            case "RETYPE": {
                private _list = _d displayCtrl 92862;
                if (lbCurSel _list >= 0) then { ["retype", [_id, _list lbData (lbCurSel _list)]] remoteExecCall ["ALiVE_fnc_fobRequest", 2] };
            };
            case "BUILD": {
                private _row = ((missionNamespace getVariable ["ALiVE_FOB_registryMirror", []]) select { (_x select 0) == _id }) param [0, []];
                closeDialog 0;
                // the build window opens once this one has gone
                if (_row isNotEqualTo []) then { _row spawn { uiSleep 0.1; ["open", _this] call ALiVE_fnc_buildMenu } };
            };
            // pressed twice within 10 s, as Dismantle FOB always has been
            case "DISMANTLE": {
                private _armed = missionNamespace getVariable ["ALiVE_FOB_dismantleArmed", ["", -100]];
                if ((_armed select 0) == _id && {time - (_armed select 1) <= 10}) then {
                    ALiVE_FOB_dismantleArmed = ["", -100];
                    ["dismantle", [_id]] remoteExecCall ["ALiVE_fnc_fobRequest", 2];
                } else {
                    ALiVE_FOB_dismantleArmed = [_id, time];
                    (_d displayCtrl 92847) ctrlSetText localize "STR_ALIVE_FOB_UI_DISMANTLE_AGAIN";
                    (_d displayCtrl 92848) ctrlSetStructuredText parseText format [localize "STR_ALIVE_FOB_DISMANTLE_CONFIRM", ctrlText (_d displayCtrl 92840)];
                };
            };
        };
    };

    // The Permissions window (data\ui\fobManage.hpp), for admins: Who Can Dismantle and its list
    // for every FOB, sent to the server with Apply. Opened from the FOB window or the ALiVE admin
    // menu, wherever the admin is. The server checks the sender is an admin.
    case "permOpen": {
        if !([missionNamespace getVariable ["ALiVE_sup_fob", objNull], "isAdmin", [player]] call ALiVE_fnc_FOB) exitWith {};
        closeDialog 0;
        [] spawn {
            uiSleep 0.1;
            if (!createDialog "ALiVE_FobPermWindow") exitWith {};
            ALiVE_FOB_permDraft = nil;
            ["permFill"] call ALiVE_fnc_fobActions;
        };
    };

    case "permFill": {
        private _d = findDisplay 9285;
        if (isNull _d) exitWith {};
        if (isNil "ALiVE_FOB_permDraft") then {
            ([missionNamespace getVariable ["ALiVE_sup_fob", objNull], "manageRules"] call ALiVE_fnc_FOB) params ["_rules", "_names"];
            ALiVE_FOB_permDraft = [(toUpper _rules) splitString "[]""', ", _names];
            (_d displayCtrl 92857) ctrlSetText _names;
        };
        private _ticked = ALiVE_FOB_permDraft select 0;
        {
            _x params ["_idc", "_token", "_key"];
            private _b = _d displayCtrl _idc;
            _b ctrlSetText format ["%1  %2", ["[  ]", "[+]"] select (_token in _ticked), localize _key];
            _b ctrlSetTooltip localize (_key + "_COMMENT");
        } forEach [
            [92853, "SIDE", "STR_ALIVE_FOB_MANAGE_SIDE"],
            [92854, "LEADER", "STR_ALIVE_FOB_MANAGE_LEADER"],
            [92855, "DEPLOYER", "STR_ALIVE_FOB_MANAGE_DEPLOYER"],
            [92856, "LIST", "STR_ALIVE_FOB_MANAGE_LIST"]
        ];
    };

    case "permToggle": {
        if (isNil "ALiVE_FOB_permDraft") exitWith {};
        private _token = _this param [1, ""];
        private _ticked = ALiVE_FOB_permDraft select 0;
        if (_token in _ticked) then { _ticked deleteAt (_ticked find _token) } else { _ticked pushBack _token };
        ["permFill"] call ALiVE_fnc_fobActions;
    };

    // the server's answer comes back as the usual message
    case "permApply": {
        private _d = findDisplay 9285;
        if (isNull _d || {isNil "ALiVE_FOB_permDraft"}) exitWith {};
        ["permissions", [(ALiVE_FOB_permDraft select 0) joinString ",", ctrlText (_d displayCtrl 92857)]] remoteExecCall ["ALiVE_fnc_fobRequest", 2];
    };

    // Change Type follows the type picked: off for the FOB's own type, with the new type's cost on it
    case "manageTypePicked": {
        private _d = findDisplay 9283;
        if (isNull _d || {uiNamespace getVariable ["ALiVE_FOB_typeFilling", false]}) exitWith {};
        private _id = uiNamespace getVariable ["ALiVE_FOB_manageId", ""];
        private _row = ((missionNamespace getVariable ["ALiVE_FOB_registryMirror", []]) select { (_x select 0) == _id }) param [0, []];
        if (_row isEqualTo []) exitWith {};
        private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
        private _list = _d displayCtrl 92862;
        private _new = if (lbCurSel _list < 0) then { _row param [10, ""] } else { _list lbData (lbCurSel _list) };
        private _cost = ([_logic, "typeSpec", [_new]] call ALiVE_fnc_FOB) param [10, 0];
        private _btn = _d displayCtrl 92863;
        _btn ctrlSetText ([localize "STR_ALIVE_FOB_UI_CHANGE_TYPE", format [localize "STR_ALIVE_FOB_UI_CHANGE_TYPE_COST", _cost]] select (_cost > 0));
        _btn ctrlEnable (ctrlEnabled _list && {_new != (_row param [10, ""])});
    };

    case "manageClosed": {
        uiNamespace setVariable ["ALiVE_FOB_manageId", nil];
        ALiVE_FOB_dismantleArmed = ["", -100];
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
