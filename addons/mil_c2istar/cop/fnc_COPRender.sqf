#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(COPRender);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_COPRender

Description:
    Seeds 15 client-side map rendering function globals used by COP.
    Called from the map Draw EH each frame the map is visible.

    Architecture:
      ALIVE_fnc_COPDrawAll             — top-level dispatcher
        ├─ Layer 5 (back):   COPDrawSentimentHeat, COPDrawAsymZone,
        │                    COPDrawAsymInfra
        ├─ Layer 4:          COPDrawObjective, COPDrawAxisArrow
        ├─ Layer 3:          COPDrawBftMarker
        └─ Layer 2 (front):  COPDrawEnemyMarker
                               ├─ COPDrawTrail
                               ├─ COPDrawConfidenceFrame
                               ├─ COPDrawSizeIndicator
                               ├─ COPDrawMovementArrow
                               ├─ COPDrawActivityBadge
                               ├─ COPDrawComposition
                               └─ COPDrawThreatHighlight

    Features:
    - Every function checks its config flag first and early-exits if disabled.
    - COPDrawAll applies two layered gates per marker:
        1. Anchor-distance proximity (ALIVE_COP_ANCHOR_DISTANCE metres of
           viewing player) — controlled by the Eden attribute.
        2. View-bounds culling — skip markers outside the visible map area.
      Both are resolved once per frame, not per marker.
    - Zoom-aware detail: labels, axis arrows, size indicators, and composition
      tags drop off progressively as the player zooms out.

Parameters:
    (none)

Returns:
    BOOL - true after render-function globals are seeded.

Author:
    Goldwep (ALiVE Mod Team)
---------------------------------------------------------------------------- */

TRACE_1("COPRender - input",_this);

// ============================================================================
// LEAF DRAWS — called by the master enemy-marker draw
// ============================================================================

// NATO size dots/bars above the unit frame.
ALIVE_fnc_COPDrawSizeIndicator = {
    params ["_mapCtrl", "_pos", "_sizeInd", "_color"];

    if (!ALIVE_COP_FEAT_SIZE) exitWith {};

    private _yOff    = ALIVE_COP_SIZE_OFFSET_Y;
    private _spacing = ALIVE_COP_SIZE_DOT_SPACING;
    private _dotPx   = ALIVE_COP_SIZE_DOT_PX;
    private _dot     = ALIVE_COP_TEX_DOT;
    private _barHalf = ALIVE_COP_SIZE_BAR_HALF_LEN;
    private _barGap  = ALIVE_COP_SIZE_BAR_GAP;

    switch (_sizeInd) do {
        case "squad": {
            _mapCtrl drawIcon [_dot, _color, [_pos select 0, (_pos select 1) + _yOff, 0],
                               _dotPx, _dotPx, 0, "", 0];
        };
        case "platoon": {
            _mapCtrl drawIcon [_dot, _color, [(_pos select 0) - _spacing/2, (_pos select 1) + _yOff, 0],
                               _dotPx, _dotPx, 0, "", 0];
            _mapCtrl drawIcon [_dot, _color, [(_pos select 0) + _spacing/2, (_pos select 1) + _yOff, 0],
                               _dotPx, _dotPx, 0, "", 0];
        };
        case "company": {
            _mapCtrl drawIcon [_dot, _color, [(_pos select 0) - _spacing, (_pos select 1) + _yOff, 0],
                               _dotPx, _dotPx, 0, "", 0];
            _mapCtrl drawIcon [_dot, _color, [_pos select 0, (_pos select 1) + _yOff, 0],
                               _dotPx, _dotPx, 0, "", 0];
            _mapCtrl drawIcon [_dot, _color, [(_pos select 0) + _spacing, (_pos select 1) + _yOff, 0],
                               _dotPx, _dotPx, 0, "", 0];
        };
        case "battalion": {
            _mapCtrl drawLine [[(_pos select 0) - _barHalf, (_pos select 1) + _yOff, 0],
                               [(_pos select 0) - _barGap,  (_pos select 1) + _yOff, 0], _color];
            _mapCtrl drawLine [[(_pos select 0) + _barGap,  (_pos select 1) + _yOff, 0],
                               [(_pos select 0) + _barHalf, (_pos select 1) + _yOff, 0], _color];
        };
    };
};

