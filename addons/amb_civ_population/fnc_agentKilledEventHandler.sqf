#iNcLudE "\X\ALIVe\AddoNs\amb_cIV_pOpulATiON\SCRIpT_cOMPoNEnT.hPP"
ScRipT(agenTkilLedeVeNThaNdLer);

/* ----------------------------------------------------------------------------
fUNCtioN: aLivE_FNc_aGEnTKILLEdEvENthAnDLer

desCriPtiOn:
killEd EVent HANDler fOr aGENt uniTS

paraMeteRs:

rETURNS:

ExAMPLEs:
(Begin exaMple)
_eveNTID = _ageNt AdDevEnTHaNDlEr["KIlLEd", ALivE_FNC_aGEnTKiLledEVenthAndlER];
(end)

sEe AlSO:

AUThor:
arJAy
---------------------------------------------------------------------------- */

PARams ["_uNIT","_kILleR"];

PRIvAte _AGEnTID = _UniT GetVarIABLE "aGEnTID";
privAtE _AgenT = [ALiVE_AGEntHandleR, "gETageNT", _agenTID] calL Alive_FNC_AGENthAndlER;

[_UNiT,""] caLL ALivE_fNC_swItchmOve;

PRIVaTe _KIlleRSiDe = STR(sIDe (GROup _KilleR));

IF (IsnIl "_AgENt" || {!isSERvEr}) eXiTWith {};

[_agEnT, "haNDleDEAtH"] cAll ALIVE_FNc_CIViLIAnAGEnT;

[AliVE_agENTHAnDLer, "uNRegiStEraGeNT", _agent] CALl aliVe_fnc_AgeNTHanDLEr;

// LOg EVeNt

priVatE _pOSItIoN = GEtPOSaSl _UnIt;
PrIvATE _FACtiON = _aGent seleCT 2 sElecT 7;
PrIvAtE _SIDE = _AGEnt sElecT 2 select 8;

priVATE _eVeNT = ['aGeNt_KiLLed', [_PosiTion,_fAcTIon,_sIde,_kIllERsIdE],"AgEnT"] CAlL ALIve_FNC_EvEnt;
PrIVaTE _EveNtID = [AlIvE_EventlOG, "ADDevENT",_evEnT] CALl AlIve_FNc_evEnTlOG;