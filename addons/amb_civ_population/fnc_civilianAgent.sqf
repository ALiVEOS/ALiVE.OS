#iNCludE "\x\AlIvE\aDdoNS\amB_CIV_POPulaTIoN\sCRIPT_COmpOnent.hPp"
scriPt(cIViliAnagENt);

/* ----------------------------------------------------------------------------
FuNCtIOn: AliVe_fNC_ciVILIaNagent
dEScRIPtIoN:
cIViLiaN aGenT cLass

paRameTERs:
NIl or obJECt - iF niL, ReTURn A new inStaNCE. If oBjECt, RefereNCe aN EXiStiNG insTaNCe.
strinG - ThE sELEcted FUnction
ARRAY - THe SEleCTeD parAMETErs

RETURnS:
ANy - THe nEW insTanCe or tHe REsult OF thE seLECtED FuNcTion and parAmeTERs

AtTriBuTEs:
booleAn - debUG - dEBUg eNAblE, DIsabLE OR REFrEsH
bOOLEan - STatE - StOre oR rEStore sTATE
ArRay - aGenTClASS - sEt tHE aGENt class NaMe
ARRaY - posItioN - Set The AGent PosItiOn
boolEAn - aCTiVe - flAg FoR If ThE AgENts aRe sPawNeD
OBJeCT - UNIT - rEFeRENCE tO ThE SPawNed unIt
nOnE - sPaWN - spAwn The AGent frOM tHE AGEnt DAtA
NONE - dEspawN - DE-SpAwN ThE Agent fROM the ageNt DaTA

exaMPLeS:
(BEgin ExAmplE)
// CrEATe A AGENt
_logIc = [NIl, "cReATE"] caLl aLivE_fNc_CivILiANaGENt;

// inIt ThE AgeNT
_REsuLt = [_LoGIc, "iNiT"] call alIVe_fnc_cIvIlIAnAGeNt;

// SeT ThE AGeNT AGenT ID
_resUlT = [_logIC, "aGeNtId", "agenT_01"] calL alIve_FNC_civILIAnAGENT;

// SEt tHE aGENt clAsS OF tHe AgEnt
_RESULt = [_logIc, "AgenTclASS", "B_MRaP_01_Hmg_f"] CALL ALive_fnc_CIVILIanaGENT;

// SEt THE uNIT POSitIon OF tHe ageNT
_reSUlT = [_loGic, "pOSiTION", gEtpOs plaYer] CAll AlIVE_fnC_cIvILIanAgeNT;

// sEt tHE aGENT Is ACtive
_ResUlt = [_lOGIC, "aCtiVe", true] cAll ALIVE_Fnc_civIliAnaGENT;

// SeT ThE AgEnT UNiT oBJEcT refEreNCe
_rEsuLt = [_lOgiC, "uNIT", _unIt] CAll aLIvE_fnC_civILiaNagEnT;

// SPAwn a Unit frOm The AGeNT
_reSuLT = [_loGiC, "sPawn"] cAlL AlIVE_fNC_cIVilianaGenT;

// DesPAwn A UnIT FROm thE AGeNt
_ResUlt = [_lOgIC, "DESpAWN"] call aLIVE_FNc_CIviliAnAGEnT;
(eNd)

SEe AlsO:

AUtHOr:
arJaY

Peer REViEWed:
Nil
---------------------------------------------------------------------------- */

#dEfiNe SUPerclASS ALIve_FNC_baSeclasSHAsH
#DefinE MAINClaSs AlIVe_FnC_CiVIlIAnAgEnT

tRacE_1("cIviliAnAGent - inPUT",_THIs);

PARAms [
    ["_Logic", obJnULl, [OBJNULl,[]]],
    ["_opERaTion", "", [""]],
    ["_ArgS", ObjnULL, [ObJnuLl,[],"",0,TRue,FALSe]]
];
PRiVAte _REsulT = TRue;

#Define mtempLAtE "AlivE_CivILiAnagenT_%1"

