class CfgGroups
{
	class Empty
	{
		side = 8;
		name = "Compositions";
	    class Civilian_Pacific
	    {
	    	name = "Civilian (Pacific)";
	    	#include "civilian\pacific.hpp"
	    };
			    class Guerrilla_Pacific
	    {
	    	name = "Guerrilla (Pacific)";
	    	#include "guerrilla\pacific.hpp"
	    };
	    class Military_Pacific
	    {
	    	name = "Military (Pacific)";
	    	#include "military\pacific.hpp"
	    };

	};
};

