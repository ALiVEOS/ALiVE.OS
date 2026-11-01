/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_siteWho

Description:
Who may act on a player site (a FOB, a Logistics hub, a rally point): one check shared by every
kind, so the same ticked rule means the same thing wherever it is set. An admin test, the Who
Can rules, and the clean-up the rules and names lists get before they are stored.

Rules are a comma-joined string of tokens:
    SIDE   - anyone on the site's side (the caller checks the side)
    LEADER - leading a group with another player in it
    OWNER  - the player who put it down (a player ID), or their group; with no owner recorded,
             group leaders as for LEADER. DEPLOYER is read as OWNER
    ITEM   - carrying an access item: Player Combat Logistics' items, or the ALiVE tablet.
             TABLET is read as ITEM
    LIST   - named in the names list: a player ID, a unit class or the slot's variable name

Parameters:
    ["filter", [rules, allowed]]           - the rules with only the tokens in allowed, upper case,
                                             in the order given (STRING)
    ["isAdmin", [unit]]                    - a logged-in or voted admin, or anyone in single player.
                                             Works on any machine for the player there, and on
                                             the server for anyone (BOOL)
    ["mayWho", [unit, rules, names, owner]] - whether any rule lets the unit in. No admin test:
                                             the callers make that. owner is a player ID, "" for
                                             none recorded, or a group (BOOL)
    ["cleanNames", [names]]                - a names list safe to store and show: printable,
                                             no quotes or markup, at most 2000 characters (STRING)

Examples:
(begin example)
private _ok = ["mayWho", [player, "SIDE,LIST", "jtac", ""]] call ALiVE_fnc_siteWho;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", "", [""]], ["_args", []]];
private _result = false;

switch (_operation) do {

    case "filter": {
        _args params [["_rules", "", [""]], ["_allowed", [], [[]]]];
        _result = (((toUpper _rules) splitString "[]""', ") select { _x in _allowed }) joinString ",";
    };

    case "isAdmin": {
        _args params [["_unit", objNull, [objNull]]];
        _result = !isNull _unit && {if (hasInterface && {_unit isEqualTo player}) then { call ALiVE_fnc_isServerAdmin } else { !isMultiplayer || {isServer && {(admin owner _unit) > 0}} }};
    };

    case "mayWho": {
        _args params [["_unit", objNull, [objNull]], ["_rules", "", [""]], ["_names", "", [""]], ["_owner", "", ["", grpNull]]];
        _result = false;
        if (isNull _unit) exitWith {};
        private _who = ((toUpper _rules) splitString "[]""', ") apply { switch (_x) do { case "DEPLOYER": {"OWNER"}; case "TABLET": {"ITEM"}; default {_x} } };
        // leading a group with another player in it: anyone alone in a group of their own leads it
        private _leads = { leader group _unit isEqualTo _unit && {(units group _unit) findIf { isPlayer _x && {_x != _unit} } > -1} };
        _result = "SIDE" in _who
            || {"LEADER" in _who && _leads}
            || {"OWNER" in _who && {
                if (_owner isEqualType grpNull) then { !isNull _owner && {group _unit isEqualTo _owner} } else {
                    if (_owner == "") then { call _leads } else { getPlayerUID _unit == _owner }
                }
            }}
            || {"ITEM" in _who && {
                // carried, as the tablet's own access items are: standing at a command post doesn't count here
                private _pr = missionNamespace getVariable ["ALIVE_SUP_PLAYER_RESUPPLY", objNull];
                private _items = if (isNull _pr || {isNil "ALIVE_fnc_PR"}) then { "" } else { [_pr, "pr_item"] call ALIVE_fnc_PR };
                private _custom = if (isNull _pr || {isNil "ALIVE_fnc_PR"}) then { "" } else { [_pr, "pr_item_custom"] call ALIVE_fnc_PR };
                if !(_items isEqualType "") then { _items = "" };
                if !(_custom isEqualType "") then { _custom = "" };
                [_items, _custom, ["ALIVE_Tablet"], _unit, false] call ALIVE_fnc_playerHasAccessItems
            }}
            || {"LIST" in _who && {
                private _list = (toLower _names) splitString (",; " + toString [9, 10, 13]);
                (getPlayerUID _unit) in _list || {(toLower typeOf _unit) in _list} || {(toLower vehicleVarName _unit) in _list}
            }};
    };

    case "cleanNames": {
        _args params [["_names", "", [""]]];
        _result = toString (((toArray _names) select { _x >= 32 && {!(_x in [34, 38, 39, 60, 62])} }) select [0, 2000]);
    };
};

_result
