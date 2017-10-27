///////////////////--Basic--///////////////////        -----> https://community.bistudio.com/wiki/enableSaving
enableSaving [false, false];

/////--Intro--/////
if (hasInterface) then {
	private ["_cam","_camx","_camy","_camz","_object"];
	
	titleText ["The ALiVE Team presents...", "BLACK IN",9999];
	
	waituntil {!(isnull player)};
	sleep 8;
	
	_object = player;
	_camx = getposATL player select 0;
	_camy = getposATL player select 1;
	_camz = getposATL player select 2;
	
	_cam = "camera" CamCreate [_camx -700 ,_camy + 700,_camz+100];
	
	_cam CamSetTarget player;
	_cam CameraEffect ["Internal","Back"];
	_cam CamCommit 0;
	
	_cam camsetpos [_camx -15 ,_camy + 15,_camz+3];
	_cam CamCommit 30;
	sleep 5;
	
	titleText ["A L i V E  | Q U I C K S T A R T  ", "BLACK IN",10];
		
	sleep 25;
			
	_cam CameraEffect ["Terminate","Back"];
	CamDestroy _cam;
};