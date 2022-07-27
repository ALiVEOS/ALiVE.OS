
class CfgPatches
{
    class ALiVE_Missions
    {
        units[] = {""};
        weapons[] = {};
        requiredVersion = 0.1;
        requiredAddons[] = {"Alive_main"};
    };
};

class CfgMissions
{
    class Showcases
    {
        class Showcase_Tour
        {
            briefingName = "ALiVE | Tour (Stratis)";
            directory = "x\alive\addons\missions\showcases\tour.stratis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "ALiVE Tour will take you through the different modules, technology and gameplay offered by ALiVE.";
            author = "ALiVE Mod Team";   
        };
        class Showcase_Getting_Started
        {
            briefingName = "ALiVE | Quick Start (Stratis)";
            directory = "x\alive\addons\missions\showcases\basic.stratis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "This is the basic quick start mission featured in the ALiVE documentation and Wiki (alivemod.com)";
            author = "ALiVE Mod Team";                    
        };
        class Showcase_HurtLocker
        {
            briefingName = "ALiVE | Hurt Locker (Stratis)";
            directory = "x\alive\addons\missions\showcases\hurtlocker.stratis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "Stratis is reeling from a brutal insurgency campaign. IED's litter the landscape, its your job to identify and disarm IEDs to ensure the safety of the civilian population. Beware of the local militia!";
            author = "ALiVE Mod Team";   
        };
        class Showcase_Khe_Sanh_Valley
        {
            briefingName = "ALiVE | Khe Sanh Valley (Khe Sanh)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Khe_Sanh_Valley.vn_khe_sanh";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_Khe_Sanh_Valley.vn_khe_sanh\pics\splash.paa";
            overviewText = "PAVN and VC Forces continue to hold key areas with in the Khe Sanh valley.";
            author = "ALiVE Mod Team";
        };
        class Showcase_Van_Tien
        {
            briefingName = "ALiVE | Op Van Tien (Cam Lao Nam)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_PF.Cam_Lao_Nam";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_PF.Cam_Lao_Nam\pics\splash.paa";
            overviewText = "PAVN launch a general offensive against military and civilian objectives throughout South Vietnam, supported by VC conducting cross-border insurgency operations.";
            author = "ALiVE Mod Team";
        };
        class Showcase_Hue_Defence
        {
            briefingName = "ALiVE | The Battle of Hue (Cam Lao Nam)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Hue_Defence.Cam_Lao_Nam";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_Hue_Defence.Cam_Lao_Nam\img\splash.paa";
            overviewText = "Travel by convoy to Hue, consolidate positions defend Hue and the Imperial City Citadel from enemy attack.";
            author = "ALiVE Mod Team";
        };
        class Showcase_Paper_Hands
        {
            briefingName = "ALiVE | Paper Hands (Cam Lao Nam)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Paper_Hands.Cam_Lao_Nam";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_Paper_Hands.Cam_Lao_Nam\pics\execution.paa";
            overviewText = "MACV-SOG are running deniable operations using Spike Teams (ST) - across the fence - in Cambodia, Laos and South Vietnam.";
            author = "ALiVE Mod Team";
        };
        class Showcase_Diamond_Hands
        {
            briefingName = "ALiVE | Diamond Hands (Cam Lao Nam)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Diamond_Hands.Cam_Lao_Nam";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_Diamond_Hands.Cam_Lao_Nam\pics\scenario.paa";
            overviewText = "Viet Cong and NVA are using three underground bunkers as command and control facilities in the Tri-Border area. Locate, clear the bunkers and collect intellgence.";
            author = "ALiVE Mod Team";
        };
        class Showcase_Erawan_Secret_War
        {
            briefingName = "ALiVE | Erawan Secret War (The Bra)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Erawan_Secret_War.vn_the_bra";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_Erawan_Secret_War.vn_the_bra\img\splash.paa";
            overviewText = "A CIA embedded pilot and crew chief have been lost in Laos. Intel suggests they have been captured and they are being held by Pathet Lao forces within the Laos jungle.";
            author = "ALiVE Mod Team";
        }; 
        class Showcase_Getting_Started_APEX
        {
            briefingName = "ALiVE | Quick Start APEX (Tanoa)";
            directory = "x\alive\addons\missions\showcases\basic2.tanoa";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "This is the basic quick start mission (on Tanoa) featured in the ALiVE documentation and Wiki (alivemod.com)";
            author = "ALiVE Mod Team";                    
        };        
        class Showcase_Divide_And_Rule
        {
            briefingName = "ALiVE | Divide and Rule (Altis)";
            directory = "x\alive\addons\missions\showcases\alive_divide_and_rule.altis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "INTEL has been received about a nuclear device being built by a scientist named Ahelef Mahmoud in an hideout in Zaros! Locate Mahmoud, disable the bomb, and return home safely!";
            author = "ALiVE Mod Team";                       
        };        
        class Showcase_Air_Superiority
        {
            briefingName = "ALiVE | Air Superiority (Altis)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_air_superiority.Altis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "Obtain Air Superiority over Altis and eliminate the given targets! AA positions have been confirmed all over the coastline - plan your mission waypoints carefully!";
            author = "ALiVE Mod Team";
        };                      
    };
    class MPMissions
    {
        class MP_COOP_Divide_And_Rule
        {
            briefingName = "ALiVE | Divide and Rule (COOP 7)";
            directory = "x\alive\addons\missions\showcases\alive_divide_and_rule.altis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "INTEL has been received about a nuclear device being built by a scientist named Ahelef Mahmoud in an hideout in Zaros! Locate Mahmoud, disable the bomb, and return home safely!";
            author = "ALiVE Mod Team";                       
        };                
        class MP_COOP_Getting_Started
        {
            briefingName = "ALiVE | Quick Start (COOP 9)";
            directory = "x\alive\addons\missions\showcases\basic.stratis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "This is the basic quick start mission featured in the ALiVE documentation and Wiki (alivemod.com)";
            author = "ALiVE Mod Team";                    
        };
        class MP_COOP_Getting_Started_APEX
        {
            briefingName = "ALiVE | Quick Start APEX (COOP 10)";
            directory = "x\alive\addons\missions\showcases\basic2.tanoa";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "This is the basic quick start mission (on Tanoa) featured in the ALiVE documentation and Wiki (alivemod.com)";
            author = "ALiVE Mod Team";                    
        };
        class MP_COOP_Air_Superiority
        {
            briefingName = "ALiVE | Air Superiority (COOP 12)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_air_superiority.Altis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "Obtain Air Superiority over Altis and eliminate the given targets! AA positions have been confirmed all over the coastline - plan your mission waypoints carefully!";
            author = "ALiVE Mod Team";
        };                 
        class MP_COOP_Air_Assault
        {
            briefingName = "ALiVE | Air Assault (COOP 8)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Air_Assault.Altis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "Steal the prototype MI-48 from the airbase at Salakano and bring it to your Command base in the north! Try to survive!";
            author = "ALiVE Mod Team";
        };
        class MP_COOP_HurtLocker
        {
            briefingName = "ALiVE | Hurt Locker (COOP 10)";
            directory = "x\alive\addons\missions\showcases\hurtlocker.stratis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "Stratis is reeling from a brutal insurgency campaign. IED's litter the landscape, its your job to identify and disarm IEDs to ensure the safety of the civilian population. Beware of the local militia!";
            author = "ALiVE Mod Team";   
        };            
        class MP_COOP_Sabotage
        {
            briefingName = "ALiVE | Sabotage (COOP 12)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Sabotage.Altis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "Lead an insurgency on Altis, use sabotage and subterfuge to capture weapons and establish safe houses across the island.";
            author = "ALiVE Mod Team";   
        };
        class MP_COOP_Khe_Sanh_Valley
        {
            briefingName = "ALiVE | Khe Sanh Valley (COOP 12)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Khe_Sanh_Valley.vn_khe_sanh";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_Khe_Sanh_Valley.vn_khe_sanh\pics\splash.paa";
            overviewText = "PAVN and VC Forces continue to hold key areas with in the Khe Sanh valley.";
            author = "ALiVE Mod Team";
        };   
        class MP_COOP_Van_Tien
        {
            briefingName = "ALiVE | Op Van Tien (COOP 12)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_PF.Cam_Lao_Nam";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_PF.Cam_Lao_Nam\pics\splash.paa";
            overviewText = "PAVN launch a general offensive against military and civilian objectives throughout South Vietnam, supported by VC conducting cross-border insurgency operations.";
            author = "ALiVE Mod Team";
        };
        class MP_COOP_Hue_Defence
        {
            briefingName = "ALiVE | The Battle of Hue (COOP 20)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Hue_Defence.Cam_Lao_Nam";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_Hue_Defence.Cam_Lao_Nam\img\splash.paa";
            overviewText = "Travel by convoy to Hue, consolidate positions defend Hue and the Imperial City Citadel from enemy attack.";
            author = "ALiVE Mod Team";
        };
        class MP_COOP_Paper_Hands
        {
            briefingName = "ALiVE | Paper Hands (COOP 12)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Paper_Hands.Cam_Lao_Nam";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_Paper_Hands.Cam_Lao_Nam\pics\execution.paa";
            overviewText = "MACV-SOG are running deniable operations using Spike Teams (ST) - across the fence - in Cambodia, Laos and South Vietnam.";
            author = "ALiVE Mod Team";
        };
        class MP_COOP_Diamond_Hands
        {
            briefingName = "ALiVE | Diamond Hands (COOP 8)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Diamond_Hands.Cam_Lao_Nam";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_Diamond_Hands.Cam_Lao_Nam\pics\scenario.paa";
            overviewText = "Viet Cong and NVA are using three underground bunkers as command and control facilities in the Tri-Border area. Locate, clear the bunkers and collect intellgence.";
            author = "ALiVE Mod Team";
        };
        class MP_COOP_Erawan_Secret_War
        {
            briefingName = "ALiVE | Erawan Secret War (COOP 12)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Erawan_Secret_War.vn_the_bra";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_Erawan_Secret_War.vn_the_bra\img\splash.paa";
            overviewText = "A CIA embedded pilot and crew chief have been lost in Laos. Intel suggests they have been captured and they are being held by Pathet Lao forces within the Laos jungle.";
            author = "ALiVE Mod Team";
        };
    };
};

