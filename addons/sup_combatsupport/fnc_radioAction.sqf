#include "script_component.hpp"

//Action Variable
uinamespace setVariable ["NEO_radioCurrentAction", (_this select 0)];

//Open Interface

switch (MOD(TABLET_MODEL)) do {
    case "Tablet01": {
        createDialog "NEO_resourceRadio";
    };

    case "Mapbag01": {
        createDialog "NEO_resourceRadio";

        ([] call ALiVE_fnc_tabletBox) params ["_uiX","_uiY","_uiW","_uiH"];
        private _ctrlBackground = ((findDisplay 655555) displayCtrl 655556);
        _ctrlBackground ctrlsettext "x\alive\addons\main\data\ui\ALiVE_mapbag.paa";
        _ctrlBackground ctrlSetPosition [
            0.15 * _uiW + _uiX,
            -0.242 * _uiH + _uiY,
            0.72 * _uiW,
            1.372 * _uiH
        ];
        _ctrlBackground ctrlCommit 0;
    };

    default {
        createDialog "NEO_resourceRadio";
    };
};
