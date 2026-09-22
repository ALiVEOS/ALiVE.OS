
disableSerialization;

["CrewInfo - Clientside process started!"] call ALiVE_fnc_dump;

// Which side the readout sits on is chosen once at module init and never
// changes, so the display is created once here. It used to be torn down and
// rebuilt on every pass of the loop, which is twenty times a second while you
// are in a vehicle, and cutRsc plays its fade-in each time. (#1036)
private _rsc = ["HudNamesLeft","HudNamesRight"] select (CREWINFO_UILOC == 1);
1000 cutRsc [_rsc, "PLAIN"];
private _ui = uiNameSpace getVariable _rsc;
private _HudNames = _ui displayCtrl 99999;

while {true} do {

    private ["_vehicleID","_picture","_vehicle","_vehname","_weapname","_weap","_wepdir","_Azimuth","_sleep"];

    // If something else has taken the layer in the meantime, put ours back.
    if (isNull _HudNames) then {
        1000 cutRsc [_rsc, "PLAIN"];
        _ui = uiNameSpace getVariable _rsc;
        _HudNames = _ui displayCtrl 99999;
    };

    _sleep = 2;

    if (player != vehicle player && !visibleMap) then {

        private ["_weap"];

        _name = "";
        _vehicleID = "";
        _picture = "";
        // vehicle player, not assignedVehicle player. Everything else in this
        // block already reads the vehicle the player is physically in, so a man
        // riding in anything other than his assigned vehicle got its name with
        // an empty crew list under it. (#1036)
        _vehicle = vehicle player;
        _vehname = getText (configFile >> "CfgVehicles" >> (typeOf vehicle player) >> "DisplayName");
        _weapname = getarray (configFile >> "CfgVehicles" >> typeOf (vehicle player) >> "Turrets" >> "MainTurret" >> "weapons");
        _sleep = 0.05;

         if (count (_weapname) > 0) then {_weap = _weapname select 0};

        _name = format ["<t size='1.25' color='#424242'>%1</t><br/>", _vehname];

        {
            if((driver _vehicle == _x) || (gunner _vehicle == _x)) then {

                if(driver _vehicle == _x) then {
                    _name = format ["<t size='0.85' color='#999999'>%1 %2</t> <img size='0.7' color='#424242' image='a3\ui_f\data\IGUI\Cfg\Actions\getindriver_ca.paa'/><br/>", _name, (name _x)];
                } else {
                    _target = cursorTarget;

                    if (_target isKindOf "Car" || _target isKindOf "Motorcycle" || _target isKindOf "Tank" || _target isKindOf "Air" || _target isKindOf "Ship") then {
                        _vehicleID = getText (configFile >> "cfgVehicles" >> typeOf _target >> "displayname");
                        _picture = getText (configFile >> "cfgVehicles" >> typeOf _target >> "picture");
                    };

                    // The whitelist that used to gate this decided nothing: both
                    // branches were the same seven lines, so every turreted vehicle
                    // already got this readout. The list is gone with it. (#1036)
                    if (!isNil "_weap") then {
                        _wepdir =  (vehicle player) weaponDirection _weap;
                        _Azimuth = round  (((_wepdir select 0) ) atan2 ((_wepdir select 1) ) + 360) % 360;

                        // Only offer the thumbnail when something under the cursor
                        // actually supplied one. An empty path rendered as a broken
                        // image every frame nothing was being looked at.
                        private _display = "";
                        if (_picture isNotEqualTo "") then {
                            _display = format ["<t size='0.85' color='#999999'> Display : </t><t size='0.85' color='#999999'><img size='1' image='%1'/></t><br/>", _picture];
                        };

                        // <t/> is an empty element, not a closing tag, so the colour
                        // and size opened just before it were never closed and every
                        // line after Heading inherited them. Both are </t> now.
                        _name = format ["<t size='0.85' color='#999999'>%1 %2</t> <img size='0.7' color='#424242' image='a3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/><br/> <t size='0.85' color='#999999'>Heading :</t> <t size='0.85' color='#3b1111'>%3</t><br/><t size='0.85' color='#999999'> Target :</t> <t size='0.85' color='#3b1111'>%4</t><br/>", _name, (name _x), _Azimuth, _vehicleID] + _display;
                    } else {
                        _name = format ["<t size='0.85' color='#999999'>%1 %2</t> <img size='0.7' color='#424242' image='a3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/><br/>", _name, (name _x)];
                    };
                 };
            } else {
              _name = format ["<t size='0.85' color='#999999'>%1 %2</t> <img size='0.7' color='#424242' image='a3\ui_f\data\IGUI\Cfg\Actions\getincargo_ca.paa'/><br/>", _name, (name _x)];
            };

        } forEach crew _vehicle;

        _HudNames ctrlSetStructuredText parseText  _name;
        _HudNames ctrlCommit 0;
    };

    sleep _sleep;
};

["CrewInfo - Clientside process ended!"] call ALiVE_fnc_dump;
