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
            class HDR_GENERAL : ALiVE_ModuleSubTitle { property = "ALiVE_sys_xstream_HDR_GENERAL"; displayName = "GENERAL"; };
            class debug : Combo { property = "ALiVE_sys_xstream_debug"; displayName = "$STR_ALIVE_XSTREAM_DEBUG"; tooltip = "$STR_ALIVE_XSTREAM_COMMENT"; defaultValue = """0"""; class Values { class Yes{name="Yes";value=1;}; class No {name="No";value=0;default=1;}; }; };
            class enabletwitch { property = "ALiVE_sys_xstream_enabletwitch"; control = "ALiVE_HiddenAttribute"; defaultValue = """1"""; expression = "_this setVariable ['enabletwitch', _value, true];"; displayName = ""; };
            class enableLiveMap { property = "ALiVE_sys_xstream_enableLiveMap"; control = "ALiVE_HiddenAttribute"; defaultValue = """1"""; expression = "_this setVariable ['enableLiveMap', _value, true];"; displayName = ""; };
            class HDR_CAMERA : ALiVE_ModuleSubTitle { property = "ALiVE_sys_xstream_HDR_CAMERA"; displayName = "CAMERA"; };
            class enableCamera : Combo { property = "ALiVE_sys_xstream_enableCamera"; displayName = "$STR_ALIVE_XSTREAM_enableCamera"; tooltip = "$STR_ALIVE_XSTREAM_enableCamera_COMMENT"; defaultValue = """1"""; class Values { class Yes{name="Yes";value=1;default=1;}; class No{name="No";value=0;}; }; };
            class acreChannel { property = "ALiVE_sys_xstream_acreChannel"; control = "ALiVE_HiddenAttribute"; defaultValue = """"""; expression = "_this setVariable ['acreChannel', _value, true];"; displayName = ""; };
            class cameraShake { property = "ALiVE_sys_xstream_cameraShake"; control = "ALiVE_HiddenAttribute"; defaultValue = """1"""; expression = "_this setVariable ['cameraShake', _value, true];"; displayName = ""; };
            class satellite { property = "ALiVE_sys_xstream_satellite"; control = "ALiVE_HiddenAttribute"; defaultValue = """1"""; expression = "_this setVariable ['satellite', _value, true];"; displayName = ""; };
            class aerial { property = "ALiVE_sys_xstream_aerial"; control = "ALiVE_HiddenAttribute"; defaultValue = """1"""; expression = "_this setVariable ['aerial', _value, true];"; displayName = ""; };
            class vehicle { property = "ALiVE_sys_xstream_vehicle"; control = "ALiVE_HiddenAttribute"; defaultValue = """1"""; expression = "_this setVariable ['vehicle', _value, true];"; displayName = ""; };
            class thirdPerson { property = "ALiVE_sys_xstream_thirdPerson"; control = "ALiVE_HiddenAttribute"; defaultValue = """1"""; expression = "_this setVariable ['thirdPerson', _value, true];"; displayName = ""; };
            class cameraManOnly { property = "ALiVE_sys_xstream_cameraManOnly"; control = "ALiVE_HiddenAttribute"; defaultValue = """1"""; expression = "_this setVariable ['cameraManOnly', _value, true];"; displayName = ""; };
            class HDR_ACCESS : ALiVE_ModuleSubTitle { property = "ALiVE_sys_xstream_HDR_ACCESS"; displayName = "ACCESS"; };
            class clientID : Edit { property = "ALiVE_sys_xstream_clientID"; displayName = "$STR_ALIVE_XSTREAM_CLIENTID"; tooltip = "$STR_ALIVE_XSTREAM_CLIENTID_COMMENT"; defaultValue = """"""; ALiVE_showWhen[] = {{"enableCamera", "is", 1}}; ALiVE_showStyle = "dim"; };
            class ModuleDescription : ModuleDescription {};
        };
    };
};
