#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(debugVirtualisedProfilesClient);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_debugVirtualisedProfilesClient

Description:
    Client-side receiver for the snapshot broadcast from
    fnc_debugVirtualisedProfiles. Filters on admin / Zeus status,
    then renders per-profile local map markers so the admin can see
    virtualised + active profile positions live during a session.

    Backs GitHub issue #863.

    Local markers (createMarkerLocal) - invisible to non-admin
    players. Per-tick cycle: delete prior markers via the tracked
    name list, render fresh markers from the new snapshot.

    Marker scheme:
      - Type icon: b_inf / o_inf / n_inf / c_unknown for entities;
        b_armor / o_armor / n_armor for vehicle profiles.
      - Colour: side-keyed (BLUFOR blue, OPFOR red, IND green, CIV yellow).
      - Alpha: 1.0 for active profiles, 0.4 for virtualised.
      - Label: "<faction>:<profileID>" or with waypoint count when entity.

Parameters:
    0: ARRAY - profile snapshot [[id, type, pos, side, faction,
                                   active, vehicleClass, unitClasses,
                                   waypointCount], ...]

Returns:
    Nothing.

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_snapshot", [], [[]]]];

if (!hasInterface) exitWith {};

// Three gates - any one passes:
//   isHost  = singleplayer OR listen-server host (server + interface)
//   isAdmin = dedicated-server admin after #login (serverCommandAvailable)
//   isZeus  = player has a curator logic assigned
// serverCommandAvailable alone fails in singleplayer / Eden preview
// because SP has no concept of "admin" - the host check covers that.
private _isHost  = isServer && hasInterface;
private _isAdmin = serverCommandAvailable "#kick";
private _isZeus  = !isNull (getAssignedCuratorLogic player);
if (!_isHost && {!_isAdmin} && {!_isZeus}) exitWith {};

// Diag so users can confirm the receiver fired when troubleshooting.
// Gated on the same global as the PFH; off by default = silent.
if (!isNil "ALiVE_debugVirtualisedProfiles" && {ALiVE_debugVirtualisedProfiles}) then {
    ["[ALiVE VirtDebug] client recv: count=%1 host=%2 admin=%3 zeus=%4", count _snapshot, _isHost, _isAdmin, _isZeus] call ALiVE_fnc_dump;
};

// Delete prior markers via the tracked name list. We don't enumerate
// allMapMarkers because that'd touch every marker on the map.
private _prior = missionNamespace getVariable ["ALiVE_debugVirtProfileMarkers", []];
{ deleteMarkerLocal _x } forEach _prior;

private _newMarkers = [];

{
    _x params ["_id", "_typ", "_pos", "_sde", "_fac", "_act", "_vcl", "_ucl", "_wpc"];

    private _color = switch (_sde) do {
        case "EAST": { "ColorRed" };
        case "WEST": { "ColorBlue" };
        case "GUER": { "ColorGreen" };
        case "CIV":  { "ColorYellow" };
        default      { "ColorWhite" };
    };

    private _typePrefix = switch (_sde) do {
        case "EAST": { "o" };
        case "WEST": { "b" };
        case "GUER": { "n" };
        case "CIV":  { "c" };
        default      { "n" };
    };

    private _icon = if (_typ == "vehicle") then {
        format ["%1_armor", _typePrefix]
    } else {
        // entity (infantry group)
        if (_typePrefix == "c") then { "c_unknown" } else { format ["%1_inf", _typePrefix] }
    };

    private _mName = format ["ALiVE_VirtDebug_%1", _id];
    private _m = createMarkerLocal [_mName, _pos];
    _m setMarkerShapeLocal "ICON";
    _m setMarkerSizeLocal [0.8, 0.8];
    _m setMarkerTypeLocal _icon;
    _m setMarkerColorLocal _color;
    _m setMarkerAlphaLocal (if (_act) then { 1.0 } else { 0.45 });

    // Rich label so each marker tells the admin what they're looking
    // at: VP prefix to distinguish from existing global debug markers,
    // type indicator (V=vehicle / I=infantry-entity), side single
    // letter, active/virtualised state glyph, class shortname, and
    // waypoint count when present.
    private _labelClass = if (_typ == "vehicle") then {
        _vcl
    } else {
        if (count _ucl > 0) then { (_ucl select 0) } else { "" }
    };
    // Class shortname - strip mod prefix at the last underscore for
    // readability ("rhs_msv_bmp2_msv" -> "bmp2_msv" still long,
    // alternative is to keep full but that crowds the label).
    private _shortClass = _labelClass;
    private _sideLetter = switch (_sde) do {
        case "EAST": { "O" };
        case "WEST": { "B" };
        case "GUER": { "I" };
        case "CIV":  { "C" };
        default      { "?" };
    };
    private _typeLetter = if (_typ == "vehicle") then { "V" } else { "E" };
    private _stateGlyph = if (_act) then { "*" } else { "~" };
    // Unit count for entity-type profiles (infantry groups). Vehicle
    // profiles don't carry a unitClasses array - their crew is on a
    // separate paired entity profile - so skip the count for vehicles.
    private _unitCount = if (_typ == "entity") then { count _ucl } else { 0 };
    private _suffix = "";
    if (_unitCount > 0) then { _suffix = format [" [%1u]", _unitCount] };
    if (_wpc > 0) then { _suffix = _suffix + format [" [%1wp]", _wpc] };

    private _label = format ["VP %1%2%3 %4%5", _stateGlyph, _typeLetter, _sideLetter, _shortClass, _suffix];
    _m setMarkerTextLocal _label;

    _newMarkers pushBack _mName;
} forEach _snapshot;

missionNamespace setVariable ["ALiVE_debugVirtProfileMarkers", _newMarkers];