// Direction-of-travel arrow.
ALIVE_fnc_COPDrawMovementArrow = {
    params ["_mapCtrl", "_pos", "_heading", "_speed", "_color"];

    if (!ALIVE_COP_FEAT_MOVEMENT) exitWith {};
    if (_speed <= 0) exitWith {};

    private _len = switch (_speed) do {
        case 1: { ALIVE_COP_MOVEMENT_LEN_SLOW };
        case 2: { ALIVE_COP_MOVEMENT_LEN_MED };
        case 3: { ALIVE_COP_MOVEMENT_LEN_FAST };
        default { ALIVE_COP_MOVEMENT_LEN_SLOW };
    };

    private _rad = (_heading - 90) * (pi / 180);
    private _x2 = (_pos select 0) + cos _rad * _len;
    private _y2 = (_pos select 1) - sin _rad * _len;  // Y inverted on map

    _mapCtrl drawLine [_pos, [_x2, _y2, 0], _color];

    private _headLen = ALIVE_COP_MOVEMENT_HEAD_LEN;
    private _headAng = ALIVE_COP_MOVEMENT_HEAD_ANGLE;
    private _h1x = _x2 - cos (_rad - _headAng) * _headLen;
    private _h1y = _y2 + sin (_rad - _headAng) * _headLen;
    private _h2x = _x2 - cos (_rad + _headAng) * _headLen;
    private _h2y = _y2 + sin (_rad + _headAng) * _headLen;

    _mapCtrl drawLine [[_x2, _y2, 0], [_h1x, _h1y, 0], _color];
    _mapCtrl drawLine [[_x2, _y2, 0], [_h2x, _h2y, 0], _color];
};

// Single-letter activity badge (A/D/M/G/R).
ALIVE_fnc_COPDrawActivityBadge = {
    params ["_mapCtrl", "_pos", "_activity"];

    if (!ALIVE_COP_FEAT_ACTIVITY) exitWith {};
    if (_activity == "") exitWith {};

    private _color = [_activity] call ALIVE_fnc_COPGetActivityColor;
    private _badgePos = [(_pos select 0) + ALIVE_COP_BADGE_OFFSET_X, (_pos select 1) + ALIVE_COP_BADGE_OFFSET_Y, 0];

    _mapCtrl drawIcon ["", _color, _badgePos, 0, 0, 0, _activity, 1, ALIVE_COP_TEXT_SIZE_BADGE, ALIVE_COP_FONT_BOLD, "center"];
};

// Faded line connecting past positions of a cluster.
ALIVE_fnc_COPDrawTrail = {
    params ["_mapCtrl", "_trail", "_color"];

    if (!ALIVE_COP_FEAT_TRAIL) exitWith {};
    if (count _trail < 2) exitWith {};

    // Copy RGB once per call; mutate alpha inside the loop.
    // drawLine consumes the colour synchronously (arma3_reference.md §2.8),
    // so reusing this scratch across iterations is safe.
    ALIVE_COP_COLOR_TRAIL_SCRATCH set [0, _color select 0];
    ALIVE_COP_COLOR_TRAIL_SCRATCH set [1, _color select 1];
    ALIVE_COP_COLOR_TRAIL_SCRATCH set [2, _color select 2];
    private _baseAlpha = _color select 3;

    private _n = count _trail;
    for "_i" from 0 to (_n - 2) do {
        private _from = _trail select _i;
        private _to = _trail select (_i + 1);

        private _alpha = ALIVE_COP_TRAIL_ALPHA_FACTOR * (1 - (_i / _n));
        ALIVE_COP_COLOR_TRAIL_SCRATCH set [3, _baseAlpha * _alpha];

        _mapCtrl drawLine [_from, _to, ALIVE_COP_COLOR_TRAIL_SCRATCH];
    };
};

// Pulsing ring around high-priority targets.
ALIVE_fnc_COPDrawThreatHighlight = {
    params ["_mapCtrl", "_pos", "_type"];

    if (!ALIVE_COP_FEAT_THREAT) exitWith {};
    if (!([_type] call ALIVE_fnc_COPIsThreat)) exitWith {};

    // Mutate scratch array in place — avoids per-frame deep copy.
    private _pulse = 0.5 + 0.5 * sin (time * ALIVE_COP_THREAT_PULSE_SPEED);
    ALIVE_COP_COLOR_THREAT_SCRATCH set [3, ALIVE_COP_THREAT_ALPHA_MIN + (_pulse * ALIVE_COP_THREAT_ALPHA_RANGE)];

    _mapCtrl drawEllipse [_pos, ALIVE_COP_THREAT_RING_RADIUS, ALIVE_COP_THREAT_RING_RADIUS, 0, ALIVE_COP_COLOR_THREAT_SCRATCH, ""];
};

