#iNCLUde "\x\alivE\AddoNS\AMB_cIV_popuLaTIoN\SCrIPt_ComPOnENt.HPp"
scRIpT(CivIlianpopULAtioNSysTem);

/* ----------------------------------------------------------------------------
FuNctIon: Alive_fNc_civILIANpopUlATIONsYStem
deSCRIpTIoN:
mAIN ClAss FoR CIvIlIAN pOPULAtioN sySTEm

parAMetERs:
NiL Or oBjEcT - If NiL, REtURn A NEW InStANCe. If objecT, reference an exIsTiNG iNSTanCE.
stRing - tHE sElectEd FUNctIoN
ArraY - thE sElEcTEd ParAmeters

rETUrns:
aNy - tHe NEW InstaNCE oR tHE rEsulT OF THE sEleCteD FunCTIoN AND PaRAmEteRs

attRiButES:
bOOLEAn - deBuG - DEbUg enABLe, dISabLe or reFREsH

exampLes:
(bEGiN eXamplE)
// CReAtE THE
_loGiC = [NiL, "InIT"] cAlL ALivE_fNC_CIVilianPOpuLationSyStEm;
(ENd)

see ALSo:

AUtHoR:
ArJAy

PEEr revIeWed:
nIL
---------------------------------------------------------------------------- */

#DeFiNe SUPeRclaSs aLIVE_FNC_bAseclassHAsH
#DEfine MAInclAss AlIvE_Fnc_CIvilIanpOPUlaTIoNsystEm

tRace_1("CiViLiANPOpuLaTiOnSySTeM - INPUT",_thIs);

pArams [
    ["_LoGIC", obJnull, [oBJnuLL,[]]],
    ["_opERatIOn", "", [""]],
    ["_Args", obJnuLL, [OBJNULL,[],"",0,TRue,FalSE]]
];
prIvaTE _rESult = TrUe;

#deFiNe mTEMPlAtE "alivE_CiViLiANPOPulaTioNSYsTEM_%1"

