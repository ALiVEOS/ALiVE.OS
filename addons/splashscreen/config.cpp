#include <script_component.hpp>

#include <CfgPatches.hpp>

class RscStandardDisplay;
class RscControlsGroup;
class RscPictureKeepAspect;
class RscPicture;

class cfgScriptPaths
{
	alive = "\x\alive\addons\UI\";
};


class RscDisplayStart: RscStandardDisplay
{
//  onLoad = "[""onLoad"",_this,""RscDisplayLoadingALIVE"",'Loading'] call compile preprocessfilelinenumbers ""\x\alive\addons\UI\initDisplay.sqf""";
 class controls
 {
  class LoadingStart: RscControlsGroup
  {
    class controls
	{
		class Logo: RscPictureKeepAspect
		{
			idc = 1200;
			// text = "\x\alive\addons\UI\logo_alive.paa";
			x = "0.25 * safezoneW";
			y = "0.3125 * safezoneH";
			w = "0.5 * safezoneW";
			h = "0.25 * safezoneH";
		};
		class Noise: RscPicture
		{
			text = "\x\alive\addons\UI\alive_bg.paa";
		};
	};
  };
 };
};