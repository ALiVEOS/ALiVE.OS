class CfgFunctions {
    class PREFIX {
        class COMPONENT {

            class civInteraction {
                description = "Main handler for civilian interaction";
                file = "\x\alive\addons\sys_civ_interaction\fnc_civInteraction.sqf";
                RECOMPILE;
            };

            class civInteractionAddAction {
                description = "Adds interaction action to civilians";
                file = "\x\alive\addons\sys_civ_interaction\fnc_civInteractionAddAction.sqf";
                RECOMPILE;
            };

            class civInteractionHandler {
                description = "Serverside handling of civilian interactions";
                file = "\x\alive\addons\sys_civ_interaction\fnc_civInteractionHandler.sqf";
                RECOMPILE;
            };

            class civInteractionHandlerOnAction {
                description = "Serverside handling of civilian interactions";
                file = "\x\alive\addons\sys_civ_interaction\fnc_civInteractionHandlerOnAction.sqf";
                RECOMPILE;
            };

            class civInteractionInit {
                description = "Initializes civilian interaction";
                file = "\x\alive\addons\sys_civ_interaction\fnc_civInteractionInit.sqf";
                RECOMPILE;
            };

            class civInteractionOnAction {
                description = "Handles civ interaction events";
                file = "\x\alive\addons\sys_civ_interaction\fnc_civInteractionOnAction.sqf";
                RECOMPILE;
            };

        };
    };
};