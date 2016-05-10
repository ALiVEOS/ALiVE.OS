
#include <script_component.hpp>
#include <config\CfgPatches.hpp>

class cfgFunctions {
	class PREFIX {
		class COMPONENT {
			#include <config\CfgFunctions.hpp>
			
			class x_lib_preinit {
				preinit = 1;
				file = "\x\alive\addons\x_lib\preinit.sqf";
			};
		};
	};
};