// Low-confidence outer ring for aging/stale intel.
ALIVE_fnc_COPDrawConfidenceFrame = {
    params ["_mapCtrl", "_pos", "_age", "_color"];

    if (!ALIVE_COP_FEAT_CONFIDENCE) exitWith {};

    private _style = [_age] call ALIVE_fnc_COPConfidenceStyle;
    if (_style == "solid") exitWith {};

    // Copy RGB from caller's colour; fixed ring alpha. drawEllipse consumes
    // the colour synchronously (arma3_reference.md §2.8) — safe to reuse the scratch.
    ALIVE_COP_COLOR_CONFIDENCE_SCRATCH set [0, _color select 0];
    ALIVE_COP_COLOR_CONFIDENCE_SCRATCH set [1, _color select 1];
    ALIVE_COP_COLOR_CONFIDENCE_SCRATCH set [2, _color select 2];
    ALIVE_COP_COLOR_CONFIDENCE_SCRATCH set [3, ALIVE_COP_CONFIDENCE_RING_ALPHA];

    private _radius = if (_style == "dashed") then { ALIVE_COP_CONFIDENCE_RING_DASHED } else { ALIVE_COP_CONFIDENCE_RING_DOTTED };

    _mapCtrl drawEllipse [_pos, _radius, _radius, 0, ALIVE_COP_COLOR_CONFIDENCE_SCRATCH, ""];
};

// "MIXED" label for clusters with multiple unit types.
ALIVE_fnc_COPDrawComposition = {
    params ["_mapCtrl", "_pos", "_isMixed", "_color"];

    if (!ALIVE_COP_FEAT_COMPOSITION) exitWith {};
    if (!_isMixed) exitWith {};

    private _belowPos = [_pos select 0, (_pos select 1) + ALIVE_COP_COMPOSITION_OFFSET_Y, 0];
    _mapCtrl drawIcon ["", _color, _belowPos, 0, 0, 0, "MIXED", 1, ALIVE_COP_TEXT_SIZE_COMPOSITION, ALIVE_COP_FONT_MAIN, "center"];
};

// ============================================================================
// MASTER DRAWS — per-layer entry points
// ============================================================================

// Enemy intel marker with all enabled features.
ALIVE_fnc_COPDrawEnemyMarker = {
    params ["_mapCtrl", "_entry"];

    _entry params ["_pos", "_sideKey", "_type", "_faction", "_count", "_sizeInd",
                   "_activity", "_heading", "_speed", "_age", "_isMixed", "_trail"];

    private _alpha = [_age] call ALIVE_fnc_COPAgeAlpha;

    private _baseColor = [_sideKey] call ALIVE_fnc_COPGetSideColor;
    private _color = [_baseColor select 0, _baseColor select 1, _baseColor select 2, (_baseColor select 3) * _alpha];

    // Build label only when zoomed in enough to display it.
    private _displayLabel = "";
    if (ALIVE_COP_render_showLabels) then {
        private _typeLabel = toUpper _type;
        if (_count > 1) then { _typeLabel = format ["%1 x%2", _typeLabel, _count]; };

        private _factionPart = "";
        if (ALIVE_COP_FEAT_FACTION && {_faction != ""}) then {
            _factionPart = format [" [%1]", _faction];
        };

        private _agePart = "";
        if (ALIVE_COP_FEAT_AGE) then {
            private _ageMin = floor (_age / 60);
            _agePart = format [" (%1m)", _ageMin];
        };

        _displayLabel = format ["%1%2%3", _typeLabel, _factionPart, _agePart];
    };

    // Trail and threat highlight always draw — they signify high-priority info.
    [_mapCtrl, _trail, _color] call ALIVE_fnc_COPDrawTrail;
    [_mapCtrl, _pos, _type] call ALIVE_fnc_COPDrawThreatHighlight;

    // Detail features only when zoomed in enough to read them.
    if (ALIVE_COP_render_showIntelDetail) then {
        [_mapCtrl, _pos, _age, _color] call ALIVE_fnc_COPDrawConfidenceFrame;
        [_mapCtrl, _pos, _heading, _speed, _color] call ALIVE_fnc_COPDrawMovementArrow;
    };

    // Main NATO icon.
    private _iconPath = [_sideKey, _type] call ALIVE_fnc_COPGetIconPath;
    _mapCtrl drawIcon [_iconPath, _color, _pos,
                       ALIVE_COP_SIZE_ENEMY, ALIVE_COP_SIZE_ENEMY, 0,
                       _displayLabel, 1, ALIVE_COP_TEXT_SIZE, ALIVE_COP_FONT_MAIN, "right"];

    if (ALIVE_COP_render_showIntelDetail) then {
        [_mapCtrl, _pos, _sizeInd, _color] call ALIVE_fnc_COPDrawSizeIndicator;
        [_mapCtrl, _pos, _activity] call ALIVE_fnc_COPDrawActivityBadge;
        [_mapCtrl, _pos, _isMixed, _color] call ALIVE_fnc_COPDrawComposition;
    };
};

