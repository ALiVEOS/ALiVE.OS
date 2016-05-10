/*
  _____
  \_   \_ __  ___ _   _ _ __ __ _  ___ _ __   ___ _   _
   / /\/ '_ \/ __| | | | '__/ _` |/ _ \ '_ \ / __| | | |
/\/ /_ | | | \__ \ |_| | | | (_| |  __/ | | | (__| |_| |
\____/ |_| |_|___/\__,_|_|  \__, |\___|_| |_|\___|\__, |
                            |___/                 |___/

@filename: intro.sqf

Author:

	Hazey

Specials Thanks:
	HighHead - For the awesome jamz of him singing! Ha!

Last modified:

	2/19/2015

Description:

	The Intro that is played at the start of the mission JIP.
______________________________________________________*/

if(isDedicated) exitWith{};

if (hasInterface) then {

    ["Insurgency | ALiVE - Running Client Intro..."] call ALiVE_fnc_Dump;

    //Intro
    [] spawn {

		playMusic "ALiVE_Intro";

		waitUntil {!isNull player};

	    titleText ["Hazey from the ALiVE Dev Team presents..", "BLACK IN",9999];
		0 fadesound 0;

		private ["_cam","_camx","_camy","_camz","_object","_name"];
		_start = time;

		sleep 10;

		_object = radio;
		_name = name player;
		_camx = getposATL _object select 0;
		_camy = getposATL _object select 1;
		_camz = getposATL _object select 2;

		_cam = "camera" CamCreate [_camx -500 ,_camy + 500,_camz+450];

		_cam CamSetTarget _object;
		_cam CameraEffect ["Internal","Back"];
		_cam CamCommit 0;

		_cam camsetpos [_camx -0 ,_camy + 0,_camz+3];

		titleText ["I N S U R G E N C Y   |   A L i V E", "BLACK IN",10];
		10 fadesound 0.9;
		_cam CamCommit 20;
		sleep 5;
		sleep 15;

		_cam CameraEffect ["Terminate","Back"];
		CamDestroy _cam;
		10 fadeMusic 0;

		sleep 1;

		_title = "<t size='1.2' color='#e5b348' shadow='1' shadowColor='#000000'>INSURGENCY | ALiVE</t>
		<img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' /><br/>";
        _text = format["%1<t>Welcome %2. Please take the time to read the following displaying shortly after this message and enjoy your stay.</t>
		<br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' />",_title, _name];

        ["openSideTop",1.4] call ALIVE_fnc_displayMenu;
        ["setSideTopText",_text] call ALIVE_fnc_displayMenu;

        sleep 20;

		_title = "<t size='1.2' color='#e5b348' shadow='1' shadowColor='#000000'>INSURGENCY | ALiVE</t>
		<img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' /><br/>";
        _text = format["%1<t>Players must search houses or kill enemy infantry to find INTEL items to help discover depot locations.</t>
		<br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' />",_title];

        ["openSideTop",1.4] call ALIVE_fnc_displayMenu;
        ["setSideTopText",_text] call ALIVE_fnc_displayMenu;

        sleep 20;

		_title = "<t size='1.2' color='#e5b348' shadow='1' shadowColor='#000000'>INSURGENCY | ALiVE</t>
		<img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' /><br/>";
        _text = format["%1<t>The center of terrorist activities is located in the northwestern part of Altis and will spread across the island!</t>
		<br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' />",_title];

        ["openSideTop",1.4] call ALIVE_fnc_displayMenu;
        ["setSideTopText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;
		playMusic "";

        _title = "<t size='1.2' color='#e5b348' shadow='1' shadowColor='#000000'>INSURGENCY | ALiVE</t>
		<img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' /><br/>";
        _text = format["%1<t>Destroy %2 weapon depots to win! Dont forget to search and clear the indicated red grids. When a grid is cleared it will turn green.</t>
		<br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' />",_title,(paramsArray select 6)];

        ["openSideTop",1.4] call ALIVE_fnc_displayMenu;
        ["setSideTopText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;

        _title = "<t size='1.2' color='#e5b348' shadow='1' shadowColor='#000000'>INSURGENCY | ALiVE</t>
		<img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' /><br/>";
        _text = format["%1<t>Join our teamspeak 3 channel (ts3.whiskeycompany.net) to meet up with other player squads.</t>
		<br/><br/><img color='#ffffff' image='media\images\img_line_ca.paa' align='left' size='0.60' />",_title];

        ["openSideTop",1.4] call ALIVE_fnc_displayMenu;
        ["setSideTopText",_text] call ALIVE_fnc_displayMenu;
    };

    waituntil {!isnull player};

};