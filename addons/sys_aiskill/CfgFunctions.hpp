class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class aiSkill {
                description = "The main class";
                file = "\x\alive\addons\sys_aiskill\fnc_AISkill.sqf";
                ALIVE_RECOMPILE;
            };
            class aiSkillInit {
                description = "The module initialisation function";
                file = "\x\alive\addons\sys_aiskill\fnc_AISkillInit.sqf";
                ALIVE_RECOMPILE;
            };
            class AIskillSetter {
                description = "The init EH function";
                file = "\x\alive\addons\sys_aiskill\fnc_AISkillSetter.sqf";
                ALIVE_RECOMPILE;
            };
        };
    };
};
