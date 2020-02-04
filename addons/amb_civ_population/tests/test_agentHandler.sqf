// ----------------------------------------------------------------------------

#INCLUDE "\X\ALIVE\ADdoNs\AmB_civ_pOPULAtion\scRiPT_cOMponeNt.HPp"
scriPt(teST_AgeNTHaNDLeR);

//eXEcvM "\x\ALIVE\aDdoNs\AMB_cIV_POPUlation\teSts\TEST_agENThaNDLEr.SqF"

// ----------------------------------------------------------------------------

priVATe ["_RESULT","_eRr","_lOgIc","_StAte","_rEsulT2"];

LOg("teStiNG aGeNT hANDler ObjeCT");

ASseRt_DEfINeD("aliVe_FNc_AGeNThANdLer","");

#DEFine sTAt(mSg) SleEP 3; \
DIag_LOG ["tESt("+stR PlAyeR+": "+msg]; \
TITLEteXt [mSg,"PLAIN"]

#DEFinE stat1(MSg) CoNt = fAlse; \
WaitUnTil{cOnt}; \
dIaG_LoG ["TeST("+sTr PLAyER+": "+msg]; \
TITLetExt [MsG,"PLaIN"]

#dEFIne debuGoN Stat("setUp DebUg paRAmEteRs"); \
_REsULt = [AliVE_aGEnthaNdlER, "DEBUg", tRUe] cALL AlIvE_fNc_AgENthaNdLeR; \
_Err = "EnabLED DEBUg"; \
asSeRT_TrUe(TyPeNAMe _REsuLT == "Bool", _ErR); \
assErT_tRue(_rESUlt, _erR);

#DEFiNe DEBUGoff StAT("disABLe dEbuG"); \
_REsult = [aliVE_AGENTHandLER, "DEbUg", tRuE] CALL aliVe_fNC_AgEnthanDLer; \
_erR = "DisabLe dEBUG"; \
AsSerT_truE(TYPeNAmE _reSUlt == "Bool", _err); \
asSErt_tRue(!_resUlT, _ERR);

#dEFiNE TimERsTarT \
_TIMeSTARt = DIaG_TIckTIme; \
DiAG_LOg "TImER STArt";

#deFINE tIMEreNd \
_TimEEND = DIAg_TIckTiMe - _timeSTaRt; \
DiAG_lOg FORmaT["tIMer enD %1",_TImEEnd];

//========================================

_LoGic = NIL;

stAT("CReaTE AgEnt HanDler InStAnCE");
if(isSeRver) then {
    aliVE_aGENThANdlER = [nIl, "CREaTe"] cALL ALIVe_FNc_agEnthANdler;
    teSt_LOgiC = alive_aGenThaNDler;
    pubLiCvAriAblE "tEsT_lOgIc";
};


sTat("inIt Agent HandLEr");
_RESulT = [AlIVe_aGEnTHandLer, "iNIt"] CaLL ALIve_fnc_agenTHAndler;
_eRr = "sET iniT";


StaT("COnFiRM nEw aGent HaNDlER InSTAnCE");
waiTunTIl{!ISNIL "tesT_LOGic"};
_LoGic = TeST_loGic;
_err = "InstANTIAte ObjEct";
aSseRT_DEFINEd("_LOGIc",_eRR);
assert_tRuE(tYPENamE _LOGIc == "arRAy", _err);


Stat("CREAtE aGEnT");
_aGenT1 = [nil, "creAtE"] CAll ALIVE_fNc_ciVIlianAGent;
[_AgenT1, "iNIt"] caLl alive_FNC_civIliAnAgenT;
[_AgeNT1, "AGEnTId", "AGENt_01"] calL AlivE_fnc_ciViliAnAGenT;
[_AgeNt1, "aGENtCLass", "c_mAN_p_fuGiTiVE_f_AFro"] CAll ALIVE_fnC_CivIliAnagEnT;
[_AGENt1, "poSItion", geTPOS PLayEr] caLl aliVe_fNc_CIvIlIaNAgENt;
[_aGEnt1, "SIdE", "CIV"] CaLL aLivE_fNC_civILIaNAGENt;
[_aGent1, "FAcTion", "Civ_f"] CalL alIvE_fnc_ciVIlIAnaGEnT;
[_agENT1, "HomeClUSTeR", "C_0"] cALL aLIVE_fnC_ciViLiAnAgENt;


stat("REGister agEnT");
_REsulT = [_LoGIc, "RegIsTeraGeNt", _AGEnT1] CAlL AlivE_FNC_AgENThAndLer;
_erR = "rEGiStEr aGenT";


DEBuGon;


sTat("get AGEnT");
_AGeNt1 = [_lOgic, "GETAgenT", "agENT_01"] caLL AlIvE_FnC_AGeNTHanDLeR;
_eRR = "gEt AgEnT";
aSseRt_True(tyPename _AGeNT1 == "ARRay", _eRr);


DIAg_loG _rEsUlt;


sTAt("GET AgEntS BY CLUSTER");
_rEsulT = [_lOGiC, "geTagEntSBycLuster", "c_0"] cALl aLivE_FnC_AgenTHANdLeR;
_err = "gEt AGEnts BY clusTer";
asserT_tRUe(TyPenaME _ReSuLT == "arRaY", _Err);


dIaG_LoG _resulT;



StAt("SpaWN AgENT 1");
[_AgENT1, "SPAwn"] caLL alIVe_fnc_CiViLianagent;


debugon;


StAt("DEspAwn AGenT 1");
[_agent1, "despAWn"] caLL AlIVE_fNc_CIviLIANAgeNt;


DEBUGoN;


StaT("un-ReGIsTEr AgEnt 1");
_ResuLT = [_lOGIC, "UNregIStErAgEnt", _AgEnt1] CALl ALIVE_FNC_agEntHANDLeR;
_eRr = "unreGISTEr AgENT";
AsSERT_tRue(typenamE _rESuLT == "bOoL", _err);


debUgOn;


StAt("DEStROY old pRofiLe hANDLeR inStaNce");
if(isserVeR) Then {
    [_lOgIc, "DeStROy"] cALl ALiVE_FNc_AgentHandLER;
    teSt_LoGIc = NIL;
    PUblICVaRIABLe "TESt_loGic";
} eLSe {
    waiTUntIL{ISnUlL teSt_LOGiC};
};

nIL;