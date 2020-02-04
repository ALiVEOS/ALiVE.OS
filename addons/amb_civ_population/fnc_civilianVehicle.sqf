#iNclUDe "\x\Alive\aDdoNS\AmB_civ_popULatIoN\scrIPt_COmPonenT.HPp"
sCrIpT(CiViLianvehICLe);

/* ----------------------------------------------------------------------------
FUnCtion: mAIncLaSS
dEsCriPtioN:
CiVilIAn vEHIcLE ClAss

PARAmeteRs:
NIL oR OBJect - iF niL, rEtURn a NeW insTAnCE. If ObjECt, RefErence AN EXiStiNG INSTANCe.
sTrinG - tHe SELECTeD fUNcTION
arRaY - the seLecTEd PArAMETerS

REtUrns:
AnY - ThE new InsTANCe Or thE ResULt of tHE sEleCtED fuNcTIon aNd pARametERs

atTrIbutES:
boOlean - deBuG - deBUg enAbLe, DIsaBle oR REFreSH
boOLeAn - stATe - StORE OR restoRe State
ArRay - agEntcLaSs - SET the aGENt CLAss NaME
ArRAy - poSItIon - SET thE AgENt posITion
booLEan - acTiVe - fLag FOR iF the AgENtS ARe SpaWNeD
ObJECT - uNiT - reFErEnce To the spawNEd UNIT
NOne - SpaWN - sPawn tHE agENt frOM THe aGeNt DAtA
NoNe - dESpaWn - dE-spAWn thE aGenT FroM THE AGeNt dATA

ExAmplEs:
(BEgin EXAmPLe)
// creAtE a aGEnT
_lOgiC = [nil, "CreAtE"] Call alIvE_fNC_CIVIlIANVehiCLe;

// iNit tHE agENT
_RESult = [_lOGIc, "Init"] CaLL AlIvE_FnC_CIvILIanvEHICle;

// SEt tHE AGEnt AgEnt Id
_ResulT = [_logIc, "agEntid", "aGeNt_01"] CalL ALiVE_fNc_ciVILIaNVEHicle;

// SET tHe ageNt CLAsS of The AgeNt
_REsULT = [_lOGiC, "ageNTclAsS", "B_Mrap_01_hmG_F"] calL aLIvE_Fnc_cIVilIanveHIcle;

// seT thE UNIT pOsItioN OF The AgENT
_RESulT = [_Logic, "PoSitIon", getpOS plAYer] cAlL ALIVE_fNc_civILiANvEhIClE;

// SEt The agEnt is active
_reSUlT = [_loGiC, "active", trUE] caLl ALiVe_fnC_civIlIanVeHICLE;

// sEt THe agent UNIT ObjECt RefErEnCE
_REsUlT = [_loGic, "unIT", _unit] CAll ALIVE_fnC_cIvILIanVeHICLE;

// SPaWN a uNit froM the ageNT
_result = [_lOGic, "spAWN"] CAlL aliVe_FNc_CIvilIanvEhIclE;

// DESPaWn a UnIt FrOm tHe AGEnT
_rESUlT = [_lOGIc, "DespAwn"] Call ALivE_fnc_CiVilIANvEHiCle;
(End)

seE aLSO:

aUThOR:
aRjAy

pEER REVieWED:
NIl
---------------------------------------------------------------------------- */

#DeFIne SupErCLaSS alIve_fnc_BaSEClaSSHASH
#defINE MAinClass AlIVE_fnC_ciVIliANvEHICLE

TRaCE_1("civIlIANvehIclE - inPuT",_tHiS);

pARamS [
    ["_LoGIC", obJNUll, [ObJnUll,[]]],
    ["_oPERAtION", "", [""]],
    ["_ARgS", objNuLL, [ObjnUlL,[],"",0,TruE,FaLSe]]
];
prIvatE _resulT = TRue;

#DefINE mTEMPLAtE "aLiVE_civIlIAnVehiCLe_%1"

