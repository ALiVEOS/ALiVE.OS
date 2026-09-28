#include "\x\alive\addons\sys_viewdistance\script_component.hpp"
#define SLIDER_VIEWDISTANCE ((vdist_dialog select 0) displayCtrl 1912)
#define TEXT_VIEWDISTANCE ((vdist_dialog select 0) displayCtrl 10091)
#define SLIDER_TERRAINGRID ((vdist_dialog select 0) displayCtrl 1913)
#define TEXT_TERRAINGRID ((vdist_dialog select 0) displayCtrl 10093)

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

#define ESTABLISH_VDIST_SLIDER(DIALOG_GVAR,CTRL_NUMVD,RANGEMAX,INCREMENTER)    \
CTRL_NUMVD sliderSetRange [_minsetvd,_maxsetvd]; \
CTRL_NUMVD sliderSetPosition INCREMENTER;\
MAXVD = _maxsetvd;

#define ESTABLISH_TDTL_SLIDER(DIALOG_GVAR,CTRL_NUMTD,RANGEMAX,INCREMENTER)    \
CTRL_NUMTD sliderSetRange [_minsettg, _maxsettg]; \
sliderSetPosition [1913, terrainGrid];

fn_vdist_Slider_ChangeViewDistance =
{
        private ["_val"];
        _val = _this select 1;
        setviewdistance _val;
        TEXT_VIEWDISTANCE ctrlSetText "" + str(round viewdistance);
};

fn_vdist_Slider_ChangeTerrainGrid =
{
        private ["_terrainGrid"];
        _terrainGrid = round(_this select 1);
        terrainGrid = _terrainGrid;
        if(tgvalue == 0) then {
        TEXT_TERRAINGRID  ctrlSetText "Disabled";
        } else {
        TEXT_TERRAINGRID  ctrlSetText "" + str(round terrainGrid);
        if (terrainGrid == _terrainGrid) then {
                setterraingrid (TGARRAY select (terrainGrid - 1));
        };
};
};

createDialog "vdist_dialog";

ESTABLISH_VDIST_SLIDER(vdist_dialog,SLIDER_VIEWDISTANCE,15000,(viewDistance));
TEXT_VIEWDISTANCE ctrlSetText "" + str(round viewDistance);
SLIDER_VIEWDISTANCE ctrlSetEventHandler ["SliderPosChanged","_this call fn_vdist_Slider_ChangeViewDistance"];

ESTABLISH_TDTL_SLIDER(vdist_dialog,SLIDER_TERRAINGRID,50,(terrainGrid));
if(tgvalue == 0) then {
        TEXT_TERRAINGRID  ctrlSetText "Disabled";
        } else {
TEXT_TERRAINGRID  ctrlSetText "" + str(round terrainGrid);
SLIDER_TERRAINGRID ctrlSetEventHandler ["SliderPosChanged","_this call fn_vdist_Slider_ChangeTerrainGrid"];
};

