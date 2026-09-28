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
    class ADDON : ModuleAliveBase
    {
        scope = 2;
        displayName = "$STR_ALIVE_WEATHER";
        function = "ALIVE_fnc_weatherInit";
        functionPriority = 220;
        author = MODULE_AUTHOR;
        isGlobal = 1;
        isPersistent = 1;
        icon = "\x\alive\addons\sys_weather\icon_sys_weather.paa";
        picture = "\x\alive\addons\sys_weather\icon_sys_weather.paa";
        class Attributes : AttributesBase
        {
            class weather_debug_setting : Combo
            {
                    property = "ALiVE_sys_weather_weather_debug_setting";
                    displayName = "$STR_ALIVE_WEATHER_DEBUG";
                    tooltip = "$STR_ALIVE_WEATHER_DEBUG_COMMENT";
                    defaultValue = """false""";
                    class Values
                    {
                        class No { name = "No"; value = false; default = 1; };
                        class Yes { name = "Yes"; value = true; };
                    };
            };
            class weather_debug_cycle_setting : Edit { property = "ALiVE_sys_weather_weather_debug_cycle_setting"; displayName = "$STR_ALIVE_WEATHER_DEBUG_CYCLE"; tooltip = "$STR_ALIVE_WEATHER_DEBUG_CYCLE_COMMENT"; defaultValue = """60"""; typeName = "NUMBER"; };
            class weather_initial_setting : Combo
            {
                    property = "ALiVE_sys_weather_weather_initial_setting";
                    displayName = "$STR_ALIVE_WEATHER_INITIAL";
                    tooltip = "$STR_ALIVE_WEATHER_INITIAL_COMMENT";
                    defaultValue = """6""";
                    class Values
                    {
                        // The editor default: no rain, fog or lightning, cloud up to half cover. It had no
                        // name, so an untouched module read as unset though it gave this weather.
                        class initialBlank { name = "Fair"; default = 6; value = 6; };
                        class initialArid { name = "Arid"; value = 0; };
                        class initialContinental { name = "Continental"; value = 1; };
                        class initialTropical { name = "Tropical"; value = 2; };
                        class initialMediterranean { name = "Mediterranean"; value = 3; };
                        class initialRandom { name = "Random"; value = 4; };
                        class initialRealWeather { name = "Real"; value = 5; };
                    };
            };
            class weather_override_setting : Combo
            {
                    property = "ALiVE_sys_weather_weather_override_setting";
                    displayName = "$STR_ALIVE_WEATHER_OVERRIDE";
                    tooltip = "$STR_ALIVE_WEATHER_OVERRIDE_COMMENT";
                    defaultValue = """0""";
                    class Values
                    {
                        class overrideBlank { name = ""; default = 0; value = 0; };
                        class overrideClear { name = "Clear"; value = 1; };
                        class overrideOvercast { name = "Overcast"; value = 2; };
                        class overrideStormy { name = "Stormy"; value = 3; };
                        class overrideFoggy { name = "Foggy"; value = 4; };
                        class overrideReal { name = "Real Weather: Use weather from real time not game time"; value = 5; };
                    };
            };
            class weather_cycle_delay_setting : Edit { property = "ALiVE_sys_weather_weather_cycle_delay_setting"; displayName = "$STR_ALIVE_WEATHER_CYCLE_DELAY"; tooltip = "$STR_ALIVE_WEATHER_CYCLE_DELAY_COMMENT"; defaultValue = """1800"""; typeName = "NUMBER"; };
            class weather_cycle_variance_setting : Edit { property = "ALiVE_sys_weather_weather_cycle_variance_setting"; displayName = "$STR_ALIVE_WEATHER_CYCLE_VARIANCE"; tooltip = "$STR_ALIVE_WEATHER_CYCLE_VARIANCE_COMMENT"; defaultValue = """0.2"""; typeName = "NUMBER"; };
            class weather_real_location_setting : Edit { property = "ALiVE_sys_weather_weather_real_location_setting"; displayName = "$STR_ALIVE_WEATHER_REAL_LOCATION"; tooltip = "$STR_ALIVE_WEATHER_REAL_LOCATION_COMMENT"; defaultValue = """COUNTRY/CITY"""; typeName = "STRING"; };
            class ModuleDescription : ModuleDescription {};
        };
    };
};
