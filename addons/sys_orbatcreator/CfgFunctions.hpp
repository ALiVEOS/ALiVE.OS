class CfgFunctions {
    class PREFIX {
        class COMPONENT {

            class orbatCreator {
                description = "Main handler for the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreator.sqf";
                RECOMPILE;
            };

            class orbatCreatorFaction {
                description = "Main handler for factions for the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorFaction.sqf";
                RECOMPILE;
            };

            class orbatCreatorInit {
                description = "Initializes the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorInit.sqf";
                RECOMPILE;
            };

            class orbatCreatorMenuDef {
                description = "This function controls the View portion of the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorMenuDef.sqf";
                RECOMPILE;
            };

            class orbatCreatorOnAction {
                description = "Handles orbat creator interface events";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorOnAction.sqf";
                RECOMPILE;
            };

            class orbatCreatorUnit {
                description = "Main handler for custom units for the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorUnit.sqf";
                RECOMPILE;
            };

        };
    };
};