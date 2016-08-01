class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            class commandRouter {
                description = "commandRouter";
								file = PATHTO_FUNC(commandRouter);
                recompile = RECOMPILE;
            };
            class testCommand {
                description = "testCommand";
								file = PATHTO_FUNC(testCommand);
                recompile = RECOMPILE;
            };
            class testManagedCommand {
                description = "testManagedCommand";
								file = PATHTO_FUNC(testManagedCommand);
                recompile = RECOMPILE;
            };
            class buildingPatrol {
                description = "buildingPatrol";
								file = PATHTO_FUNC(buildingPatrol);
                recompile = RECOMPILE;
            };
            class managedBuildingPatrol {
                description = "managedBuildingPatrol";
								file = PATHTO_FUNC(managedBuildingPatrol);
                recompile = RECOMPILE;
            };
            class ambientMovement {
                description = "Ambient movement within a given radius";
								file = PATHTO_FUNC(ambientMovement);
                recompile = RECOMPILE;
            };
            class seaPatrol {
                description = "Ambient sea patrol within a given radius";
								file = PATHTO_FUNC(SeaPatrol);
                recompile = RECOMPILE;
            };
            class garrison {
                description = "Places units in building positions";
								file = PATHTO_FUNC(garrison);
                recompile = RECOMPILE;
            };
            class managedGarrison {
                description = "managedGarrison";
								file = PATHTO_FUNC(managedGarrison);
                recompile = RECOMPILE;
            };
            class insurgents {
                description = "Basic insurgents behaviour";
								file = PATHTO_FUNC(insurgents);
                recompile = RECOMPILE;
            };
            class ambush {
                description = "Ambush behaviour";
								file = PATHTO_FUNC(ambush);
                recompile = RECOMPILE;
            };
        };
    };
};
