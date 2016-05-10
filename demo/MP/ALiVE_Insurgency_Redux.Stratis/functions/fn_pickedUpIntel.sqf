/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_pickedUpIntel.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Man am I still writing these?

	Calls text for intel getting picked up.

______________________________________________________*/

private ["_title","_text"];

_title = "<t size='1.2' color='#e5b348' shadow='1' shadowColor='#000000'>INSURGENCY | ALiVE</t>
<img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' /><br/>";
_text = format["%1<t color='#eaeaea'>New intel received on the location of an ammo cache. A marker has been added to the map.</t>
<br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' />",_title];

["openSideTop",1.4] call ALIVE_fnc_displayMenu;
["setSideTopText",_text] call ALIVE_fnc_displayMenu;