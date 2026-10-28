// Generated from WebKnight's Zombies and Creatures unit list. Groups for its one faction, WBK_AI_ZHAMBIES,
// which ships none, so ALiVE placement and the AI Commander can field it. A Sprinter (Angry) leads each
// group. OPFOR only, the faction's own side: ALiVE gathers a faction's groups from every side, so a West or
// Indep copy put BLUFOR or Independent zombies into an OPFOR faction.
class CfgGroups
{
    class East
    {
        class WBK_AI_ZHAMBIES
        {
            name = "WBK Zombies";
            class Infantry
            {
                name = "Infantry";
                class ALiVE_WBK_Horde_Civ
                {
                    name = "Civilian horde";
                    side = 0;
                    faction = "WBK_AI_ZHAMBIES";
                    icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
                    rarityGroup = 0.5;
                    class Unit0
                    {
                        position[] = {0,0,0};
                        rank = "SERGEANT";
                        side = 0;
                        vehicle = "Zombie_O_RA_Civ";
                    };
                    class Unit1
                    {
                        position[] = {5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_RC_Civ";
                    };
                    class Unit2
                    {
                        position[] = {-5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_Civ";
                    };
                    class Unit3
                    {
                        position[] = {10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_Civ";
                    };
                    class Unit4
                    {
                        position[] = {-10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_Civ";
                    };
                    class Unit5
                    {
                        position[] = {15,-15,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shambler_Civ";
                    };
                    class Unit6
                    {
                        position[] = {-15,-15,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shambler_Civ";
                    };
                    class Unit7
                    {
                        position[] = {20,-20,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Crawler_Civ";
                    };
                };
                class ALiVE_WBK_Pack_Civ
                {
                    name = "Civilian pack";
                    side = 0;
                    faction = "WBK_AI_ZHAMBIES";
                    icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
                    rarityGroup = 0.5;
                    class Unit0
                    {
                        position[] = {0,0,0};
                        rank = "SERGEANT";
                        side = 0;
                        vehicle = "Zombie_O_RA_Civ";
                    };
                    class Unit1
                    {
                        position[] = {5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_Civ";
                    };
                    class Unit2
                    {
                        position[] = {-5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_Civ";
                    };
                    class Unit3
                    {
                        position[] = {10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shambler_Civ";
                    };
                };
                class ALiVE_WBK_Runners_Civ
                {
                    name = "Civilian runners";
                    side = 0;
                    faction = "WBK_AI_ZHAMBIES";
                    icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
                    rarityGroup = 0.5;
                    class Unit0
                    {
                        position[] = {0,0,0};
                        rank = "SERGEANT";
                        side = 0;
                        vehicle = "Zombie_O_RA_Civ";
                    };
                    class Unit1
                    {
                        position[] = {5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_RA_Civ";
                    };
                    class Unit2
                    {
                        position[] = {-5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_RC_Civ";
                    };
                    class Unit3
                    {
                        position[] = {10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_RC_Civ";
                    };
                };
                class ALiVE_WBK_Squad_NATO
                {
                    name = "Infected NATO squad";
                    side = 0;
                    faction = "WBK_AI_ZHAMBIES";
                    icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
                    rarityGroup = 0.5;
                    class Unit0
                    {
                        position[] = {0,0,0};
                        rank = "SERGEANT";
                        side = 0;
                        vehicle = "Zombie_O_RA_NATO";
                    };
                    class Unit1
                    {
                        position[] = {5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_RC_NATO";
                    };
                    class Unit2
                    {
                        position[] = {-5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_NATO";
                    };
                    class Unit3
                    {
                        position[] = {10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_NATO";
                    };
                    class Unit4
                    {
                        position[] = {-10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shambler_NATO";
                    };
                    class Unit5
                    {
                        position[] = {15,-15,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shooter_NATO";
                    };
                };
                class ALiVE_WBK_Squad_CSAT
                {
                    name = "Infected CSAT squad";
                    side = 0;
                    faction = "WBK_AI_ZHAMBIES";
                    icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
                    rarityGroup = 0.5;
                    class Unit0
                    {
                        position[] = {0,0,0};
                        rank = "SERGEANT";
                        side = 0;
                        vehicle = "Zombie_O_RunnerAngry_CSAT";
                    };
                    class Unit1
                    {
                        position[] = {5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_RunnerCalm_CSAT";
                    };
                    class Unit2
                    {
                        position[] = {-5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_CSAT";
                    };
                    class Unit3
                    {
                        position[] = {10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_CSAT";
                    };
                    class Unit4
                    {
                        position[] = {-10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shambler_CSAT";
                    };
                    class Unit5
                    {
                        position[] = {15,-15,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shooter_CSAT";
                    };
                };
                class ALiVE_WBK_Squad_AAF
                {
                    name = "Infected AAF squad";
                    side = 0;
                    faction = "WBK_AI_ZHAMBIES";
                    icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
                    rarityGroup = 0.5;
                    class Unit0
                    {
                        position[] = {0,0,0};
                        rank = "SERGEANT";
                        side = 0;
                        vehicle = "Zombie_O_RA_AAF";
                    };
                    class Unit1
                    {
                        position[] = {5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_RC_AAF";
                    };
                    class Unit2
                    {
                        position[] = {-5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_AAF";
                    };
                    class Unit3
                    {
                        position[] = {10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_AAF";
                    };
                    class Unit4
                    {
                        position[] = {-10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shambler_AAF";
                    };
                    class Unit5
                    {
                        position[] = {15,-15,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shooter_AAF";
                    };
                };
                class ALiVE_WBK_Squad_FIA
                {
                    name = "Infected FIA squad";
                    side = 0;
                    faction = "WBK_AI_ZHAMBIES";
                    icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
                    rarityGroup = 0.5;
                    class Unit0
                    {
                        position[] = {0,0,0};
                        rank = "SERGEANT";
                        side = 0;
                        vehicle = "Zombie_O_RA_FIA";
                    };
                    class Unit1
                    {
                        position[] = {5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_RC_FIA";
                    };
                    class Unit2
                    {
                        position[] = {-5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_FIA";
                    };
                    class Unit3
                    {
                        position[] = {10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_FIA";
                    };
                    class Unit4
                    {
                        position[] = {-10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shambler_FIA";
                    };
                    class Unit5
                    {
                        position[] = {15,-15,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shooter_FIA";
                    };
                };
                class ALiVE_WBK_Squad_LDF
                {
                    name = "Infected LDF squad";
                    side = 0;
                    faction = "WBK_AI_ZHAMBIES";
                    icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
                    rarityGroup = 0.5;
                    class Unit0
                    {
                        position[] = {0,0,0};
                        rank = "SERGEANT";
                        side = 0;
                        vehicle = "Zombie_O_RA_LDF";
                    };
                    class Unit1
                    {
                        position[] = {5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_RC_LDF";
                    };
                    class Unit2
                    {
                        position[] = {-5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_LDF";
                    };
                    class Unit3
                    {
                        position[] = {10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Walker_LDF";
                    };
                    class Unit4
                    {
                        position[] = {-10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shambler_LDF";
                    };
                    class Unit5
                    {
                        position[] = {15,-15,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_O_Shooter_LDF";
                    };
                };
            };
            class SpecOps
            {
                name = "Special Infected";
                class ALiVE_WBK_Special
                {
                    name = "Special infected";
                    side = 0;
                    faction = "WBK_AI_ZHAMBIES";
                    icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
                    rarityGroup = 0.5;
                    class Unit0
                    {
                        position[] = {0,0,0};
                        rank = "SERGEANT";
                        side = 0;
                        vehicle = "Zombie_O_RA_Civ";
                    };
                    class Unit1
                    {
                        position[] = {5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_Special_OPFOR_Leaper_1";
                    };
                    class Unit2
                    {
                        position[] = {-5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_Special_OPFOR_Screamer";
                    };
                    class Unit3
                    {
                        position[] = {10,-10,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_Special_OPFOR_Boomer";
                    };
                };
                class ALiVE_WBK_Leapers
                {
                    name = "Leapers";
                    side = 0;
                    faction = "WBK_AI_ZHAMBIES";
                    icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
                    rarityGroup = 0.5;
                    class Unit0
                    {
                        position[] = {0,0,0};
                        rank = "SERGEANT";
                        side = 0;
                        vehicle = "Zombie_O_RA_Civ";
                    };
                    class Unit1
                    {
                        position[] = {5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_Special_OPFOR_Leaper_1";
                    };
                    class Unit2
                    {
                        position[] = {-5,-5,0};
                        rank = "PRIVATE";
                        side = 0;
                        vehicle = "Zombie_Special_OPFOR_Leaper_2";
                    };
                };
            };
        };
    };
};
