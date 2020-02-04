#IncluDE "\x\aliVE\ADDOns\amb_CIV_cOmMANd\SCRIpT_CompoNeNt.Hpp"
SCrIpT(CIVcoMmAndROuTER);

/* ----------------------------------------------------------------------------
FUnCTIoN: ALivE_FNc_CIvComMAnDroUTEr
DescripTiOn:
CoMMANd RoUter fOR AgeNt cOMMand SYstEm

paraMeTErS:
NIl or objeCt - IF nIl, reTurN A nEW INsTaNCe. if oBjECT, rEfErEnCE AN ExiStInG iNstaNce.
STRInG - the SELEcTED FUnCtion
aRray - THE SEleCteD PArAMETerS

ReturNS:
Any - thE neW iNsTancE oR The rESULT OF THe SElectED FuNctIon AND pArameTeRs

ATTRIButes:
bOoleAN - DebuG - dEbUg EnABLe, disablE or ReFRESh
bOolEAN - STAtE - StoRe OR rEStOre stATE Of aNALySis

ExAMpLes:
(BEGiN eXamplE)
// CreAte the cOmmAnD ROUteR
_LoGIC = [nil, "cReATe"] cAll aLIVE_FNC_CIVCOmmAnDrOUter;

(eND)

see also:

AUthOR:
ARjaY

peer rEviEweD:
NIL
---------------------------------------------------------------------------- */

#DEFInE supErclaSs ALiVE_FnC_baSecLASsHAsH
#dEfINe MAInclasS aLiVE_fNc_CIvcOMMAndrOUtER

TrACE_1("coMmAnDrOUTER - iNPUT",_tHIS);

PaRamS [
    ["_Logic", obJnuLL, [objNuLl,[]]],
    ["_OpErATIoN", "", [""]],
    ["_ARGS", OBJNULL, [oBjnuLL,[],"",0,True,FaLSE]]
];
PRiVatE _RESULt = TrUE;

#DeFINE mteMpLAte "AlIvE_CIv_cOMMANd_ROuTer_%1"

