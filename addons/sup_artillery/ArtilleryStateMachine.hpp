class ArtilleryStateMachine {
    list = "";

    class Idle {
        onState = "";
        onStateEntered = "";
        onStateLeaving = "";

        class HasFireMission {
            targetState = "Active";
            condition = "[_this, 'hasFireMission'] call ALIVE_fnc_Artillery";
            onTransition = "";
        };
    };

    class Active {
        onState = "[_this, 'onActive'] call ALIVE_fnc_Artillery";
        onStateEntered = "";
        onStateLeaving = "";

        class InRange {
            targetState = "Execute";
            condition = "[_this, 'inRange'] call ALIVE_fnc_Artillery";
            onTransition = "";
        };

        class NotInRange {
            targetState = "Move";
            condition = "!([_this, 'inRange'] call ALIVE_fnc_Artillery)";
            onTransition = "";
        };
    };

    class Move {
        onState = "[_this, 'onMove'] call ALIVE_fnc_Artillery";
        onStateEntered = "";
        onStateLeaving = "";

        class InPosition {
            targetState = "Execute";
            condition = "[_this, 'inPosition'] call ALIVE_fnc_Artillery";
            onTransition = "";
        };

        class Abort {
            targetState = "ReturnToBase";
            condition = "!([_this, 'hasFireMission'] call ALIVE_fnc_Artillery)";
            onTransition = "";
        };
    };

    class Execute {
        onState = "[_this, 'onExecute'] call ALIVE_fnc_Artillery";
        onStateEntered = "";
        onStateLeaving = "";

        class Abort {
            targetState = "ReturnToBase";
            condition = "!([_this, 'hasFireMission'] call ALIVE_fnc_Artillery)";
            onTransition = "";
        };
    };

    class Fire {
        onState = "[_this, 'onFire'] call ALIVE_fnc_Artillery";
        onStateEntered = "";
        onStateLeaving = "";

        class FireMissionComplete {
            targetState = "ReturnToBase";
            condition = "[_this, 'isFireMissionComplete'] call ALIVE_fnc_Artillery";
            onTransition = "";
        };

        class Fired {
            targetState = "FireDelay";
            condition = "true";
            onTransition = "";
        };
    };

    class FireDelay {
        onState = "";
        onStateEntered = "";
        onStateLeaving = "";

        class Continue {
            targetState = "Fire";
            condition = "[_this, 'fireNextRound'] call ALIVE_fnc_Artillery";
            onTransition = "";
        };
    };

    class ReturnToBase {
        onState = "[_this, 'onReturnToBase'] call ALIVE_fnc_Artillery";
        onStateEntered = "";
        onStateLeaving = "";

        class AtBase {
            targetState = "Idle";
            condition = "[_this, 'inPosition'] call ALIVE_fnc_Artillery";
            onTransition = "";
        };
    };
};
