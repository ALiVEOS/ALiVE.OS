#include <script_component.hpp>

//Action Variable
uinamespace setVariable ["NEO_radioCurrentAction", (_this select 0)];

//Open Interface

switch (MOD(TABLET_MODEL)) do {
    case "Tablet01": {
        createDialog "NEO_resourceRadio";
    };

    case "Mapbag01": {
        createDialog "NEO_resourceRadio_MapBag";
    };

    default {
        createDialog "NEO_resourceRadio";
    };
};