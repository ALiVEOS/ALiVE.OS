#ifndef execNow
#define execNow call compile preprocessfilelinenumbers
#endif

0 fadesound 0;

titleText ["The ALiVE Team presents...", "BLACK IN",9999];

sleep 1;

titleText ["A L i V E   |   H u r t   L o c k e r", "BLACK IN",9999];

sleep 5;

titleText ["
Stratis is reeling from a brutal insurgency campaign. After the war only small pockets of local militia survive. However, IED's litter the landscape, its your job to identify and disarm IEDs to ensure the safety of the civilian population. Beware local militia who control the towns and villages.
", "BLACK IN",9999];

sleep 15;

titleText ["
Orders are to recon the towns and villages across Stratis to determine threat. Clear all enemy within boundaries in order to regain control of the island. There is an extreme threat of IEDs, VB-IEDs and highly likely that militia have established roadblocks on roads leading into towns and villages. Civilians have long since been evacuated, slaughtered or removed from the island. You must disarm, disable or destroy all IEDs to enable civilians to move back to the island. Your small team has transport support available from the local airfield.
", "BLACK IN",9999];

sleep 30;

titleText ["A L i V E   |   H u r t   L o c k e r", "BLACK IN",5];
15 fadesound 1;

_object = player;
_camx = getposATL _Object select 0;
_camy = getposATL _Object select 1;
_camz = getposATL _Object select 2;

_cam = "camera" CamCreate [_camx +100 ,_camy - 100,50];

_cam CamSetTarget _object;
_cam CameraEffect ["Internal","Back"];
_cam CamCommit 0;

_cam camsetpos [_camx -15 ,_camy + 15,3];
_cam CamCommit 10;

// disable AI slots
disabledAI = 1;

sleep 7;

_cam CameraEffect ["Terminate","Back"];
CamDestroy _cam;

