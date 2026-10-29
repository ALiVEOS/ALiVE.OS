/*
    NEO_fnc_artyCmdrUnitSelected
    Commander's guns (F509): the Artillery panel when the "Commander's guns" row is picked. It mirrors
    NEO_fnc_artyUnitLbSelChanged without a battery object: the ordnance is what the AI Commander's
    batteries can fire, the rings are those of its battery nearest the player, and SITREP, Move and Base
    stay off. Rate of fire and dispersion are the commander's own.

    Author: Jman
*/
([] call ALiVE_fnc_tabletBox) params ["_uiX", "_uiY", "_uiW", "_uiH"];
private _display = findDisplay 655555;
if (isNull _display) exitWith {};
private _map = _display displayCtrl 655560;
private _artyHelpUnitText = _display displayCtrl 655596;
private _artyBaseButton = _display displayCtrl 655610;
private _artyOrdnanceTypeText = _display displayCtrl 655600;
private _artyOrdnanceTypeLb = _display displayCtrl 655601;
private _artyRateOfFireText = _display displayCtrl 655602;
private _artyRateOfFireLb = _display displayCtrl 655603;
private _artyRoundCountText = _display displayCtrl 655604;
private _artyRoundCountLb = _display displayCtrl 655605;
private _artyMoveButton = _display displayCtrl 655606;
private _artyDontMoveButton = _display displayCtrl 655607;
private _artyDispersionText = _display displayCtrl 655608;
private _artyDispersionSlider = _display displayCtrl 655609;
private _artyRateDelayText = _display displayCtrl 655611;
private _artyRateDelaySlider = _display displayCtrl 655612;
private _sitRepButton = _display displayCtrl 655625;
private _supportMarker = NEO_radioLogic getVariable "NEO_supportMarker";
private _artyMarkers = NEO_radioLogic getVariable "NEO_supportArtyMarkers";

_artyHelpUnitText ctrlSetStructuredText parseText format ["<t color='#FFFFFF' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_CMDR_HELP"];

// SITREP, Move and Base belong to a battery of the players' own
_sitRepButton ctrlEnable false;
_artyMoveButton ctrlEnable false; _artyMoveButton ctrlSetPosition [_uiX + (_uiW / 1000), _uiY + (_uiH / 1.425), (_uiW / 1000), (_uiH / 1000)]; _artyMoveButton ctrlCommit 0;
_artyDontMoveButton ctrlEnable false; _artyDontMoveButton ctrlSetPosition [_uiX + (_uiW / 1000), _uiY + (_uiH / 1.375), (_uiW / 1000), (_uiH / 1000)]; _artyDontMoveButton ctrlCommit 0;
_artyBaseButton ctrlEnable false; _artyBaseButton ctrlSetText localize "STR_ALIVE_CS_UI_RTB";

// Markers
uinamespace setVariable ["NEO_artyMarkerCreated", nil];
{ _x setMarkerAlphaLocal 0 } forEach _artyMarkers + [_supportMarker];
[[], 0] call NEO_fnc_supportDrawRing;

// Re-initialise the controls
{ _x ctrlSetPosition [1, 1, (_uiW / 1000), (_uiH / 1000)]; _x ctrlCommit 0; } forEach [_artyDispersionSlider, _artyRateDelaySlider];
// the commander sets its own dispersion: a value left from one of the players' batteries must not
// draw a ring round the clicked grid
_artyDispersionSlider sliderSetPosition 0;
{ _x ctrlSetText "" } forEach [_artyOrdnanceTypeText, _artyRateOfFireText, _artyRoundCountText, _artyDispersionText, _artyRateDelayText];
{ lbClear _x } forEach [_artyOrdnanceTypeLb, _artyRateOfFireLb, _artyRoundCountLb];
{ _x ctrlSetBackgroundColor [0, 0, 0, 0] } forEach [_artyOrdnanceTypeLb, _artyRateOfFireLb, _artyRoundCountLb];

private _ords = ["ordnance"] call NEO_fnc_artyCmdrBoard;
if (_ords isNotEqualTo []) then {
    _artyOrdnanceTypeLb ctrlSetBackgroundColor [0.047, 0.047, 0.047, 0.72];
    _artyOrdnanceTypeText ctrlSetStructuredText parseText format ["<t color='#B4B4B4' size='0.8' font='PuristaMedium'>%1</t>", localize "STR_ALIVE_CS_UI_ORDNANCE"];
    _artyOrdnanceTypeLb ctrlEnable true;
    {
        private _row = _artyOrdnanceTypeLb lbAdd _x;
        _artyOrdnanceTypeLb lbSetData [_row, _x];
    } forEach _ords;

    // the rings of the commander battery nearest the player: red inside its minimum, green its reach
    private _near = ["nearest", [getPosATL player]] call NEO_fnc_artyCmdrBoard;
    if (_near isNotEqualTo []) then {
        {
            _x setMarkerPosLocal (_near select 0);
            _x setMarkerShapeLocal "ELLIPSE";
            _x setMarkerBrushlocal "SolidBorder";
            if (_forEachIndex == 0) then {
                _x setMarkerAlphaLocal 0.8;
                _x setMarkerSizeLocal [_near select 2, _near select 2];
                _x setMarkerColorLocal "ColorRed";
            } else {
                _x setMarkerAlphaLocal 0.3;
                _x setMarkerSizeLocal [_near select 1, _near select 1];
                _x setMarkerColorLocal "ColorGreen";
            };
        } forEach _artyMarkers;
    };

    _artyOrdnanceTypeLb ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_artyConfirmButtonEnable; _this call NEO_fnc_artyOrdLbSelChanged"];
    _map ctrlSetEventHandler ["MouseButtonDown", "_this call NEO_fnc_radioMapEvent"];
    uinamespace setVariable ["NEO_radioMapClickArmed", true];
    if (lbSize _artyOrdnanceTypeLb > 0) then { _artyOrdnanceTypeLb lbSetCurSel 0 };
};

[] call NEO_fnc_artyConfirmButtonEnable;
