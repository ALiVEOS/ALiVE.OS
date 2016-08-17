class CfgGroups
{
	class Empty
	{
		side = 8;
		name = "Compositions";
		class Civilian
		{
            #include "civilian\urban.hpp"
        };
	    class Civilian_Desert
	    {
	    	name = "Civilian (Desert)";
	    	#include <civilian\desert.hpp>
	    };
	    class Civilian_Woodland
	    {
	    	name = "Civilian (Woodland)";
	    	#include "civilian\woodland.hpp"
	    };
		class Guerrilla
		{
            #include "guerrilla\urban.hpp"
        };
	    class Guerrilla_Desert
	    {
	    	name = "Guerrilla (Desert)";
	    	#include "guerrilla\desert.hpp"
	    };
	    class Guerrilla_Woodland
	    {
	    	name = "Guerrilla (Woodland)";
	    	#include "guerrilla\woodland.hpp"
	    };
		class Military
		{
            #include "military\urban.hpp"
        };
	    class Military_Desert
	    {
	    	name = "Military (Desert)";
	    	#include "military\desert.hpp"
	    };
	    class Military_Woodland
	    {
	    	name = "Military (Woodland)";
	    	#include "military\woodland.hpp"
	    };
	};
};

