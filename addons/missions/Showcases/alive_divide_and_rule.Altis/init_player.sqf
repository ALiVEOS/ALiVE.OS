fnc_addChemLightActions = {
	_this addAction ["Activate chemlight",{
			chem = "Chemlight_blue" createVehicle [getPosASL (_this select 0) select 0, getPosASL (_this select 0) select 1,1];
			chem attachTo [(_this select 0),[0.1,0,0.4]];
		},[],1,false,true,"",
		"((getposASL _this select 2)  < 1) && {isnil 'chem'}"
	];
	_this addAction ["Deactivate chemlight",{
			detach chem; chem = nil;
		},
		[],1,false,true,"",
		"!isnil 'chem'"
	];
};

_this call fnc_addChemLightActions;
_this addEventhandler ["respawn",{(_this select 0) call fnc_addChemLightActions}];
