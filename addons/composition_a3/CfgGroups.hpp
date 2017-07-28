class CfgGroups
{
    class Empty
    {
        side = 8;
        name = "Compositions";
        class Civilian
        {
            name = "$STR_ZEC_Civilian";
            #include "civilian\urban.hpp"
        };
        class Civilian_Desert
        {
            name = "$STR_ZEC_CivilianDesert";
            #include <civilian\desert.hpp>
        };
        class Civilian_Pacific
        {
            name = "$STR_ZEC_CivilianPacific";
            #include "civilian\pacific.hpp"
        };
        class Civilian_Woodland
        {
            name = "$STR_ZEC_CivilianWoodland";
            #include "civilian\woodland.hpp"
        };
        class Guerrilla
        {
            name = "$STR_ZEC_Guerrilla";
            #include "guerrilla\urban.hpp"
        };
        class Guerrilla_Desert
        {
            name = "$STR_ZEC_GuerrillaDesert";
            #include "guerrilla\desert.hpp"
        };
        class Guerrilla_Pacific
        {
            name = "$STR_ZEC_GuerrillaPacific";
            #include "guerrilla\pacific.hpp"
        };
        class Guerrilla_Woodland
        {
            name = "$STR_ZEC_GuerrillaWoodland";
            #include "guerrilla\woodland.hpp"
        };
        class Military
        {
            name = "$STR_ZEC_Military";
            #include "military\urban.hpp"
        };
        class Military_Desert
        {
            name = "$STR_ZEC_MilitaryDesert";
            #include "military\desert.hpp"
        };
        class Military_Pacific
        {
            name = "$STR_ZEC_MilitaryPacific";
            #include "military\pacific.hpp"
        };
        class Military_Woodland
        {
            name = "$STR_ZEC_MilitaryWoodland";
            #include "military\woodland.hpp"
        };
    };
};

