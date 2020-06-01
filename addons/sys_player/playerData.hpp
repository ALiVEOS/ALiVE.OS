// Define player data getting and setting
#define FILLER_ITEM QUOTE(ItemWatch);

if (hasInterface) then {
    PLACEHOLDERCOUNT = 0;
};

getContainerMagazines = {
    private ["_target","_container","_magazines","_contMags"];
    _target = (_this select 0);
    _container = (_this select 1);
    _magazines = magazinesAmmoFull _target;
    TRACE_1("Mags", _magazines);
    _contMags = [];
    {
        private "_mag";
        _mag = _x;
        if ( toLower(_mag select 4) == _container && !(getnumber (configFile>>"CfgMagazines">>(_mag select 0)>>"count") == 1) && !(_mag select 2)) then {
            if(MOD(sys_player) getvariable ["saveAmmo", false]) then {
                    _contMags set [count _contMags, [_mag select 0, _mag select 1]];
            } else {
                    _contMags set [count _contMags, [_mag select 0, getnumber (configFile>>"CfgMagazines">>(_mag select 0)>>"count")]];
            };
        };
    } foreach _magazines;
    _contMags;
};

getWeaponMagazine = {
        private ["_target","_magazine","_weap"];
        _target = (_this select 0);
        _weap = (_this select 1);
        _magazine = [];
        {
            if ( (_x select 3) == _weap && (_x select 2) ) then {
                if(MOD(sys_player) getvariable ["saveAmmo", false]) then {
                        _magazine set [count _magazine, [_x select 0, _x select 1]];
                } else {
                        _magazine set [count _magazine, [_x select 0, getnumber (configFile>>"CfgMagazines">>(_x select 0)>>"count")]];
                };
            };
        } foreach (magazinesAmmoFull _target);
        _magazine;
};

addItemToUniformOrVest = {
    private ["_target","_item","_result"];
    _target = _this select 0;
    _item = _this select 1;
    if(typename _item == "ARRAY") then {
        if(_item select 0 != "") then {
            TRACE_2("adding item array", _target, _item);
            _target addMagazine _item; // add to client

//            ["server",QMOD(sys_player),[[(_this select 0), _item],{(_this select 0) addMagazine (_this select 1);}]] call ALIVE_fnc_BUS; // Do it on server as addMagazine array is not global
        };
    } else {
        if(_item != "") then {
            if(isClass(configFile>>"CfgMagazines">>_item)) then {
                    TRACE_2("adding item magazine", _target, _item);
                    _target addMagazine _item;
            } else {
                if(isClass(configFile>>"CfgWeapons">>_item>>"WeaponSlotsInfo") && getNumber(configFile>>"CfgWeapons">>_item>>"showempty")==1) then {
                    TRACE_2("adding item weapon", _target, _item);
                    _target addWeaponGlobal _item;
                } else {
                    TRACE_2("adding item", _target, _item);
                    _target addItem _item;
                };
            };
        };
    };
};

fillContainer = {
    //Fill up uniform, vest, backpack with placeholder objects to ensure correct load when restored
    private ["_target","_container","_count","_loaded"];
    _target = _this select 0;
    _container = _this select 1;
    _count = PLACEHOLDERCOUNT;
    _loaded = false;
    while{!_loaded} do {
            private "_currentLoad";
            if (_container == "uniform") then {
                _currentLoad = loadUniform _target;
            } else {
                _currentLoad = loadVest _target;
            };
            _target addItem FILLER_ITEM;
//            ["server",QMOD(sys_player),[[(_this select 0), "ItemWatch"],{(_this select 0) addItem (_this select 1);}]] call ALIVE_fnc_BUS; // Do it on server as addItem is not global
            if (_container == "uniform") then {
                if (loadUniform _target == _currentLoad) then {_loaded = true;};
            } else {
                if (loadVest _target == _currentLoad) then {_loaded = true;};
            };
            PLACEHOLDERCOUNT = PLACEHOLDERCOUNT + 1;
    };
    TRACE_2("Added Filler items", PLACEHOLDERCOUNT - _count, PLACEHOLDERCOUNT);
};