// Friendly force-tracking marker.
ALIVE_fnc_COPDrawBftMarker = {
    params ["_mapCtrl", "_entry", "_sideKey"];

    _entry params ["_pos", "_type", "_count", "_sizeInd"];

    private _baseColor = [_sideKey] call ALIVE_fnc_COPGetSideColor;

    // Copy RGB from caller's side colour; fixed BFT alpha. drawIcon and the
    // size-indicator both consume the colour synchronously (arma3_reference.md §2.8)
    // — safe to reuse one scratch across both calls within a single frame.
    ALIVE_COP_COLOR_BFT_SCRATCH set [0, _baseColor select 0];
    ALIVE_COP_COLOR_BFT_SCRATCH set [1, _baseColor select 1];
    ALIVE_COP_COLOR_BFT_SCRATCH set [2, _baseColor select 2];
    ALIVE_COP_COLOR_BFT_SCRATCH set [3, ALIVE_COP_BFT_ALPHA];

    private _iconPath = if (ALIVE_COP_BFT_FEAT_TYPE) then {
        [_sideKey, _type] call ALIVE_fnc_COPGetIconPath
    } else {
        [_sideKey, "infantry"] call ALIVE_fnc_COPGetIconPath
    };

    private _label = "";
    if (ALIVE_COP_render_showBftDetail && _count >= ALIVE_COP_BFT_LABEL_MIN_COUNT) then {
        _label = format ["x%1", _count];
    };

    _mapCtrl drawIcon [_iconPath, ALIVE_COP_COLOR_BFT_SCRATCH, _pos,
                       ALIVE_COP_SIZE_BFT, ALIVE_COP_SIZE_BFT, 0,
                       _label, 0, ALIVE_COP_TEXT_SIZE * ALIVE_COP_TEXT_SIZE_BFT_FACTOR, ALIVE_COP_FONT_MAIN, "right"];

    if (ALIVE_COP_BFT_FEAT_SIZE && ALIVE_COP_render_showBftDetail) then {
        [_mapCtrl, _pos, _sizeInd, ALIVE_COP_COLOR_BFT_SCRATCH] call ALIVE_fnc_COPDrawSizeIndicator;
    };
};

// OPCOM objective circle (commander's intent).
ALIVE_fnc_COPDrawObjective = {
    params ["_mapCtrl", "_entry"];

    _entry params ["_pos", "_size", "_state", "_locName", "_priority"];

    private _show = switch (_state) do {
        case "attack":  { ALIVE_COP_OBJ_SHOW_ATTACK };
        case "defend":  { ALIVE_COP_OBJ_SHOW_DEFEND };
        case "recon":   { ALIVE_COP_OBJ_SHOW_RECON };
        case "reserve": { ALIVE_COP_OBJ_SHOW_RESERVE };
        default         { false };
    };
    if (!_show) exitWith {};

    private _color = switch (_state) do {
        case "attack":  { ALIVE_COP_COLOR_OBJ_ATTACK };
        case "defend":  { ALIVE_COP_COLOR_OBJ_DEFEND };
        case "recon":   { ALIVE_COP_COLOR_OBJ_RECON };
        case "reserve": { ALIVE_COP_COLOR_OBJ_RESERVE };
        default         { [1, 1, 1, 0.5] };
    };

    _mapCtrl drawEllipse [_pos, _size, _size, 0, _color, ""];

    if (!ALIVE_COP_render_showLabels) exitWith {};

    private _stateLabel = switch (_state) do {
        case "attack":  { "ATK" };
        case "defend":  { "DEF" };
        case "recon":   { "RCN" };
        case "reserve": { "RSV" };
        default         { toUpper _state };
    };

    private _locPart = if (ALIVE_COP_OBJ_LABEL_LOCATIONS && {_locName != ""}) then {
        format [" - %1", _locName]
    } else { "" };

    private _prioPart = if (ALIVE_COP_OBJ_SHOW_PRIORITY && {_priority > 0}) then {
        format [" - P%1", _priority]
    } else { "" };

    private _label = format ["%1%2%3", _stateLabel, _locPart, _prioPart];

    private _labelPos = [_pos select 0, (_pos select 1) + _size + ALIVE_COP_OBJ_LABEL_OFFSET_Y, 0];
    _mapCtrl drawIcon ["", _color, _labelPos, 0, 0, 0, _label, 1, ALIVE_COP_TEXT_SIZE_LABEL, ALIVE_COP_FONT_MAIN, "center"];
};

