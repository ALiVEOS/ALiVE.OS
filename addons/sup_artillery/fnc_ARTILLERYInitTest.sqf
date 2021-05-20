params ["_mode","_input"];
systemchat str _input;
switch _mode do {
	// Default object init
	case "init": {
		_logic = _input param [0,objNull,[objNull]]; // Module logic
		_isActivated = _input param [1,true,[true]]; // True when the module was activated, false when it is deactivated
		_isCuratorPlaced = _input param [2,false,[true]]; // True if the module was placed by Zeus

		//systemchat str ["init", _logic];
	};
	// When some attributes were changed (including position and rotation)
	case "attributesChanged3DEN": {
		_logic = _input param [0,objNull,[objNull]];

		_logic setvariable ["artillery_he", 1000];

		//systemchat "added";

		//systemchat str ["registeredToWorld3DEN", allvariables _logic];
	};
	// When added to the world (e.g., after undoing and redoing creation)
	case "registeredToWorld3DEN": {
		_logic = _input param [0,objNull,[objNull]];

		//systemchat str ["registeredToWorld3DEN", allvariables _logic];
	};
	// When removed from the world (i.e., by deletion or undoing creation)
	case "unregisteredFromWorld3DEN": {
		_logic = _input param [0,objNull,[objNull]];

		//systemchat str ["unregisteredFromWorld3DEN", _logic];
	};
	// When connection to object changes (i.e., new one is added or existing one removed)
	case "connectionChanged3DEN": {
		_logic = _input param [0,objNull,[objNull]];

		//systemchat str ["connectionChanged3DEN", _logic];
	};
	// When object is being dragged
	case "dragged3DEN": {
		_logic = _input param [0,objNull,[objNull]];
systemchat format ["HE: %1", _logic getvariable "artillery_he"];
		//systemchat str ["connectionChanged3DEN", _logic];
	};
};

true