#include "\x\alive\addons\sys_viewdistance\script_component.hpp"
#define SLIDER_VIEWDISTANCE ((vdist_dialog select 0) displayCtrl 1912)
#define TEXT_VIEWDISTANCE ((vdist_dialog select 0) displayCtrl 10091)
#define SLIDER_TERRAINGRID ((vdist_dialog select 0) displayCtrl 1913)
#define TEXT_TERRAINGRID ((vdist_dialog select 0) displayCtrl 10093)
#define SLIDER_OBJECTVD ((vdist_dialog select 0) displayCtrl 1914)
#define TEXT_OBJECTVD ((vdist_dialog select 0) displayCtrl 10095)

private ["_mingettg","_minsettg","_maxsettg","_maxgettg","_tgvalue","_settg"];
// The fallbacks are the editor's defaults, for a module made by script. They were the number 2,
// which parseNumber refuses.
_mingettg = ADDON getvariable["minTG", "1"]; // get the minimum terrain grid set in themodule
_minsettg = parseNumber format ["%1", _mingettg]; // convert the minimum variable to a number
if (_minsettg == 0) then {_minsettg = 1;}; //if the minimum terrain grid has not been set i.e blank, then set it to 1
_maxgettg = (ADDON getVariable ["maxTG", "5"]); // get the maximum terrain grid set in the module
_maxsettg = parseNumber format ["%1", _maxgettg]; // convert the maximum variable to a number
if (_maxsettg == 0) then {_maxsettg = 5;}; //if the maximum terrain grid has not been set i.e blank, then set it to  5
// The same tidying as fnc_vDist: whole tiers 1 to 5, and a reversed pair taken the other way round.
_minsettg = ((round _minsettg) max 1) min 5;
_maxsettg = ((round _maxsettg) max 1) min 5;
if (_minsettg > _maxsettg) then { private _swap = _minsettg; _minsettg = _maxsettg; _maxsettg = _swap; };

private ["_minsetvd","_maxsetvd","_mingetvd","_maxgetvd"];
_mingetvd = ADDON getvariable["minVD", "500"]; // get the minimum view distance set in themodule
_minsetvd = parseNumber format ["%1", _mingetvd]; // convert the minimum variable to a number
if (_minsetVD == 0) then {_minsetvd = 500;}; //if the minimum view distance has not been set i.e blank, then set it to 500
_maxgetvd = (ADDON getVariable ["maxVD", "20000"]); // get the maximum view distance se in the module
_maxsetvd = parseNumber format ["%1", _maxgetvd]; // convert the maximum variable to a number
if (_maxsetvd == 0) then {_maxsetvd = 15000;};//if the maximum view distance has not been set i.e blank, then set it to 1000
// The maximum holds, as it's also the cap the module applies: a minimum above it (a Max View
// Distance under the 500 m default Min, say) comes down to it rather than raising the cap.
_minsetvd = _minsetvd min _maxsetvd;

// the object view distance (buildings, trees, vehicles) runs from the same minimum up to the module's
// Max Object View Distance, and never past the view distance itself
private _maxsetovd = parseNumber format ["%1", ADDON getVariable ["maxOVD", "20000"]];
if (_maxsetovd <= 0) then { _maxsetovd = _maxsetvd };
MINVD = _minsetvd;
MAXVD = _maxsetvd;
MAXOVD = _maxsetovd;
MINTG = _minsettg;
MAXTG = _maxsettg;