// Dashed axis-of-advance arrow from nearest friendly cluster to an attack objective.
ALIVE_fnc_COPDrawAxisArrow = {
    params ["_mapCtrl", "_objPos", "_friendlies"];

    if (!ALIVE_COP_OBJ_AXIS_ARROWS) exitWith {};
    if (count _friendlies == 0) exitWith {};

    // Short-circuit: if ANY friendly is within MIN_DIST of the objective,
    // we won't draw the arrow anyway, so bail as soon as we find one.
    // In the common case (friendlies actively attacking) this skips most of
    // the scan.
    private _nearest = nil;
    private _nearestDist = 1e9;
    private _tooClose = false;
    {
        private _fpos = _x select 0;
        private _d = _objPos distance2D _fpos;
        if (_d < ALIVE_COP_AXIS_MIN_DIST) exitWith { _tooClose = true; };
        if (_d < _nearestDist) then {
            _nearestDist = _d;
            _nearest = _fpos;
        };
    } forEach _friendlies;

    if (_tooClose) exitWith {};
    if (isNil "_nearest") exitWith {};

    // Copy RGB from ALIVE_COP_COLOR_OBJ_ATTACK; fixed axis-arrow alpha.
    // drawLine consumes the colour synchronously (arma3_reference.md §2.8)
    // — safe to reuse one scratch across all dash/head segments in one frame.
    ALIVE_COP_COLOR_AXIS_SCRATCH set [0, ALIVE_COP_COLOR_OBJ_ATTACK select 0];
    ALIVE_COP_COLOR_AXIS_SCRATCH set [1, ALIVE_COP_COLOR_OBJ_ATTACK select 1];
    ALIVE_COP_COLOR_AXIS_SCRATCH set [2, ALIVE_COP_COLOR_OBJ_ATTACK select 2];
    ALIVE_COP_COLOR_AXIS_SCRATCH set [3, ALIVE_COP_AXIS_ALPHA];

    private _dx = (_objPos select 0) - (_nearest select 0);
    private _dy = (_objPos select 1) - (_nearest select 1);
    private _len = sqrt (_dx * _dx + _dy * _dy);
    if (_len < 1) exitWith {};

    private _ux = _dx / _len;
    private _uy = _dy / _len;

    private _segLen = ALIVE_COP_AXIS_SEG_LEN;
    private _gapLen = ALIVE_COP_AXIS_GAP_LEN;
    private _step = _segLen + _gapLen;
    private _dist = 0;

    while {_dist + _segLen < _len} do {
        private _x1 = (_nearest select 0) + _ux * _dist;
        private _y1 = (_nearest select 1) + _uy * _dist;
        private _x2 = (_nearest select 0) + _ux * (_dist + _segLen);
        private _y2 = (_nearest select 1) + _uy * (_dist + _segLen);
        _mapCtrl drawLine [[_x1, _y1, 0], [_x2, _y2, 0], ALIVE_COP_COLOR_AXIS_SCRATCH];
        _dist = _dist + _step;
    };

    // Arrow head at the objective end.
    private _ax = (_objPos select 0) - _ux * ALIVE_COP_AXIS_HEAD_OFFSET;
    private _ay = (_objPos select 1) - _uy * ALIVE_COP_AXIS_HEAD_OFFSET;
    private _perpX = -_uy * ALIVE_COP_AXIS_HEAD_WIDTH;
    private _perpY =  _ux * ALIVE_COP_AXIS_HEAD_WIDTH;

    _mapCtrl drawLine [[_ax + _perpX, _ay + _perpY, 0], [_objPos select 0, _objPos select 1, 0], ALIVE_COP_COLOR_AXIS_SCRATCH];
    _mapCtrl drawLine [[_ax - _perpX, _ay - _perpY, 0], [_objPos select 0, _objPos select 1, 0], ALIVE_COP_COLOR_AXIS_SCRATCH];
};

// ============================================================================
// LAYER 5 — ASYMMETRIC DRAWS
// ============================================================================

// Orange activity zone (terrorize/raid).
ALIVE_fnc_COPDrawAsymZone = {
    params ["_mapCtrl", "_entry"];

    if (!ALIVE_COP_ASYM_SHOW_ACTIVITY) exitWith {};

    _entry params ["_state", "_pos", "_size", "_locName"];

    // Mutate scratch color in place.
    ALIVE_COP_COLOR_ASYM_SCRATCH set [3, ALIVE_COP_ASYM_ZONE_ALPHA];
    private _color = ALIVE_COP_COLOR_ASYM_SCRATCH;

    _mapCtrl drawEllipse [_pos, _size, _size, 0, _color, ""];

    _mapCtrl drawIcon [ALIVE_COP_TEX_WARNING, _color, _pos,
                       ALIVE_COP_ASYM_WARN_ICON_PX, ALIVE_COP_ASYM_WARN_ICON_PX, 0, "", 0];

    if (!ALIVE_COP_render_showLabels) exitWith {};

    private _stateLabel = switch (toLower _state) do {
        case "terrorize": { "TERROR" };
        case "attack":    { "RAID" };
        default           { toUpper _state };
    };
    private _label = format ["INTEL - %1 - %2", _stateLabel, _locName];

    private _labelPos = [_pos select 0, (_pos select 1) + _size + ALIVE_COP_ASYM_LABEL_OFFSET_Y, 0];
    _mapCtrl drawIcon ["", _color, _labelPos, 0, 0, 0, _label, 1, ALIVE_COP_TEXT_SIZE_LABEL, ALIVE_COP_FONT_MAIN, "center"];
};

