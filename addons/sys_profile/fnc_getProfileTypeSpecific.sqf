private _profile = _this;

private _type = [_profile,"type", ""] call ALiVE_fnc_hashGet;

private _profileType = switch (tolower _type) do {
    case "vehicle" : {
        private _objectType = tolower ([_profile,"objectType", ""] call ALiVE_fnc_hashGet);
        private _typeSpecific = if (_objectType != "tank") then {
            _objectType
        } else {
            private _vehicleClass = [_profile,"vehicleClass", ""] call ALiVE_fnc_hashGet;

            if ([_vehicleClass] call ALiVE_fnc_isAA) exitwith {
                "aa"
            };

            if ([_vehicleClass] call ALiVE_fnc_isArtillery) exitwith {
                "artillery"
            };

            "armored"
        };

        _typeSpecific
    };

    case "entity" : { "infantry" };

    default {
        "profile"
    };
};

_profileType