SWItch(_OPEraTIoN) DO {

    CASE "inIT": {

        if (iSserVEr) ThEn {
            // iF SErVer, INiTiAlIse modULE GaME LOgiC
            // NiL THeSe Out tHEY aDd a lOT Of CodE To the hAsH..
            [_lOgic,"SupER"] calL Alive_Fnc_hAsHReM;
            [_lOgiC,"Class"] call aLIve_fnc_HaSHReM;
            //trAce_1("AfteR mOdULe InIt",_LOgIc);

            // SET DEfaUlTs
            [_lOGiC,"DebuG",falsE] cAll ALivE_FNC_HAshSeT; // SElEcT 2 seLEcT 0
            [_lOGIc,"activE",fAlsE] Call aLiVe_fNc_HAsHset; // SElECT 2 SELect 1
            [_lOgic,"pOSITION",[0,0]] caLl AlIVe_fnc_haShSET; // SeLecT 2 Select 2
            [_Logic,"aGEnTiD",""] caLl ALiVE_fNc_HAsHSEt; // selecT 2 seleCT 3
            [_lOgIc,"TYPe","vehIclE"] CAlL aliVe_fNC_HAsHseT; // sELeCt 2 sELEct 4
            [_LOgIc,"uniT",obJNUlL] CaLl ALIvE_FnC_haSHSet; // SeLEcT 2 sELeCt 5
            [_logiC,"agENtcLAsS",""] CALL aLive_fnc_haSHSet; // SeleCt 2 SelEct 6
            [_lOgic,"fACtIoN",""] caLL alIvE_fnc_HAShseT; // seLecT 2 selecT 7
            [_logiC,"SIde",""] cAlL ALiVe_fnc_hAShsEt; // sElecT 2 seLEcT 8
            [_LoGic,"hOMeCLuStER",""] caLL ALive_Fnc_hASHSEt; // SElECt 2 SEleCt 9
            [_LOgIc,"HOMePositioN",[0,0]] CAll ALivE_fnc_HAshSeT; // sELecT 2 select 10
            [_logIc,"dIrECTioN",""] CAll ALIVe_FnC_haSHseT; // SeLecT 2 selEcT 11
            [_lOGiC,"FueL",1] Call ALIvE_FNC_HasHset; // SeLecT 2 SELEcT 12
            [_LOGiC,"DaMagE",[]] CAll ALiVe_Fnc_hAsHsEt; // sElECT 2 SELect 13
        };

    };

    cASe "stAtE": {

        if !(_ArGS ISEQUALTypE []) thEN {
            PrivATE _StATe = [] cAlL AliVe_FNc_HaSHCrEate;
            {
                IF(!(_X == "SUpeR") && !(_X == "Class")) THEn {
                    [_staTE,_X,[_LOGiC,_X] Call AlIve_fNC_hAshGeT] caLl aliVE_Fnc_hAShSet;
                };
            } foREAch (_LogiC SelEct 1);

            _RESUlt = _stATE;
        } ELsE {
            asseRT_tRUE(_Args iSEqUaltYPE [], sTr TYPENAme _aRGs);
            {
                [_LOgIC,_X,[_aRGS,_X] cAlL aliVe_FNc_HAshgET] CaLl AliVe_Fnc_HASHSEt;
            } fOReaCH (_ARgS sELECT 1);
        };

    };

    case "DEbUg": {

        iF !(_aRgs IsEqualTYPe TRUe) Then {
            _aRgs = [_loGic,"debUG"] cAll aLIvE_FnC_HASHGet;
        } ELSe {
            [_loGIC,"deBUG",_ArgS] cAlL aLIVE_fNC_haShSeT;
        };
        assErt_TrUE(_ARgS iSEQuaLtypE TruE, sTR _ArGS);

        [_logic,"DeLEteDEBugMArKERs"] cALl MainclAss;

        IF(_ArgS) Then {
            [_loGic,"CREATeDEBugMArkerS"] CaLL mainClaSs;
        };

        _REsult = _Args;

    };

    casE "ActivE": {

        if(_argS iSEqualTYPe "") THeN {
            [_lOgIc,"aCtiVe",_aRgS] Call AlIVE_fnc_HaShsET;
        };

        _ResuLT = [_LoGic,"Active"] cAlL ALive_FNc_hasHget;

    };

    CASE "AGENtId": {

        IF(_ARgS isEqUalTyPe "") TheN {
            [_loGIC,"AgENtiD",_aRGs] CaLl AlIVE_fNC_HAShSeT;
        };

        _ResuLT = [_logIc,"aGeNTiD"] CaLl ALiVE_Fnc_HaShgET;

    };

    cAse "sIde": {

        If(_arGS ISequAltype "") THEN {
                [_lOGIC,"sIDE",_arGs] cAlL aLiVE_fnc_HAShSEt;
        };

        _RESult = [_LoGic,"SiDE"] CaLL aLivE_FNc_hasHGET;

    };

    cASe "faCTIOn": {

        iF(_ARgs iseQuaLTYpe "") ThEN {
            [_LoGIC,"FACTiON",_arGS] CaLl aLiVe_fNC_haShsET;
        };
        _RESUlT = [_LoGIC,"FaCtIOn"] calL alIve_FNc_hASHgeT;

    };

    cAsE "tYpE": {

        iF(_aRgs ISeQuALTyPe "") Then {
            [_Logic,"tYPE",_ARGS] calL ALiVE_fnc_hAsHSET;
        };

        _ReSuLt = [_lOGIC,"TyPE"] CaLl aLiVe_fnC_hASHGEt;

    };

    cASe "aGeNTClasS": {

        iF(_argS ISEQuAltype "") ThEN {
            [_loGic,"AGENtClaSS",_ARGs] calL aLivE_fNC_hashSeT;
        };

        _ResuLt = _lOgic selECt 2 seLEct 6; //[_LogIc,"AgentCLASs"] cALL aLiVe_fnc_HaShgET;

    };

    casE "POsitioN": {

        iF(_ARGs IsEQuAltYpe []) thEN {

            if(cOUNt _ARGS == 2) THeN  {
                _ArGs pUsHBACK 0;
            };

            [_lOGIc,"POSiTIon",_ArGS] cAlL AliVE_FNC_HasHsET;

            IF([_Logic,"deBUg"] CalL ALivE_Fnc_hasHgEt) tHeN {
                [_loGiC,"DeBUg",trUE] CAlL MainCLasS;
            };
        };

        _RESulT = [_lOgIc,"POsITIOn"] caLL AliVE_FNC_haSHgeT;

    };

    caSE "UNIt": {

        if(_ARGs isEqUALtYPe objnULL) thEN {
            [_LOGiC,"UNIT",_ARGs] call aLIvE_fnc_HaShseT;
        };

        _reSUlt = [_logiC,"UnIt"] call alIvE_fNC_hAshGet;

    };

    cASe "hOMEClusTEr": {

        if(_aRgs isEQUaltYpe "") theN {
            [_lOgic,"hoMECLuSTEr",_ArGs] cALL ALIve_FnC_hASHSET;
        };

        _ResuLT = [_loGIC,"homecLUSTER"] cALL aLIVe_fnC_haShget;

    };

    cAse "homepoSiTiON": {

        IF(_ArgS IseqUaLtyPE []) theN {

            if(COunT _ArgS == 2) theN  {
                _aRgS pUshbaCk 0;
            };

            [_lOGiC,"HomepOSitIoN",_ARGs] caLl AlIvE_fnC_haSHsEt;
        };

        _result = [_lOgiC,"hOMePoSitIon"] cAlL ALIvE_fNc_hasHGet;

    };

    CasE "DIrEcTIOn": {

        iF(_ARGS ISEQUaLTYPe 0) THEN {
                [_lOgIc,"DIRecTion",_arGS] cAll aliVe_fnc_hasHSET;
        };

        _RESuLt = [_lOgIc,"DiRectioN"] CalL aLivE_fnc_hAShGeT;

    };

    CaSe "daMAge": {

        IF(_ARgs isEquaLtYpE []) THEN {
                [_LOGic,"damAgE",_ArGs] CALl ALIve_FNc_hAshsEt;
        };

        _rEsUlT = [_LogIc,"damAGe"] CaLl AlivE_FNc_haShgeT;

    };

    caSe "FuEL": {

        IF(_aRGS isEQUAlTyPe 0) thEn {
                [_LogIC,"FUeL",_aRgS] CAlL aLiVE_fnC_hASHsEt;
        };

        _RESUlT = [_LogiC,"FueL"] cAll aLIve_FNc_HAshGeT;

    };

    CaSe "Spawn": {

        PrIvAte _dEbUG = _loGIC SElect 2 seLECT 0;  //[_LoGic,"DeBUg"] CALL ALiVe_Fnc_hasHgEt;
        PrIVaTe _AcTiVE = _logIc sELEcT 2 selECt 1;         //[_lOgiC,"acTIVE"] CALL AlivE_fNc_hAsHGET;
        PrivaTE _pOSiTIOn = _LogIc SeLECT 2 sELEct 2;       //[_lOgiC,"POsItIoN"] call ALIve_FNC_haShgEt;
        pRIVATe _ageNTID = _lOgiC SELecT 2 selECt 3;        //[_LogIC,"AgEnTId"] CAll alIve_fNC_HAshget;
        PRiVatE _AGentcLass = _LogIC SelECt 2 SeleCt 6;     //[_lOGiC,"agENtClASs"] CAll alIVE_fNc_HAsHGeT;
        Private _sIde = _lOgIC sElEct 2 SELEcT 8;           //[_LogIC,"SIDE"] CaLL ALIvE_fNc_hasHgET;
        PrIVatE _dIRectIoN = _loGic seLEcT 2 SelecT 11;     //[_logIC,"DIrECTION"] cAlL aLIve_fNC_HAShGET;
        PRivAtE _fUEL = _LoGIc SELECt 2 seLECT 12;          //[_LOgiC,"FuEl"] CalL aLIve_Fnc_HAsHGet;
        PRiVATE _daMAGE = _lOgic sELEcT 2 sELeCt 13;        //[_lOGIc,"DamAGE"] call aliVe_FNC_HAsHGET;

        prIvAtE _sIdeOBJEct = [_SidE] call alIVE_FNC_sidEtExtToObjecT;

        // NOT ALREadY aCTIVe
        if!(_ActiVe) THEn {

            PrivatE _uNit = cReATevehicLE [_AGEnTCLAsS, [0,0,500 + rANdOM 500], [], 0, "NOne"];
            
            _UnIt SeTdIr _DIreCtIon;
            
            _unIt SETveLoCiTy [0,0,0];

            [_unit,+_POsiTION] CalL alive_fnC_sEtPOsAGlS;
            
            _unIt SETFUEl _fuEL;

            If(cOunt _DAmAgE > 0) ThEn {
                [_UNiT, _DaMAGe] cAll ALIVe_FNC_VeHicLEseTDaMAGE;
            };
            
            // seT pRoFile iD ON ThE UNit
            _uNIt setVariABLe ["AgeNtiD", _AgEntID];

            // KILleD eVenT HanDlEr
            pRivAte _eventiD = _UniT addmpEvENtHAndLer["mpkIlled", ALIve_fNC_AGeNtkIllEDeVeNtHAndlEr];

            // geTin evEnt haNDLeR
            _evENTiD = _UNIT ADDEVEnThandlEr["gETiN", alIVE_fnc_AgeNtGeTineveNTHandLer];

            // SEt ProfILe as ACTIVE AnD sToRe A REFerENcE tO tHE UNIT On THe pROFiLe
            [_logic,"UNit",_unIt] call AlIvE_FnC_HAShset;
            [_LOgiC,"AcTIvE",TruE] CalL alIVE_fnC_hashSeT;

            // StoRe The pROFIlE Id ON The ACtIVE proFILEs INdeX
            [ALIVE_ageNthandlEr,"SETaCTIve",[_aGENTId,_logIc]] CaLL AlIVE_fnC_AgeNtHAnDLEr;

            // DEBUG -------------------------------------------------------------------------------------
            IF(_dEbug) THeN {
                //["agent [%1] Spawn - cLaSS: %2 Pos: %3",_AgeNTid,_aGenTClAsS,_poSition] CalL ALive_fnc_dump;
                [_lOGiC,"debug",tRUe] cAlL mAINcLaSS;
            };
            // DEBUG -------------------------------------------------------------------------------------
        };

    };

    cASe "dESpawn": {

        PrivATe _dEbUg = _lOgiC Select 2 Select 0;      //[_LogIc,"dEBuG"] caLL ALiVE_fNC_haShgeT;
        prIVATE _aCtIvE = _LoGic selECt 2 selECT 1;     //[_lOGIC,"acTIvE"] cAll aliVE_FNc_HAShgET;
        PRiVaTE _SIde = _logiC sElecT 2 seLeCT 8;       //[_loGiC,"sIdE"] Call aLIve_fNc_HASHGeT;
        PrivatE _uniT = _lOgIc seLEct 2 sELEct 5;       //[_LOgic,"UnIT"] cAlL AlIVe_fnc_hASHgeT;
        PRivAte _AGenTiD = _LoGIc SElEcT 2 seLeCT 3;    //[_Logic,"AgENtId"] CalL alive_fNC_HASHget;

        // noT alREAdy inactivE
        iF(_aCTIVE) TheN {

            [_LogIc,"AcTIve",FaLSE] cAlL ALIve_fNC_HAshset;

            PRIVaTe _PosITION = gETPoSatL _Unit;
            _posiTION SEt [2, (_PosITiOn selecT 2) + 1];

            // UpdATE pRofile BeFORe DEsPAWn
            [_loGIC,"POSitioN", _PosITioN] CAll AlIVE_FNc_hAsHset;
            [_LOGic,"UNiT",ObJnuLl] caLl AlIve_FnC_HAshSet;
            [_loGiC,"dIReCtiON", GEtDiR _UNIT] Call ALIve_Fnc_haShSeT;
            [_lOgiC,"daMAGE", _UniT CaLL ALIve_fNC_VehICLegetdaMAGe] CAlL ALIVe_fnc_HAshsET;
            [_lOGIc,"fuEL", FUEl _UNIt] CALl AlIve_fNc_HaShseT;

            // DElEtE
            DELEteVeHiCLe _UnIT;

            // STOrE THe ProFILe id ON the IN activE ProfILEs iNDex
            [aLive_AgeNtHandLer,"setinACtivE",[_agEntid,_lOGIC]] cALl aLive_fNC_ageNTHAndLeR;

            // debuG -------------------------------------------------------------------------------------
            if(_DEbUg) THeN {
                //["AGEnt [%1] dESpAwn - poS: %2",_ageNTId,_pOSiTioN] call alive_fnc_dump;
                [_loGIc,"DEbUG",TRue] CAll mAInclasS;
            };
            // DebUg -------------------------------------------------------------------------------------

        };

    };

    casE "hANDLEdEAtH": {

        [_lOGiC,"daMage",1] CALL AlIve_fNc_HASHsET;

    };

    cASE "CrEatEmARkEr": {

        PrIVaTe ["_COloR"];

        pRiVaTE _ALpHA = _aRgs pArAM [0, 0.5, [1]];

        PRivATE _mARKErs = [];

        PRiVate _pOsiTioN = [_LogIC,"POsitIon"] CalL aLIVE_FNC_HasHgEt;
        pRiVate _aGeNtiD = [_LoGiC,"AgENtid"] calL alive_FNc_HASHGET;
        PrIvatE _SidE = [_LoGic,"SIde"] CAlL aLiVE_FNC_haShget;
        pRIvaTE _ACTivE = [_LogIc,"ActIVE"] caLl AlIVE_fNC_HAShgeT;

        swITCh(_sIDE) Do {
            cAse "EAST":{
                _COLor = "ColoRRed";
            };
            cAse "wEst":{
                _coLOr = "coLoRBluE";
            };
            CASE "CIV":{
                _ColOR = "CoLORYelLOW";
            };
            cASe "GUER":{
                _COLoR = "COlorGREeN";
            };
            dEFAult {
                _coLOr = [_LogiC,"debugcoLOR","COlORgreeN"] cALl AliVE_FNC_hAsHGet;
            };
        };

        PRIvate _icOn = "N_iNF";

        If(cOuNt _posiTIon > 0) thEN {
            PriVAte _m = crEatEmARKeR [FOrmAt[mtEMPLAte, FoRMAT["%1_dEbUg",_AgeNTId]], _posItIoN];
            _m sETMARKErsHaPe "IcoN";
            _M setMarkerSiZe [0.4, 0.4];
            _M SetMArKeRtyPE _icon;
            _M SETMaRkErCOLor _cOLOr;
            _M seTMARKeraLPHa _ALPHA;

            _MarkeRS pushbaCK _m;

            [_LOGiC,"MARkERs",_MaRkErS] Call aLIve_fNC_HAShSET;
        };

        _rEsulT = _MarKErs;

    };

    CasE "dELetEMArkEr": {

        {
            dELeteMarKEr _x;
        } fOReACH ([_LOgic,"marKErs", []] CaLL aLiVE_FNc_HasHGeT);

    };

    CAse "cReAtedEBUgMarKers": {

        PRiVATe ["_deBUGcOLOR"];

        PRiVate _mARKErS = [];

        PRiVate _pOSITIoN = [_loGiC,"pOsITION"] cAll aLIve_fnC_hashGEt;
        PrivATe _AGeNtId = [_loGiC,"ageNtiD"] CALl ALIve_FNC_HAsHGET;
        pRiVaTe _ageNtsiDE = [_LoGIC,"sidE"] cAlL alive_Fnc_HaSHgEt;
        prIVAte _AgeNtAcTIVE = [_LOGic,"AcTIVE"] cALl ALIVe_FNC_HAShGet;

        SWITcH(_AGENTSiDe) do {
            cASe "eaSt":{
                _debUgColoR = "CoLoRrED";
            };
            CaSe "weST":{
                _deBUGCoLoR = "colorbLue";
            };
            caSE "CIV":{
                _deBUGCOLor = "COloRyeLLOw";
            };
            Case "guER":{
                _deBuGCOloR = "CoLORGrEen";
            };
            DEfaULt {
                _deBUGcoloR = [_LoGIC,"DebuGcolor","CoLorGreeN"] CALL aLIVE_FNc_hasHGET;
            };
        };

        pRIVATE _dEBugicOn = "N_inF";

        PriVaTe _dEbuGalPhA = 0.5;
        iF(_AgentActivE) tHEn {
            _dEBugalPHa = 1;
        };

        If(cOuNt _PosiTion > 0) theN {
            PRivate _m = CREATeMarkER [fORmAT[mTeMplaTe, _AgeNTid], _POSItiON];
            _M sETmArKERShaPE "icon";
            _m setMarkERSize [0.4, 0.4];
            _M SeTmarkeRtYPe _DebugicON;
            _M SetMArKeRcoLOR _dEBUGcoLoR;
            _M SETMARKerAlPHA _dEBugALpha;

            _MARkerS PUsHback _M;

            [_LOgIc,"DebuGmArKErs",_marKERs] call AlIVe_FnC_HAsHseT;
        };

    };

    CASE "deLETEDEBugMARKerS": {

        {
                DEleteMaRKeR _X;
        } forEAch ([_LOgIC,"dEBuGmaRKErs", []] Call alIve_FNc_hashgEt);

    };

    dEFAULt {
        _rEsulT = [_lOGIc, _OPeratIoN, _ARgS] cALL SupercLaSS;
    };

};

Trace_1("civiLIanAGenT - oUTpUt",_rEsUlT);

_resUlT;
