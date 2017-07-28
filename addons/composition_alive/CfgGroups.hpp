class CfgGroups
{
	class Empty
	{
	    class Guerrilla
	    {
	    	#include "guerrilla\urban.hpp"
	    };
	    class Guerrilla_Desert
	    {
	    	#include "guerrilla\desert.hpp"
	    };
	    class Guerrilla_Pacific
	    {
	    	#include "guerrilla\pacific.hpp"
	    };
	    class Guerrilla_Woodland
	    {
	    	#include "guerrilla\woodland.hpp"
	    };

		class Military
		{
            #include "military\urban.hpp"
        };
	    class Military_Desert
	    {
	    	#include "military\desert.hpp"
	    };
	    class Military_Pacific
	    {
	    	#include "military\pacific.hpp"
	    };
	    class Military_Woodland
	    {
	    	#include "military\woodland.hpp"
	    };
	};
};

