_this addAction ["Cut green wire",{
		if !(CORRECT_DISARM == "cut the green wire") then {
            _this spawn {
		NUKE_TRIGGERED = true;
		hint format["As you cut the wire you see a flash on the display and a timer counting downwards! The nuclear device seems to go off in about 5 minutes!"];
            	sleep 300 + (random 100);
		[[getposATL (_this select 0),1200,3600],"ALiVE_fnc_Nuke",true,false] spawn BIS_fnc_MP;
            };
		} else {
			hint format["You hear a little click, and the display goes black! The nuclear device was disabled successfully!"]; DISARM_SUCCEDED = true
		};
	},[],1,false,true,"",
	"isnil 'NUKE_TRIGGERED'"
];
_this addAction ["Cut blue wire",{
		if !(CORRECT_DISARM == "cut the blue wire") then {
			_this spawn {
			NUKE_TRIGGERED = true;
			hint format["As you cut the wire you see a flash on the display and a timer counting downwards! The nuclear device seems to go off in about 5 minutes!"];
            		sleep 300 + (random 100);
			[[getposATL (_this select 0),1200,3600],"ALiVE_fnc_Nuke",true,false] spawn BIS_fnc_MP;
            };
		} else {hint format["You hear a little click, and the display goes black! The nuclear device was disabled successfully!"]; DISARM_SUCCEDED = true};
	},[],1,false,true,"",
	"isnil 'NUKE_TRIGGERED'"
];
_this addAction ["Cut red wire",{
		if !(CORRECT_DISARM == "cut the red wire") then {
			_this spawn {
			NUKE_TRIGGERED = true;
			hint format["As you cut the wire you see a flash on the display and a timer counting downwards! The nuclear device seems to go off in about 5 minutes!"];
            		sleep 300 + (random 100);
			[[getposATL (_this select 0),1200,3600],"ALiVE_fnc_Nuke",true,false] spawn BIS_fnc_MP;
            };
		} else {hint format["You hear a little click, and the display goes black! The nuclear device was disabled successfully!"]; DISARM_SUCCEDED = true};
	},[],1,false,true,"",
	"isnil 'NUKE_TRIGGERED'"
];
_this addAction ["Remove core",{
		if !(CORRECT_DISARM == "remove the core") then {
			_this spawn {
		NUKE_TRIGGERED = true;
		hint format["As you remove the core you see a flash on the display and a timer counting downwards! The nuclear device seems to go off in about 5 minutes!"];
            	sleep 300 + (random 100);
		[[getposATL (_this select 0),1200,3600],"ALiVE_fnc_Nuke",true,false] spawn BIS_fnc_MP;
            };
        } else {hint format["You hear a little click, and the display goes black! The nuclear device was disabled successfully!"]; DISARM_SUCCEDED = true};
	},[],1,false,true,"",
	"isnil 'NUKE_TRIGGERED'"
];
_this addAction ["Block hatch",{
		if !(CORRECT_DISARM == "block the hatch") then {
			_this spawn {
		NUKE_TRIGGERED = true;
		hint format["As you try to block the hatch you see a flash on the display and a timer counting downwards! The nuclear device seems to go off in about 5 minutes!"];
            	sleep 300 + (random 100);
		[[getposATL (_this select 0),1200,3600],"ALiVE_fnc_Nuke",true,false] spawn BIS_fnc_MP;
            };
		} else {hint format["You hear a little click, and the display goes black! The nuclear device was disabled successfully!"]; DISARM_SUCCEDED = true};
	},[],1,false,true,"",
	"isnil 'NUKE_TRIGGERED'"
];

_disarm_types = ["cut the green wire","cut the blue wire","cut the red wire","remove the core","block the hatch"];
CORRECT_DISARM = _disarm_types call BIS_fnc_SelectRandom;
CORRECT_DISARM;