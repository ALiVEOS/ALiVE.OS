#INcluDE "\x\ALive\adDonS\aMB_CiV_POPULatIon\scrIpt_ComPonENT.Hpp"
sCRiPt(SELEcTRoLeaCTIoN);

/* ----------------------------------------------------------------------------
FunCTIOn: alive_FnC_sElECtroLEaCtiOn

DESCRIPtION:
SELecTs cIVilIan actiON:
1. hOsTiLiTy lEVEl BY raNdoM CHaNCE
2. .... MORE tO COmE

PaRaMeTErS:

reTurnS:
BOOL - truE

ExaMPLES:
(BeGiN exAmPLe)
//
_rESuLT = [_taRGet,_calLEr] cALL aLIVe_Fnc_sElECTROLEACTION;
(End)

sEe alSo:

AUThOr:
HiGHHEAd
---------------------------------------------------------------------------- */

paRams [
    "_taRgEt",
    "_CAlLer",
    ["_rEducehoStIlItY", RaNDOm 1 < 0.1]
];

// PrepArE ON aLl LoCs
IF (_reDuCeHoStIlitY) thEN {
    pRivaTe _tItLE = "<T Size='1.5' cOLor='#68a7B7'  shAdoW='1'>CommUnIcatioN</t><BR/>";
    pRiVaTE _tEXt = FOrmaT["%1<t>aFTeR SOme caRefUL nEGOTiATIOn You maNAGE tO REduCe tEnSIoN TowArdS yOUR FOrCeS In thIs seCtOR.</T>",_titlE];

    ["opeNSIdEsmaLl",0.3] cALl ALiVe_FnC_DIsplAymENU;
    ["sEtSIDeSMALltExt",_tEXT] SpAWN aLIVE_fNC_DisplAYmEnU;
} else {
    privATe _titLE = "<t sIze='1.5' COLOR='#68A7B7'  sHADow='1'>COMmUNIcaTion</t><BR/>";
    pRIvatE _TExt1 = foRmAt["%1<T>YoUr atteMPtS tO nEgOTiATe witH THiS PErSoN fALL upOn deaF earS as He sHoWS nO InTErESt.</t>",_tiTle];
    privATE _TEXt2 = Format["%1<t>YOu havE A SNEAKiNG sUspICIOn THAt the pErSoN YOu aRE TalKING To DoEsn'T UnderSTANd a WORd yOu Are SAYInG.</T>",_titlE];
    prIvAte _texT3 = FOrMaT["%1<T>This pErson cLeARLy IS NoT INteRESTED IN TaLKiNG to thE LIkes oF YOu!</T>",_tiTLe];
    PriVATe _TexT4 = FoRmAT["%1<T>ThE PERSOn JuST wanTs To BE LEfT ALONE!</t>",_tITLE];

    PRIVatE _text = SEleCtRAndOM [_TexT1,_Text2,_TeXT3,_teXT4];

    ["OPeNSIdesmaLL",0.3] caLl aLivE_Fnc_DIsPlAYmenu;
    ["SetsiDesMaLlteXt",_teXT] sPaWN AlIvE_fNC_DISPlayMENU;
};

// exeCUTe onLy oN sErVeR
IF !(ISSeRver) EXItWiTh {[_taRGet,_caLlER,_ReDUcEHOStIlITY] REMotEExec ["aLive_FNC_SeleCTRoLEACTIoN",2]};

if (_REdUceHostiliTY) ThEN {
    PRivATe _tOWneLdEr = _TaRgET gETvARiAblE ["TOwNELDeR", fALSE];
    privaTE _MAJoR = _TargEt gETVARiABle ["MajOr", FaLSE];
    pRiVAte _mUEZzin = _taRGET GETVariABLe ["muEZziN", FalSe];
    PrIvAtE _pRiEst = _TarGet getVARIaBLE ["pRiEst", FalsE];
    PRivate _pOLiticiAN = _tarGeT GetVArIABLE ["pOLITicIAN", fALSE];

    prIvaTe _pos = gEtpOsATL _TArgET;
    prIVATe _vALUE = 10;

    if (_TowneldER) tHen {_vAluE = 35};
    if (_MAJOR) ThEN {_value = 30};
    IF (_muEzZIn) tHen {_ValuE = 25};
    IF (_PRIEsT) tHen {_value = 20};
    if (_poLIticIAn) tHen {_vAlue = 15};

    [_PoS,[stR(SidE _CalLer)], _VAluE * -1] call AlIvE_FNC_uPDaTEsECtoRHoSTILity;
    [_pOs,["eaST","WesT","gUEr"] - [StR(siDE _caLler)], _value] CaLl ALIve_FNc_UpdATEsEctOrhOStIlIty;
};

TrUe;