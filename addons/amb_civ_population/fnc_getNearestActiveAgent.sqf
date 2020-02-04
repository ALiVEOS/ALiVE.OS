#includE "\X\aLIvE\ADdonS\amb_cIV_POpuLATIoN\SCRIpT_COmPoNENt.HpP"
SCript(GetNEAReStAcTivEAGent);

/* ----------------------------------------------------------------------------
fuNCtIon: aLIve_fNc_getNEARESTAcTiveAgent

DEscriptIon:
fiNd NearesT actiVe aGeNT.

paRamETeRs:
ArRAY - poSITIon

retUrnS:
obJEct - UNIT If oNe FoUNd

ExAMples:
(beGin EXAMpLE)
//
_reSUlT = [_Pos] calL aLiVE_fnc_GETNEaReSTactIVEAGenT;
(END)

SEE AlSo:

AuthOR:
tUPolov
---------------------------------------------------------------------------- */


paramS ["_poS"];
PRivatE _aGENTsAcTIVE = [ALiVE_aGeNThANdLER, "ageNTsactIVe"] CalL AliVE_fNC_haShgeT;
PrIVaTE _rESulT = [];
PRIvATe _NEARAGENTS = [];
{
     PriVate _AGeNTPROfiLe = [alivE_AGeNTHAnDLeR, "GEtAGenT", _X] call aLIve_Fnc_AgEntHaNdlEr;
     pRiVaTE _pOSITION = _aGEntPRoFILe SELECt 2 SeLect 2;
     _nEArAgEnTs PUshBAcK [_agENtPRofiLE, _POSItIOn diSTaNCe _PoS];
} fOrEaCH (_agENtSaCtIve seLect 1);

priVAtE _SORtCoDe = {
    private _disT = _thiS SeLECT 1;
     _dISt
};

if (cOUNT (_AgENtsaCTIve SeleCt 1) > 0) tHeN {
    _NearaGEnTS = [_NeARAGenTS, _sOrtcODE] cALL AlIvE_Fnc_sHelLsORT;
    _RESuLt = (_NeAragEntS sELect 0) sElEcT 0;
};
_RESult
