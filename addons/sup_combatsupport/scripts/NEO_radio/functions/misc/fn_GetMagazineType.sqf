private["_battery","_ordnanceType","_weaponType","_howitzer","_mortar","_mlrs","_ord"];

 _battery = _this select 0;
_ordnanceType = _this select 1;


 _weaponType = typeof(vehicle _battery);


_howitzer = ["B_MBT_01_arty_F","O_MBT_02_arty_F"];
_mortar = ["I_Mortar_01_F","O_Mortar_01_F","B_G_Mortar_01_F","B_Mortar_01_F"];
_mlrs = ["B_MBT_01_mlrs_F"];
_ord ="";

if (_weaponType in _mortar) then {
    if (_ordnanceType == "HE") then {_ord = "8Rnd_82mm_Mo_shells"};
    if (_ordnanceType == "SMOKE") then {_ord = "8Rnd_82mm_Mo_Smoke_white"};
    if (_ordnanceType == "ILLUM") then {_ord = "8Rnd_82mm_Mo_Flare_white"};

};

if (_weaponType in _howitzer) then {
    if (_ordnanceType == "HE") then {_ord = "32Rnd_155mm_Mo_shells"};
    if (_ordnanceType == "SMOKE") then {_ord = "6Rnd_155mm_Mo_smoke"};
    if (_ordnanceType == "SADARM") then {_ord = "2Rnd_155mm_Mo_guided"};
    if (_ordnanceType == "CLUSTER") then {_ord = "2Rnd_155mm_Mo_Cluster"};
    if (_ordnanceType == "LASER") then {_ord = "2Rnd_155mm_Mo_LG"};
    if (_ordnanceType == "MINE") then {_ord = "6Rnd_155mm_Mo_mine"};
    if (_ordnanceType == "AT MINE") then {_ord = "6Rnd_155mm_Mo_AT_mine"};
        diag_log format["_ord Type: %1",_ord];
};

if (_weaponType in _mlrs) then {
    if (_ordnanceType == "ROCKETS") then {_ord = "12Rnd_230mm_rockets"};
};

/*
 * --------------------------------
 * RHS: Escalation 0.3 support
 */

private["_rhs_afrf_2s3m","_rhs_afrf_bm21","_rhs_usaf_m109a6"];


// RHS:AFRF Support
_rhs_afrf_2s3m = ["rhs_2s3_tv"];
_rhs_afrf_bm21 = ["RHS_BM21_MSV_01","RHS_BM21_VDV_01","RHS_BM21_VMF_01","RHS_BM21_VV_01"];


// RHS:USAF Support
_rhs_usaf_m109a6 = ["rhsusf_m109_usarmy","rhsusf_m109d_usarmy"];


// RHS:AFRF - 2S3M
// http://doc.rhsmods.org/index.php/2S3M
//    Extra round types for this vehicle --
//        White phosphorus:    rhs_mag_WP_2a33
//        Atomic:                rhs_mag_Atomic_2a33
if (_weaponType in _rhs_afrf_2s3m) then {
    if (_ordnanceType == "HE") then {_ord = "rhs_mag_HE_2a33"};
    if (_ordnanceType == "LASER") then {_ord = "rhs_mag_LASER_2a33"};
    if (_ordnanceType == "SMOKE") then {_ord = "rhs_mag_SMOKE_2a33"};
    if (_ordnanceType == "ILLUM") then {_ord = "rhs_mag_ILLUM_2a33"};
};


// RHS:AFRF - BM-21
// http://doc.rhsmods.org/index.php/BM-21
if (_weaponType in _rhs_afrf_bm21) then {
    if (_ordnanceType == "ROCKETS") then {_ord = "RHS_mag_40Rnd_122mm_rockets"};
};


// RHS:USAF - M109A6
// http://doc.rhsmods.org/index.php/M109A6
if (_weaponType in _rhs_usaf_m109a6) then {
    if (_ordnanceType == "HE") then {_ord = "32Rnd_155mm_Mo_shells"};
    if (_ordnanceType == "SADARM") then {_ord = "2Rnd_155mm_Mo_guided"};
    if (_ordnanceType == "MINE") then {_ord = "6Rnd_155mm_Mo_mine"};
    if (_ordnanceType == "CLUSTER") then {_ord = "2Rnd_155mm_Mo_Cluster"};
    if (_ordnanceType == "SMOKE") then {_ord = "6Rnd_155mm_Mo_smoke"};
    if (_ordnanceType == "LASER") then {_ord = "2Rnd_155mm_Mo_LG"};
    if (_ordnanceType == "AT MINE") then {_ord = "6Rnd_155mm_Mo_AT_mine"};
};


/*
 * --------------------------------
 */

   _ord
