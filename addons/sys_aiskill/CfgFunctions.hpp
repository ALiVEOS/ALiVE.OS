class CfgFunctions {
    class PREFIX {
        class COMPONENT {
            class aiSkill {
                description = "The main class";
								file = PATHTO_FUNC(AISkill);
                recompile = RECOMPILE;
            };
            class aiSkillInit {
                description = "The module initialisation function";
								file = PATHTO_FUNC(AISkillInit);
                recompile = RECOMPILE;
            };
            class AIskillSetter {
                description = "The init EH function";
								file = PATHTO_FUNC(AISkillSetter);
                recompile = RECOMPILE;
            };
        };
    };
};
