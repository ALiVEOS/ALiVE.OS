///////////////////////////////////////////////////////////////////////////
//          THIS MODULE IS NO LONGER USED
//          PLEASE TURN YOUR ATTENTION TO THE PLAYER OPTIONS MODULE
///////////////////////////////////////////////////////////////////////////

class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase { class Edit; class Combo; class ModuleDescription; };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase { class ALiVE_ModuleSubTitle; };
        class ModuleDescription;
    };
    class ADDON : ModuleAliveBase {
        scope = 1;
        displayName = "$STR_ALIVE_PLAYERTAGS";
        function = "ALIVE_fnc_emptyInit";
        functionPriority = 204;
        isGlobal = 1;
        isPersistent = 1;
        icon = "x\alive\addons\sys_playertags\icon_sys_playertags.paa";
        picture = "x\alive\addons\sys_playertags\icon_sys_playertags.paa";
        class Attributes : AttributesBase
        {
            class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sys_playertags_HDR_GENERAL"; displayName = "GENERAL"; };
            class playertags_debug_setting : Combo { property = "ALiVE_sys_playertags_playertags_debug_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_DEBUG"; tooltip = "$STR_ALIVE_PLAYERTAGS_DEBUG_COMMENT"; defaultValue = """false"""; class Values { class No{name="No";value=false;default=1;}; class Yes{name="Yes";value=true;}; }; };
            class playertags_style_setting : Combo
            {
                    property = "ALiVE_sys_playertags_playertags_style_setting";
                    displayName = "$STR_ALIVE_PLAYERTAGS_STYLE";
                    tooltip = "$STR_ALIVE_PLAYERTAGS_STYLE_COMMENT";
                    defaultValue = """modern""";
                    class Values
                    {
                        class modern { name = "Modern"; value = "modern"; default = 1; };
                        class current { name = "Default"; value = "default"; };
                    };
            };
            class playertags_onview_setting : Combo { property = "ALiVE_sys_playertags_playertags_onview_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_ONVIEW"; tooltip = "$STR_ALIVE_PLAYERTAGS_ONVIEW_COMMENT"; defaultValue = """false"""; class Values { class No{name="No";value=false;default=1;}; class Yes{name="Yes";value=true;}; }; };
            class playertags_displayrank_setting : Combo { property = "ALiVE_sys_playertags_playertags_displayrank_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_RANK"; tooltip = "$STR_ALIVE_PLAYERTAGS_RANK_COMMENT"; defaultValue = """true"""; class Values { class No{name="No";value=false;}; class Yes{name="Yes";value=true;default=1;}; }; };
            class playertags_displaygroup_setting : Combo { property = "ALiVE_sys_playertags_playertags_displaygroup_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_GROUP"; tooltip = "$STR_ALIVE_PLAYERTAGS_GROUP_COMMENT"; defaultValue = """true"""; class Values { class No{name="No";value=false;}; class Yes{name="Yes";value=true;default=1;}; }; };
            class playertags_invehicle_setting : Combo { property = "ALiVE_sys_playertags_playertags_invehicle_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_INVEHICLE"; tooltip = "$STR_ALIVE_PLAYERTAGS_INVEHICLE_COMMENT"; defaultValue = """false"""; class Values { class No{name="No";value=false;default=1;}; class Yes{name="Yes";value=true;}; }; };
            class playertags_restricttofriendly_setting : Combo { property = "ALiVE_sys_playertags_playertags_restricttofriendly_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_FRIENDLYUNITSONLY"; tooltip = "$STR_ALIVE_PLAYERTAGS_FRIENDLYUNITSONLY_COMMENT"; defaultValue = """true"""; class Values { class Yes{name="Yes";value=true;default=1;}; class No{name="No";value=false;}; }; };
            class playertags_targets_setting : Edit { property = "ALiVE_sys_playertags_playertags_targets_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_TARGETS"; tooltip = "$STR_ALIVE_PLAYERTAGS_TARGETS_COMMENT"; defaultValue = """['CAManBase', 'Car', 'Tank', 'StaticWeapon', 'Helicopter', 'Plane']"""; typeName = "ARRAY"; };
            class HDR_SIZE : ALiVE_ModuleSubTitle { property = "ALiVE_sys_playertags_HDR_SIZE"; displayName = "DISTANCE AND SIZE"; };
            class playertags_distance_setting : Edit { property = "ALiVE_sys_playertags_playertags_distance_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_DISTANCE"; tooltip = "$STR_ALIVE_PLAYERTAGS_DISTANCE_COMMENT"; defaultValue = """20"""; typeName = "NUMBER"; };
            class playertags_tolerance_setting : Edit { property = "ALiVE_sys_playertags_playertags_tolerance_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_TOLERANCE"; tooltip = "$STR_ALIVE_PLAYERTAGS_TOLERANCE_COMMENT"; defaultValue = """0.75"""; typeName = "NUMBER"; };
            class playertags_scale_setting : Edit { property = "ALiVE_sys_playertags_playertags_scale_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_SCALE"; tooltip = "$STR_ALIVE_PLAYERTAGS_SCALE_COMMENT"; defaultValue = """0.65"""; typeName = "NUMBER"; };
            class playertags_height_setting : Edit { property = "ALiVE_sys_playertags_playertags_height_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_HEIGHT"; tooltip = "$STR_ALIVE_PLAYERTAGS_HEIGHT_COMMENT"; defaultValue = """1.1"""; typeName = "NUMBER"; };
            class HDR_COLOURS : ALiVE_ModuleSubTitle { property = "ALiVE_sys_playertags_HDR_COLOURS"; displayName = "COLOURS"; };
            class playertags_namecolour_setting : Edit { property = "ALiVE_sys_playertags_playertags_namecolour_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_NAMECOLOUR"; tooltip = "$STR_ALIVE_PLAYERTAGS_NAMECOLOUR_COMMENT"; defaultValue = """#FFFFFF"""; typeName = "STRING"; };
            class playertags_groupcolour_setting : Edit { property = "ALiVE_sys_playertags_playertags_groupcolour_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_GROUPCOLOUR"; tooltip = "$STR_ALIVE_PLAYERTAGS_GROUPCOLOUR_COMMENT"; defaultValue = """#A8F000"""; typeName = "STRING"; };
            class playertags_thisgroupleadernamecolour_setting : Edit { property = "ALiVE_sys_playertags_playertags_thisgroupleadernamecolour_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_THISGROUPLEADERNAMECOLOUR"; tooltip = "$STR_ALIVE_PLAYERTAGS_THISGROUPLEADERNAMECOLOUR_COMMENT"; defaultValue = """#FFB300"""; typeName = "STRING"; };
            class playertags_thisgroupcolour_setting : Edit { property = "ALiVE_sys_playertags_playertags_thisgroupcolour_setting"; displayName = "$STR_ALIVE_PLAYERTAGS_THISGROUPCOLOUR"; tooltip = "$STR_ALIVE_PLAYERTAGS_THISGROUPCOLOUR_COMMENT"; defaultValue = """#009D91"""; typeName = "STRING"; };
            class ModuleDescription : ModuleDescription {};
        };
    };
};