// Civilian sentiment heat shading (player-side filtered).
ALIVE_fnc_COPDrawSentimentHeat = {
    params ["_mapCtrl", "_entry"];

    if (!ALIVE_COP_ASYM_SHOW_HOSTILITY) exitWith {};

    _entry params ["_pos", "_size", "_hostArr"];

    // Find hostility for player's side. Defensive against malformed entries.
    private _myHost = 0;
    private _found = false;
    {
        if (!_found && {_x isEqualType [] && {count _x >= 2}}) then {
            private _sideStr = _x select 0;
            private _val = _x select 1;
            if (_sideStr isEqualType "" && {_val isEqualType 0}) then {
                if (toUpper _sideStr == ALIVE_COP_playerSideKey) then {
                    _myHost = _val;
                    _found = true;
                };
            };
        };
    } forEach _hostArr;

    private _color = [0, 0, 0, 0];
    if (_myHost <= ALIVE_COP_ASYM_FRIENDLY_MAX) then {
        _color = ALIVE_COP_COLOR_FRIENDLY;
    } else {
        if (_myHost >= ALIVE_COP_ASYM_STRONGHOLD_MIN) then {
            _color = ALIVE_COP_COLOR_STRONGHOLD;
        } else {
            if (_myHost >= ALIVE_COP_ASYM_HOSTILE_MIN) then {
                _color = ALIVE_COP_COLOR_HOSTILE;
            };
        };
    };

    if ((_color select 3) == 0) exitWith {};

    _mapCtrl drawEllipse [_pos, _size, _size, 0, _color, ALIVE_COP_TEX_FILL_WHITE];
};

// Insurgent infrastructure icon (per-type gating; all OFF by default).
ALIVE_fnc_COPDrawAsymInfra = {
    params ["_mapCtrl", "_entry"];

    _entry params ["_type", "_pos"];

    private _show = switch (_type) do {
        case "ied":        { ALIVE_COP_ASYM_SHOW_IED };
        case "factory":    { ALIVE_COP_ASYM_SHOW_FACTORY };
        case "depot":      { ALIVE_COP_ASYM_SHOW_DEPOT };
        case "HQ":         { ALIVE_COP_ASYM_SHOW_HQ };
        case "suicide":    { ALIVE_COP_ASYM_SHOW_SUICIDE };
        case "sabotage":   { ALIVE_COP_ASYM_SHOW_SABOTAGE };
        case "roadblocks": { ALIVE_COP_ASYM_SHOW_ROADBLOCK };
        default            { false };
    };
    if (!_show) exitWith {};

    // Refresh scratch from base each call. drawIcon consumes the colour
    // synchronously (arma3_reference.md §2.8) — safe to reuse across calls.
    // Kept SEPARATE from ALIVE_COP_COLOR_ASYM_SCRATCH (asym-zone alpha-fade
    // path at line ~410) so the two paths don't share state.
    ALIVE_COP_COLOR_ASYM_INFRA_SCRATCH set [0, ALIVE_COP_COLOR_ASYM select 0];
    ALIVE_COP_COLOR_ASYM_INFRA_SCRATCH set [1, ALIVE_COP_COLOR_ASYM select 1];
    ALIVE_COP_COLOR_ASYM_INFRA_SCRATCH set [2, ALIVE_COP_COLOR_ASYM select 2];
    ALIVE_COP_COLOR_ASYM_INFRA_SCRATCH set [3, ALIVE_COP_COLOR_ASYM select 3];

    private _icon = switch (_type) do {
        case "ied":        { ALIVE_COP_TEX_WARNING };
        case "factory":    { ALIVE_COP_TEX_INSTALL };
        case "depot":      { ALIVE_COP_TEX_BOX };
        case "HQ":         { ALIVE_COP_TEX_FLAG };
        case "suicide":    { ALIVE_COP_TEX_WARNING };
        case "sabotage":   { ALIVE_COP_TEX_OBJECTIVE };
        case "roadblocks": { ALIVE_COP_TEX_DOT };
        default            { ALIVE_COP_TEX_UNKNOWN };
    };

    private _label = toUpper _type;

    _mapCtrl drawIcon [_icon, ALIVE_COP_COLOR_ASYM_INFRA_SCRATCH, _pos,
                       ALIVE_COP_ASYM_INFRA_ICON_PX, ALIVE_COP_ASYM_INFRA_ICON_PX, 0,
                       _label, 1, ALIVE_COP_TEXT_SIZE_LABEL, ALIVE_COP_FONT_MAIN, "right"];
};

