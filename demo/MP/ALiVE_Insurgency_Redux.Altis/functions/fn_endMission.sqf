/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: fn_endMission.sqf

Author:

	Hazey

Last modified:

	2/11/2015

Description:

	Ends the mission and displays a happy little text!
	Good Job Soldier!

TODO:

	Add comment lines so people can get a better understand of how and why it works.

______________________________________________________*/

private ["_title","_text"];

_title = "<t size='1.2' color='#e5b348' shadow='1' shadowColor='#000000'>INSURGENCY | ALiVE</t>
<img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' /><br/>";
_text = format["%1<t color='#eaeaea'>All Caches have been destroyed and you have won the day. Good work soldier!</t>
<br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' />",_title];

["openSideTop",1.4] call ALIVE_fnc_displayMenu;
["setSideTopText",_text] call ALIVE_fnc_displayMenu;

INS_west_score = INS_west_score + 1;
publicVariable "INS_west_score";

end_title = {titleText["All ammo caches have been destroyed!", "PLAIN"];};
[nil, "end_title", nil, true] spawn BIS_fnc_MP;
sleep 40;
endMission "END1";