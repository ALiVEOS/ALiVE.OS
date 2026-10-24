/*
    NEO_fnc_artyCmdrConfirm
    Commander's guns (F509): Confirm on the "Commander's guns" row. The operator check has already run
    (NEO_fnc_artyConfirmButton). The grid, the round and the count go to the server, which picks the AI
    Commander's battery, checks for friendlies and answers on the side channel.

    Author: Jman
*/
private _display = findDisplay 655555;
if (isNull _display) exitWith {};
private _artyOrdnanceTypeLb = _display displayCtrl 655601;
private _artyRoundCountLb = _display displayCtrl 655605;
private _supportMarker = NEO_radioLogic getVariable "NEO_supportMarker";

// a fresh map click first, else the last-shot marker, as a battery of the players' own does
private _pos = if (!isNil { uinamespace getVariable "NEO_artyMarkerCreated" }) then {
    getMarkerPos _supportMarker
} else {
    getMarkerPos (NEO_radioLogic getVariable ["NEO_supportMarkerArtyLastShot", _supportMarker])
};
_pos set [2, 0];
private _ordnanceType = _artyOrdnanceTypeLb lbData (lbCurSel _artyOrdnanceTypeLb);
private _count = (parseNumber (_artyRoundCountLb lbData (lbCurSel _artyRoundCountLb))) max 1;
private _coord = _pos call BIS_fnc_posToGrid;
private _callsignPlayer = (format ["%1", group player]) call NEO_fnc_callsignFix;

// the request on the side channel, read in each player's own language
[[player, [["STR_ALIVE_CS_MSG_CMDR_REQUEST", "STR_ALIVE_CS_MSG_CMDR_REQUEST_1"] select (_count == 1), "$STR_ALIVE_CS_UI_CMDR_GUNS", _callsignPlayer, _count, _ordnanceType, _coord select 0, _coord select 1], "side"], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP;

[_pos, _ordnanceType, _count] remoteExecCall ["ALIVE_fnc_combatSupportCmdrArtyRequest", 2];
missionNamespace setVariable ["NEO_artyCmdrSentAt", time];

// the last-shot marker, so the same grid can be called again without a new click
private _lastShotMarker = NEO_radioLogic getVariable ["NEO_supportMarkerArtyLastShot", ""];
if (_lastShotMarker == "") then {
    _lastShotMarker = createMarkerLocal ["NEO_supportMarkerArtyLastShot", _pos];
    // ALiVE's strike target pin when the player has its pins on, Arma's otherwise (ALiVE_fnc_mapPins)
    ["pin", [_lastShotMarker, "hd_Destroy_noShadow", "strikeTarget", "ColorOrange"]] call ALiVE_fnc_mapPins;
    NEO_radioLogic setVariable ["NEO_supportMarkerArtyLastShot", _lastShotMarker];
};
_lastShotMarker setMarkerPosLocal _pos;
_lastShotMarker setMarkerTextLocal format [localize "STR_ALIVE_CS_UI_MARKER_LAST_FIRE", mapGridPosition _pos];
_lastShotMarker setMarkerAlphaLocal 1;

[lbCurSel 655565] call NEO_fnc_radioRefreshUi;
