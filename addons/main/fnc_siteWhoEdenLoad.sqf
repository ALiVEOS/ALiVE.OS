#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(siteWhoEdenLoad);

/* ----------------------------------------------------------------------------
Function: fnc_siteWhoEdenLoad

Description:
Eden attributeLoad shared by every site's Who Can setting (ALiVE_SideChoiceMulti): Player FOBs' Who
Can Dismantle, the Logistics Hub's Who Can Collect and Who Can Dismantle, and the Rally Points'
Who Can Manage. A multi-select list of who on the site's side may do it; any ticked row lets a
player in, and with none ticked only admins can. Checked in game by ALiVE_fnc_siteWho.

Storage: one string, the ticked rows' tokens comma separated: SIDE, LEADER, the owner token
(DEPLOYER on FOBs, OWNER elsewhere), ITEM, LIST.

Each row's text is <prefix><token> in the module's stringtable, its tooltip <prefix><token>_COMMENT.

Parameters:
    [_display, _value, _titleKey, _default, _prefix, _ownerToken]

Author:
Jman
---------------------------------------------------------------------------- */

params [["_display", controlNull], ["_value", "SIDE"], ["_titleKey", ""], ["_default", "SIDE"], ["_prefix", ""], ["_ownerToken", "OWNER"]];
if (isNull _display) exitWith {};
private _list = _display controlsGroupCtrl 100;
if (isNull _list) exitWith {};

(_display controlsGroupCtrl 101) ctrlSetText localize _titleKey;

private _raw = if (_value isEqualType "") then { _value } else { _default };
private _picked = (toUpper _raw) splitString "[]""', ";

lbClear _list;
{
    private _key = _prefix + _x;
    private _i = _list lbAdd localize _key;
    _list lbSetData [_i, _x];
    _list lbSetTooltip [_i, localize (_key + "_COMMENT")];
    if (_x in _picked) then { _list lbSetSelected [_i, true] };
} forEach ["SIDE", "LEADER", _ownerToken, "ITEM", "LIST"];

// a plain click ticks or unticks just that row, and ticked rows read [+], as on ALiVE's other lists
[_list] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenListToggle.sqf';
