class CfgGroups
{
    class Empty
    {
        side = 8;
        name = "Compositions";
        class Military_Bocage
        {
            name = "$STR_ALIVE_COMP_SPE_MilitaryBocage";
            #include "military\bocage.hpp"
        };
        class Guerrilla_Bocage
        {
            name = "$STR_ALIVE_COMP_SPE_GuerrillaBocage";
            #include "guerrilla\bocage.hpp"
        };
        
    };

};