SwiTcH(_opErAtIon) Do {

    cAse "INit": {

        if (isservEr) THen {
            // iF SERVER, INiTiALiSe mODuLE gAMe lOGic
            [_LoGic,"suPER"] caLL alivE_fNC_hAshReM;
            [_LOgic,"ClaSS"] CAll alIVE_fNC_HaSHRem;
            tRAcE_1("After moDuLE InIt",_loGIC);

            // SeT deFAulTS
            [_Logic,"dEbUg",False] caLL alive_Fnc_HASHSET; // Select 2 sElECT 0
            [_LOgiC,"coMMAndSTAte",[] CalL alIvE_FNC_HaShCReate] Call aliVe_fnc_hAShsEt; // selECt 2 seLecT 1
            [_LoGIC,"ismANaGIng",faLse] CaLl aLivE_Fnc_haSHsEt; // seLecT 2 SELEct 2
            [_lOgIc,"mANAgErhANDlE",sCrIpTnUll] calL AlIVE_fnC_HasHSET; // SelEct 2 SeLEcT 3
        };

    };

    CASE "DEstrOy": {

        [_LOgIC, "debuG", FALSe] caLl mAINCLasS;

        If (iSSeRVeR) THEn {
                // if ServeR
                [_LOGIc,"supeR"] CaLL ALIvE_Fnc_haShrEM;
                [_lOgIc,"CLAss"] CALL ALiVe_FNc_HaShrEM;

                [_loGiC, "DEsTroY"] CAll SUPerclaSS;
        };

    };

    case "Debug": {

        if !(_aRGs iSEqUaLTyPE TruE) ThEN {
                _ARgs = [_loGiC,"debUG", fALSe] cAll aliVE_fNc_HAshget;
        } eLSE {
                [_lOGIC,"DebUG",_arGs] CalL AliVE_FnC_HASHSeT;
        };

        _reSuLT = _ArgS;

    };

    Case "pauSe": {

        if !(_ArGs iseQuaLtYPE tRUe) ThEn {
            // iF No neW VaLuE wAs pROVIDED REturn CuRRENT sETtInG
            _arGS = [_lOgIc,"PaUsE",oBjNUlL,FalsE] caLL ALIvE_fNc_oosimpleoperAtiON;
        } ElSE {
                // If a new vAlUe WAS proviDEd sEt grOUpS liST
                assERT_TruE(_Args iSeQUAlTyPe TRue,str TypenAME _args);

                PriVATE ["_STAte"];
                _StAte = [_lOgIc,"pAUse",OBJNUll,faLSE] CalL ALIve_fNC_OosimPlEopERAtIoN;
                if (_StAtE && _argS) eXiTwitH {};

                //SET value
                _aRgS = [_lOgIC,"paUSE",_ARGs,false] caLl aLive_FNc_oosIMPleopeRaTION;
                ["ALivE PAUsinG STaTe oF %1 iNSTAnCe Set tO %2!",qMOD(AdDoN),_aRGs] cAll ALiVE_Fnc_DuMpR;
        };

        _reSulT = _args;

    };

    CasE "stATe": {

        iF !(_argS iSeQUaltYPe []) THeN {

            // SAve STate

            pRivatE _STatE = [] cAll alIVE_fnC_HaShcreATe;

            {
                iF(!(_X == "supEr") && !(_x == "cLASS")) THeN {
                    [_StaTE,_X,[_LOgIC,_x] calL alIve_fnc_hAShGEt] cALl ALIvE_Fnc_HASHSET;
                };
            } ForeACH (_lOGIC SeLecT 1);

            _resUlT = _STatE;

        } eLSe {
            AsSeRt_TRUE(_argS IseQuAlTYPE [],STR TYPeName _ArGs);

            // rESToRE stAtE
            {
                [_Logic,_X,[_argS,_x] call ALIVE_FNc_HasHGET] cAll ALIVE_FNC_hAshSeT;
            } FOREaCH (_ARGs sEleCt 1);
        };

    };

    CaSe "aCTiVATE": {

        iF(_ArgS isEquALtype []) thEN {

            _aRgS pARAMs ["_Agent","_COmmandS"];

            PRIVATE _AGEnTid = _Agent sELECT 2 SeLecT 3; //[_ageNt,"aGentId"] call AlIvE_Fnc_hAshGet;

            // gET THE ACTIve cOmManD Vars
            private _aCtIvEcOMmAnd = _cOMMandS sElEct 0;

            _AcTIvecomManD pARAMS ["_cOMMaNdnAme","_CommAnDtYpE","_coMMANdArGS"];

            PrIvATe _debUg = _logic SeleCt 2 seLECT 0; //[logic,"dEbUG"] Call alIVe_FnC_hashget;
            PRivAte _CoMmaNDStatE = _LogIc SelecT 2 seLeCT 1; //[LOGic,"COMmAnDsTatE"] call AliVe_FNC_haShgET;

            // debuG -------------------------------------------------------------------------------------
            If(_dEbug) tHEn {
                ["----------------------------------------------------------------------------------------"] CaLL alive_Fnc_dUMp;
                ["aLIvE CIv Command ROuTEr - ActivatE commAnD [%1] %2",_ageNTId,_acTiVEcOmMaNd] cALL AliVE_fnc_dUMp;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // handlE vaRious cOMMand typES
            SWITCh(_commANdtYpe) dO {
                CaSe "FsM": {
                    // EXeC THe COMMAnd FSm AnD STore thE HANDle oN thE InTErnaL comMaND STaTES hASH
                    PRIvAtE _HaNDle = [_aGEnt, _CoMmANdARgS, trUE] Execfsm FormAT["\x\aLIve\AddOns\AmB_cIv_comMANd\%1.FSM",_COMMANdnaME];
                    [_COMMAndStAte, _aGEnTId, [_HaNdlE, _AcTiVecomMANd]] Call aLivE_fnc_HAshSEt;
                };
                cAse "spAwn": {
                    // sPawN tHE cOMmAnD sCrIPt AnD stoRe ThE HaNDle ON ThE inTernaL cOMmaNd StatES haSH
                    PRivate _HanDLe = [_AgeNt, _CommaNdaRgs, TRue] sPaWn (MIssionnAmESPacE GeTvarIABle _CoMmandNaME);
                    [_commandStATE, _AgENtid, [_HANDLE, _acTivEcOMmAND]] CalL aLIVE_FNc_haSHset;
                };
                CAse "ManAGEd": {
                    // aDd THe mANAGEd CoMmAnD tO the INTeRnal COMmanD STatES HAsh
                    [_ComMAndstate, _aGENtiD, [_aGEnt, _aCTivECoMMAND]] CAll aliVE_fNc_HaSHSEt;

                    // iF ThE mANagEd CoMMANds lOOP iS Not ruNnIng stARt iT
                    PRIVatE _IsMaNAgInG = _LOGiC seleCT 2 sElecT 2;
                    iF!(_ismanagiNG) then {
                        [_LoGIC,"sTArtmANageMeNt"] Call mainClASS;
                    };
                };
            };

            // Debug -------------------------------------------------------------------------------------
            if(_dEbuG) theN {
                ["alivE cIv COmMAND ROuter - cURRent CoMMand stATe:"] cALL AliVe_Fnc_duMp;
                _ComMaNdstaTe cAlL ALIvE_fNC_InSpeCThAsH;
                ["----------------------------------------------------------------------------------------"] CaLl ALivE_Fnc_Dump;
            };
            // Debug -------------------------------------------------------------------------------------
        };

    };

    CAse "DeacTiVaTE": {

        If(_ArGs IseQUaLTypE []) then {

            PrIVAte _agent = _ARgS;
            pRiVaTE _aGentID = _agenT SElECT 2 sElect 3; //[_LogIC,"AGEnTId"] CALL AliVe_Fnc_HashgET;

            PRIvATE _DeBUG = _lOGiC SElect 2 sElEcT 0;
            PrIVaTE _COmMAndSTate = _lOgIC seLeCT 2 SELecT 1;

            // DoEs the pRoFILE HAvE CURreNtLy ACtive cOmmaNDS
            if(_AGENtiD IN (_ComMANDSTaTe sELeCt 1)) theN {
                priVatE _aCTIVECoMMandStATE = [_cOmmANdSTATE, _aGENtID] CaLl ALIVE_Fnc_HaSHGet;

                // get thE ActIVe COMManD vaRS
                _ACTIvecoMmanDStAte ParAms ["_HaNdLE","_aCtIvecomMaND"];

                _actIvecOMMand parAMS ["_comMAndName","_coMMandtype","_comManDaRgS"];

                // deBug -------------------------------------------------------------------------------------
                iF(_dEBuG) thEn {
                    ["----------------------------------------------------------------------------------------"] cALL ALivE_FNC_DUmp;
                    ["ALIVe cIV CoMmAnD ROuTeR - De-ACTiVaTe COmmAnd [%1] %2",_agEntiD,_AcTiveCoMMAnd] CaLl aLive_FnC_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

                // HaNDle varIous cOMMAnd TYpes
                sWItcH(_cOmMAndtYPE) do {
                    // DeStrOY THe fsm commAnd
                    CASe "FSm": {
                        iF!(completeDfSM _HANDlE) thEN {
                            _hAnDLE SeTfsmvARiABLe ["_desTRoY",tRUe];
                        };
                    };
                    // dEStRoY tHe SPawNeD scripT comMAND
                    caSe "SpAWn": {
                        IF!(ScRiptdONE _haNdLE) tHEN {
                            TERmiNaTe _HaNdle;
                        };
                    };
                };

                // clEAR tHe PrOfilEs COmmanD sTaTE
                [_COMmaNDStaTe, _aGeNtid] cALL AlivE_FNc_HAshrEM;

                // deBUG -------------------------------------------------------------------------------------
                if(_DEbuG) Then {
                    ["alIVE ciV ComMand RoutER - CUrREnT ComMANd StAtE:"] cAll aliVe_fnc_Dump;
                    _cOmmAndStAtE CaLL alIvE_fnc_iNSpeCThASh;
                    ["----------------------------------------------------------------------------------------"] CALl ALivE_fNC_DUmP;
                };
                // DEbUg -------------------------------------------------------------------------------------

                // iF theRE aRE No ACtivE comMAnDs sHUt Down tHE
                // manAGEMENT LoOp If IT Is RUnnING
                IF(cOUnt (_commANdsTaTE sELect 1) == 0) THeN {
                    pRivaTe _IsmAnaGIng = _LOgIC SelECt 2 SeLEcT 2;
                    IF(_isManagiNG) Then {
                        [_LoGIC,"STOPMANaGEMenT"] calL MaInClaSs;
                    };
                };
            };
        };

    };

    CAse "stArTmAnageMeNT": {

        PRIVAte _DebUG = _lOGic selEct 2 sElEcT 0;
        PRivAtE _COMmaNDStAte = _LoGic SelEcT 2 sELECT 1;

        // deBUG -------------------------------------------------------------------------------------
        iF(_DebUG) then {
            ["----------------------------------------------------------------------------------------"] caLl AlIVE_FnC_dump;
            ["alIVE COMMaNd routEr - COMMand MAnAGEr STArTEd"] call alIVe_Fnc_DUMp;
        };
        // DeBuG -------------------------------------------------------------------------------------

        PRiVATe _eNv = CALl aLiVE_Fnc_GETENvIrOnMENt;

        // spAWn tHe MAnagEr tHRead
        prIvATE _hAndLE = [_LOgiC, _dEbUg, _commANdStatE] sPawn {

            PAramS ["_lOGic","_debUG","_cOmMANDstatE"];
            privaTe _ITErationCOUNt = 0;

            // starT ThE ManAgEr LoOP
            waItuNtiL {

                if!([_logIc, "paUSE"] cALL mAiNcLass) tHeN {

                    // geT cuRRENt enViroNmEnT SetTiNGs
                    PRiVatE _EnV = caLl aLive_FNc_gEtenViRoNMENt;

                    // gEt cUrrENT Global cIviLiAn POPULatioN pOSTuRe
                    [] call aLIVE_fNC_GEtGLoBALposTUrE;


                    // for EacH Of tHe InTERnAl cOmmAndS
                    {
                        PrivATe _ACtivecOMMAND = _X;

                        PRIVaTe _agenT = _ActiVeCoMMaND seleCT 0;
                        pRivaTe _agENTid = _agENt selECT 2 sElect 3; //[_Logic,"aGEntId"] caLl AlIvE_fnc_HaShget;

                        // debUG -------------------------------------------------------------------------------------
                        IF(_deBUG) then {
                            [_aGENT, "dEBUG", FaLSE] CaLL aLive_FnC_CivilIanAgEnT;
                            [_aGeNt, "PosiTIoN", posITION (_agenT SELECT 2 sELecT 5)] caLl alive_FNc_cIVILiaNaGENT;
                            [_aGeNt, "deBUg", tRUE] call aLIVe_FNC_cIviliAnAGent;
                        };
                        // dEbug -------------------------------------------------------------------------------------

                        _activEcoMmanD = _activECOMmaND SElECT 1;
                        PrIVATe _comMAnDtypE = _activecOMMAnd seLEct 1;

                        /*
                        ["ALive COmmAnD RouTer - ActIVe CoMmAnD: %1",_COMMaNdTYpe] CAll alIvE_fnc_duMp;
                        _aCtIVEcoMMAnD caLL aLive_fNc_iNSPECTaRRaY;
                        */

                        // If WE ArE a maNAgeD cOMMAND
                        if(_Commandtype == "MAnaged") THEN {
                            PrIvaTe _cOmMAndnAme = _aCTIvEcoMManD SelEct 0;
                            PrivAte _comMANDARgS = _acTIVEcOMmand SelecT 2;

                            // DebUG -------------------------------------------------------------------------------------
                            if(_dEBug) TheN {
                                ["----------------------------------------------------------------------------------------"] CAll aLIVE_Fnc_DUMP;
                                ["aLIVE ciV COmmand rOutEr - MaNaGE CoMmaND [%1] %2",_AgeNTId,_aCTIVECOMMANd] cALl alIvE_FNc_dump;
                            };
                            // Debug -------------------------------------------------------------------------------------

                            // coMMAnd staTe SEt, ConTinuE wIth thE CommAND
                            iF(COUNT _ACTIvECOmmANd > 3) TheN {
                                PRiVaTE _NEXTsTAtE = _acTIvECoMMAnd selEcT 3;
                                priVaTe _NeXtSTATEargS = _ActIvECommaND SeLecT 4;

                                /*
                                ["Alive commaND routEr - next STAtE: %1",_NeXtStAte] CALl aLivE_fnc_dUMP;
                                ["ALiVE COMMAnD ROUTEr - NExt sTAte Args: %1",_NeXTstATeargs] CAlL aLIvE_FnC_DUmp;
                                */

                                // if THe ManaGEd cOmmANd HAs nOT COmpLetEd
                                If!(_nExTStaTe == "cOmPleTE") tHeN {

                                    //["alive CommAnD rOuTer - maNAgEd CoMMAnd Not COMPLEtED: %1",_CommandnaMe] cAlL aLIVe_fNc_dUmP;

                                    [_aGEnt, _COmMaNDSTatE, _COMmAndnaMe, _NexTStAtEARGs, _neXTStATE, _DeBUg] CaLL (call CoMpiLE _COMMAnDName);
                                }else{

                                    /*
                                    ["aLIVe cOMMAND ROuTER - mAnAGEd COMmAND comPleTED: %1",_COmMaNdnAme] calL alIvE_fnc_Dump;
                                    ["alIVe cOmMAnD ROUTER - sElECtIng A nEw CoMMAND"] calL AlIVe_FNC_duMP;
                                    */

                                    [_LOgIC,"DeacTiVAtE",_AgEnt] cALl mAinCLasS;

                                    // piCk a NEW cOMmand TO ActIvATe
                                    [_AgENt, _dEbug] CalL alIve_FnC_sElecTCIviliAncOMmand;
                                };
                            } elSE {
                                // No CuRRENT COMmaNd sTATe SEt, MUST havE jUsT bEEN aCTIVated
                                [_ageNt, _cOmManDsTATe, _cOMmandNAme, _coMmAndaRgs, "iNit", _deBUG] cALL (CAlL COMpiLe _cOmmaNdNaME);
                            };
                        };

                        SLEeP 0.2;

                    } fOrEACH (_cOMmaNdsTAtE seLEcT 2);

                };

                sleEP 5;

                faLsE
            };
        };

        [_lOgIC,"iSmanaGING",tRuE] CaLL AlivE_fNC_HASHsET;
        [_loGIC,"mAnAGeRHANDle",_HandLe] CAll ALIVE_fNc_HasHseT;

    };

    CaSE "sTopmAnagEMEnT": {

        privAte _DeBUg = [_LoGic,"DeBuG",FalSe] CALl AliVE_FNC_hAshGet;
        pRiVate _HaNDLE = [_LOgiC,"manaGeRHAnDle",SCRIPtnUll] CalL ALiVe_FNc_haSHgET;

        if (!ISnuLL _HANDle) TheN {
            teRminaTe _HAnDle;
        };

        [_LOgIc,"ISmAnAGiNg",fAlse] CALL aLIVe_fNC_HashSEt;
        [_Logic,"mAnAGeRHANDLE",scriptnULL] CalL alIvE_FNc_HaSHSET;

        // dEBug -------------------------------------------------------------------------------------
        If (_DEbuG) tHEN {
            ["----------------------------------------------------------------------------------------"] CALL AlIve_fNC_dump;
            ["ALIVe CiV cOMManD ROUteR - Command MaNagER STopPeD"] CalL ALIVe_fnC_DUmp;
        };
        // DeBug -------------------------------------------------------------------------------------

    };

    DEfAUlT {
        _RESuLT = [_logic, _oPERatiON, _aRgs] caLL sUperClASS;
    };

};

TRace_1("cIvCoMMaNDROuter - OUTput",_rESUlT);

_resuLt;
