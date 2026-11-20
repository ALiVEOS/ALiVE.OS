// Mods known to interfere with ALiVE, read by ALiVE_fnc_modConflicts.
//
// One class per mod:
//   name        - shown to players and admins
//   patches[]   - CfgPatches classes; any one loaded means the mod is loaded
//   missionVar  - a variable a mission-script version of the mod sets ("" when it has none)
//   effect      - what it does to ALiVE
//   handling    - what Guard does about it ("" when the mod gives no way to leave ALiVE's AI out)
//   groupVars[] - set true on each group ALiVE makes, under Guard
//   unitVars[]  - set true on each unit ALiVE makes, under Guard
//   unitVarsWithBehaviour[] - set true on each unit only while ALiVE's own Soldier Behaviour is on
// The variables are each mod's own documented opt-outs, set public so they hold on a headless client.
class CfgALiVEModConflicts {
    class LAMBS_Danger {
        name = "LAMBS Danger";
        patches[] = {"lambs_danger"};
        missionVar = "";
        effect = "its group tactics (flanking, assaulting, hiding from vehicles) move ALiVE's groups off the orders their commander gave them";
        handling = "LAMBS group tactics are turned off for ALiVE's groups; each soldier keeps his own LAMBS reactions, unless ALiVE's Soldier Behaviour is on";
        groupVars[] = {"lambs_danger_disableGroupAI"};
        unitVars[] = {};
        unitVarsWithBehaviour[] = {"lambs_danger_disableAI"};
    };
    class VCOM_AI {
        name = "VCOM AI";
        patches[] = {"VCOM_AI"};
        missionVar = "Vcm_ActivateAI";
        effect = "it takes over the movement, formations and skills of ALiVE's groups";
        handling = "VCOM is switched off for ALiVE's groups and soldiers";
        groupVars[] = {"Vcm_Disable"};
        // VCOM reads its calls for help off each soldier, not the group, so the soldiers carry it too
        unitVars[] = {"Vcm_Disable"};
        unitVarsWithBehaviour[] = {};
    };
    class ASR_AI3 {
        name = "ASR AI3";
        patches[] = {"asr_ai3_main"};
        missionVar = "";
        effect = "it sets the skills and reactions of ALiVE's soldiers, over the AI Skill module's settings";
        handling = "ALiVE's soldiers are left out of ASR AI3";
        groupVars[] = {};
        unitVars[] = {"asr_ai_exclude"};
        unitVarsWithBehaviour[] = {};
    };
    class A3_Command {
        name = "A3 Command";
        patches[] = {"A3C_CORE"};
        missionVar = "";
        effect = "it treats the AI groups of any side no player is fighting (every group, with no players in) as a player's own: they stop attacking on their own and never flee, their other AI mods are turned off, and on a dedicated server they are taken back off a headless client";
        handling = "ALiVE's groups are left out of A3 Command, which also keeps them off its command map; a group a player leads stays A3 Command's";
        groupVars[] = {"A3C_HC_BLACKLIST"};
        unitVars[] = {};
        unitVarsWithBehaviour[] = {};
    };
    class BHL_AI {
        name = "BHL AI";
        patches[] = {"BHL_AI"};
        missionVar = "";
        effect = "it changes how every AI helicopter lands, ALiVE's transport and resupply helicopters included";
        handling = "";
        groupVars[] = {};
        unitVars[] = {};
        unitVarsWithBehaviour[] = {};
    };
};
