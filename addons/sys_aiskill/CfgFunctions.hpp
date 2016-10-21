class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class aiSkill {
                description = "The main class";
                file = "\x\alive\addons\sys_aiskill\fnc_AISkill.sqf";
                RECOMPILE;
            };
            class aiSkillInit {
                description = "The module initialisation function";
                file = "\x\alive\addons\sys_aiskill\fnc_AISkillInit.sqf";
                RECOMPILE;
            };
            class AIskillSetter {
                description = "The init EH function";
                file = "\x\alive\addons\sys_aiskill\fnc_AISkillSetter.sqf";
                RECOMPILE;
            };
        };
    };
};
