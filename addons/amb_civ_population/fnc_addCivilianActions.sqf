#IncLUDe "\x\aLIVe\AdDons\AMB_CIv_pOPULATIoN\ScRiPT_CoMPoNent.hpp"
sCRIPt(addCIviliANAcTioNs);

/* ----------------------------------------------------------------------------
FunctIoN: alivE_Fnc_aDdcIviLIaNaCtIOns

DEsCRIptION:
adDS cIvilIan aCTIONs

PARaMETers:

reTurns:
BOOL - TRUe

eXampLEs:
(BeGiN EXaMpLe)
//
_rESUlT = _unit CAll alIvE_fNc_aDdcIvIliaNACTIoNS;
(End)

sEE aLsO:

AutHOr:
HighhEaD
---------------------------------------------------------------------------- */

pRiVaTE _oBjecT = _This SELECT 0;

iF (sIdE _OBJEcT != cIviLiaN || {isNIl qgVar(ROLEs_DISabLED)} || {gvAr(ROlES_DISabLEd)}) EXiTwIth {}; // OnLy adD aCtions IF CivILiAN Roles MODuLe fIEld != nonE

PRIvATE _roLe = "TOWneLDER";
PrIvatE _tEXT = fOrMat["TaLk tO %1",_rolE];
PriVaTE _PARAMs = [];
PRIvaTe _code = {_ObjEcT = _tHiS sElecT 0; _CaLler = _ThiS seLeCT 1; _paRams = _ThiS SELect 3; [_oBjecT,_CAlleR] calL aLIve_FNC_SELEcTrOlEACTion};
prIvATE _ConDitIOn = "aLive _TArGet" + "&&" + FoRMAt["_TArgeT GETVAriAblE [%1,false]",Str(_roLe)];

PrivATE _Id = _OBJect AddACtIoN [
    _teXt,
    _COdE,
    _pAramS,
    1,
    FALsE,
    TrUE,
    "",
    _CONditION,
    5
];

_rOLE = "mAjoR";
_teXT = FoRMat["taLk To %1",_ROLE];
_paRAMs = [];
_CODE = {_ObjEct = _ThIs SeleCT 0; _cAllER = _tHIS SElECT 1; _pArAMS = _THIs sELEct 3; [_oBjECt,_CalLeR] Call aLivE_Fnc_sELeCtROleactioN};
_CoNdItIoN = "AliVE _tArGET" + "&&" + fOrMAt["_taRGEt geTVArIABle [%1,faLse]",sTR(_RoLe)];

_ID = _objECt aDdActIOn [
    _TExt,
    _coDE,
    _PARams,
    1,
    FAlSE,
    TRUe,
    "",
    _COndiTioN,
    5
];

_ROLE = "prIest";
_tEXt = fOrmat["TaLk to %1",_rolE];
_pARaMs = [];
_codE = {_objecT = _THis SelEcT 0; _CalLer = _tHiS SELEcT 1; _ParaMS = _tHIs seLECt 3; [_oBJeCt,_CAllER] CalL AliVE_FNc_selEctroLEaCTiON};
_CoNDITion = "AlIVE _TargeT" + "&&" + fORmaT["_TARgET gETvArIabLE [%1,FaLSe]",str(_ROlE)];

_iD = _OBJEcT ADdACtiOn [
    _tExt,
    _COde,
    _PARAMS,
    1,
    FAlSE,
    trUe,
    "",
    _CoNDItIoN,
    5
];

_Role = "MueZZiN";
_texT = foRmaT["TAlk TO %1",_Role];
_ParaMS = [];
_CODe = {_objeCt = _thIS sELECt 0; _CAlLEr = _ThIS sElEct 1; _PaRaMs = _thIS SEleCt 3; [_obJeCt,_CALler] CaLl alIve_FNc_sELECTRoleAcTion};
_CoNDition = "AlIVe _TaRgET" + "&&" + fORMaT["_TaRGet GETvaRiABlE [%1,falSE]",Str(_RoLE)];

_Id = _OBjeCT addacTIoN [
    _TexT,
    _cODe,
    _PaRams,
    1,
    fALsE,
    trUe,
    "",
    _COnDiTIoN,
    5
];

_RoLe = "POlItIciaN";
_text = FoRmAt["Talk To %1",_rolE];
_paRAmS = [];
_CODe = {_ObJecT = _ThiS sElECt 0; _CAlLer = _thiS selECT 1; _pARaMs = _tHIS seLECT 3; [_oBJeCt,_CaLLEr] caLl aliVe_fNc_SeleCTroLEActION};
_CoNditIon = "alIve _TarGeT" + "&&" + foRMaT["_tARGet geTvaRIabLe [%1,FalSE]",STr(_rolE)];

