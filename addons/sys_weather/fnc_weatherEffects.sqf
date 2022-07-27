#include "\x\alive\addons\sys_weather\script_component.hpp"
SCRIPT(weatherEffects);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_weatherEffects
Description:
Creates clientside weather effects.
Runs locally to player only.

Should support:
1. ALiVE Weather
2. ALiVE Real Weather
3. ACE Weather

Parameters:
STRING - Effect Type
BOOL - On or off
ARRAY - Effect Parameters

Returns:
SCALAR - Effect handle

Attributes:
Boolean - debug - Debug enabled
Boolean - enabled - Enabled or disable module

Parameters:
none


Examples:
(begin example)
["Snow",true,[_intensity]] call ALiVE_fnc_weatherEffects;
(end)

See Also:
- <ALIVE_fnc_weatherInit>


Author:
Tupolov
---------------------------------------------------------------------------- */

// Weather Effects

if (isDedicated) exitWith {};

params ["_type","_args"];

["WEATHER EFFECTS: %1",_this] call ALiVE_fnc_dump;

switch (_type) do {
    case "Mist": {
    	// Set View Distance

        // Set Colour

        //


    };
    case "Fog Patches": {
    	/* STATEMENT */
    };
    case "Fog": {
    	/* STATEMENT */
    };
    case "Rain Mist": {
    	/* STATEMENT */
    };
    case "Rain": {
    	/* STATEMENT */
    };
    case "Freezing Rain": {
    	/* STATEMENT */
    };
    case "Ice Pellets": {
    	/* STATEMENT */
    };
    case "Snow": {
        // Provides effects for light, normal, heavy snow
        // Credit MKY for particle effects
        private _intensity = _args select 0;
        private _enabled = _args select 1;

        if (_enabled) then {

            if (isNil QGVAR(snowEmitters)) then {
                // Initialise effect
                GVAR(snowHost) = "Land_Bucket_F" createVehicleLocal (position vehicle player);
                GVAR(snowHost) attachTo [player,[0,0,0]];
                GVAR(snowHost) hideObjectGlobal true;
                GVAR(snowHost) allowDamage false;
                GVAR(snowHost) enableSimulation false;
                GVAR(snowHost) setDir (windDir);

                // Setup emitters
                GVAR(snowEmitters) = [];
                private _obj = GVAR(snowHost);
                private _color = [[1,1,1,0],[1,1,1,1]];
                private _pos = position GVAR(snowHost);

                private _parent = "#particleSource" createVehicleLocal _pos;
                _parent setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,10,0],"","Billboard",1,10,[0,0,8],[0,0,-8],(.7),.1375,.10,0.4,[.03],_color,[1000],.7,.3,"","",_obj];
                _parent setParticleCircle [0,[0,0,0]];
                _parent setParticleRandom [0,[15,15,.5],[0,0,1],0,0.55,[0,0,0,.5],0,0];

                private _front = "#particleSource" createVehicleLocal _pos;
                _front setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,10,0],"","Billboard",1,10,[0,30,12],[0,0,-8],(.7),.1375,.10,0.4,[.03],_color,[1000],.7,.3,"","",_obj];
                _front setParticleCircle [0,[0,0,0]];
                _front setParticleRandom [0,[20,20,.5],[0,0,1],0,0.55,[0,0,0,.5],0,0];


                private _rear = "#particleSource" createVehicleLocal _pos;
                _rear setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,10,0],"","Billboard",1,10,[0,-25,12],[0,0,-8],(.7),.1375,.10,0.4,[.03],_color,[1000],.7,.3,"","",_obj];
                _rear setParticleCircle [0,[0,0,0]];
                _rear setParticleRandom [0,[15,15,.5],[0,0,1],0,0.55,[0,0,0,.5],0,0];


                private _right = "#particleSource" createVehicleLocal _pos;
                _right setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,10,0],"","Billboard",1,10,[25,0,12],[0,0,-8],(.7),.1375,.10,0.4,[.03],_color,[1000],.7,.3,"","",_obj];
                _right setParticleCircle [0,[0,0,0]];
                _right setParticleRandom [0,[20,20,.5],[0,0,1],0,0.55,[0,0,0,.5],0,0];

                private _left = "#particleSource" createVehicleLocal _pos;
                _left setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,10,0],"","Billboard",1,10,[-15,0,12],[0,0,-8],(.7),.1375,.10,0.4,[.03],_color,[1000],.7,.3,"","",_obj];
                _left setParticleCircle [0,[0,0,0]];
                _left setParticleRandom [0,[20,20,.5],[0,0,1],0,0.55,[0,0,0,.5],0,0];

                GVAR(snowEmitters) = [_parent, _front, _rear, _right, _left];

                GVAR(snowDrops) = [0.004,0.003,0.006,0.005,0.005];

                0 = [] spawn {
                    // Start with very light snow
                    {
                        private _intNum = _x;
                        {
                            private _intVAL = parseNumber (format ["0.00%1",_intNum]);
                            if (_intVAL > (GVAR(snowDrops) select _forEachIndex)) then {
                                (GVAR(snowEmitters) select _forEachIndex) setDropInterval _intVAL;
                            };
                        } forEach GVAR(snowEmitters);
                        sleep 1;
                    } forEach [9,8,7,6,5,4,3,2,1];
                };

            };

            // Update emitters based on intensity
            switch (_intensity) do {
                case "Normal": {
                    private _parent = GVAR(snowEmitters) select 0;
                    _parent setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,10,0],"","Billboard",1,8,[0,0,8],[0,0,-8],(.7),1.69,1,2,[.05],[[1,1,1,0],[1,1,1,.99]],[1000],.7,.3,"","",GVAR(snowHost)];
                    _parent setParticleRandom [0,[15,15,.5],[0,0,0],0,0.55,[0,0,0,.5],0,0];

                    private _front = GVAR(snowEmitters) select 1;
                    _front setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,14,2,0],"","Billboard",1,10,[0,30,12],[0,0,-8],1,1.59,1,2,[1.75],[[1,1,1,0.2],[1,1,1,0.4]],[1000],0.5,0.15,"","",GVAR(snowHost)];
                    _front setParticleRandom [0,[20,20,.5],[0,0,0],0,0,[0,0,0,0.03],0,0];

                    private _rear = GVAR(snowEmitters) select 2;
                    _rear setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,6,0],"","Billboard",1,14,[0,0,18],[0,0,-8],(.7),1.69,1,2,[5],[[1,1,1,0],[1,1,1,.29]],[1000],.7,.2,"","",GVAR(snowHost)];
                    _rear setParticleRandom [0,[40,40,.5],[0,0,0],0,0,[0,0,0,0],0,0];

                    private _right = GVAR(snowEmitters) select 3;
                    _right setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,14,2,0],"","Billboard",1,10,[0,10,12],[0,0,-8],1,1.59,1,2,[1.75],[[1,1,1,0.2],[1,1,1,0.4]],[1000],0.5,0.15,"","",GVAR(snowHost)];
                    _right setParticleRandom [0,[15,20,.5],[0,0,0],0,0,[0,0,0,0.03],0,0];

                    private _left = GVAR(snowEmitters) select 4;
                    _left setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,6,0],"","Billboard",1,8,[0,0,8],[0,0,-8],0,1.69,1,2,[5],[[1,1,1,0],[1,1,1,.29]],[1000],.7,.2,"","",GVAR(snowHost)];
                    _left setParticleRandom [0,[40,40,.5],[0,0,0],0,0,[0,0,0,0],0,0];

                    GVAR(snowDrops) = [0.003,0.004,0.009,0.000,0.009];
                };
                case "Heavy": {
                    private _parent = GVAR(snowEmitters) select 0;
                    _parent setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,6,0],"","Billboard",1,5,[0,15,8],[0,0,0],(0),1.59,1,1.5,[3],[[1,1,1,.15],[1,1,1,0.15]],[1000],0, 0,"","",GVAR(snowHost)];
                    _parent setParticleRandom [0, [25,0,8], [0, 0, 0], 0, .5, [0,0,0,0.03], 0, 0];

                    private _front = GVAR(snowEmitters) select 1;
                    _front setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,6,0],"","Billboard",1,8,[0,30,8],[0,0,0],(0),1.59,1,1.5,[3],[[1,1,1,.15],[1,1,1,0.25]],[1000],0, 0,"","",GVAR(snowHost)];
                    _front setParticleRandom [0, [30,0, 8], [0, 0, 0], 0, .5, [0,0,0,0.03], 0, 0];

                    private _rear = GVAR(snowEmitters) select 2;
                    _rear setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,6,0],"","Billboard",1,5,[0,-10,6],[0,0,0],(0),1.59,1,1.5,[3],[[1,1,1,0],[1,1,1,0.15]],[1000],0, 0,"","",GVAR(snowHost)];
                    _rear setParticleRandom [0, [15,12, 6], [0, 0, 0], 0, .5, [0,0,0,0.03], 0, 0];

                    private _right = GVAR(snowEmitters) select 3;
                    _right setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,6,0],"","Billboard",1,5,[20,0,6],[0,0,0],(0),1.59,1,1.5,[3],[[1,1,1,0],[1,1,1,0.25]],[1000],0, 0,"","",GVAR(snowHost)];
                    _right setParticleRandom [0, [20,15, 4], [0, 0, 0], 0, .5, [0,0,0,0.03], 0, 0];

                    private _left = GVAR(snowEmitters) select 4;
                    _left setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d",16,13,6,0],"","Billboard",1,5,[-20,0,6],[0,0,0],(0),1.59,1,1.5,[3],[[1,1,1,0],[1,1,1,0.25]],[1000],0, 0,"","",GVAR(snowHost)];
                    _left setParticleRandom [0, [20,15, 4], [0, 0, 0], 0, .5, [0,0,0,0.03], 0, 0];

                    GVAR(snowDrops) = [0.001,0.001,0.001,0.001,0.001]
                };
            };

            // Add Respawn handler
            player addEventHandler ["Respawn",{detach GVAR(snowHost); GVAR(snowHost) attachTo [vehicle player,[0,0,0]];(true);}];

            player addEventHandler ["GetIn",{detach GVAR(snowHost); GVAR(snowHost) attachTo [vehicle player,[0,0,0]];(true);}];

                {
                    (GVAR(snowEmitters) select _forEachIndex) setDropInterval (GVAR(snowDrops) select _forEachIndex);
                } foreach GVAR(snowEmitters);

            // Start per frame handler
            GVAR(snowHandler) = [{

            },10,[]] call CBA_fnc_addPerFrameHandler;


        } else {
            // fade out snow effect

            // Kill PFH
            [GVAR(snowHandler)] call CBA_fnc_removePerFrameHandler;
            GVAR(snowHandler) = -1;

            // delete emitters
            GVAR(snowEmitters) = nil;

            // delete emitter host
            deleteVehicle GVAR(snowHost);

        };
    };
    case "Snow Grains": {
    	/* STATEMENT */
    };
    case "Hail": {
    	/* STATEMENT */
    };
    case "Ice Crystals": {
    	/* STATEMENT */
    };
    case "Smoke": {
    	/* STATEMENT */
    };
    case "Haze": {
    	/* STATEMENT */
    };
    case "Volcanic Ash": {
    	/* STATEMENT */
    };
    case "Widespread Dust": {
    	/* STATEMENT */
    };
    case "Sand": {
    	/* STATEMENT */
    };
    case "Dust Whirls": {
    	/* STATEMENT */
    };
    case "Sandstorm": {
    	/* STATEMENT */
    };
    case "Low Drifting": {
    	/* STATEMENT */
    };
    case "Blowing": {
    	/* STATEMENT */
    };
    case "Dust Storm": {
    	/* STATEMENT */
    };
    case "Tornado": {
    	/* STATEMENT */
    };
    case "Monsoon": {
    	/* STATEMENT */
    };
    case "Color": {
    	/* STATEMENT */
    };
    case "Heathaze": {
    	/* STATEMENT */
    };
    case "Visible Breath": {
    	/* STATEMENT */
    };
    case "High Winds": {
    	/* STATEMENT */
    };
    default {
     	/* STATEMENT */
    };
};
