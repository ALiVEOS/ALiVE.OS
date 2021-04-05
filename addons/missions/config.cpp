
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
            briefingName = "ALiVE | Tour";
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
        class Showcase_HurtLocker
        {
            briefingName = "ALiVE | Hurt Locker (Stratis)";
            directory = "x\alive\addons\missions\showcases\hurtlocker.stratis";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "Stratis is reeling from a brutal insurgency campaign. IED's litter the landscape, its your job to identify and disarm IEDs to ensure the safety of the civilian population. Beware of the local militia!";
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
        class Showcase_Vietnam
        {
            briefingName = "ALiVE | Op Van Tien (Vietnam)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_PF.Cam_Lao_Nam";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "PAVN launch a general offensive against military and civilian objectives throughout South Vietnam, supported by VC conducting cross-border insurgency operations.";
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
            briefingName = "ALiVE | Air Superiority (CO 12)";
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
        class MP_COOP_Vietnam
        {
            briefingName = "ALiVE | Op Van Tien (COOP 12)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_PF.Cam_Lao_Nam";
            overviewPicture = "x\alive\addons\missions\logo_alive.paa";
            overviewText = "PAVN launch a general offensive against military and civilian objectives throughout South Vietnam, supported by VC conducting cross-border insurgency operations.";
            author = "ALiVE Mod Team";
        };
        class MP_COOP_Hue_Defence
        {
            briefingName = "ALiVE | Hue Defence (COOP 20)";
            directory = "x\alive\addons\missions\mpscenarios\ALiVE_Hue_Defence.Cam_Lao_Nam";
            overviewPicture = "x\alive\addons\missions\mpscenarios\ALiVE_Hue_Defence.Cam_Lao_Name\img\splash.paa";
            overviewText = "Travel by convoy to Hue, consolidate positions defend Hue and the Imperial City Citadel from enemy attack.";
            author = "ALiVE Mod Team";
        };
    };
};

