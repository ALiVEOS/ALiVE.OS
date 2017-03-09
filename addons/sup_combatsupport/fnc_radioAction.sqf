#include <script_component.hpp>

//Action Variable
uinamespace setVariable ["NEO_radioCurrentAction", (_this select 0)];

//Open Interface

switch (MOD(TABLET_MODEL)) do {
    case "Tablet01": {
        createDialog "NEO_resourceRadio";
    };

    case "Mapbag01": {
        createDialog "NEO_resourceRadio";

        private _ctrlBackground = ((findDisplay 655555) displayCtrl 655556);
        _ctrlBackground ctrlsettext "x\alive\addons\mil_c2istar\data\ui\ALIVE_mapbag.paa";
        _ctrlBackground ctrlSetPosition [
            0.15 * safezoneW + safezoneX,
            -0.242 * safezoneH + safezoneY,
            0.72 * safezoneW,
            1.372 * safezoneH
        ];
        _ctrlBackground ctrlCommit 0;
    };

    default {
        createDialog "NEO_resourceRadio";
    };
};