GVAR(UNIT_DATA) = [
        ["lastSaveTime",{ dateToNumber date;}, "SKIP"],
        ["puid",{ getPlayerUID (_this select 0);}, "SKIP"],
        ["name",{ name (_this select 0);}, {(_this select 0) setName (_this select 1);}],
        ["speaker",{ speaker (_this select 0);}, {(_this select 0) setSpeaker (_this select 1);}],
        ["nameSound",{ nameSound (_this select 0);}, {(_this select 0) setNameSound (_this select 1);}],
        ["pitch",{ pitch (_this select 0);}, {(_this select 0) setPitch (_this select 1);}],
        ["face",{ face (_this select 0);}, {(_this select 0) setFace (_this select 1);}],
        ["class",{typeof  (_this select 0);}, {[MOD(sys_player), "checkPlayer", [(_this select 0), (_this select 1)]] call ALIVE_fnc_Player;}],
        ["rating",{rating  (_this select 0);}, {(_this select 0) addrating (_this select 1);}],
        ["rank",{rank (_this select 0);}, {(_this select 0) setUnitRank (_this select 1);}],
        ["group",{group  (_this select 0);}, "SKIP"], // {[(_this select 0)] joinSilent (_this select 1);}
        ["leader", {(leader  (_this select 0) == (_this select 0));}, "SKIP"], // {(_this select 1) selectLeader (_this select 0);}
        ["viewDistance", { (_this select 0) getvariable ["viewDistance",1500];}, {setviewDistance (_this select 1);}],
        ["terrainGrid", { (_this select 0) getvariable ["terrainGrid",25];}, {setterraingrid (_this select 1);}]
        // Identity?
];

GVAR(POSITION_DATA) = [
    ["position",{getposATL  (_this select 0);}, {(_this select 0) setposATL (_this select 1);}],
    ["dir",{getDir  (_this select 0);}, {(_this select 0) setdir (_this select 1);}],
    ["anim",{    _animState = animationState (_this select 0); _animStateChars = toArray _animState;
        _animP = toString [_animStateChars select 5, _animStateChars select 6, _animStateChars select 7]; _thisstance = "";
        switch (_animP) do
        {
            case "erc":
            {
                //diag_log ["player is standing"];
                _thisstance = "Stand";
            };
            case "knl":
            {
                //diag_log ["player is kneeling"];
                _thisstance = "Crouch";
            };
            case "pne":
            {
                //diag_log ["player is prone"];
                _thisstance = "Lying";
            };
        };
        _thisstance;
     }, {(_this select 0) playActionNow (_this select 1);}],
    ["side", { side (group (_this select 0));}, "SKIP"],
    ["vehicle",{
        if (vehicle (_this select 0) != (_this select 0)) then {
            str (vehicle (_this select 0));
       } else {
               "NONE";
       };
    }, {(_this select 0) setVariable ["vehicle", (_this select 1), true];}
    ],
     ["seat", {_seat = "NONE";
        if (vehicle (_this select 0) != (_this select 0)) then {
            _find = [str(vehicle (_this select 0)), "REMOTE", 0] call CBA_fnc_find;  // http://dev-heaven.net/docs/cba/files/strings/fnc_find-sqf.html
            if ( _find == -1 ) then {
                if (driver (vehicle (_this select 0)) == (_this select 0)) then { _seat = "driver"; };
                if (gunner (vehicle (_this select 0)) == (_this select 0)) then { _seat = "gunner"; };
                if (commander (vehicle (_this select 0)) == (_this select 0)) then { _seat = "commander"; };
            };
        };
       _seat;
    }, {
        private ["_thisVehicle","_thisSeat"];
        _thisVehicle = (_this select 0) getVariable ["vehicle", "NONE"];
        if (_thisVehicle != "NONE") then {
            {
                TRACE_1("", _x getVariable "vehicleID");
                if ( _x getVariable "vehicleID" == _thisVehicle) exitWith {
                        _thisSeat = (_this select 1);
                         if (_thisSeat != "") then {
                            TRACE_2("", _thisVehicle, _thisSeat);
                                    switch (_thisSeat) do
                                    {
                                       case "driver":
                                        {
                    //                   diag_log ["player is driver"];
                                           (_this select 0) assignAsDriver _x;
                                           (_this select 0) moveInDriver _x;
                                        };
                                       case "gunner":
                                        {
                        //                    diag_log ["player is gunner"];
                                            (_this select 0) assignAsGunner _x;
                                            (_this select 0) moveInGunner _x;

                                        };
                                       case "commander":
                                        {
                            //                diag_log ["player is commander"];
                                            (_this select 0) assignAsCommander _x;
                                            (_this select 0) moveInCommander _x;
                                        };
                                    };
                        } else {
                              (_this select 0) assignAsCargo _x;
                               (_this select 0) moveInCargo _x;
                        };
                };
            } forEach vehicles;
        };
    }]
];

