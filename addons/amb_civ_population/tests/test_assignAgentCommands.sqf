// ----------------------------------------------------------------------------

#INcluDe "\x\alIVe\AdDOnS\amb_CIV_POPuLaTiON\sCRIpt_coMpOnenT.HPp"
scriPt(test_AgEnThaNDLer);

//Execvm "\x\AliVE\AddOnS\amB_cIv_PoPuLaTion\teStS\teSt_ASSigNaGentcOmmAndS.SQf"

// ----------------------------------------------------------------------------

pRIVAtE ["_ReSuLt","_ERr","_LoGIC","_STATE","_RESUlT2"];

log("teSTINg agENt hAnDLer obJect");

AssErT_DEfiNEd("ALiVe_FNc_aGENThANDLeR","");

#DeFiNE stAt(Msg) sLEeP 3; \
diaG_Log ["TEsT("+StR PlAyEr+": "+msG]; \
tITleTEXt [Msg,"PlAIN"]

#DEfINE STAT1(MsG) CoNT = FaLsE; \
waiTUntil{COnt}; \
DiAG_Log ["TEST("+sTR pLaYER+": "+msg]; \
TitLEText [MSG,"PlaIN"]

#DefiNe deBugOn StaT("SETUP dEBUg PaRaMetERS"); \
_ReSulT = [alive_AgEnTHAnDLEr, "deBuG", tRUE] cALL aLiVe_fNC_agENthandLEr; \
_ERR = "eNabled DEbuG"; \
aSSERt_trUe(TYPENamE _REsULt == "BooL", _ErR); \
ASSeRT_True(_resUlt, _ErR);

#deFine DEbuGOfF stAt("dISable dEbug"); \
_rEsUlT = [aLIVE_aGenThAnDLer, "deBug", TrUe] cAll ALiVe_fnC_agENTHAndlER; \
_eRr = "dISABLe DEbuG"; \
asSErT_true(tyPeNAMe _rEsulT == "bOOL", _erR); \
ASsErT_TRUe(!_resuLT, _Err);

#dEFIne TImErstArt \
_TIMEStarT = DIAG_TICKTiMe; \
DIag_log "TImER sTarT";

#dEFinE TIMEReNd \
_timEEnD = DIaG_TiCktImE - _tIMeSTaRt; \
dIag_LoG ForMAT["TimEr eND %1",_TIMEeND];

//========================================

PrIvAte["_AgeNts","_agEnT","_tYpe"];

// gEt anY aCTIvE CivIlIAn ageNtS

sTaT("gEt ALL AGenTS");

["ActIve AGENts:"] caLl ALIve_fnc_Dump;

_AGentS = [ALIVe_AgeNTHAndleR,"getageNtS"] Call aLive_FNc_agentHaNdLer;


STaT("AsSIGn ComMaND To aLL Agents");

{
    _TyPE = _X sElEcT 2 SelEct 4;

    iF(_tyPE == "aGeNT") THEn {
        _x cAll Alive_FnC_iNspEcthAsH;
        //[_x, "SetaCtiVEComMAnD", ["AliVE_fNc_CC_sUicIdeTARGET", "MANagED", [wEST]]] CaLl ALivE_FnC_civIlIanAGEnT;
        [_X, "SeTactIVecOMMaND", ["alIve_FnC_cC_ROGuEtarGEt", "MaNAGed", [wESt]]] CALL ALiVe_FNC_CiViliaNaGEnT;
    };
} foREaCH (_agENts SELECt 2);


