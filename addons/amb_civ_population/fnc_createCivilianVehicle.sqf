#iNcLUDe "\X\AliVe\ADdONs\SYs_profile\ScrIPT_COMPOnENt.hpP"
scRIPt(crEAtECIviLIaNvEhIcle);

/* ----------------------------------------------------------------------------
funCTION: AlivE_fNC_creATecivILianvEHiCLE

DeSCription:
CrEate profileS baSED ON VehiclE TYPe inClUdinG VEHicle CReW

PARAMeTErS:
StriNG - VeHIcLE CLaSs NamE
strING - sidE naME
strIng - rAnK
ARRAY - POsiTIoN
sCaLAr - dIREcTIOn

RETURNS:
ARRay Of CreateD proFIleS

EXAmPlEs:
(Begin exaMPLE)
// CrEAte PrOfIlES foR veHICle ClASs
_REsUlt = ["B_heLi_LIGHT_01_f","west",GetPOSaTL pLAYEr] caLL alIve_Fnc_crEaTECiviLiaNveHicLE;
(EnD)

seE alSo:

aUtHor:
arJAY
---------------------------------------------------------------------------- */

PaRamS [
    "_VeHICLEClaSs",
    "_sIde",
    "_fACTIon",
    "_PosITIOn",
    ["_dIRECtion", 0],
    ["_SpAwngOoDpoSItion", trUE],
    ["_pREFIx", ""],
    ["_clusTERid", ""],
    ["_BuildINGPOsitIon", [0,0,0]]
];

// gEt cOunTS OF currEnt prOfiles

PriVATe _vEHiclEId = FORmaT["Agent_%1",[AliVe_aGeNTHAndlEr, "GETNextinsErTId"] CalL AliVE_fnC_AgentHaNdler];

PRiVAte _VeHiCLEkInd = _vehICleclaSS CaLL ALivE_Fnc_veHicLEgEtKiNdOF;

// CREAtE THE pRoFIlE foR ThE vEhiClE

PRivaTe _CiVIliaNVEHIcLE = [Nil, "CREaTe"] Call alIVe_Fnc_CiviliAnvehICle;
[_ciViLIaNvEhIcLE, "inIT"] CaLl ALIve_fnC_civIlIAnVEhiclE;
[_ciVILIaNVehicle, "aGentid", _vEHIClEiD] Call AliVE_FnC_civiliANvEhicle;
[_cIvILiAnVeHICle, "AgentcLass", _vEHicleclaSS] cAll Alive_fnC_civIlIANVEHIclE;
[_cIviLIANveHIcLE, "PosITion", _pOSITIoN] caLl AlIVE_fnC_CIViLIAnveHIclE;
[_cIVIliaNveHicle, "direCTIon", _dIReCTiON] calL ALiVe_FnC_CIvIliANveHiCLE;
[_CIVilianVehIcle, "Side", _sidE] caLl alIVe_Fnc_CivILIanveHiclE;
[_cIViLiaNvEHIClE, "fActioN", _FACTioN] CaLl alIve_FNC_ciVILIaNvEhiCle;
[_ciVIlIAnVEHICLE, "damAGE", 0] CAll alIVE_Fnc_CIvILIANVeHIClE;
[_civiLiAnveHIclE, "fuel", 1] CalL Alive_FNc_cIVilIaNVeHIClE;
[_ciViLIANVeHIcLE, "hoMeClUster", _CluSteriD] caLl ALiVe_fnc_CiVilIaNVeHIcLe;
[_ciVIlIANvehicLe, "homEPosition", _bUIlDIngPositIoN] Call aLivE_FNC_CIVilIANVehiCle;

[ALiVe_aGENtHaNDlEr, "rEGISTeraGeNT", _cIViLIAnVEHiCle] CALl aliVE_fNC_AgEnTHanDlEr;

_civilIAnVEHiCLe