GVAR(HEALTH_DATA) = [
    ["damage",{damage  (_this select 0);}, {(_this select 0) setdamage (_this select 1);}],
    ["lifestate",{ lifestate  (_this select 0);}, {
        if (tolower(_this select 1) == "unconscious") then {
            (_this select 0) setUnconscious true;
        };
    }],
    ["head_hit",{(_this select 0) getVariable ["head_hit",0];}, {(_this select 0) setVariable ["head_hit",(_this select 1),true];}],
    ["body",{(_this select 0) getVariable ["body",0];}, {(_this select 0) setVariable ["body",(_this select 1),true];}],
    ["hands",{ (_this select 0) getVariable ["hands",0];}, {(_this select 0) setVariable ["hands",(_this select 1),true];}],
    ["legs",{(_this select 0) getVariable ["legs",0];}, {(_this select 0) setVariable ["legs",(_this select 1),true];}],
    ["fatigue",{ getFatigue (_this select 0);}, {(_this select 0) setFatigue (_this select 1);}],
    ["bleeding",{ getBleedingRemaining (_this select 0);}, {(_this select 0) setBleedingRemaining (_this select 1);}],
    ["oxygen",{ getOxygenRemaining (_this select 0);}, {(_this select 0) setOxygenRemaining (_this select 1);}]
];