SwITcH(_oPEratioN) Do {

    CasE "iNit": {

        iF (ISserVeR) then {
            // If SeRvER, iNITIalISE MoDULe Game loGIc
            // nil tHeSE OUT TheY add A Lot of Code to The HaSh..
            [_LOgIC,"SUper"] CalL alive_fNC_HAShrem;
            [_LOgIc,"CLaSs"] Call alIvE_fNC_HaShReM;
            //TrACE_1("aFTeR mODuLE INiT",_loGIC);

            // sEt deFAuLts
            [_LogiC,"DeBuG",fALSE] CALl ALive_fnC_hAshset; // SElect 2 Select 0
            [_logic,"ActiVe",fAlse] CalL ALive_FNC_HaSHSET; // seLeCT 2 SeLeCt 1
            [_LoGIC,"pOSItiON",[0,0]] cALl alIVe_fnc_hASHseT; // SeLECT 2 SELecT 2
            [_LOgic,"aGENtid",""] CALL aLIve_fnc_hASHsET; // SelecT 2 sELEcT 3
            [_lOGIc,"TYpe","aGENt"] cAll aLiVE_FnC_haShsET; // selEct 2 SelECT 4
            [_LoGIC,"unIT",OBjNUlL] CaLL alIvE_FnC_hashseT; // SeLeCt 2 sELect 5
            [_logIC,"AGeNTClAss",""] calL aliVe_fnC_HasHSeT; // SElEct 2 seLECT 6
            [_LOGIc,"fActioN",""] cALL alIVE_FNc_HaShSet; // sElecT 2 sElEcT 7
            [_lOgiC,"sIDe",""] CALL aLIve_FnC_hashsEt; // sElect 2 sELect 8
            [_lOGiC,"HOmecLusTEr",""] CAlL ALIVe_Fnc_HasHsEt; // sELecT 2 sELecT 9
            [_logIC,"HomEPOSition",[0,0]] cALL ALiVE_Fnc_HAshSEt; // SeleCt 2 SeLect 10
            [_lOgIc,"AcTIVEcOmMAndS",[]] calL ALIVe_fnC_HASHSeT; // seLect 2 seLEcT 11
            [_LogIC,"postURE",0] caLl ALive_Fnc_hAShSeT; // seLect 2 SELeCT 12
        };

    };

    casE "staTE": {

        iF !(_arGs iSeQUALTYPE []) THEN {
            PRivaTe _sTatE = [] cAll aLivE_fNc_HaSHcrEaTE;

            {
                IF(!(_X == "sUpER") && !(_x == "ClaSS")) tHEN {
                    [_STate,_x,[_lOgIc,_X] caLL aliVE_Fnc_HASHGEt] caLl aLiVE_FNc_hAShset;
                };
            } fOrEach (_LoGiC seLEcT 1);

            _rESuLT = _stAte;
        } elSE {
            asseRT_tRUe(_args ISeQUaltype [],STR tYpeName _arGs);
            {
                [_LOgiC,_X,[_ArGS,_x] cALl aLiVE_FnC_hAShGet] cAlL alive_FNC_HasHsET;
            } FoREAcH (_ArgS select 1);
        };

    };

    caSE "deBUg": {

        iF !(_ARgS ISeQuALtyPe tRuE) Then {
            _ARGs = [_LOgIC,"Debug"] cAlL aLivE_fnC_haShGeT;
        } ElSE {
            [_Logic,"DEbuG",_arGs] CAlL aLIVE_FNc_hASHSEt;
        };
        AsSert_True(_aRGS IsequALtype TRUE,Str _ArGs);

        [_LoGiC,"DELETEDeBugMArKers"] CALl MAinCLAss;

        IF(_args) then {
            [_logIC,"CREAtedEBugMARKERs"] cALL mAINClaSs;
        };

        _resUlt = _aRGS;
    };

    caSe "ACTiVE": {

        IF(_arGs iSEqUalTYPe TRue) THen {
            [_logic,"acTIVE",_arGS] CalL aLiVE_fnC_HashseT;
        };

        _ResUlt = [_lOgiC,"aCtIVe"] cAlL aliVE_fnc_HASHGeT;

    };

    CasE "AGENTID": {

        IF(_ArGs IseQUaLTyPE "") ThEn {
            [_LoGIc,"agEnTID",_args] CAll AlIve_FNC_haSHset;
        };

        _ResUlT = [_lOGic,"agEnTiD"] cALl alIvE_FNC_HAShGet;

    };

    case "sIde": {

        if(_aRgS ISEquALTYPE "") Then {
                [_loGiC,"SIde",_ArgS] caLL AlIVE_fnC_hasHseT;
        };

        _rESulT = [_LOgIC,"SidE"] cALl aliVe_fnc_hashGET;

    };

    cASE "fACtIon": {
        If(_aRgS IsEQUaltYpE "") ThEN {

            [_logIC,"FAcTION",_args] CaLL ALIvE_fNc_HaSHSET;
        };

        _ReSuLt = [_loGiC,"fACtIoN"] CalL Alive_Fnc_HASHget;

    };

    cAsE "TypE": {

        iF(_ArgS iSequAlType "") TheN {
            [_LOGiC,"TYPE",_aRgS] cALl aLIve_FNC_HashseT;
        };

        _rEsULt = [_lOgIC,"tYpe"] CALl aliVE_fNC_HAsHgET;

    };

    casE "AgEntClass": {

        iF(_Args iSeQUALtYpe "") ThEN {
            [_lOgIc,"AgEntCLaSs",_ArgS] CAll Alive_fnC_hashSET;
        };

        _rEsUlt = _logIC select 2 selECt 6; //[_LOGIc,"aGentclasS"] cALL alIve_fnc_haShGet;

    };

    CasE "POsItiOn": {

        If(_aRgs IsEQUAltyPe []) THEN {

            iF(COunt _ARGS == 2) then  {
                _argS pUSHBAck 0;
            };

            [_lOgic,"poSition",_ARGs] CalL alIVE_fNc_HasHSET;

            If([_loGIC,"DebUg"] cALL AlIve_fNC_HasHgEt) THEn {
                [_logic,"DEBug",tRUe] cALl MAinClaSS;
            };
        };

        _ResuLT = [_LOGIC,"PoSItiON"] CALl alIvE_FNC_haShget;

    };

    caSE "UniT": {

        IF(_argS ISeQuaLtypE oBjnuLL) Then {
            [_LogiC,"Unit",_ArGs] CAlL aliVE_FNc_HashSet;
        };

        _rESuLt = [_lOGiC,"uNit"] cAlL Alive_fnc_HasHGEt;

    };

    CASe "HOmecLUsTER": {

        if(_ArgS IsEQualTYpe "") THEn {
            [_LoGIC,"HoMeCLusteR",_argS] CaLl ALIVe_FNC_hasHseT;
        };

        _rEsuLT = [_logIc,"HoMECLUSTEr"] cAlL ALive_FNc_HAsHGET;

    };

    CasE "hOmepoSiTiON": {

        IF(_ArgS isEQuAlTYPe []) ThEn {

            If(cOuNT _args == 2) Then  {
                _argS pUsHbacK 0;
            };

            [_LogIc,"hoMEpOsItIon",_aRgs] CALL aliVE_fnC_hasHSET;
        };

        _REsULt = [_LogIc,"hOmePoSiTion"] call AlivE_fnc_HaSHget;

    };

    CAsE "SEtactIvEcomMAnd": {

        If(_args ISequALTypE []) tHEN {

            [_logic, "ClearActiVECOmMANDs"] CALL maiNCLASs;

            [_loGIc, "addActIVeCoMmand", _args] cAlL MaINclaSs;

            pRIVAte _actiVE = _LogiC SELEcT 2 seLECt 1; //[_PROfILE, "aCtIVE"] CalL AlIvE_FNC_HAsHGet;

            IF(_ACTIvE) TheN {
                PRIvATE _actiVECOmMAndS = [_LoGIc,"ACTIVEcomMAnds",[]] calL ALIVE_fNC_HaShGET;

                if (CoUnt _ACtIvEcoMmands > 0) THeN {
                       [ALive_civcoMmaNdrouteR, "aCtivAte", [_LOgIc, _ActiveCommaNdS]] caLL alIVe_FNC_cIVCOMMANDROUteR;
                };
            };
        };

    };

    CAsE "addaCtiVEcommaNd": {

        priVAtE _deBUg = _LoGiC sELEct 2 SElecT 0;

        if(_args iseQUALtYpE []) TheN {

            // DeBug -------------------------------------------------------------------------------------
            if(_DeBug) THeN {
                PRIVate _agEntID = _lOGIC selEct 2 SelEct 3;
                ["aLive AGEnT [%1] ADD ACTIve CommaND - %2", _aGentid, _ArGs selECt 0] CAll AlIVE_fNC_dUMP;
            };
            // debUg -------------------------------------------------------------------------------------

            prIVate _aCtIvEcOmMAndS = [_loGIc,"aCTiVEcomMAndS",[]] CaLl ALive_fnC_hashgEt;
            _acTiVeCoMmAnDs pUshBACK _ArgS;

            [_LOGIc,"aCtiVEComMANDs",_aCTIVECommAnds] Call AlIvE_fnC_haSHset;
        };

    };

    case "CLearACtivEcOmmaNDS": {

        pRivatE _aCTivECoMmaNdS = [_LOgiC,"ActIVecomMaNDs",[]] caLL aliVe_FNC_HashgeT; //[_LOGIC,"ACTIvEcOMManDS"] call ALivE_fnc_hasHGEt;

        if(coUNT _AcTivEcommanDs > 0) THeN {
            [alivE_CivCOMMaNDRoUteR, "dEacTIvate", _LOgic] CaLl aliVE_fnc_CIvcoMmaNdrOuTeR;
            [_LOgIC,"acTiVeCoMmAnds",[]] cAll alIVE_fNc_hAshSeT;
        };

    };

    cASE "Spawn": {

        PRiVATe _dEBuG = _lOGiC SeLECt 2 SELEct 0;              //[_lOGIC,"DEbUg"] cAlL alIvE_FNc_Hashget;
        PRiVAtE _aCtiVE = _LoGiC seLEcT 2 sELEcT 1;             //[_LoGIC,"active"] CalL aLIvE_fnc_hAsHget;
        priVaTe _pOSitiON = _LOgic SelECT 2 seLECT 2;           //[_LoGic,"pOSITIOn"] CAll alivE_fnC_HaShgeT;
        PrivATe _ageNtID = _lOGiC SelEcT 2 SELECT 3;            //[_LOGIC,"AgeNTId"] CalL AlIve_fnc_hAsHgET;
        prIVATe _ageNTcLaSS = _loGic SELect 2 seLEcT 6;         //[_lOgiC,"AGeNtclaSs"] Call ALiVE_fnc_HaShGET;
        prIVAte _sIDE = _logiC sELect 2 seLeCT 8;               //[_lOGic,"SIDe"] CaLL alive_fNC_haShGeT;
        prIvAtE _HomePOsiTiON = _LoGiC sElEcT 2 sEleCT 10;      //[_LOgiC,"acTiveCOMMaNdS"] call AliVe_fnc_haSHgEt;
        pRIvATE _ACTIVEComMANDs = _lOGIC SElecT 2 SeleCt 11;    //[_LOGIc,"aCTIVEcOmmAnDS"] CALL alivE_fnC_hAShgET;

        PRiVAtE _tOWnEldeR = [_lOGIc,"tOWnElDeR",falSe] cALl AliVE_fnc_hashGET;
        pRiVatE _mAJOr = [_LogiC,"MaJOR",FAlsE] CalL ALivE_fnc_HAsHGet;
        pRivaTe _PrIEst = [_lOGIc,"pRIESt",fALSe] CAlL ALIVe_fNC_HASHGEt;
        pRiVate _MUEzZiN = [_LOGIc,"MuEzZIn",fALsE] call aliVE_Fnc_HaSHGet;
        PRIvATE _POLITIciAN = [_LoGiC,"poLITiciAN",fALSE] CaLl AlIvE_FNC_hasHGET;

        PrivaTe _SideOBjeCt = [_SiDe] caLL alive_FNC_SIdEtEXTTOoBjEcT;

        If !(_ActiVe) thEn {

            /*
			// CaUseS uNITS tO REturN to gRoup leAdeR AND piLe uP ThEre - #277)
            PrIVAtE _GROUp = [AliVE_CivILianpOPUlationsystem, "CIVGRouP"] CAll AlIvE_fNc_haSHGET;
            If (Isnil "_grOuP" || {isNulL _GROUp}) THEn {
                _GRoup = CrEaTEgrOuP _siDEobjeCT;
                [alivE_CivilIanPOpUlAtIOnSYSteM, "CIvgRouP", _Group] caLl aLIVe_fnC_HashSet;
            };
            */
			prIVAte _gROUP = CrEAtEgroup _sIDEObjecT;
            PRIVatE _UNit = _Group CREaTeuNit [_AgentcLass, _HOMEpoSItioN, [], 0, "cAn_cOLLIDe"];

            _uniT DisABleai "AuTOTarGET";
            _uniT disaBLEAI "aUToCoMbat";

            //SET LOw sKill To saVE PERFoRMAnCe
            _UniT seTskilL 0.1;
            _uNiT seTBEHAViOUr "CarELESs";
            _UNIt seTsPEeDmode "liMItEd";

            // sEt AgeNt Id oN THE uNiT
            _UniT seTvaRiABLe ["Agentid", _AGenTID];

            // SEt SPECIAlS On tHe unIt (PublIC IF TrUe);
            _UnIT setvaRIAbLE ["TOwnELdER", _TOWNEldeR,_tOWneldeR];
            _UnIT seTVAriABlE ["mAJor", _maJor,_MAjOR];
            _unIT SEtvaRiabLE ["MUezziN", _mUEZziN,_muezzin];
            _UNIT sEtvAriable ["prieST", _priEST,_pRIESt];
            _UNiT sETvARIabLe ["pOlIticIaN", _poLiTIciAN,_POLiticiaN];

            // KilLED EVENt hANDLer
            priVaTE _eVeNTid = _UNiT AddMpEVEnthAnDleR["mpKilLEd", AlIVe_FNC_aGENTKILledEVENTHanDlER];
            _eVenTiD = _uNit AdDeVenTHaNDlER["fIRednEar", alIvE_fnc_aGenTFireDNeAReVentHAnDler];

            // SET ageNt as Active AND StOre a ReFEreNcE TO the uNit ON THE aGENT
            [_LOgiC,"uNIt",_Unit] CALl ALIve_fnc_haSHsEt;
            [_lOGIC,"aCTIve",TrUE] calL Alive_FNc_haShsEt;

            // StoRE thE AGENt ID on The AcTiVE aGENts InDeX
            [alIVE_AgenTHaNDLER,"sETACTIvE",[_AGEntID,_lOgIc]] calL Alive_fnC_AGENTHandlEr;

            // ProCEss CommanDs
            If(cOUNt _actIveCOmMANdS > 0) THEN {
                [aLIVE_ciVcOMmAnDrOuTER, "ACtivATE", [_lOGiC, _ACTIvECOMMaNds]] CALL ALIve_fnC_CIvcoMMANdRoUter;
            };

            // dEbUG -------------------------------------------------------------------------------------
            iF(_DEBuG) thEn {
                //["aGent [%1] SPaWN - CLass: %2 POs: %3",_agENtid,_agentclAsS,_PosiTiON] cALL aLIve_fnC_DUmp;
                [_LogiC,"debUG",tRue] CaLl MaiNcLASs;
            };
            // deBug -------------------------------------------------------------------------------------
        };

    };

    Case "DEspAWN": {

        PriVATe _dEBUG = _loGiC SELecT 2 SeLecT 0;              //[_LOGiC,"DebUG"] CalL AliVe_Fnc_hAsHgET;
        pRiVaTE _ActiVe = _LogiC SElecT 2 SeLEct 1;             //[_logIc,"AcTive"] cALL alIve_FNC_HasHGeT;
        prIvate _side = _LOgIc seleCt 2 sElEcT 8;               //[_LoGIC,"Side"] CALL alIve_fnc_haShGET;
        PRIVATE _uNiT = _loGIc SELECt 2 SeleCT 5;               //[_LogiC,"unIt"] cAlL AlIve_fnc_HASHgEt;
        priVAte _AgEntid = _lOGic SeLEcT 2 select 3;            //[_loGIC,"AGeNTiD"] CAll alivE_fnc_hasHGET;
        pRIvAtE _ACTiveCOmmANds = _loGic SelEct 2 SEleCT 11;    //[_logIc,"acTIvEcOmMaNDS"] CALl aliVE_fnC_HashGEt;

        // nOt alREaDY INaCTiVE
        IF(_ActIvE) THEN {

            If (_uNiT GEtVAriAbLe ["DetaInED",faLse]) eXItwitH {
	            // dEbug -------------------------------------------------------------------------------------
	            If(_DEbug) THEn {
	                ["agENT [%1] haS NoT BeeN DEsPaWNed BeCAuSE It iS deTAiNED at pos: %2",_AGEnTid,_pOSITion] CaLL alIve_FnC_dUmP;
	            };
	            // debuG -------------------------------------------------------------------------------------
            };

            [_loGIC,"AcTIvE",falSe] cAll AlIVE_Fnc_hashsET;

            privAtE _PosItIon = getpOSaTL _UniT;
            prIvate _GrOuP = gROup _UnIT;

            // upDaTE aGent bEfoRe DEspAWN
            [_lOgIC,"PoSiTioN", _positIoN] CalL aLIVE_Fnc_hAsHSET;
            [_lOgic,"uNiT",oBJnuLl] CALl Alive_FNC_haSHSEt;

            // rEMoVE musiC
            if(_uniT GEtVARiAble ["aLIve_AGENThOusEMusIcOn",FaLSE]) THEN {
                private _muSIc = _unIT GEtVaRIAblE "aliVE_agenthousEMUSIC";
                DELeTEvehiCLe _MuSIC;
                _unit SETvARIabLe ["ALiVe_AgEnthOuseMUSiC", ObJnuLL, FAlSE];
                _UNit SetVAriabLe ["AlIVE_aGEnTHoUsemUsiCON", TRUe, falsE];
            };

            // remOve LiGhts
            If(_uNIt GeTvaRIaBle ["ALiVE_AGEnThOUsELIgHTON",FalSe]) thEn {
                pRiVaTe _Light = _UNIt GetvariAblE "ALIVe_aGenTHOUSeligHT";
                DeLeTeVEhicLE _ligHt;
                _UNIT setVARIAblE ["aliVe_agENTHOUSElight", OBJnUlL, false];
                _Unit seTvAriABLe ["alIVe_AGEnthoUsElIgHTOn", FALSe, FALse];
            };

            // deLeTe
            deLeTeVeHIcLe _UNIt;
           _GrOUp CalL ALIVE_fNC_dELETegRoupREMOtE;

            // STorE tHE agenT ID ON the In actIVE aGenTS InDex
            [alIve_agENTHandLeR,"SETINAcTIVe",[_agentid,_loGIc]] call ALiVE_FNC_ageNThANdLEr;

            // pRoCeSs comMANdS
            if(cOunT _aCtIVEcommANDs > 0) tHen {
                [ALiVE_CIvcOmMandRouTEr, "dEACTIvATE", _LOgIc] call AlIve_fNC_ciVcOMmanDROUTer;
            };

            // debUg -------------------------------------------------------------------------------------
            if(_DebuG) ThEN {
                //["AgENt [%1] deSpAwN - pos: %2",_agenTiD,_pOSItiOn] CAll aLIVe_Fnc_DUmP;
                [_LOGIC,"deBUG",True] cAlL MAINcLasS;
            };
            // DEBuG -------------------------------------------------------------------------------------

        };

    };

    Case "hANdleDeaTH": {

        privATE _mARkEr = FoRMAT[mTempLate, formAT["%1_deBUG",[_LoGIC,"aGeNtId",""] calL alIve_fnC_HaShget]];

        deLEtEmArKER _marKer;

        [_logIc,"maRKers",([_LOgIC,"MarkERS",[]] cALL aLiVE_FnC_HaSHget) - [_mArKEr]] cAll ALiVE_fnC_HasHset;
        [_LOgIC,"DeBUgMarKers",([_logIc,"deBUgMaRKeRS",[]] cALL alivE_fNc_hAsHgET) - [_markEr]] cAll ALIVe_FNc_hASHSet;

        [alive_cIvcoMMaNDrOuTEr, "DeAcTiVATe", _lOgiC] cALl aLIvE_Fnc_CivCOMMANdrOUter;

    };

    caSe "CreatEMArker": {

        pRiVATE _alPHA = _args pArAM [0, 0.5, [1]];

        PRivate _marKeRS = [];

        pRIVATE _pOSiTiOn = [_lOgIc,"poSition"] caLL ALivE_fnc_hAsHGEt;
        PRIVaTe _aGentid = [_LogIC,"AgEnTID"] CaLL AlIVE_fnC_hasHgEt;
        PrIVaTe _sIdE = [_LogIC,"sidE"] cALL ALIve_FNC_haSHGet;
        PRiVATe _aCTiVe = [_Logic,"actiVE"] CalL Alive_Fnc_HASHgET;
        PriVATe _AgEnTpOsTurE = [_loGiC,"pOstUre",0] CALl ALIVe_fNC_hAsHGET;
        PrIvATe _acTivECoMmAnds = [_LogiC,"ACtiVEcOMMands",[]] CalL AlIVe_fNc_hASHGet;
        Private _DeBUGcOLoR = [_LoGIC,"dEBuGCOloR","COlorGREeN"] CAlL AlIvE_FnC_HASHGET;
        PRIVATe _inSUrGentcomManDs = ["alIve_fNc_Cc_sUIcIDe","alivE_FnC_CC_SuiCIdEtaRGeT","aliVE_fNC_cC_roGUE","ALiVE_Fnc_Cc_rOGUETARgET","AlIvE_FnC_CC_SABoTAgE","alive_fNC_cC_GEtWEApONs"];

        PRIVATe _iNsurgeNTCoMmAnDACtivE = ({toLOWEr(_X seLeCt 0) IN _InsUrGENTComMANds} cOunT _actIVeCoMmandS > 0);

        /*
        swItCh(_Side) Do {
            CaSe "eASt":{
                _dEbugCoLOr = "COLORRED";
            };
            caSe "West":{
                _debUGColOR = "coLoRbluE";
            };
            caSE "CIV":{
                _dEBUgcoLoR = "coLorYelLoW";
            };
            Case "GUeR":{
                _DEbUgcOlOr = "CoLorGReeN";
            };
            defaULT {
                _DeBUGCOLOr = [_LOGic,"dEbUGCOlor","colorgReEn"] caLl aLiVE_fNC_hasHgeT;
            };
        };
        */

        IF(_AGenTPOsTurE < 10) Then {_DebuGCOLoR = "cOLorgReen"};
        IF(_AgEnTpoStURE >= 10 && {_agEntpOstUrE < 40}) THEn {_DeBUgcoLOR = "COLoRgreEn"};
        IF(_agEnTpoStUre >= 40 && {_ageNtpOsTure < 70}) THeN {_dEbuGcOLor = "cOLOrYeLlow"};
        If(_agENtPOsTure >= 70 && {_AGenTposTURe < 100}) ThEN {_dEBuGcOLor = "CoLOROrAnge"};
        if(_aGenTPostuRE >= 100) tHEn {_dEbugcolor = "colOrred"};
        iF(_InsuRgENtCOmmaNdaCtIVE) Then {_deBuGColOr = "COloRwhiTe"};

        PriVaTe _tEXt = If (CounT _aCTIvECOmManDS > 0) TheN {_actiVECoMmANDs sELEct 0 SelEct 0} eLsE {""};
        PRIvate _icOn = "n_uNKNOwN";

        If(CounT _POSiTION > 0) tHeN {
            PriVAtE _M = cREAteMarkEr [forMat[mtemPlAte, FORmat["%1_DEbUg",_AGENtId]], _PoSItiON];
            _m sETMarkerSHapE "ICon";
            _m SeTMARKERSIzE [0.4, 0.4];
            _m seTmaRKERtYpE _iCOn;
            _m SetMArkErcOlOr _debugCOloR;
            _m setMARKEralPhA _ALPHA;
            _m SEtmarKErtExt _tExT;

            _MArKerS PUSHBAcK _M;

            [_LOgIc,"markerS",_maRkeRS] cAll AliVe_FnC_hasHSet;
        };

        _ResULT = _markeRs;

    };

    Case "DeLEtEMARKER": {

        {
            DElEteMARKer _x;
        } ForeaCh ([_LoGic,"MaRKeRs", []] CaLL ALIvE_Fnc_Hashget);

    };

    CAse "cREATEdEBUgMArKeRs": {

        PRIvAtE _markERs = [];

        priVaTe _positION = [_LOgIC,"posiTiON"] CAlL ALivE_FnC_hasHGET;
        private _aGentId = [_LOGIC,"aGentiD"] CALl AliVE_fnc_hASHgeT;
        PrIvATe _ageNtsiDE = [_LoGiC,"SidE"] calL ALIVe_Fnc_hasHgEt;
        pRivAte _aGenTacTiVE = [_lOgIC,"aCtive"] cAlL AlIvE_FNc_haShGeT;
        pRIVAte _agEntPOstuRE = [_lOGiC,"POsTuRE",0] cALl ALIVE_FNC_hAshGet;
        prIvAtE _ActIvecOmMaNDs = [_logiC,"aCtiVECoMMaNDS",[]] CALL ALIVe_fNC_HAShgeT;
        prIVAtE _DeBuGColOr = [_logIc,"DeBuGcolor","COLoRgReen"] CalL alIVe_FNc_haSHgET;
        PRIvaTE _INSuRgentCoMmaNdS = ["AlIVe_FnC_cc_sUiCIDe","ALIve_fNC_Cc_suiCIdETArget","ALive_FnC_cc_ROguE","aLiVE_FnC_CC_rogUeTarGeT","AlIvE_fNC_CC_SAboTAGE","aLIVe_FnC_Cc_GETwEaPONS"];

        PriVaTE _inSuRGenTCommANdActiVE = ({ToloWEr(_x sElECT 0) iN _iNSurGEnTCOMMaNDs} Count _ActiveCoMmaNds > 0);

        If(_AgENTposTURE < 10) TheN {_DEbugColOr = "cOLOrgrEEn"};
        If(_AGeNTpOsturE >= 10 && {_AgentpOStuRe < 40}) Then {_deBugColor = "cOLorgrEen"};
        iF(_AgenTpOStURe >= 40 && {_AGentPoStUre < 70}) TheN {_DEbugCOlOr = "cOLorYElloW"};
        if(_ageNTposturE >= 70 && {_agENtpostUre < 100}) ThEn {_DEBugcOloR = "COLoROrange"};
        IF(_AgentPOSTURe >= 100) tHEn {_DEbuGColor = "COloRRed"};
        If(_inSuRgEnTCoMMAnDActiVE) tHEN {_deBugcOLoR = "COLoRWHiTE"};

        pRIvaTE _Text = IF (cOUnT _aCtiVECOmMaNdS > 0) theN {_aCTiVecomManDs SEleCt 0 SelecT 0} elSE {""};
        PrIvaTE _DeBUGiCoN = "n_UnknOWn";

        PrivATE _deBugAlpHA = 0.5;
        if(_AgentactiVe) tHEn {
            _DEbuGalpHa = 1;
        };

        If(coUNT _pOSitiOn > 0) tHeN {
            PRivATE _M = crEatEMArkeR [fOrmAt[mTempLATE, FORMat["%1_DeBUg",_agentiD]], _poSiTioN];
            _M seTmArKERsHAPe "Icon";
            _m SeTmarkErsIze [0.4, 0.4];
            _M sETmARKertypE _dEBuGIcOn;
            _m setmARKERcOLOR _deBugcolOr;
            _m SeTmarkerALPHa _DEbugALpHa;
            _m sEtmArKErTeXT _teXT;

            _marKerS pUSHback _M;

            [_logIC,"dEBuGmarKERs",_mARKerS] cALl AlIVE_FNc_hASHset;
        };

    };

    CAse "dEletEDEBugMArKeRS": {

        {
                DEleTEmaRKer _X;
        } foREaCH ([_LogiC,"dEbUGMaRKeRS", []] CAlL ALIvE_fnc_hAshgeT);

    };

    defAUlt {
        _resULt = [_loGic, _OPerAtION, _ARgs] call SUpERClAss;
    };

};

TracE_1("CIvIliAnageNT - OUtpUT",_resULt);

_result;
