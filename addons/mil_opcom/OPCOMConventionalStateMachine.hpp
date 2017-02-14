class ALiVE_OPCOMConventionalStateMachine {

    list = "ALiVE_OPCOM_CONVENTIONAL_STATEMACHINE_LIST";

    class PostStart {
        onState = "systemchat 'poststart'";
        onStateEntered = "[_this,'postStart'] call ALiVE_fnc_OPCOMConventional";
        onStateLeaving = "";

        class Finished {
            targetState = "CycleStart";
            condition = "true";
            onTransition = "";
        };

    };

    class CycleStart {
        onState = "systemchat 'cyclestart'";
        onStateEntered = "[_this,'cycleStart'] call ALiVE_fnc_OPCOMConventional";
        onStateLeaving = "";

        class Finished {
            targetState = "UpdateFriendlyForces";
            condition = "true";
            onTransition = "";
        };

    };

    class UpdateFriendlyForces {
        onState = "systemchat 'UpdateFriendlyForces'";
        onStateEntered = "private _scriptHandle = [_this,'updateFriendlyForces'] spawn ALiVE_fnc_OPCOMConventional; _this setvariable ['updateFriendlyForcesHandle', _scriptHandle];";
        onStateLeaving = "_this setvariable ['updateFriendlyForcesHandle', nil]";

        class Finished {
            targetState = "CycleEnd";
            condition = "scriptDone (_this getvariable 'updateFriendlyForcesHandle')";
            onTransition = "";
        };

    };

    // this probably needs to be broken up

    class UpdateEnemyForces {
        onState = "systemchat 'UpdateEnemyForces'";
        onStateEntered = "private _scriptHandle = [_this,'updateEnemyForces'] spawn ALiVE_fnc_OPCOMConventional; _this setvariable ['updateEnemyForcesHandle', _scriptHandle];";
        onStateLeaving = "_this setvariable ['updateEnemyForcesHandle', nil]";

        class Finished {
            targetState = "CycleEnd"; // UpdateClusterOccupation
            condition = "scriptDone (_this getvariable 'updateEnemyForcesHandle')";
            onTransition = "";
        };

    };

    // this might need to be broken up

    class UpdateClusterOccupation {
        onState = "systemchat 'ClusterOccupation'";
        onStateEntered = "[_this,'updateClusterOccupation'] call ALiVE_fnc_OPCOMConventional";
        onStateLeaving = "";

        class Finished {
            targetState = "CycleEnd";
            condition = "true";
            onTransition = "";
        };

    };

    class CycleEnd {
        onState = "systemchat 'CycleEnd'";
        onStateEntered = "[_this,'cycleEnd'] call ALiVE_fnc_OPCOMConventional;";
        onStateLeaving = "";

        class Finished {
            targetState = "CycleStart";
            condition = "time - (_this getvariable 'lastCycleEndTime') >= 3";
            onTransition = "";
        };

    };



};