// Each slider has a box over it showing its value. Moving the slider updates the box; typing a value in
// the box and pressing Enter (or clicking away) sets it, kept inside the slider's range, and moves the slider.
fn_vdist_refreshObjectVD = {
    private _cap = (MAXOVD min viewDistance) max MINVD;
    SLIDER_OBJECTVD sliderSetRange [MINVD, _cap];
    private _now = getObjectViewDistance select 0;
    private _o = (_now min _cap) max MINVD;
    if (_o != _now) then { setObjectViewDistance _o };
    SLIDER_OBJECTVD sliderSetPosition _o;
    TEXT_OBJECTVD ctrlSetText str (round _o);
};
fn_vdist_setViewDistance = {
    params ["_value", ["_fromSlider", false]];
    private _v = ((round _value) max MINVD) min MAXVD;
    setViewDistance _v;
    if (!_fromSlider) then { SLIDER_VIEWDISTANCE sliderSetPosition _v };
    TEXT_VIEWDISTANCE ctrlSetText str (round viewDistance);
    // a shorter view distance takes the object view distance down with it
    call fn_vdist_refreshObjectVD;
};
fn_vdist_setObjectVD = {
    params ["_value", ["_fromSlider", false]];
    private _cap = (MAXOVD min viewDistance) max MINVD;
    private _o = ((round _value) max MINVD) min _cap;
    setObjectViewDistance _o;
    if (!_fromSlider) then { SLIDER_OBJECTVD sliderSetPosition _o };
    TEXT_OBJECTVD ctrlSetText str (round _o);
};
fn_vdist_setTerrainGrid = {
    params ["_value", ["_fromSlider", false]];
    private _t = ((round _value) max MINTG) min MAXTG;
    terrainGrid = _t;
    setTerrainGrid (TGARRAY select (_t - 1));
    if (!_fromSlider) then { SLIDER_TERRAINGRID sliderSetPosition _t };
    TEXT_TERRAINGRID ctrlSetText str _t;
};
// a box's value is applied on Enter or when it loses focus; anything that isn't a number puts the current value back
fn_vdist_boxHandlers = {
    params ["_box", "_apply", "_current"];
    _box setVariable ["ALiVE_vdistApply", _apply];
    _box setVariable ["ALiVE_vdistCurrent", _current];
    _box setVariable ["ALiVE_vdistTake", {
        params ["_box"];
        private _n = parseNumber ctrlText _box;
        if (_n <= 0) then { _n = call (_box getVariable "ALiVE_vdistCurrent") };
        [_n] call (_box getVariable "ALiVE_vdistApply");
    }];
    _box ctrlAddEventHandler ["KillFocus", { [_this select 0] call ((_this select 0) getVariable "ALiVE_vdistTake") }];
    _box ctrlAddEventHandler ["KeyDown", {
        params ["_box", "_key"];
        if (_key in [28, 156]) then { [_box] call (_box getVariable "ALiVE_vdistTake"); true } else { false }
    }];
};

createDialog "vdist_dialog";

SLIDER_VIEWDISTANCE sliderSetRange [_minsetvd, _maxsetvd];
SLIDER_VIEWDISTANCE sliderSetPosition viewDistance;
TEXT_VIEWDISTANCE ctrlSetText str (round viewDistance);
SLIDER_VIEWDISTANCE ctrlAddEventHandler ["SliderPosChanged", { [_this select 1, true] call fn_vdist_setViewDistance }];
[TEXT_VIEWDISTANCE, fn_vdist_setViewDistance, { viewDistance }] call fn_vdist_boxHandlers;

SLIDER_TERRAINGRID sliderSetRange [_minsettg, _maxsettg];
SLIDER_TERRAINGRID sliderSetPosition terrainGrid;
if (tgvalue == 0) then {
    // one tier only: nothing to choose
    TEXT_TERRAINGRID ctrlSetText "Disabled";
    TEXT_TERRAINGRID ctrlEnable false;
} else {
    TEXT_TERRAINGRID ctrlSetText str (round terrainGrid);
    SLIDER_TERRAINGRID ctrlAddEventHandler ["SliderPosChanged", { [_this select 1, true] call fn_vdist_setTerrainGrid }];
    [TEXT_TERRAINGRID, fn_vdist_setTerrainGrid, { terrainGrid }] call fn_vdist_boxHandlers;
};

call fn_vdist_refreshObjectVD;
SLIDER_OBJECTVD ctrlAddEventHandler ["SliderPosChanged", { [_this select 1, true] call fn_vdist_setObjectVD }];
[TEXT_OBJECTVD, fn_vdist_setObjectVD, { getObjectViewDistance select 0 }] call fn_vdist_boxHandlers;