GVAR(LOADOUT_DATA) = [

    ["assignedItemMagazines", {
        private ["_target","_magazines","_weap"];
        _target = (_this select 0);
        _magazines = [];
        _weap = currentWeapon _target;
        {
            private "_magazine";
            _target selectWeapon _x;
            if(currentWeapon _target==_x) then {
                _magazine = currentMagazine _target;
                if(_magazine != "") then {
                    _magazines set[count _magazines, _magazine];
                };
            };
        } forEach (assignedItems _target);
        _target selectWeapon _weap;
        _magazines;},
     {
        removeBackpack (_this select 0);
        (_this select 0) addbackpack "B_Bergen_mcamo"; // as a place to put items temporarily
        {
            [(_this select 0), _x] call addItemToUniformOrVest;
        } foreach (_this select 1);
    }],
    ["primaryWeaponMagazine", { [(_this select 0), 1] call getWeaponmagazine;},
     { removeAllWeapons (_this select 0);
//         ["server",QMOD(sys_player),[[(_this select 0)],{removeAllWeapons (_this select 0);}]] call ALIVE_fnc_BUS; // RemoveAllWeapons is not global
         {
                (_this select 0) addMagazine _x;
         } foreach (_this select 1);
    }],
    ["primaryweapon", {primaryWeapon (_this select 0);}, {
        (_this select 0) addWeaponGlobal (_this select 1);
    }],
    ["primaryWeaponItems", {primaryWeaponItems (_this select 0);}, {
        private ["_target","_primw"];
        _target = _this select 0;
        {
            _target removePrimaryWeaponItem _x;
        } foreach (primaryWeaponItems _target);
        {
            if (_x !="" && !(_x in (primaryWeaponItems _target))) then {
                _target addPrimaryWeaponItem _x;
            };
        } foreach (_this select 1);
    }],
    ["handgunWeaponMagazine", { [(_this select 0), 2] call getWeaponmagazine;},
     {
         {
                (_this select 0) addMagazine _x;
         } foreach (_this select 1);
         //[0, {diag_log format['post mags: %1', magazinesAmmoFull _this];},  (_this select 0)] call CBA_fnc_globalExecute;
    }],
    ["handgunWeapon", {handgunWeapon (_this select 0);}, {
        (_this select 0) addWeaponGlobal (_this select 1);
    }],
    ["handgunItems", {handgunItems (_this select 0);}, {
        {
            (_this select 0) removeHandGunItem _x;
        } foreach (handgunItems (_this select 0));
        {
            if (_x !="" && !(_x in (handgunItems (_this select 0)))) then {
                (_this select 0) addHandGunItem _x;
            };
        } foreach (_this select 1);
    }],
    ["secondaryWeaponMagazine", { [(_this select 0), 4] call getWeaponmagazine;},
     {
         {
                (_this select 0) addMagazine _x;
         } foreach (_this select 1);
    }],
    ["secondaryWeapon", {secondaryWeapon (_this select 0);}, {
        if ((_this select 1) != "") then {
            (_this select 0) addWeaponGlobal (_this select 1);
        };
        removeBackpack (_this select 0);
    }],
    ["secondaryWeaponItems", {secondaryWeaponItems (_this select 0);}, {
        private ["_target","_primw"];
        _target = _this select 0;
        {
            if (_x !="" && !(_x in (secondaryWeaponItems _target))) then {
                _target addsecondaryWeaponItem _x;
            };
        } foreach (_this select 1);
    }],

    ["uniform", {uniform (_this select 0);}, {
        //if (uniform (_this select 0) != (_this select 1)) then {
                removeUniform (_this select 0);
                //[0, {diag_log format['remove uniform: %1', uniform _this];},  (_this select 0)] call CBA_fnc_globalExecute;

                if ((_this select 0) isUniformAllowed (_this select 1)) then {
                    (_this select 0) addUniform (_this select 1);
                } else {
                    (_this select 0) forceAddUniform (_this select 1);
                };
                // Check to see uniform state on client and server
                //[0, {diag_log format['add uniform: %1', uniform _this];},  (_this select 0)] call CBA_fnc_globalExecute;

                {
                    (_this select 0) removeItemFromUniform _x;
//                    ["server",QMOD(sys_player),[[(_this select 0), _x],{(_this select 0) removeItemFromUniform (_this select 1);}]] call ALIVE_fnc_BUS; // removeItemFromUniform is not global
                    //[0, {diag_log format['uniformItems pre: %1', uniformItems _this];},  (_this select 0)] call CBA_fnc_globalExecute;
                } foreach uniformItems (_this select 0);
        /*} else {

                [0, {diag_log format['server no change uniform: %1', uniform _this];},  (_this select 0)] call CBA_fnc_globalExecute;
                [0, {diag_log format['server remove uniform items: %1', uniformItems _this];},  (_this select 0)] call CBA_fnc_globalExecute;
        };*/
    }],

    ["uniformItems", {
        private ["_uniformItems"];
        _uniformItems = [];
        {

            if ( getnumber (configFile>>"CfgMagazines">>_x>>"count") == 1 || !isClass (configFile>>"CfgMagazines">>_x) ) then {
                TRACE_1("Uniform Item", _x);
                _uniformItems set [count _uniformItems, _x];
            };
        } foreach uniformItems (_this select 0);
        _uniformItems;
     }, {
        private ["_acreActive"];
        PLACEHOLDERCOUNT = 0;
        _acreActive = isClass(configFile >> "CfgPatches" >> "acre_main");
        {
            //[(_this select 0), _x] call addItemToUniformOrVest;
            if ((_acreActive) && {_x call acre_api_fnc_isRadio}) then 
            {
                (_this select 0) addItemToUniform (_x call acre_api_fnc_getBaseRadio);
            } 
            else 
            {
                (_this select 0) addItemToUniform _x;
            };
           // (_this select 0) addItemToUniform _x;
//            ["server",QMOD(sys_player),[[(_this select 0), _x],{(_this select 0) addItemToUniform (_this select 1);}]] call ALIVE_fnc_BUS; // addItemToUniform is not global
        } foreach (_this select 1);
        //[0, {diag_log format['uniformItems: %1', uniformItems _this];},  (_this select 0)] call CBA_fnc_globalExecute;
    }],
    ["uniformMagazines", {
        private ["_uniformMags"];
        _uniformMags = [];
        _uniformMags = [(_this select 0), "uniform"] call getContainerMagazines;
        _uniformMags;
    },{
        {
            [(_this select 0), _x] call addItemToUniformOrVest;
        } foreach (_this select 1);
        //[0, {diag_log format['uni mags: %1', magazinesAmmoFull _this];},  (_this select 0)] call CBA_fnc_globalExecute;
        [(_this select 0),"uniform"] call fillContainer;
    }],
    ["vest", {vest (_this select 0);}, {
                removeVest (_this select 0);
                //[0, {diag_log format['remove vest: %1', vest _this];},  (_this select 0)] call CBA_fnc_globalExecute;

                (_this select 0) addVest (_this select 1);
                // Check to see vest state on client and server
                //[0, {diag_log format['add vest: %1', vest _this];},  (_this select 0)] call CBA_fnc_globalExecute;

                {
                    (_this select 0) removeItemFromVest _x;
//                    ["server",QMOD(sys_player),[[(_this select 0), _x],{(_this select 0) removeItemFromVest (_this select 1);}]] call ALIVE_fnc_BUS; // removeItemFromVest is not global
                } foreach vestItems (_this select 0);
    }],
    ["vestItems", {
        private ["_vestItems"];
        _vestItems = [];
        {
            if ( getnumber (configFile>>"CfgMagazines">>_x>>"count") == 1 || !isClass (configFile>>"CfgMagazines">>_x) ) then {
                TRACE_1("Vest Item", _x);
                _vestItems set [count _vestItems, _x];
            };
        } foreach vestItems (_this select 0);
        _vestItems;
    }, {
        private ["_acreActive"];
        _acreActive = isClass(configFile >> "CfgPatches" >> "acre_main");
        {
            if ((_acreActive) && {_x call acre_api_fnc_isRadio}) then 
            {
                (_this select 0) addItemToVest (_x call acre_api_fnc_getBaseRadio);
            } 
            else 
            {
                (_this select 0) addItemToVest _x;
            };
            //(_this select 0) addItemToVest _x;
//            ["server",QMOD(sys_player),[[(_this select 0), _x],{(_this select 0) addItemToVest (_this select 1);}]] call ALIVE_fnc_BUS; // addItemToVest is not global
        } foreach (_this select 1);
        //[0, {diag_log format['vestItems: %1', vestItems _this];},  (_this select 0)] call CBA_fnc_globalExecute;
    }],
    ["vestMagazines", {
        private ["_vestMags"];
        _vestMags = [];
        _vestMags = [(_this select 0), "vest"] call getContainerMagazines;
        _vestMags;
    },{
        {
            [(_this select 0), _x] call addItemToUniformOrVest;
        } foreach (_this select 1);
        //[0, {diag_log format['vest mags: %1', magazinesAmmoFull _this];},  (_this select 0)] call CBA_fnc_globalExecute;
        [(_this select 0),"vest"] call fillContainer;
    }],
    ["backpack", {backpack (_this select 0);}, {
        removeBackpack (_this select 0);
        if ((_this select 1) != "") then {
            TRACE_1("Adding Backpack", (_this select 1));
            (_this select 0) addBackpack (_this select 1);
        };
    }],
    ["backpackCargo", {
        private ["_cargo","_backpacks"];
        _cargo = getbackpackcargo (unitbackpack (_this select 0));
        TRACE_1("",_cargo);
        _backpacks = [];
        {
            for "_i" from 1 to ((_cargo select 1) select _foreachindex) do {
                _backpacks set [count _backpacks, _x];
            };
        } foreach (_cargo select 0);
        _backpacks;
    },{
        private ["_acreActive","_target"];
        clearAllItemsFromBackpack (_this select 0);
        _acreActive = isClass(configFile >> "CfgPatches" >> "acre_main");
        _target = _this select 0;
        {
            private "_item";
            _item = _x;
            if(_item != "") then {
                if(getNumber(configFile>>"CfgVehicles">>_item>>"isbackpack")==1) then {
                    TRACE_2("adding item to backpack", _target, _item);
                    if ((_acreActive) && {_x call acre_api_fnc_isRadio}) then 
                    {
                        (unitBackpack _target) addItemCargoGlobal [(_item call acre_api_fnc_getBaseRadio),1];
                    } 
                    else 
                    {
                        (unitBackpack _target) addBackpackCargoGlobal [_item,1];
                    };
                    //(unitBackpack _target) addBackpackCargoGlobal [_item,1];
                };
            };
        } foreach (_this select 1);
    }],
    ["backpackMagazines", {
        private ["_bpMags"];
        _bpMags = [];
        _bpMags = [(_this select 0), "Backpack"] call getContainerMagazines;
        _bpMags;
    },{
        {
            [(_this select 0), _x] call addItemToUniformOrVest;
        } foreach (_this select 1);
    }],
    ["backpackitems", {
        private ["_bp"];
        _bp = [];
        {
            if ( getnumber (configFile>>"CfgMagazines">>_x>>"count") == 1 || !isClass (configFile>>"CfgMagazines">>_x) ) then {
                    _bp set [count _bp, _x];
            };
        } foreach backpackitems (_this select 0);
        _bp;
    }, {
        private ["_target","_acreActive"];
        _target = _this select 0;
        _acreActive = isClass(configFile >> "CfgPatches" >> "acre_main");
        {
            private "_item";
            _item = _x;
            TRACE_2("adding item to backpack", _target, _item);
            if(_item != "") then {
                    if(isClass(configFile>>"CfgWeapons">>_item>>"WeaponSlotsInfo") && getNumber(configFile>>"CfgWeapons">>_item>>"showempty")==1) then {
                        (unitBackpack _target) addWeaponCargoGlobal [_item,1];
                    } else {
                        if ((_acreActive) && {_x call acre_api_fnc_isRadio}) then 
                        {
                           (unitBackpack _target) addItemCargoGlobal [(_item call acre_api_fnc_getBaseRadio),1];
                        } 
                        else 
                        {
                            if (_item == "ItemRadio") then {
                                (unitBackpack _target) addItemCargoGlobal [_item,1];
                            } else {
                                _target addItem _item;
                            };
                        };
                            //_target addItem _item;
                        };
            };
        } foreach (_this select 1);
        // remove item placeholders from vest and uniform
        TRACE_2("Removing placeholder items", FILLER_ITEM, PLACEHOLDERCOUNT);
        for "_i" from 1 to PLACEHOLDERCOUNT do {
            _target removeItem FILLER_ITEM;
//            ["server",QMOD(sys_player),[[(_this select 0), "ItemWatch"],{(_this select 0) removeItem (_this select 1);}]] call ALIVE_fnc_BUS; // removeItem is not global
        };
    }],
    ["headgear", {
        private ["_data", "_headgear"];
        _data = headgear (_this select 0);
        _data;
    }, {
        removeHeadgear (_this select 0);
        (_this select 0) addHeadgear (_this select 1);
    }],
    ["assigneditems", {
        private ["_data", "_goggles", "_target"];
        _target = (_this select 0);
        _data = assignedItems _target;
        _goggles = goggles _target;
           if((_goggles != "") && !(_goggles in _data)) then {
            _data set [count _data, _goggles];
        };
        _data;
    }, {
        removeAllAssignedItems (_this select 0);
        removeGoggles (_this select 0);
        {
            // Check to see if item is a binocular type which in fact is treated as a weapon
            if !(isClass(configFile>>"CfgWeapons">>_x>>"WeaponSlotsInfo")) then {
                (_this select 0) addItem _x;
                (_this select 0) assignItem _x;
            } else {
                (_this select 0) addWeaponGlobal _x;
            };
        } foreach (_this select 1);
    }],
    ["weaponstate", {
        private ["_currentweapon","_currentmode","_isFlash","_isIR","_weapLow","_data"];
        if (typeof (vehicle (_this select 0)) == typeof (_this select 0)) then {
            _currentweapon = (weaponState (_this select 0)) select 1;
            _currentmode = (weaponState (_this select 0)) select 2;
            _isFlash = (_this select 0) isFlashlightOn _currentweapon;
            _isIR = (_this select 0) isIRLaserOn _currentweapon;
            _nvg = currentVisionMode (_this select 0);
            _weapLow = weaponLowered (_this select 0);
            _data = [_currentweapon, _currentmode, _isFlash, _isIR, _nvg, _weapLow];
        } else { // Player in vehicle
            _currentweapon = currentWeapon (_this select 0);
            _data = [_currentweapon];
        };
        _data;
    }, {

        TRACE_2("", typeof vehicle (_this select 0), typeof (_this select 0));
        if (typeof (vehicle (_this select 0)) == typeof (_this select 0)) then {
            private ["_ammo","_target","_weap"];
            _target = _this select 0;
            _weap = ((_this select 1) select 0);
            // Set weapon
            _target selectWeapon _weap;
            // Set firemode
            if (count (_this select 1) > 1) then {
                _ammo = _target ammo _weap;
                _target setAmmo [_weap, 0];
                (_this select 0) forceWeaponFire [_weap, (_this select 1) select 1];
                _target setAmmo [_weap, _ammo];
                // Set magazine?
                // (_this select 0) action ["SwitchMagazine", (_this select 0), (_this select 0), ((_this select 1) select 1)];
                // Set NVG
                if ( ((_this select 1) select 4) == 1 ) then {
                    (_this select 0) action ["nvGoggles", (_this select 0)];
                } else {
                    (_this select 0) action ["nvGogglesOff", (_this select 0)];
                };
                // Set Gun Light
                if ((_this select 1) select 2) then {
                    (_this select 0) action ["GunLightOn", (_this select 0)];
                };
                // Set IR Laser
                if ((_this select 1) select 3) then {
                    (_this select 0) action ["IRLaserOn", (_this select 0)];
                };
                // Lower Weapon
                if ((_this select 1) select 5) then {
                    (_this select 0) action ["WeaponOnBack", (_this select 0)];
                };
            };
        } else { // Player in vehicle
            (_this select 0) selectWeapon ((_this select 1) select 0);
        };
    }]

];

GVAR(SCORE_DATA) = [
    ["score",{score  (_this select 0);},  {(_this select 0) addScore (_this select 1);}]
];
