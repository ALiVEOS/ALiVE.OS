class CfgFunctions {
    class PREFIX {
        class COMPONENT {

            class orbatCreator {
                description = "Main handler for the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreator.sqf";
                ALIVE_RECOMPILE;
            };

            class orbatCreatorFaction {
                description = "Main handler for factions for the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorFaction.sqf";
                ALIVE_RECOMPILE;
            };

            class orbatCreatorInit {
                description = "Initializes the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorInit.sqf";
                ALIVE_RECOMPILE;
            };

            class orbatCreatorMenuDef {
                description = "This function controls the View portion of the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorMenuDef.sqf";
                ALIVE_RECOMPILE;
            };

            class orbatCreatorOnAction {
                description = "Handles orbat creator interface events";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorOnAction.sqf";
                ALIVE_RECOMPILE;
            };

            class orbatCreatorUnit {
                description = "Main handler for custom units for the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorUnit.sqf";
                ALIVE_RECOMPILE;
            };

        };
    };
};