class CfgFunctions {
    class PREFIX {
        class COMPONENT {

            class orbatCreator {
                description = "Main handler for the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreator.sqf";
                recompile = RECOMPILE;
            };

            class orbatCreatorFaction {
                description = "Main handler for factions for the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorFaction.sqf";
                recompile = RECOMPILE;
            };

            class orbatCreatorInit {
                description = "Initializes the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorInit.sqf";
                recompile = RECOMPILE;
            };

            class orbatCreatorMenuDef {
                description = "This function controls the View portion of the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorMenuDef.sqf";
                recompile = RECOMPILE;
            };

            class orbatCreatorOnAction {
                description = "Handles orbat creator interface events";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorOnAction.sqf";
                recompile = RECOMPILE;
            };

            class orbatCreatorUnit {
                description = "Main handler for custom units for the orbat creator";
                file = "\x\alive\addons\sys_orbatcreator\fnc_orbatCreatorUnit.sqf";
                recompile = RECOMPILE;
            };

        };
    };
};