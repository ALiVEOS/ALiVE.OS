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
    class ADDON: ModuleAliveBase {
        author = "Tupolov";
        scope = 1;
        displayName = "$STR_ALIVE_XSTREAM";
        icon = "x\alive\addons\sys_xstream\icon_sys_xstream.paa";
        function = "ALIVE_fnc_xStreamInit";
        functionPriority = 240;
        isGlobal = 2;
        isTriggerActivated = 0;
        picture = "x\alive\addons\sys_xstream\icon_sys_xstream.paa";
        class ModuleDescription { description = "$STR_ALIVE_XSTREAM_COMMENT"; };
        class Attributes : AttributesBase
        {
            class debug : Combo { property = "ALiVE_sys_xstream_debug"; displayName = "$STR_ALIVE_XSTREAM_DEBUG"; tooltip = "$STR_ALIVE_XSTREAM_COMMENT"; defaultValue = """0"""; class Values { class Yes{name="Yes";value=1;}; class No {name="No";value=0;default=1;}; }; };
            class enabletwitch : Combo { property = "ALiVE_sys_xstream_enabletwitch"; displayName = "$STR_ALIVE_XSTREAM_enabletwitch"; tooltip = "$STR_ALIVE_XSTREAM_enabletwitch_COMMENT"; defaultValue = """1"""; class Values { class Yes{name="Yes";value=1;default=1;}; class No{name="No";value=0;}; }; };
            class enableLiveMap : Combo { property = "ALiVE_sys_xstream_enableLiveMap"; displayName = "$STR_ALIVE_XSTREAM_enableLiveMap"; tooltip = "$STR_ALIVE_XSTREAM_enableLiveMap_COMMENT"; defaultValue = """1"""; class Values { class Yes{name="Yes";value=1;default=1;}; class No{name="No";value=0;}; }; };
            class enableCamera : Combo { property = "ALiVE_sys_xstream_enableCamera"; displayName = "$STR_ALIVE_XSTREAM_enableCamera"; tooltip = "$STR_ALIVE_XSTREAM_enableCamera_COMMENT"; defaultValue = """1"""; class Values { class Yes{name="Yes";value=1;default=1;}; class No{name="No";value=0;}; }; };
            class acreChannel : Edit { property = "ALiVE_sys_xstream_acreChannel"; displayName = "$STR_ALIVE_XSTREAM_acreChannel"; tooltip = "$STR_ALIVE_XSTREAM_acreChannel_COMMENT"; defaultValue = """"""; };
            class cameraShake : Combo { property = "ALiVE_sys_xstream_cameraShake"; displayName = "$STR_ALIVE_XSTREAM_CAMERASHAKE"; tooltip = "$STR_ALIVE_XSTREAM_CAMERASHAKE_COMMENT"; defaultValue = """1"""; class Values { class Yes{name="Yes";value=1;default=1;}; class No{name="No";value=0;}; }; };
            class satellite : Combo { property = "ALiVE_sys_xstream_satellite"; displayName = "$STR_ALIVE_XSTREAM_satellite"; tooltip = "$STR_ALIVE_XSTREAM_satellite_COMMENT"; defaultValue = """1"""; class Values { class Yes{name="Yes";value=1;default=1;}; class No{name="No";value=0;}; }; };
            class aerial : Combo { property = "ALiVE_sys_xstream_aerial"; displayName = "$STR_ALIVE_XSTREAM_aerial"; tooltip = "$STR_ALIVE_XSTREAM_aerial_COMMENT"; defaultValue = """1"""; class Values { class Yes{name="Yes";value=1;default=1;}; class No{name="No";value=0;}; }; };
            class vehicle : Combo { property = "ALiVE_sys_xstream_vehicle"; displayName = "$STR_ALIVE_XSTREAM_vehicle"; tooltip = "$STR_ALIVE_XSTREAM_vehicle_COMMENT"; defaultValue = """1"""; class Values { class Yes{name="Yes";value=1;default=1;}; class No{name="No";value=0;}; }; };
            class thirdPerson : Combo { property = "ALiVE_sys_xstream_thirdPerson"; displayName = "$STR_ALIVE_XSTREAM_thirdPerson"; tooltip = "$STR_ALIVE_XSTREAM_thirdPerson_COMMENT"; defaultValue = """1"""; class Values { class Yes{name="Yes";value=1;default=1;}; class No{name="No";value=0;}; }; };
            class cameraManOnly : Combo { property = "ALiVE_sys_xstream_cameraManOnly"; displayName = "$STR_ALIVE_XSTREAM_cameraManOnly"; tooltip = "$STR_ALIVE_XSTREAM_cameraManOnly_COMMENT"; defaultValue = """1"""; class Values { class Yes{name="Yes";value=1;default=1;}; class No{name="No";value=0;}; }; };
            class clientID : Edit { property = "ALiVE_sys_xstream_clientID"; displayName = "$STR_ALIVE_XSTREAM_CLIENTID"; tooltip = "$STR_ALIVE_XSTREAM_CLIENTID_COMMENT"; defaultValue = """"""; };
            class ModuleDescription : ModuleDescription {};
        };
    };
};
