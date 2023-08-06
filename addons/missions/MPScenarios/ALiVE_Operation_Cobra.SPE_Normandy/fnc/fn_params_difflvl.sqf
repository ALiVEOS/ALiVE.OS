/*
    Author: Jman
    Date: 05/08/2023

    Description:
        Sets SPE diificulty mode

    Parameter(s):
        _paramValue - Value of the parameter [NUMBER, defaults to 1]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_paramValue", 0, [1]]
];

if (isServer && {_paramValue == 1}) then {
		SPE_CadetMode = false;
		SPE_HardcoreMode = true;
} else {
		SPE_CadetMode = true;
		SPE_HardcoreMode = false;
};

true