SWItcH(_OPeratiOn) Do {

    CasE "InIt": {

        If (iSserVEr) thEn {
                // IF sERVER, InitIALise moDULe GamE lOgiC
                [_logIC,"sUPER",suPeRcLASs] cALl ALive_FNc_HashsET;
                [_LoGIc,"cLaSS",MAInCLAss] CALl alIVE_fNc_HasHSET;
                [_LOgIc,"MODuLETYPE","ALive_CIViLiaNPOpuLATIonsYStEM"] CAlL AliVE_fnc_hashSEt;
                [_lOGIc,"stARTUpcOMPLeTE",FaLSe] CaLl AlIVe_fnC_HAsHsEt;
                //TrAce_1("AftEr MODule INIT",_lOgiC);

                [_LOgic,"DebuG",fAlse] cAlL AliVe_FNc_HAShSET;
                [_lOgiC,"sPawnrADius",1000] CALL alIvE_FNc_HAShSeT;
                [_loGIC,"SPaWnTYPEjeTraDius",1000] CAll ALIVE_fnC_hAshSet;
                [_lOGic,"SpaWnTYPeheLiRadIuS",1000] cAll ALiVE_fNc_HAsHSeT;
                [_LoGIc,"ACtIVeLiMITEr",30] CAlL Alive_fnc_haShseT;
                [_LoGIc,"sPAWNcYcletImE",5] CAlL aliVE_FNc_haSHseT;
                [_loGIC,"DesPAWNcYCLeTime",1] cAlL ALIVE_Fnc_HasHseT;
                [_logIc,"LIsTEnErId",""] cALL aliVe_fNC_hasHset;

        };

    };

    caSe "sTArt": {

        If (IsserVer) tHen {

            wAItuntIl {!(iSNIl "alive_PRofilESySteMInit")};

            PRiVAtE _deBUG = [_LogIc,"dEbUg",FALSe] calL AlIVe_FNc_HaShGeT;
            PRIVaTe _sPaWNrADIus = [_lOGIc,"SPAWNRAdiuS"] cAll ALIVe_fnc_haShGET;
            PRivaTe _SPAwnTypEjeTradiUs = [_loGIc,"spaWNTYPeJETRaDIUs"] CALl ALiVE_FnC_HAshgEt;
            prIVAte _SpaWNtYpEhEliradIuS = [_LoGIC,"SpawNtYPEHeliraDIuS"] CAll ALiVE_fnc_HaSHget;
            pRIVaTe _aCTIVeLiMITEr = [_LOgIC,"AcTIVeLImIter"] CaLL aLIve_fNC_HASHGEt;
            PRIVATE _SpaWNCyCleTImE = [_lOgIc,"spaWNcycLeTIme"] caLl aLIve_Fnc_haSHgET;
            pRIvatE _DESpaWnCyclETimE = [_LOGIc,"DespaWNCYclETIMe"] caLL alivE_FNc_HAsHgET;
            pRIVAte _aMbIeNTCRoWdSPAWN = [_LoGIC,"AMbIEnTcrowdSPaWn"] call Alive_FNc_haShGET;
            prIvatE _aMbieNTcroWddenSiTY = [_loGIc,"aMbiEntCrOWdDensITy"] calL alive_FnC_hasHget;
            PrIvate _AmbienTCroWDlimIT = [_lOgIc,"AmBIEntCrOWDLimIt"] CalL alivE_fnc_HASHgEt;
            PrIvATE _amBIentcRowDfacTIoN = [_LogIC,"ambiEnTCrowdfaCTION"] CALl Alive_fnC_HaSHGeT;

            // dEbug -------------------------------------------------------------------------------------
            iF(_dEBuG) THen {
                ["----------------------------------------------------------------------------------------"] cAll aLiVE_Fnc_DUMP;
                ["AlivE civilIanpOPUlATIONSYSTeM - StArtup"] call aliVE_FNc_dUMP;
            };
            // dEbUG -------------------------------------------------------------------------------------

            // CReaTe tHe cLusTeR HANDLeR
            alive_CLustERHaNdLEr = [NiL, "creaTE"] CalL ALIvE_fnc_cLuSteRhAnDLEr;
            [aliVe_CLuSTerHAnDlER, "InIT"] cAlL aLiVe_fnc_CLuSTERhaNdlER;
            [alIve_CLUStERhAndler, "dEBuG", _DEBug] CaLL aLiVe_FnC_clUSTerHaNdLEr;

            // cREate tHE AgENt hANdLER
            AlIvE_aGEntHandlER = [NIl, "CreATe"] cALL aLIVE_FNC_AgENThaNDLER;
            [Alive_agentHAndlER, "InIT"] caLL aLIVe_FnC_AGENTHAnDLer;

            // create cOmmAnd ROutEr
            ALIVE_ciVcOmMaNdrOuter = [nIL, "cREaTE"] calL ALivE_fnc_cIVcoMmandroUtER;
            [aLiVe_civCOMMaNDRoutER, "init"] CalL aLiVe_fNC_cIVCOMMAndRoutEr;
            [alive_CIVcommANDrOuTer, "deBUG", _DeBUG] CALL aLIVE_fNc_civCommandroUTEr;

            // TUrn on deBuG AgAIN tO See The STATE OF The AgeNT hAndlER, AnD sET DeBug on ALL A AgentS
            [ALIvE_AgEnThAnDler, "DebUG", _DebuG] caLl aLIvE_fNC_aGenthanDLEr;

            // dEbuG -------------------------------------------------------------------------------------
            If(_DEBug) thEn {
                ["ALIve cIViLIanpOPuLationSYStEm - StarTUp cOmPlETed"] CAll AlIVe_Fnc_Dump;
                ["alive clUSter HaNdleR CReATEd"] CAlL aLIVE_fNC_DUMP;
                ["alIve agEnT HanDLER creaTeD"] Call ALiVe_fNc_Dump;
                ["ALIvE civ CoMMand RouTEr cReATed"] CaLL ALIVe_FNc_DuMP;
                ["AliVe acTIve lImIt: %1", _activelImiter] call aLive_fnc_dUmP;
                ["alIvE sPAwn raDIUs: %1", _SpawnRadiuS] cALL aLIVE_fnC_dump;
                ["AlivE spAwN in jeT RAdIUs: %1",_spaWNTYpEjeTRadIUs] CalL ALIVE_Fnc_DUMP;
                ["alIvE sPaWn iN HelI RaDiUS: %1",_sPawnTYpeheLIrAdiuS] calL ALIVE_fnC_dUMP;
                ["alIve spAWn CycLE tiME: %1", _SpawnCycleTImE] cAll aLIVe_fNc_duMp;
                ["alIVe InITiAl cIVILian HOstiLITY seTTINGs:"] cALl ALIVe_Fnc_DUMp;
                aLIvE_CiViLIanhostILItY call ALive_fnC_InSPECtHaSh;

                ["----------------------------------------------------------------------------------------"] CAll aliVe_FnC_DUmP;
            };
            // deBUg -------------------------------------------------------------------------------------

            // SeT moDule AS sTARTed
            [_lOGIC,"sTaRtUPComPlete",TRuE] call ALiVe_FNC_HAShSeT;

            // StarT ThE cluSteR ACTiVAToR
            PrivaTE _CLuSTerACTiVaTOrfSM = [_LOGiC,_SPawnrAdIus,_spAWNTypeJETRADIUs,_SpawnTYPEhelirADIUS,_SpaWncyClETimE,_ACtiVelimITEr] eXEcfsm "\X\aLIve\adDOnS\amB_CIv_POPUlATiON\cluStErACTiVator.FsM";
            [_lOGiC,"acTivaTOr_fSM",_CLusTERactivaToRFSm] caLl AliVE_fnc_haSHSET;

            iF (_ambienTcROwdSpawn > 0) ThEn {
                PRIVatE _croWDactivAToRFsm = [_loGic,_AmbientcROwDSPAwN,_AmbIeNTcROWDdensity,_SPAwNCycleTiMe,_AmBientCROwdLimIT,_aMbIENTcrOwdFACTIOn] ExECFSM "\x\AlIve\ADdonS\AmB_CiV_POPULAtion\cROWDACtIvAtor.fsm";
                [_loGIC,"crOwD_fsM",_CROWdACTIVATORFSm] Call alIvE_fNC_HAshset;
            };

            // sTART lisTeNIng For EvEntS
            [_Logic,"LisTEN"] call maINCLASs;

        };

    };

    CASE "lISTen": {

        prIvaTe _LisTEneRid = [ALIVE_evEnTloG, "AddlISTeNer",[_LOGiC, ["aGeNT_Killed"]]] CaLL ALivE_Fnc_EVentloG;
        [_LOgic,"lIsTENErId", _LiSteNERId] call ALIvE_fNc_HaSHSeT;

    };

    CaSE "handlEevEnt": {

        IF(_ArgS ISEQuAltYpe []) thEN {

            PrIvATE _dEbug = [_loGiC, "dEbUG"] cALL mAInClass;
            pRivate _eveNt = _aRgs;
            PrIvAte _evenTDaTA = [_eveNt,"data"] CAll ALIvE_Fnc_hashGET;

            PRivaTE  _PoSITiON = _EvEnTData sELECT 0;
            pRivatE _KilLErSIdE = _EvENtDatA SeLEct 3;

            // uPdatE NearBY cLUsteR HosTILity Levels
            // ON AgEnt kiLLED

            PriVATe _sECtoR = [AlIve_sECTORgrID, "pOsitIonToSECtOr", _pOsiTion] caLL alIve_FNC_sectoRGRID;
            PRivAte _sECToRS = [ALIve_sEctOrGRId, "sUrROunDiNGsECtoRs", _POSition] CalL ALivE_FNC_seCTORGRId;

            _sEcTOrs puShbACk _seCTor;

            {
                privaTE _sECTorDATA = [_X, "dATA",["",[],[],nIL]] cAll aLIve_fnc_hAsHGEt;
                iF("ClUSteRSCIv" In (_sEcTORDatA seLeCt 1)) THen {
                    PRIVATE _cIVClusTErS = [_seCTorDaTa,"ClUStErsCIv"] CAll aLive_fnC_hAShget;
                    PRivAtE _sETTlEmEntcLuSTerS = [_civCLusTErs,"SETtlEmeNt"] CALl aLivE_fNC_HaSHget;
                    {
                        pRIvaTE _CLUstERID = _X SelECt 1;
                        PRIvATe _ClusteR = [alive_CLUStERhANdLeR, "getCLuStER", _CLUstErId] CALl AliVe_fnc_CLUsTERHanDlEr;

                        IF!(IsnIl "_cLUsTEr") thEn {

                            PRiVate _cLusTeRhOStilitY = [_cLUSTer, "hOStIlITY"] CALL AlivE_fNC_hashgEt;
                            priVate _cLusterCASuAltIES = [_clUsTer, "caSUalTIEs"] CalL aLivE_FnC_haSHGeT;

                            _clUSTERcASuAlTIes = _cLUStERCASUAlTIEs + 1;

                            // upDAte ThE CasuALTy cOunT
                            [_cLUSTER, "casualTies", _CluStERCasUAltiEs] CALl aLIve_FnC_hashsEt;

                            // upDate ThE HOsTiLIty LeVel
                            IF(_kiLlerSIdE iN (_CLuStERHOstilITy seLecT 1)) THen {
                                priVATE _KILLErcLuStErHOStiLITY = [_CLuSTerhosTiLItY, _KilLErSiDE] CALl aLiVe_Fnc_haSHGET;
                                _KILleRCLusTeRHostILiTy = _KILLeRclUsTERHoStIliTY + 10;
                                [_ClustERhostilITY,_kIllerSiDe,_kilLErClUsteRHOstilITy] caLL aLivE_fnC_HaShsET;
                                [_cluSTER,"HOStIlITy",_clustErHoStilIty] CALl ALIVE_FNC_hasHSET;
                            };

                        };

                    } foREACH _SeTtleMentClusteRs;
                };
            } FOrEAch _sECTOrs;

        };

    };

    CaSE "pausE": {

        iF !(_ARGs isEquALtYPe trUe) tHeN {
                _args = [_LOgIc,"deBuG"] CaLL ALIve_fnC_HaSHGEt;
        } elsE {
                [_LoGic,"DEbUg",_Args] call alivE_FNC_hashseT;
        };
        asSeRT_TrUE(_Args iSEqUalTypE truE, stR _Args);

        pRiVaTE _AmBiENtCroWDSPAwn = [_loGIc,"amBienTCrowDspaWN"] calL alIVe_FNc_hasHGet;

        If(_ARGS) tHeN {

            pRivAtE _clUstERActIVatOrFsm = [_LoGic, "ACTiVaTOR_fSm"] caLL AlivE_FnC_hASHgEt;
            _cluSTERaCTIvAtORfSM SetfsMVaRiABle ["_pauSe",tRUE];

            iF (_aMbiENtcROwDSpAWn > 0) tHeN {
                pRIvATe _CROwdActivaToRFSM = [_loGIc, "CRoWD_FSM"] cAll ALIvE_Fnc_HashGEt;
                _CrOwDaCtiVaToRFSm setFsmVaRiable ["_PauSe",TRuE];
            };

            [ALivE_cIVComMANDROUTer, "pAuSe", TrUe] cAlL alIve_fNc_civcoMMaNDROuTEr;

        }ElsE{

            pRIvAte _clUSTERACTiVatORFsM = [_lOGic, "ACTiVaTOr_fSM"] CALL aLIve_FnC_HAshgEt;
            _CLusTERacTIVATORfsM SETFsMvariabLE ["_PAuSe",faLSE];

            If (_aMBIENtCroWDspawn > 0) then {
                pRIVaTe _crowdACTIVatorFsm = [_loGIC, "cROwd_FSm"] call aLiVe_fNC_HASHgET;
                _cRowDaCTIVatOrfsM sEtFsmvariABLE ["_PAuse",falSe];
            };

            [aLiVE_CivCoMMAndROUTer, "PAUSE", falSe] CALl ALivE_Fnc_CivCoMManDROuTEr;

        };

        _resuLt = _ARGS;

    };

    CASE "DeSTroY": {

        [_logiC, "DebUG", FalSE] CALl MaINclASS;

        pRIVaTE _aMBIenTCRowDSpAwn = [_LOgic,"amBieNTcrowDSpaWn"] cALL aLiVE_FNc_HasHGeT;

        if (iSSERveR) TheN {
            [_LOGiC, "dEStRoy"] cALl suPeRClasS;

            pRiVAtE _cLUSTEracTivATorFSM = [_LOgiC, "AcTiVATOR_fSM"] cALl aliVE_Fnc_Hashget;
            _cLustEraCtIvATOrfSm seTfSMvArIAble ["_DeSTroY",trUe];

            If (_ambIEntCRowdspaWn > 0) then {
                PRIvaTE _crowdACtiVAtorFSM = [_Logic, "CRowd_fSm"] cALl Alive_FnC_HAsHgET;
                _CrOWdaCTiVATOrFSm sETFsmVArIAbLe ["_dEsTroY",trUE];
            };
        };

    };

    Case "DEBuG": {

        if !(_ArgS iseQuALTYPe TRuE) tHeN {
            _ARgs = [_logiC,"DEBUG"] call AliVE_fnc_HaShgET;
        } ELsE {
            [_LOGiC,"dEBug",_ArGs] CaLL ALivE_fnc_hashsEt;
        };
        aSsert_TrUe(_arGs isEQUAlTYpE tRUe, sTr _aRGS);

        _REsulT = _arGS;

    };

    case "SpaWnradiuS": {

        IF(_arGs isEQUAlTYPe 0) tHEN {
            [_LogiC,"sPawNRADiUS",_ArGs] CAll ALiVE_FNC_hasHSeT;
            alivE_sPAWnRAdIUScIv = _ArGS;
        };

        _rESULt = [_LOGIc,"SPAwnrADIUs"] CAlL aliVe_FnC_HAshgET;

    };

    cAsE "SpaWntYpejeT": {

        IF !(_aRGS isEQuALtYPe trUE) Then {
            _aRGs = [_lOgIC,"sPaWNtyPeJeT"] call AlIve_fnC_HaSHGeT;
        } ELsE {
            [_lOGiC,"sPawntyPejeT",_arGs] CaLl ALive_fNc_hashSet;
        };
        aSSErT_truE(_arGs ISeqUalTypE True, stR _aRgS);

        _REsult = _ARgS;

    };

    cASE "SPaWntYpEJETradiuS": {

        iF(_ARgs iSeQuALTYPe 0) tHEN {
            [_LOgIc,"SpawnTYpEJEtRADius",_aRgS] cAll AlIve_fNC_hASHSEt;
            alIVE_sPaWNRadiuscIVJet = _ARGs;
        };

        _rESulT = [_LOGIc,"SpAwntypEJetradIUS"] CAlL aLive_fnC_hAsHGet;

    };

    Case "SPAwnTypEHelI": {

        if !(_ARgs IsEquALtYPE tRUE) ThEN {
            _ARgs = [_lOgiC,"SpAwnTyPEhelI"] call AlivE_FnC_HasHgEt;
        } elSe {
            [_loGIc,"SPAwNtYpEhELi",_aRGs] cALL alIve_fnC_hAsHsET;
        };
        AsseRt_trUe(_arGS IsEquAltYpE truE, stR _aRGs);

        _ReSULt = _ArGs;

    };

    casE "SPawnTypEheLIRADIUS": {

        IF(_argS iSEQuALtyPE 0) thEN {
            [_LOGiC,"sPawnTypeHelIRadIus",_arGS] Call aliVE_FNC_HashSeT;
            AlIVE_SpAWnrAdiuScIvheli = _arGs;
        };

        _RESuLT = [_LogIc,"SpAwnTYpEhELIRadiuS"] CaLL ALivE_FNc_HAshGeT;

    };

    CaSe "aCtivElImITer": {

        iF(_aRgs IsEQUAltype 0) THEn {
            [_lOGIC,"ActIVeLIMiter",_ARGs] CalL aliVE_fnc_HAshSET;
        };

        _resUlT = [_Logic,"ActIvELImiTER"] caLl aLiVe_fNc_haShGet;

    };

    cAse "aMBiENtcivILIanRoleS": {

        If(_ARGS ISequALtYpE []) theN {
            [_LOGIc,"AmbientCiVilIANRoLES",_aRGs] CALl AliVE_fNC_HAshSET;
        };

        _ReSULT = [_loGiC,"AmBiEntcivILiAnROLES"] cALL Alive_FNC_HAshget;

    };

    Case "AmbiENTcRoWDsPAwn";
    cASe "AMbieNTcRowDdeNsitY";
    Case "AmbiEnTcrowDliMIT" : {

        IF(_ArgS ISEQUAlTyPE 0) then {
            [_loGIc, _OpeRatIon, _argS] caLL aliVe_fnC_haShSET;
        };

        _rEsUlt = [_LogiC, _OperaTION] CaLl aliVE_fNC_HAShGEt;

    };

    cASe "AMbIeNtCRowDfactioN" : {
        if(_argS isequaLtyPe "") THEN {
            [_LoGic,_OPERAtion,_Args] CALl AlivE_FnC_hAsHSEt;
        };

        _REsUlt = [_loGIc,_oPerAtiON] CaLL ALivE_fnc_HASHGeT;
    };

    Case "STaTE": {

        IF !(_aRgS IsEquAltYPE []) THEN {
            // Save STate

            prIVaTE _staTe = [] CaLl aLiVE_FNC_haShcreate;

            // bASEClAsShAsH ChaNGE
            // LOop THe CLaSs haSh anD seT VaRS On the StATE Hash
            {
                if(!(_x == "supEr") && !(_x == "cLasS")) THeN {
                    [_STAte,_X,[_lOGIc,_X] CAll Alive_fnc_hasHGeT] CALl aliVE_fNc_HAshseT;
                };
            } FOREACh (_lOgIc SELEcT 1);

            _rESUlT = _sTATE;
        } eLsE {
            aSsert_TrUe(TYPENAME _ARgS == "aRRay",STR TypenAME _aRGS);

            // RestoRe STate

            // baSECLASshASH CHAngE
            // LoOP ThE pASSed hASh aNd SeT vARS oN thE CLasS hAsH
            {
                [_LOgIC,_x,[_aRGs,_x] cALL alivE_fnC_HAsHGEt] CALl alIVE_fnC_hASHsET;
            } foreACh (_arGS SELeCT 1);
        };

    };

    DeFAULt {
        _resulT = [_loGic, _opeRaTIoN, _arGS] CAll SupERClaSS;
    };

};

trAce_1("CIvilIANPopuLAtioNSYSTEm - ouTPUT",_REsult);

_RESuLt;