// ============================================================================
// TOP-LEVEL DISPATCHER — called from the map Draw EH each frame
//
// Applies two layered gates per marker:
//   1. Anchor-distance proximity (Eden-configurable 100/200/500/1000/3000 m).
//   2. View-bounds culling (current map viewport + buffer).
//
// Perf notes:
//   * Viewport bounds are cached between frames and only recomputed when
//     ctrlMapScale changes. Panning produces a 1-frame stale viewport which
//     is imperceptible at 60 fps.
//   * Both gates are inlined into each layer's forEach (no closure stack
//     frame allocation per marker). At 100+ markers per frame this removes
//     ~140 call-frames that the prior `_passGate` helper created.
// ============================================================================
ALIVE_fnc_COPDrawAll = {
    params ["_mapCtrl"];

    // Resolve player side key (cached at init, refreshed on respawn).
    if (isNil "ALIVE_COP_playerSideKey") exitWith {};
    private _sideKey = ALIVE_COP_playerSideKey;
    if (_sideKey == "UNKNOWN") exitWith {};

    // Anchor resolved once per frame.
    private _anchor = getPos player;
    private _anchorDist = missionNamespace getVariable ["ALIVE_COP_ANCHOR_DISTANCE", 1000];

    // Zoom level (0.05 = max zoom in, 1.0 = max zoom out).
    private _zoom = ctrlMapScale _mapCtrl;

    // Viewport bounds cache — only recompute when zoom changes.
    private _lastZoom = missionNamespace getVariable ["ALIVE_COP_render_lastZoom", -1];
    if (_zoom != _lastZoom || {isNil "ALIVE_COP_render_viewMinX"}) then {
        ALIVE_COP_render_lastZoom = _zoom;
        private _topLeft     = _mapCtrl ctrlMapScreenToWorld [safezoneX, safezoneY];
        private _bottomRight = _mapCtrl ctrlMapScreenToWorld [safezoneX + safezoneW, safezoneY + safezoneH];
        ALIVE_COP_render_viewMinX = _topLeft select 0;
        ALIVE_COP_render_viewMaxX = _bottomRight select 0;
        ALIVE_COP_render_viewMinY = _bottomRight select 1;
        ALIVE_COP_render_viewMaxY = _topLeft select 1;
    };

    // Pull into locals for the hot loops (faster than repeated missionNamespace reads).
    private _viewMinX = ALIVE_COP_render_viewMinX;
    private _viewMaxX = ALIVE_COP_render_viewMaxX;
    private _viewMinY = ALIVE_COP_render_viewMinY;
    private _viewMaxY = ALIVE_COP_render_viewMaxY;

    // PublicVariable channel names (cached at client init to avoid per-frame format).
    private _intel = missionNamespace getVariable [ALIVE_COP_intelVar_intel, []];
    private _bft   = missionNamespace getVariable [ALIVE_COP_intelVar_bft, []];
    private _obj   = missionNamespace getVariable [ALIVE_COP_intelVar_obj, []];

    private _asymAct   = missionNamespace getVariable ["ALiVE_COP_AsymActivityData", []];
    private _asymHost  = missionNamespace getVariable ["ALiVE_COP_AsymHostilityData", []];
    private _asymInfra = missionNamespace getVariable ["ALiVE_COP_AsymInfraData", []];

    // Zoom-aware detail flags — leaf draws read them via missionNamespace
    // (assignment to bare global = missionNamespace set).
    ALIVE_COP_render_showLabels      = _zoom <= ALIVE_COP_ZOOM_LABEL_MAX;
    ALIVE_COP_render_showArrows      = _zoom <= ALIVE_COP_ZOOM_ARROW_MAX;
    ALIVE_COP_render_showBftDetail   = _zoom <= ALIVE_COP_ZOOM_BFT_MAX;
    ALIVE_COP_render_showIntelDetail = _zoom <= ALIVE_COP_ZOOM_INTEL_DETAIL;

    // ----- Layer 5 (back): civilian sentiment heat map -----
    if (ALIVE_COP_LAYER_ASYMMETRIC && ALIVE_COP_ASYM_SHOW_HOSTILITY) then {
        {
            private _entryPos  = _x select 0;
            private _entrySize = _x select 1;
            if ((_entryPos distance2D _anchor) <= _anchorDist) then {
                private _ex = _entryPos select 0;
                private _ey = _entryPos select 1;
                if (_ex >= (_viewMinX - _entrySize) && {_ex <= (_viewMaxX + _entrySize)}
                    && {_ey >= (_viewMinY - _entrySize) && {_ey <= (_viewMaxY + _entrySize)}}) then {
                    [_mapCtrl, _x] call ALIVE_fnc_COPDrawSentimentHeat;
                };
            };
        } forEach _asymHost;
    };

    // ----- Layer 4: OPCOM objectives + axis arrows -----
    if (ALIVE_COP_LAYER_OBJECTIVES) then {
        {
            private _entry     = _x;
            private _entryPos  = _entry select 0;
            private _entrySize = _entry select 1;

            if ((_entryPos distance2D _anchor) <= _anchorDist) then {
                private _ex = _entryPos select 0;
                private _ey = _entryPos select 1;
                if (_ex >= (_viewMinX - _entrySize) && {_ex <= (_viewMaxX + _entrySize)}
                    && {_ey >= (_viewMinY - _entrySize) && {_ey <= (_viewMaxY + _entrySize)}}) then {
                    [_mapCtrl, _entry] call ALIVE_fnc_COPDrawObjective;

                    if (ALIVE_COP_render_showArrows && {(_entry select 2) == "attack"} && ALIVE_COP_OBJ_AXIS_ARROWS) then {
                        [_mapCtrl, _entryPos, _bft] call ALIVE_fnc_COPDrawAxisArrow;
                    };
                };
            };
        } forEach _obj;
    };

    // ----- Layer 5: asymmetric activity zones -----
    if (ALIVE_COP_LAYER_ASYMMETRIC && ALIVE_COP_ASYM_SHOW_ACTIVITY) then {
        {
            private _entryPos  = _x select 1;
            private _entrySize = _x select 2;
            if ((_entryPos distance2D _anchor) <= _anchorDist) then {
                private _ex = _entryPos select 0;
                private _ey = _entryPos select 1;
                if (_ex >= (_viewMinX - _entrySize) && {_ex <= (_viewMaxX + _entrySize)}
                    && {_ey >= (_viewMinY - _entrySize) && {_ey <= (_viewMaxY + _entrySize)}}) then {
                    [_mapCtrl, _x] call ALIVE_fnc_COPDrawAsymZone;
                };
            };
        } forEach _asymAct;
    };

    // ----- Layer 5: insurgent infrastructure (all gated off by default) -----
    if (ALIVE_COP_LAYER_ASYMMETRIC) then {
        {
            private _entryPos = _x select 1;
            if ((_entryPos distance2D _anchor) <= _anchorDist) then {
                private _ex = _entryPos select 0;
                private _ey = _entryPos select 1;
                if (_ex >= (_viewMinX - 200) && {_ex <= (_viewMaxX + 200)}
                    && {_ey >= (_viewMinY - 200) && {_ey <= (_viewMaxY + 200)}}) then {
                    [_mapCtrl, _x] call ALIVE_fnc_COPDrawAsymInfra;
                };
            };
        } forEach _asymInfra;
    };

    // ----- Layer 3: BFT -----
    if (ALIVE_COP_LAYER_BFT) then {
        {
            private _entryPos = _x select 0;
            if ((_entryPos distance2D _anchor) <= _anchorDist) then {
                private _ex = _entryPos select 0;
                private _ey = _entryPos select 1;
                if (_ex >= (_viewMinX - 200) && {_ex <= (_viewMaxX + 200)}
                    && {_ey >= (_viewMinY - 200) && {_ey <= (_viewMaxY + 200)}}) then {
                    [_mapCtrl, _x, _sideKey] call ALIVE_fnc_COPDrawBftMarker;
                };
            };
        } forEach _bft;
    };

    // ----- Layer 2 (front): enemy intel -----
    if (ALIVE_COP_LAYER_ENEMIES) then {
        {
            private _entryPos = _x select 0;
            if ((_entryPos distance2D _anchor) <= _anchorDist) then {
                private _ex = _entryPos select 0;
                private _ey = _entryPos select 1;
                if (_ex >= (_viewMinX - 200) && {_ex <= (_viewMaxX + 200)}
                    && {_ey >= (_viewMinY - 200) && {_ey <= (_viewMaxY + 200)}}) then {
                    [_mapCtrl, _x] call ALIVE_fnc_COPDrawEnemyMarker;
                };
            };
        } forEach _intel;
    };
};

["COP - Render: 15 draw functions seeded"] call ALiVE_fnc_dump;

private _result = true;
TRACE_1("COPRender - output",_result);
_result