_ID = _OBJECT aDDACTION [
    _TExt,
    _CODe,
    _PArAmS,
    1,
    faLse,
    TRuE,
    "",
    _cOnDiTIoN,
    5
];

_TEXt = "DeTaiN";
_PaRAms = [];
_Code = {_oBJEcT = _tHIs sELecT 0; _caller = _ThiS SeLECT 1; _PARAMS = _THiS sELECT 3; _GrOup = gRoup _oBjecT; [_oBjEct] JoiNsILENt (gRoup _CAlLER); _oBjeCT SEtvArIabLe ['detaINED',tRUE,truE]; _gROup cAll Alive_FNC_delEtEGROUpREmoTE};
_cOndITIOn = "aLivE _TarGET" + "&&" + "!(_targET GetvARIABle ['deTAInED',fALSE])";

_Id = _ObjeCt AdDacTion [
    _tEXT,
    _CoDE,
    _pARamS,
    1,
    FAlSe,
    TRUE,
    "",
    _CONDITiOn,
    5
];

_TExt = "ARRESt";
_Params = [];
_coDE = {_ObJEct = _thIs SElecT 0; _CAlLeR = _thIs sElECT 1; _PArAmS = _tHIs sELEcT 3; _GROup = iF (siDE (GRoUP _objECT) == cIViLIan) THeN {GROuP _oBjeCT} else {creatEgrOUP CiVIlIAN}; [_objeCt] jOiNSILent _grOUP; _OBJECT dISaBleai "pATh"};
_coNdiTion = "AlIve _targeT" + "&&" + "(_TArgeT GetVAriable ['DETAinED',FALsE])";

_ID = _OBjEct AddActION [
    _TeXt,
    _Code,
    _ParAMs,
    1,
    FaLSE,
    True,
    "",
    _cONDiTIOn,
    5
];

_TeXT = "reLEaSE";
_paRAMS = [];
_cOdE = {_obJECt = _tHIS SELeCT 0; _calleR = _THis selECt 1; _pARAMS = _THIS seLEcT 3; _GRoup = if (SidE (grOup _OBjecT) == CiviliaN) THEN {grOuP _objeCt} eLSe {createGroUP CIvIlIaN}; [_ObjECt] joINSiLENt _GRoUP; _oBJeCt sETvaRiAbLe ['deTAineD',false,TRue]; _ObJeCt EnABleAI "Path"};
/*
// CaUSes UNItS To RetuRN to gROUP LEaDeR AND pile up thEre - #277)
_cODE = {_oBjeCT = _thIs SelECt 0; _cALlEr = _THIs SelECT 1; _PAramS = _THis sELecT 3; _GrOup = [AlivE_cIvILiANpOPUlaTIOnSySteM, "cIVgRouP"] calL ALiVE_fnc_hasHSet; [_ObjECT] jOINSILeNt _GRoup; _ObjEcT SETvAriAbLe ['DEtAined',FalSE,TruE]};
*/
_coNdItIOn = "aLivE _tArgeT" + "&&" + "_taRgeT GeTvariabLe ['deTAinEd',FaLse]";

_iD = _oBJECt AdDaCtiOn [
    _text,
    _coDe,
    _paRaMS,
    1,
    FalSE,
    trUE,
    "",
    _cOnDITioN,
    5
];

_TEXt = "SeaRCh";
_PAramS = [];
_COde = {_ObJeCt = _THiS sELecT 0; _CAllEr = _THIS selecT 1; _ParaMs = _THIS sElEcT 3; _CaLler aCTION ["geaR", _oBJECt]};
_coNDItION = "ALivE _tarGEt";

_ID = _ObJecT AddacTiON [
    _TexT,
    _CODe,
    _pARams,
    1,
    fALSe,
    tRue,
    "",
    _conDItiON,
    5
];

IF (RaNDOm 1 > 0.9) tHEN {
    _Text = "gaTher InteL";
    _PaRAMs = [];
    _CODe = {_ObJEct = _THIS SElECT 0; _CAlLER = _tHIS sELECt 1; _pAraMs = _ThIS SELECt 3; openmaP TRue; [gETpoSAtL _OBjECT, 2000] CAlL AlIvE_fnC_OpComtoGGLeINstallaTiOnS; _ObjECt sETvArIaBLE ["inTELgATherEd",trUe]};
    _CoNdITIoN = "ALiVE _TArgET && {iSnIl {_taRgeT geTVARiabLe 'inTELgAtheReD'}}";

    _Id = _object aDDActiON [
        _TeXt,
        _COde,
        _PaRAMS,
        1,
        FaLSE,
        TruE,
        "",
        _CONdiTiON,
        5
    ];
};

TRue;