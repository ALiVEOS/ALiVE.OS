#ifndef execNow
#define execNow call compile preprocessfilelinenumbers
#endif

//Starting Init
["ALiVE | Divide and Rule - Executing init.sqf..."] call ALiVE_fnc_Dump;

/////////////////////
// Init server
/////////////////////

if (isServer) then {

};


/////////////////////
// Init clients
/////////////////////

if (hasInterface) then {

    ["ALiVE | Divide and Rule - Running ClientInit..."] call ALiVE_fnc_Dump;

    player createDiaryRecord ["Diary", ["Dismantle the device",
    	"INTEL has been received about a nuclear device beeing build in an hideout in Zaros, centre of terrorist activities on Lemnos! The contact is said to be a scientist named Ahelef Mahmoud, very likely to be located near the device! Objective is to question Mahmoud, disable the bomb, and return home safely!"
    ]];

    //Intro
    [] spawn {
	    titleText ["The ALiVE Team presents...", "BLACK IN",9999];
		0 fadesound 0;

		private ["_cam","_camx","_camy","_camz","_object"];
		_start = time;

		waituntil {(player getvariable ["alive_sys_player_playerloaded",false]) || ((time - _start) > 20)};
		sleep 10;

		_object = player;
		_camx = getposATL player select 0;
		_camy = getposATL player select 1;
		_camz = getposATL player select 2;

		_cam = "camera" CamCreate [_camx -500 ,_camy + 500,_camz+450];

		_cam CamSetTarget player;
		_cam CameraEffect ["Internal","Back"];
		_cam CamCommit 0;

		_cam camsetpos [_camx -15 ,_camy + 15,_camz+3];

		titleText ["A L i V E   |   D I V I D E  A N D  R U L E", "BLACK IN",10];
		10 fadesound 0.9;
		_cam CamCommit 20;
		sleep 5;
		sleep 15;

		_cam CameraEffect ["Terminate","Back"];
		CamDestroy _cam;

		sleep 1;

		_title = "<t size='1.5' color='#68a7b7' shadow='1'>DIVIDE AND RULE</t><br/>";
        _text = format["%1<t>INTEL has been received about a nuclear device beeing build in an hideout in Zaros, centre of terrorist activities on Lemnos!</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>DIVIDE AND RULE</t><br/>";
        _text = format["%1<t>The contact is said to be a scientist named Ahelef Mahmoud, very likely to be located near the device!</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

        sleep 15;

        _title = "<t size='1.5' color='#68a7b7' shadow='1'>DIVIDE AND RULE</t><br/>";
        _text = format["%1<t>Objective is to question Mahmoud, disable the bomb, and return home safely!</t>",_title];

        ["openSideSmall",0.4] call ALIVE_fnc_displayMenu;
        ["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
    };
};