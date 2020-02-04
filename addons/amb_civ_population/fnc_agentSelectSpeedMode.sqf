#inCLude "\x\AlIVE\ADdOns\amb_Civ_POPUlaTion\ScriPt_cOmPoNENT.hpP"
Script(agENtselECtsPEEDmODe);

/* ----------------------------------------------------------------------------
FUNcTiOn: aLivE_FNc_AGenTselECTSPEeDMODE

dEscriPTIOn:
seT a RanDOmISH speeD MOde ON AN AGeNT

PARAMeTers:

OBjEct - AgEnT to aDjUst sPeeD mOdE of

ReturnS:

eXampLeS:
(begIn exaMPLE)
_LIgHT = [_AgeNT] CaLl AlIve_FNc_AGEntseLECTSpEEdmODE
(ENd)

seE ALSo:

aUThOR:
aRJay
---------------------------------------------------------------------------- */

PriVAte _AgeNt = _this seleCt 0;

pRIvATE _prOBAbIlItYNorMaL = 0.1;
pRIvAtE _ProBABILiTYFuLl = 0.05;

pRIVatE _POStURE = _agEnT GeTVAriablE ["PostUrE", 0];

if(_poSture < 10) tHen {_PRoBabIlITynorMAL = 0.1; _PrOBAbILitYfUll = 0.05};
iF(_PosTURe >= 10 && {_pOsTUre < 40}) tHen {_prObABiLITYNoRmAL = 0.2; _pRoBAbIlITYfulL = 0.1};
If(_pOstURE >= 40 && {_pOsTUre < 70}) THen {_PrOBaBILitYnOrmaL = 0.3; _pRoBaBiLItyFUll = 0.1};
If(_PostUrE >= 70 && {_PosTuRe < 100}) THen {_prOBAbilITynOrMAl = 0.4; _PROBaBILityfUlL = 0.2};
if(_pOsture >= 100) thEN {_pROBabiLItYNorMAL = 0.4; _probABILitYFull = 0.2};

/*
SWItCH(_PosTURE) do {
    CasE 4: {
        _pRObaBiLItynoRmAl = 0.4;
        _proBabiLiTYFull = 0.2;
    };
    CAse 3: {
        _pRObaBiLITYNormaL = 0.3;
        _PRoBABIlitYfulL = 0.1;
    };
    CaSe 2: {
        _PRObabiLItYnoRmAL = 0.2;
        _PRObAbiLiTYfUll = 0.1;
    };
    CASE 1: {
        _pRobaBiLITYNOrMAl = 0.1;
        _ProBABILitYfuLL = 0.05;
    };
};
*/

PrIvATe _diceROLL = RanDOm 1;

_AgEnT sEtSPeeDMoDE "lIMiTed";

IF(_DIceROLl < _probabILITYNOrMaL) THeN {
    _AgenT SeTSPEEDmode "nOrmaL";
};

if(_DICeRoLl < _prOBAbilITYfUlL) THeN {
    _ageNT SetsPEEDmode "fUlL";
};

