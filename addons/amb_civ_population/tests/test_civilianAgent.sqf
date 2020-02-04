// ----------------------------------------------------------------------------

#INCLUDe "\x\alive\adDonS\Amb_CiV_poPULatIOn\ScRipT_ComPONENt.HPP"
SCRipt(teST_CivilIANAGEnT);

//ExECvM "\x\alive\adDONs\AMB_CiV_pOPULAtioN\TESts\TeST_CIvILiANAGeNt.sQF"

// ----------------------------------------------------------------------------

pRiVatE ["_ResULt","_ERR","_logIc","_StATe","_REsuLT2"];

LOG("teStIng civIlIAN agent OBject");

aSsErt_DeFiNEd("ALIvE_fNC_CivILIanagEnT","");

#DEfiNE STAt(mSG) SLEeP 3; \
DIAg_lOg ["TEst("+str pLAyeR+": "+MsG]; \
tItLeTEXt [MsG,"PLaIn"]

#dEfiNE stat1(msg) CONT = fAlse; \
wAITuNtIL{conT}; \
DiAG_lOg ["TESt("+StR plAYER+": "+mSg]; \
TItLETeXT [msG,"pLAin"]

#define dEbUgoN sTAt("sEtup deBug paRaMEtERs"); \
_ReSuLT = [_loGic, "dEbUG", TrUE] cALL ALive_fNC_CIviliANagEnt; \
_ErR = "EnAbLEd debuG"; \
aSSert_TrUE(tYPenaME _rESuLt == "BOOL", _erR); \
asSeRt_TRUe(_ResUlt, _Err);

#dEFinE dEBUGOfF StAT("DIsABlE DeBug"); \
_rEsuLT = [_lOGIC, "debuG", FalSE] CALL alIVe_fNC_ciViLIAnAgenT; \
_Err = "dISaBLE DEbuG"; \
asseRT_TRue(TYpeNaMe _rEsuLt == "BoOL", _ERR); \
ASsERT_True(!_reSUlT, _eRr);

#DefINe TiMERSTaRt \
_TiMeStARt = DiAg_tICkTIme; \
DIAG_lOG "TimEr StArt";

#dEFine TiMErend \
_timEEnd = diag_tiCkTIMe - _TimEsTART; \
DiAg_LoG FOrmat["TImEr EnD %1",_tImEENd];

//========================================

_LOgIc = nIL;

STaT("CReaTe AGEnt iNStaNcE");
iF(IsSerVEr) THen {
    _logic = [NIL, "creATe"] caLl alIve_FNc_civiLIanaGent;
    TeST_lOGIC = _loGiC;
    PubliCvariABLE "teSt_loGic";
};


sTAT("iNiT AgEnT");
_reSULt = [_LoGIC, "InIt"] call AlIvE_FNC_ciViLIanAgENt;
_eRr = "sET iNIT";
AsSeRt_TrUE(TYPEnAmE _REsuLT == "BOol", _ERR);


StAt("coNFIRm NeW agENt InstAnCE");
waITUnTIl{!isnIL "TESt_LOgic"};
_LoGIc = Test_LogIC;
_erR = "iNsTaNtiate ObJEcT";
asSeRt_DEfINed("_LOGiC",_eRR);
ASSERt_TRuE(tYpENAme _LogIC == "aRrAY", _Err);


stat("seT AgenT Id");
_ReSUlT = [_lOGiC, "agENtiD", "AgeNT_01"] CalL Alive_FNc_CIvIliaNAgenT;
_eRR = "seT profiLe id";
AsSeRT_TRuE(tYPename _ReSuLt == "strING", _ErR);


sTAT("set AgENT CLAsS");
_rEsuLT = [_LOgic, "ageNtcLaSS", "c_MAN_p_fUgitiVE_F_AfRo"] cALL ALIvE_FnC_cIviLiANAgEnT;
_ErR = "sET vehICLe ClAsSes";
AsSeRT_TRUE(tyPenAmE _ResuLT == "StRING", _eRR);


sTAT("sET pOSITIoN");
_ReSULt = [_LOgIc, "pOsITioN", gEtpOS PLAyeR] call alIVe_fNc_CiVilIAnagEnt;
_erR = "Set pOSiTIoN";
ASserT_TrUe(TYPEnAmE _rESult == "arRAy", _ERr);


sTAT("GET staTe");
_statE = [_logIc, "sTatE"] call AliVe_fNC_ciViLIAnAGenT;
_eRR = "GEt sTaTe";
asSeRT_truE(tYPeNaMe _State == "ArRAY", _erR);


_sTAtE Call ALive_FNC_iNspecthAsH;


sTAt("SPawn");
_ResuLT = [_Logic, "SPawn"] CALl ALIVE_fnC_civIlIAnagenT;
_ERr = "Spawn";
aSserT_trUe(TyPeName _REsULt == "BOOL", _ErR);


StAt("SLEepING BEfOre deSpAWn");
slEeP 40;


sTAT("De-SpawN");
_RESulT = [_lOGIC, "dESpaWN"] CAll aLivE_fNC_civilIanagEnt;
_err = "Despawn";
aSSert_TRuE(TyPenAME _REsUlT == "bool", _ERR);


STAT("GEt StatE");
_stATe = [_loGiC, "STaTE"] CaLl AlivE_FnC_cIViliANaGent;
_Err = "gET stAtE";
aSsErt_TrUE(typeNAME _stATe == "arRAY", _ERr);


_staTe Call alivE_FNc_inSpectHAsh;


StAt("sLEEpinG bEfOrE rEsPAWN");
SLeeP 10;


sTAT("SPaWn");
_REsULT = [_lOGIc, "SPawn"] CALL aLiVe_fnc_ciVIlIaNageNt;
_err = "Spawn";
ASserT_tRue(tYpenAMe _reSULt == "boOl", _Err);


STaT("SLeEPinG BEfore DeSpawN");
SLeep 40;


STat("DE-spAwn");
_reSuLt = [_lOGIc, "dEsPAWN"] CaLL ALIVE_fNc_CivIlIANAGeNT;
_ERr = "dESpAWn";
asSerT_tRUe(tYPEnAME _REsUlT == "bOol", _Err);


Stat("sLeEpINg BeFOre DesTROy");
sleep 40;


sTaT("DESTRoy oLd prOFILe InstAncE");
iF(iSSERvEr) thEN {
    [_lOgiC, "deStRoy"] cAlL AliVE_Fnc_CIViLiaNagENT;
    teST_LoGiC = nIl;
    pUBlicVaRIaBlE "teST_LogIc";
} elSE {
    waituNtiL{IsnuLl TEst_lOGIC};
};

NIL;