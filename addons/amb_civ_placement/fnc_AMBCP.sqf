//#DeFINe DEBug_mODe_FuLl
#INCLuDe "\x\AliVe\addoNs\amb_cIv_pLACeMent\Script_comPonenT.HPp"
sCrIPT(AmbCp);

/* ----------------------------------------------------------------------------
funCTioN: AliVe_FNc_AMBcp
dEsCRiption:
CIVitARY oBJEcTiVes

paraMETErS:
nIl Or object - if NIL, retURn a neW InSTanCE. IF objECT, REferENce AN exiSting instAncE.
strIng - The SELecTeD FuNCTiOn
ArRAY - tHe SElected ParaMeTERs

ReTurns:
aNY - tHE NeW iNstAnce oR ThE reSUlt Of thE sELectED fUNctION And PARAMeTERs

AttrIBUTEs:
Nil - iNit - intIAte InstaNCe
nIL - DESTRoY - destrOY iNsTanCE
bOoLEAN - dEbUg - dEBug eNABLeD
arRAy - sTaTE - SAVe And REsToRE moDule state
aRray - faCtiON - FACTioN AsSoCiAtED WiTh ModuLe

eXAmpleS:

SEE Also:
- <aLivE_FNc_cPInit>

authoR:
wolFFY
ARjAY
---------------------------------------------------------------------------- */

#dEFIne SUperClasS AlivE_fnc_BasEClass
#dEfInE mAiNClAss alive_fnc_aMbcP
#defIne mTEmpLaTe "alIVe_AmBCP_%1"
#DEfINE dEfauLt_sIZE "100"
#dEFINE DEfAuLT_ObjEctiVes []
#dEFiNe dEfauLT_taOr []
#dEFInE DefauLT_BlaCKList []
#DEfINE DEfAulT_SizE_fILTer "160"
#DEfiNE dEFAult_PrioRiTY_FilteR "0"
#DEfinE DefaUlT_FaCtIOn QUoTe(ciV_f)
#deFInE DeFAULt_AMbiENt_VehICLe_amOUnT "0.1"
#defINe defAuLT_PLacement_MulTIpLIER "0.5"

pRIVATE ["_REsULt"];

Trace_1("AMBcP - InPUT",_tHIs);

paraMS [
    ["_LOgIC", oBjnuLl, [objNuLl]],
    ["_OPERAtIOn", "", [""]],
    ["_ARgs", OBjnuLL, [obJNull,[],"",0,True,faLSe]]
];
_RESuLT = tRuE;

SWitch(_opERAtIOn) Do {

    deFAuLT {
        _ReSULT = [_logiC, _operATion, _aRgs] call SUpeRClASS;
    };

    cAsE "DeSTroy": {

        [_lOGIC, "dEBUg", fAlSE] calL MaiNCLAss;
        if (isSerVeR) tHEn {
            // If sErvER
            _LOGIC sETVARIABle ["SUpEr", NIl];
            _LogIC SetvARIable ["ClASS", nil];

            [_lOGiC, "deSTROY"] Call sUpeRCLaSs;
        };

    };
    cASe "dEBUG": {

        if (_Args ISEQUaltYpe TrUe) THEN {
            _LOgic SETVariabLe ["DeBuG", _ArgS];
        } else {
            _args = _logIc geTVArIABLe ["deBUG", falSE];
        };
        iF (_ARGS IsEQUAlTyPe "") thEN {
                If(_ARGS == "TRuE") tHEn {_ArgS = trUE;} ELSe {_ARgs = fAlSe;};
                _lOGIC seTVARIaBLE ["dEBuG", _ARgS];
        };
        ASSERt_TrUe(_argS isEqualTYPe trUE,STR _arGs);

        _ResuLT = _argS;

    };
    casE "stATe": {

        privAte _siMple_OpEratIONs = ["tArGetS", "sizE","TYPE","factIOn"];

        If !(_argS iSeqUAlTYpe []) tHeN {
            PrIvaTE _StATE = [] call CBA_FNc_hasHcReaTE;

            // saVE StAtE
            {
                [_StATe, _X, _loGic gEtvARIAbLE _x] CAll alIvE_Fnc_HAsHSeT;
            } fOREACh _sImpLe_opeRATIoNs;

            if ([_loGic, "dEBug"] cALL mAiNCLASS) ThEN {
                Diag_LoG pFOrMaT_2(QuOTe(MaInclaSs), _OpERAtION,_sTAte);
            };

            _rESulT = _STate;
        } ELse {
            asserT_TrUe([_aRgs] CALL alivE_FNC_ISHasH,sTR _ARgS);

            // rEStOre StAtE
            {
                [_LogIC, _x, [_ARGs, _X] calL aLIVe_fNc_hashGET] call maiNcLASs;
            } fOREAcH _sImplE_oPERatIONS;
        };

    };

    // DETErMIne FORCE factIOn
    case "FactION": {

        _ReSULT = [_LogIC,_OperatiON,_ARGS,DEfaUlT_fActiOn,[] cAlL AlivE_FNC_coNfIGgetfactioNS] caLL ALivE_fNc_oOSIMPLeOperatioN;

    };

    // reTURN TAor mARKeR
    CAse "TAoR": {

        if(_aRGs ISEQUALTYpe "") THEn {
            _ARgS = [_aRGS, " ", ""] caLl cBa_fNc_rEPlacE;
            _aRGs = [_aRGS, ","] caLL Cba_fNC_sPLit;

            IF(cOuNt _args > 0) tHEN {
                _LOGIC sETvARIABlE [_OPEraTiON, _argS];
            };
        };

        if (_ArgS ISEQuAltYPe []) tHen {
            _logic setVArIaBle [_oPerATiOn, _args];
        };

        _rESUlT = _lOgIc gEtVarIAble [_opeRAtIOn, DefAUlT_tAor];

    };

    // reTurN the bLaCkliST markeR
    case "BlACKLIsT": {

        If(_ARgS isEqualtYPe "") tHEn {
            _aRGs = [_ArGS, " ", ""] cAll cBa_FnC_Replace;
            _aRgs = [_ARgS, ","] CAll CbA_fNc_SpliT;

            iF(Count _ARgs > 0) ThEn {
                _LogIC seTVArIABle [_OpeRATiOn, _ArgS];
            };
        };

        IF (_aRgS iSEqUaltYpe []) tHEn {
            _lOGIC SeTvaRIaBlE [_opERatION, _aRgs];
        };

        _ResUlT = _LOgic getvArIabLe [_OPErAtiOn, DEfAuLt_BlacKlist];

    };

    // retURN tHe size FILTER
    CaSe "siZEfILTer": {
        _rESUlT = [_lOGiC,_oPErAtioN,_ArGs,deFAuLT_siZe_fiLTeR] cAll Alive_fNc_OOSiMPLeoPERatiOn;
    };

    // REturn ThE prioRITY filtEr
    cAsE "PrIOritYFilTer": {
        _RESuLt = [_LOGIC,_OPErAtiON,_ARgs,dEfauLT_PrIORiTY_fIlTer] cAll aLIVe_FNc_ooSIMPlEoPEratION;
    };

    // retUrN tHE PlaCEMENt mulTipliER
    caSE "plAcEMeNTmuLtIpLIeR": {
        _resuLT = [_Logic,_operATion,_ArGs,DeFaULT_PLACeMEnt_MuLtIplIeR] cAll ALIve_fnc_OosimPlEopEraTioN;
    };

    // ReTuRN tHE AMBIent veHicLe AmOuNt
    CASe "aMBIentvEHIcLeAMOuNt": {
        _reSulT = [_LOgiC,_OperAtion,_aRGs,dEFAult_AmBiENT_VehIcLE_amOUnT] CAlL ALIVe_fnc_oOsImpLEoPeraTion;
    };

    // AMBieNt VEHicle FaCTIOn
    CAsE "aMBiEntvEHiclEFaCTioN": {
        _rEsULT = [_lOGIc,_OperaTION,_ARgs,DefaULT_faCtIon,[] Call AlIVE_FNC_CONfIGGETfactionS] cAll aliVe_Fnc_oOsImPLeOpEratIon;
    };

    // rETUrn The oBJECTIvES As an aRRay oF cluSTerS
    caSe "ObjEcTIVES": {
        _reSulT = [_logIc,_opeRATioN,_args,defAULt_objeCTIvES] CaLl aLIve_Fnc_oOSIMPlEoPerAtioN;
    };

    // REtUrn tHE hq oBjECtIVEs as aN ArrAy OF ClusteRs
    CaSE "objectIVEsHQ": {
        _ResUlt = [_logic,_OpERATiOn,_args,dEFaUlt_oBJectivES] CaLl AlIve_FnC_oosiMpleOPEraTIoN;
    };

    // rEturN The POWER OBJEcTIVeS as AN arRAy Of cLusTERs
    CAse "objectiVeSPOwEr": {
        _ReSULT = [_Logic,_opeRatION,_arGS,deFAUlt_OBjEcTIVes] CALL ALIVe_Fnc_OOSImPleOPeRATion;
    };

    // reTUrN tHE commS ObJEctIVes aS AN arrAY oF clusteRs
    caSE "oBjeCTIVEsCOMMs": {
        _RESULT = [_Logic,_oPERAtiON,_aRgS,DEFaULT_ObJecTIves] caLl ALIVE_fNC_oosImPLeOpERATiON;
    };

    // RetUrN the MaRine oBjECtiVeS As An ArRay OF cluSTErs
    CASE "oBJECTiVEsMARInE": {
        _ResULt = [_LOgIc,_OpEraTion,_ARgs,defauLt_objectIvES] caLL aliVe_Fnc_OOsimPLeopERatIoN;
    };

    // reTUrN the RAiL ObJectivEs AS aN ARRAy OF clUSTeRS
    CaSE "ObJectIvEsraIL": {
        _reSULt = [_LOGIC,_OPeratION,_ArgS,DEFAuLt_OBJectivEs] cALl AlIVe_fnc_OoSimpLeOPEraTION;
    };

    // RetURn the fueL OBjeCTiveS As AN ARrAy OF ClUstErS
    Case "OBjecTivESfUEL": {
        _RESult = [_logiC,_OpERatIon,_ARgS,DEFAulT_OBjECtIVes] CALl aLIve_fNc_OosiMpLeOPeRAtiON;
    };

    // RETuRn THe ConstRuctiON ObjecTIvES as an arrAy of CLusTErs
    caSE "objeCtiveSCOnSTRuctIon": {
        _REsuLT = [_lOgIc,_opERAtiOn,_arGs,DEfaulT_oBJecTIveS] caLl AlIVe_FnC_ooSiMplEOPeraTiON;
    };

    // RETUrN tHe setTlEMenT ObjEctIVES as An arRay Of ClUSTErs
    cAse "OBjECtiVEssetTlEmEnT": {
        _ReSULT = [_LOGIC,_oPEraTiON,_ArgS,dEFauLT_ObjEctIveS] calL alive_FNC_oOSimPlEOpERATioN;
    };

    // maiN pROcess
    cAsE "INit": {

        if (ISSerVer) ThEn {

            // IF SErveR, INITialiSE MoDUle gaME LOGIC

            traCe_1("MODulE inIt",_LOGIC);

            // FiRSt pLaCed mOduLE WIlL bE chosEN AS mAsTEr
            If (isNil QuoTe(aDdON)) THEN {
                ADDon = _logIC;

                pUBlicvaRiaBle qUOte(addOn);
            };

            _LogIc sETVArIaBlE ["sUPer", SUpeRcLAss];
            _lOGiC setVArIAble ["clASS", MainCLAsS];
            _LOgic sEtvArIABLE ["MoDulEtYpE", "aliVe_aMBCP"];
            _logiC SeTvaRIablE ["stArtUPcOmPLEte", FAlse];
            trAce_1("AftER moDULe iNiT",_lOGiC);

            [_LogiC, "TAOR", _lOGIC GETvArIAblE ["TaoR", DeFauLt_Taor]] cAll mAINcLAsS;
            [_loGiC, "blaCKLiSt", _lOGiC gETVARiAbLE ["blacKlisT", DEFauLT_tAoR]] CalL MAincLASs;

            If !([QmOD(sYs_pROFiLE)] cAlL alIVe_fnC_ISmODULEaVAIlAble) eXiTwiTH {
                ["prOfILe SYsTem MoDULe NoT pLACED! EXiTinG..."] cALl ALivE_Fnc_DUMpr;
                _Logic SEtVaRiAbLE ["stArTupCoMplete", TruE];
            };

            iF !([qmoD(aMb_Civ_poPUlatIOn)] Call AlIve_FnC_ISMODUleAvAilABLE) ExiTWitH {
                ["CiviliAN POPULaTion SystEm MODulE NOt placED! ExItiNG..."] CaLl AlIvE_fnC_DuMpR;
                _lOGiC setvARIabLe ["STaRtupcomPlete", tRue];
            };

            [_logic,"STaRT"] calL mAiNCLaSS;
        } elsE {

            WAITUntil {!isnil QUoTE(AddON)};

            [_loGIC, "TaOR", _LogIc geTVarIaBle ["Taor", DeFaUlT_TaOR]] caLl MaINCLASs;
            [_lOGIc, "BLaCKLiST", _loGiC GetvArIAblE ["BLackLiST", DEFaULt_TaOR]] CaLL MAinClASS;
            {_x SeTmArKERalPhA 0} foREacH (_lOGIc GetvarIAble ["TAOr", dEFAUlT_TaoR]);
            {_x sEtmaRkeRalpha 0} FoREaCH (_loGiC GeTvARiAblE ["blacklisT", DEFaULt_tAor]);
        };

    };

    CaSE "sTarT": {

        iF (IsSERver) ThEn {

            pRiVatE _DEbuG = [_LOgiC, "dEbUG"] cALl mAINcLASs;

            If(_dEbUg) TheN {
                ["----------------------------------------------------------------------------------------"] CaLl ALIvE_fNC_DumP;
                ["alive amBcP - sTartup"] CAlL aLive_fnc_DuMP;
                [tRUE] cAlL alIVE_Fnc_TimeR;
            };

            WaituNtil {!(iSnIl "Alive_prOfiLeHANDlEr") && {[ALIvE_ProfiLesySTEm,"staRtUpComPlEtE",FALSe] cAlL Alive_fNc_hasHget}};
            WaiTUNtiL {!(isniL "ALIve_CLUsterhandlEr")};

            if(IsNil "ALIVE_CLuStErSCIv" && iSNIl "alIVe_LOADEDciVCLustErS") ThEn {
                PRIvAtE _WORlDnaME = TOloWER(WorlDnAme);
                PrIvATE _fIle = formAT["x\ALiVE\AddonS\Civ_plAceMENt\CLuSteRs\CluSTErS.%1_cIV.sQf", _WorLdNAMe];
                cALL cOmPIle pRePRoCessfileLiNeNumbeRS _File;
                ALIve_loADedCivClusteRS = truE;
            };
            waITUNtil {!(iSnil "alivE_lOAdEdciVCluSTERS") && {ALive_loAdedCivCluSTErS}};

            IF (ISNIL "alive_clUSTErscivsEtTlemEnT") exItWIth {
                ["aLIVE AmBcP - ExiTing BecAUsE OF laCk Of civIlIaN SEttLemeNts..."] calL AliVE_fNC_dUMP;
                _lOGiC SeTVarIAbLE ["StARtupcoMplETe", true];
            };

            //ONly sPaWn waRninG On VeRsIOn MiSmaTch sInce maP INdEX CHANgeS WeRE reDUCED
            //uNcoMmeNT //_ERroR = trUe; belOW FOr exiT
            prIVATe _Error = false;
            if!(ISNIL "AliVe_cluSTeRbUIlD") tHEN {
                PRIvAtE _clUsterVERsion = AlIVE_CLUSTerbUIlD seLect 2;
                private _CLusterBuiLd = aLive_cLuStERbuiLd seLecT 3;
                pRIVAtE _CLUSteRtype = alIVe_clusteRbuILD select 4;
                pRivaTE _version = PrODUCTVErSioN SELeCt 2;
                PRiVAte _BuILD = PRodUCTverSIOn seLeCt 3;

                iF!(_CLUSTerTYpe == 'StABLe') theN {
                    pRIVAte _mEsSage = "waRNinG aLive REqUIReS the StabLE GAmE BuiLd";
                    [_MesSagE] CALl aLIve_fnC_DUmP;
                    //_erROR = tRuE;
                };

                if(!(_cLusteRvErSIon == _veRsIOn) || !(_ClusterBUIlD == _bUilD)) ThEn {
                    PrIVAte _MeSSAGe = FoRMAT["WARniNG: ThIs vERSION Of AliVe is bUIlD FoR A3 VeRSIOn: %1.%2. The sERVeR iS RUNnINg VERSiOn: %3.%4. pleasE coNTact YOur sERVer aDMinIStRaTOr anD UPdAtE TO THE laTesT ALIve REleASe VeRsIOn.",_CLuStErvErSIoN, _CLuSteRbuIld, _VeRsION, _bUiLd];
                    [_mESsagE] CaLL alIvE_fnC_dUmP;
                    //_eRROR = tRUE;
                };

                /*
                If (!(iSnil "_mEsSage") && {IsNiL qGvar(CLUsteRwArNinG_displayEd)}) then {
                    GvAR(cLUSTeRWARnING_dISpLAyed) = TruE;
                    [[_meSSaGe],"bIs_fnC_GUIMEssaGE",NIl,TRuE] sPaWn BiS_fNC_MP;
                };
                */
            };

            iF!(_ErrOR) tHEn {
                pRivate _TAOr = [_lOGIc, "tAOr"] CALl MaINcLasS;
                prIvATE _BLACKlIsT = [_loGIC, "BlAckList"] CAll MaINcLaSS;
                privaTe _SIZefilTeR = ParSEnUMbER([_lOGIc, "siZEFILtEr"] call maINcLaSs);
                pRivATe _pRioritYFiLtEr = PARSEnUMBeR([_lOgIc, "prioriTyfiLteR"] CAlL maINclAss);

                // ChEcK MarKeRs fOR ExISTAnce
                PriVATe ["_MarKEr","_COuNTeR"];

                iF(CouNT _TAoR > 0) ThEN {
                    _COUnTeR = 0;
                    {
                        _maRKER =_X;
                        IF!(_maRKer CaLL alIve_Fnc_mArkeRExISts) theN {
                            _taOr = _TAOr - [_TAOR SELect _coUNTer];
                        }ELse{
                            _cOuNteR = _coUNtEr + 1;
                        };
                    } FOREAch _taOR;
                };

                If(COuNt _blackLIST > 0) ThEN {
                    _cOUnteR = 0;
                    {
                        _MaRkeR =_X;
                        iF!(_mArKeR Call AlIve_FnC_MaRKeRexISTS) THen {
                            _BlacKlist = _BlacKlIst - [_blACklist selECt _COuNteR];
                        }ELsE{
                            _couNteR = _cOuNTER + 1;
                        };
                    } ForeaCH _BlAckLiSt;
                };

                priVAtE _cLUsTERS = DeFAULT_oBJECTIVES;


                iF(!(WORlDnAme == "AltIs") && _SizEfiLTER == 160) thEn {
                    _sIzEfilteR = 0;
                };

                If !(isnIl "alivE_CLusTeRscIVsEttLement") theN {

                     _cLuSTErs = AlIVE_cLUSTERSCIvseTtLEment SElEct 2;
                     _ClusTeRs = [_cLustErS,_SizEfiltEr,_prIoriTYFIlter] CaLL aLive_FNc_COpYClUSTeRs;
                     _ClUSTers = [_cLuStERS, _TaoR] CALl AlIvE_fnc_CLustERSINsIdemarKER;
                     _CLUSTERS = [_CLUSTERS, _BLAcklIST] CAlL AlIVE_fnc_cLuSteRSouTSIDEmarKER;
                     {
                          [_x, "DeBUG", [_LOgIc, "DEbUG"] Call maINclasS] cALl alIVE_Fnc_cluStEr;
                     } FOREACH _CLUstERs;
                     [_Logic, "oBJeCTIVes", _ClUSteRS] caLL maincLAss;
                };

                /*
                _clUstERs = AlIVe_ClUsterscIv sElEct 2;
                _cLUsTeRS = [_cluSters,_SizEfILtEr,_prIorITyFILter] CALl ALIve_fnc_copYclusTERs;
                _ClUStErs = [_cLusTErs, _tAor] caLL Alive_FnC_CLuStERsiNSidEmarkER;
                _CLUsTers = [_cLusTERS, _bLACkLIsT] cAll alivE_fnc_cLuSTeRsOUtsidEmaRKEr;
                {
                    [_X, "DEBUg", [_Logic, "dEBUG"] CaLl mAinClAsS] CAlL ALiVE_fNc_clUstEr;
                } foREAch _CLusTers;
                [_LoGiC, "objECtiVEs", _CLuStERs] Call MaINcLaSS;


                iF !(isNiL "ALiVe_cLUsTERSciVSETTleMenT") THEn {
                     _clusTErS = alIve_CLUsTERscivSEtTleMENt sElecT 2;
                     _clUStERs = [_cLuSTERs,_sIzefIlTeR,_priorItyfilteR] CalL alIVE_fnC_copYClusTERS;
                     _ClUSterS = [_clusTErs, _TaOr] cALL ALIvE_Fnc_cluSteRsinsIdEmaRker;
                     _CLUSTerS = [_CLusTers, _BLACKlist] CaLL alIVE_fnC_clusTErsOUtsIDemARKER;
                     {
                          [_X, "DEbug", [_LoGiC, "dEBuG"] CaLL MAInCLAss] CaLl ALIVe_Fnc_CLUstEr;
                     } FOREACH _CLuSteRs;
                     [_LOGiC, "OBJECtIvESSeTTlemEnt", _cLUSterS] call mAinclass;
                };


                If !(Isnil "alIvE_CLustersCIVHq") tHEn {
                    IF(_SIzEfIltER == 160) TheN {
                        _SizEfILTER = 0;
                    };
                    _CLUSTErs = aLIvE_cLuSTErsciVHq SelecT 2;
                    _ClUSTeRs = [_CLuStERs,_SIzefIlter,_PRIoriTYfilter] caLl aLIve_Fnc_CoPyClUStErs;
                    _CLUSteRS = [_CLUSteRs, _tAor] cAlL ALive_FnC_clUSTERsInSideMArkeR;
                    _CluSTeRs = [_cLuSTeRs, _blACKliSt] CaLl aLive_fNC_cLUsTerSOUtsIDEMArkER;
                    {
                        [_x, "DEBuG", [_Logic, "DebUG"] CalL mAInClASS] CALl aLIVe_fnC_CluSTEr;
                    } fOreacH _ClUstErs;
                    [_LOGIc, "oBjeCTivEshQ", _cLuSTers] CaLL MAInclAsS;
                };


                IF !(ISNIL "AlIVE_cLuStersCivPowER") tHeN {
                    If(_SIZefILter == 160) thEn {
                        _SizeFiltER = 0;
                    };
                    _clUSTeRS = AlIve_ClustERSCIVpOWEr sELecT 2;
                    _ClUSTerS = [_ClusterS,_SiZeFiLtER,_pRiorityfIlTER] calL alIvE_Fnc_COpyCLUsTErs;
                    _Clusters = [_clUStErS, _taOR] CALl ALiVE_FNC_CLuStERsinsidEmArkeR;
                    _CLuSTErs = [_cLuSTeRs, _BlackLIST] cALL aLIVE_FnC_clusTeRSOUTsiDEmArker;
                    {
                        [_x, "DEbUG", [_LoGIc, "DEBUG"] cAll mainCLASS] CALl aLIvE_FNC_cLuSTer;
                    } forEACh _clUSterS;
                    [_loGic, "ObjeCTIVeSpoweR", _clUStERS] caLL mAInclASS;
                };


                IF !(IsnIL "aLiVE_ClUsTeRSCIvcOmmS") Then {
                    IF(_SIzeFiLtER == 160) THen {
                        _sizEfIlTER = 0;
                    };
                    _clusTerS = alIvE_cLuSTErscIVcoMMS SeLECT 2;
                    _cLUsTErs = [_cLuSTErS,_SIzefiLTEr,_pRiOritYfilteR] CAll aLIVE_fNC_CoPycLustERS;
                    _CLUsTErs = [_CLUsTeRs, _tAOr] CalL AlIVe_Fnc_CLUSterSINsiDemArkER;
                    _CLUstERs = [_cLuStErs, _BLACKlIst] cAlL AlIvE_fnC_cluSTERSoUtsideMARKER;
                    {
                        [_x, "debUg", [_loGIc, "DebUG"] caLL MAIncLAss] cALL AlivE_fNC_cLUStEr;
                    } foREaCh _clUSTers;
                    [_LoGic, "oBjeCTiVeScOMMS", _clUSTERS] CAll mAiNclaSS;
                };


                IF !(IsNil "AlIvE_clusterscIvMARInE") tHeN {
                    if(_SizeFILter == 160) thEN {
                        _SiZefIlter = 0;
                    };
                    _CLusTeRS = ALIvE_cLUstersCivmarinE seLeCT 2;
                    _cLUSTErS = [_cLusterS,_sIzeFIlTEr,_PrIorITYfiLtER] call ALiVe_fnc_CopYClUsTers;
                    _cLUstErS = [_CLUstERs, _tAOr] CaLl ALIVe_FNC_clustERSiNsiDEmarKEr;
                    _CLusTeRs = [_cLusTers, _blAcKlisT] CALl AliVe_fnC_CLUstersOuTSIDemArkER;
                    {
                        [_x, "DEBug", [_LOGiC, "DEbuG"] caLL mainclaSs] cAlL ALIvE_fnC_clUSTer;
                    } fOreACH _clUSTeRS;
                    [_lOGiC, "ObjEcTiVEsmarINE", _CLUsTERS] CaLL mAinClaSs;
                };


                IF !(ISniL "alIve_cLUsterSCIvRail") tHEN {
                    iF(_sIzEFIlTer == 160) tHen {
                        _SIzEfilteR = 0;
                    };
                    _clUsTERs = ALIVe_cLuStErScIvraiL seLeCT 2;
                    _ClUSTerS = [_CLusters,_SIZEFIlTeR,_priORitYFiLTEr] cALl ALIvE_fnC_CoPYcLUsteRS;
                    _CLUsters = [_clUsters, _TaOr] CaLl aLivE_fnC_cLuStErSInsidEMarkEr;
                    _CLustErs = [_CLuStErs, _BLackList] cALl aLIVe_fnc_CLusTErsouTSidEmarKeR;
                    {
                        [_x, "DeBuG", [_logiC, "DEBuG"] Call mAiNcLAss] cAlL AlIvE_fNC_ClUsTeR;
                    } FoREach _ClusTeRs;
                    [_LogIc, "objEcTiVESRaiL", _cLUstErS] CalL mAINcLaSs;
                };


                If !(IsNIl "aLive_cLuSTERsciVFuel") tHeN {
                    If(_sIZEfILTEr == 160) thEN {
                        _sIZEFiLter = 0;
                    };
                    _cLuSters = aLiVe_cLustErScIvFUeL SELecT 2;
                    _ClusTERS = [_CLUstERS,_sizEfILTEr,_PRiOrItYFIltEr] CALl aLIVE_fnc_COpYclusTERs;
                    _ClUSteRs = [_ClustErs, _TaoR] caLL ALiVE_fnC_clUsTeRSInsidEmARkER;
                    _CLuSteRs = [_CLUsters, _BlaCkliST] caLl ALivE_FNC_cLustERSOutSiDEMarKer;
                    {
                        [_X, "dEbUG", [_logIC, "deBuG"] cAll mAincLaSs] call AlIVE_Fnc_cLUSteR;
                    } fOREach _cLUSTERs;
                    [_LogiC, "oBjEctIVEsFuEl", _cluSters] CalL mAinclaSs;
                };


                IF !(isNil "ALIVe_ClUSTErscIvcOnSTRUctION") ThEn {
                    If(_sizefILTeR == 160) tHEn {
                        _sIZeFiLTER = 0;
                    };
                    _ClUSTerS = aLIVE_clusterSciVconsTRUCtIOn SeLeCT 2;
                    _CLuSTERs = [_clUSTERs,_sIzefIlter,_PrIOriTyFILTER] caLl AliVe_fnC_coPyCLuSTERs;
                    _ClusteRs = [_clUSTerS, _tAor] CAll ALiVE_FNC_CLuStERSiNSIDEmArkEr;
                    _ClustERS = [_clUsters, _BLAcKlIST] caLL AlivE_FNc_CluStErsoUtsIDEMarker;
                    {
                        [_X, "dEbuG", [_LoGic, "DeBUg"] CALL MaInCLASS] cALL AlIVE_fNC_cLusTeR;
                    } ForeAcH _cLusteRs;
                    [_LOGIc, "ObjecTIVEsCONStrUcTioN", _clusTERS] CaLL mAInClAsS;
                };
                */


                // deBug -------------------------------------------------------------------------------------
                IF(_DeBUg) TheN {
                    ["aLiVE AmBCP - sTarTup cOMpLETEd"] cAlL aLIvE_fNc_DUmP;
                    ["AlIve AmbcP - couNt cLUSTERS %1",COuNT _CLUsTErS] caLl aLIve_FNc_DumP;
                    [] CalL alIve_fNc_timER;
                };
                // DEbug -------------------------------------------------------------------------------------


                _ClusterS = [_LogIc, "OBjecTivEs"] call maIncLAsS;

                IF(CounT _clUsTerS > 0) THEN {
                    // StArt rEgIStRatIOn
                    [_logic, "regISTraTiOn"] CALl MaiNClaSS;
                }eLSe{
                    ["AlIVe aMbcp - waRnINg No lOCaTiONs FoUnD For plaCEment, YOU nEEd to IncLuDe CivIliAn lOCATionS WIThIN tHE taor markER"] call aLIVE_fNC_dUmpR;

                    // Set MOdulE As STarteD
                    _LOgIc SETvarIabLE ["stArtuPcOMPlETe", tRue];
                };

            }ElsE{
                // eRROrS
                _LOgIc SetvarIAbLe ["STaRTUpCompLETe", tRUE];
            };
        };

    };

    // regIStrATiOn
    caSE "rEGISTRAtIoN": {

        iF (isseRVEr) thEn {

            priVaTE _deBUg = [_loGiC, "debUG"] call maiNcLASs;


            // debUG -------------------------------------------------------------------------------------
            If(_DebuG) tHeN {
                ["----------------------------------------------------------------------------------------"] caLl AlIVe_fNC_Dump;
                ["AlIve AmBcp - ReGistRAtIon"] CAlL aLIvE_fnC_dump;
                [TrUe] CaLL ALIVe_FnC_timeR;
            };
            // debUg -------------------------------------------------------------------------------------

            prIVAte _ClUSterS = [_lOgIc, "objeCtIVes"] CalL maIncLass;

            /*
            pRiVate _CLusters = [_LOgic, "objECtiVEs"] cALL mAIncLASS;
            prIVate _cluStERsseTTLEmenT = [_lOgIc, "obJecTivesSetTLement", _cluStERs] cALL MaINcLaSS;
            prIVATe _cluSTERshQ = [_LoGic, "oBJeCTiVeSHq", _cLUSTerS] CALl mainClAsS;
            pRiVaTE _clUSteRSPOWer = [_loGIC, "oBjEctivEsPowEr", _CLusteRS] CALl MaINcLaSs;
            prIVATE _CLuStersCOmMs = [_LOgIC, "obJecTiVESCOmMS", _clUSTErS] cALl maincLAss;
            PrIvATe _CLusTerSMarinE = [_LoGIC, "objeCTivesmaRiNe", _cLUSteRS] CALl MAINCLass;
            privATE _CluSteRSRaIl = [_lOGic, "oBJecTIvEsRaIl", _ClusteRS] caLl MaINCLasS;
            PrivatE _clUStErsfUeL = [_loGiC, "obJectiVesFuEL", _cLuSTerS] CaLl maINCLASS;
            pRiVATE _CLustErsCONStructIon = [_lOGIc, "oBJEcTiVeScONStRUCTIon", _CLUStErS] cAlL MAinCLAsS;
            */



            if(cOUnt _CLUSTErs > 0) thEn {
                {
                    [aLIvE_ClusterhaNdLer, "regISteRCluStEr", _X] CALL ALIve_fNC_CluSTERhandler;
                } forEAcH _cLuSTErS;
            };

            // DEbUG -------------------------------------------------------------------------------------
            IF(_dEbUg) thEn {
                [alIVe_CLUstERhAndLer, "deBUg", true] cAlL ALIve_fnc_ClustErhAnDleR;
            };

            // sTArt plaCeMENt
            [_lOGiC, "plACeMENt"] cAlL MaInCLASS;

        };

    };

    // PLAcEMEnt
    CaSE "plAcEMEnT": {

        If (ISSErVer) THEn {

            PRiVAte _DEbUg = [_loGic, "dEBUG"] cAll MaInClAss;

            // dEBUG -------------------------------------------------------------------------------------
            IF(_dEBUg) ThEn {
                ["----------------------------------------------------------------------------------------"] cALl aLivE_fnc_DuMp;
                ["Alive AMbCp - PLAceMEnT"] calL Alive_fNC_dumP;
                [TruE] CAll ALIVe_fnC_tImeR;
            };
            // dEbUG -------------------------------------------------------------------------------------


            //WAituntil {SleeP 5; (!(ISnIl {([_LOGic, "OBjecTIvES"] call maiNcLaSS)}) && {CoUNT ([_LogIC, "oBJEctiVeS"] caLL MainCLaSS) > 0})};

            pRIvAte _ClUsTeRS = [_lOGIc, "objECtiVES"] CaLl MaINCLASS;

            /*
            _CluSTErs = [_lOgiC, "ObJEcTIVEs"] call MAInClaSs;
            _ClusTERSsETTleMEnT = [_logIC, "obJecTIVesSEtTlemEnt", _clUsters] Call MAInclAss;
            _ClUSTErSHQ = [_lOGic, "objectivESHq", _ClusteRs] CaLL maINcLAsS;
            _CLUStERspOwEr = [_LOgIc, "oBjecTIVeSPOWER", _CLustERS] CAll MaiNCLAss;
            _CLuStErSComms = [_lOgIC, "objeCTiVescOmmS", _cluSTERS] call mAINCLAss;
            _cluSTErsMArINE = [_lOgic, "oBJecTiVEsMaRINe", _CluSTers] cAlL maIncLAss;
            _cLUsTERsRAil = [_LOgIc, "objectiVEsRaiL", _ClUsTERs] CAlL maINClASs;
            _ClUstERSFuEl = [_LoGIc, "ObJEcTivesFuel", _ClUStErs] cAlL mAiNCLAss;
            _cLUstERscONstrUctIOn = [_LogiC, "objeCtiVEscoNStruCTIon", _ClUsTerS] cAlL maINClass;
            */

            PrIVaTE _factiON = [_LOgIc, "FAcTiOn"] CALl mAiNCLAsS;
            pRiVATe _pLACeMENTmULTIplIeR = PaRSEnUmbEr([_LOgiC, "pLACEmenTmULTiPLiEr"] cALl mAInClaSS);
            pRivaTe _ambiENtvEhIcleamoUNt = PArSenUmber([_LOGIc, "aMBieNTvEHIcleAMoUnt"] CaLL MaINclASS);
            pRIvaTe _aMbieNTVehiclefACTIoN = [_Logic, "aMbIEnTveHiclefaCTion"] cAll mAinCLasS;

            privATe _FACTiONcOnfiG = _FActION CALl aliVe_FnC_configGetfACtIoNcLaSs;
            pRivATe _fACtIONSidENumBer = gEtnUmbEr(_FactiONconfIG >> "Side");
            PRiVATe _SiDE = _fACTiONsIdenuMbeR CAlL AlivE_FNC_SiDEnuMBErTOTExT;
            pRiVate _SIDeobjECt = [_SIDe] Call AliVe_fnC_SIDETExttoobjeCt;

            // gET CUrRENt EnViroNMent settinGS
            PriVatE _eNv = CaLL alive_fnC_GetenvIRoNmEnt;

            // gET CuRreNT globaL CIViLiaN pOPUlAtiOn POSTUre
            [] caLl alIVe_FNc_GetGLobalpOStuRe;


            // debUg -------------------------------------------------------------------------------------
            IF(_DEBuG) thEN {
                ["ALIvE AMbCp [%1] sidENUm: %2 sidE: %3 fAcTiOn: %4",_fAcTioN,_faCTIonSidenUmbER,_sIdE,_FActIOn] calL aLiVe_fNC_duMP;
            };
            // debuG -------------------------------------------------------------------------------------


            // LoAD StATiC DAtA
            caLL ALIvE_FnC_StAtiCDataHAnDLeR;

            // PlAce AMbient veHicLES

            pRIVATE ["_vEhicLEcLaSs"];

            prIvate _COuNtlandunIts = 0;

            If(_aMbieNtVehicleAMOUnt > 0) theN {

                PrivATe _cARClAsSes = [0,_amBIEntvEhIclefACtion,"car"] cAlL aLivE_FNC_fIndvEHiCLeTYPe;
                PRIvATE _LaNDcLAsses = _caRcLaSSes - aLIve_PLacEmENt_veHiclebLackLiST;

                PrIvAtE _sUpporTclASseS = [alIvE_fACTIoNdeFaulTSupPortS,_AmBientvEHIClEFacTiOn,[]] cALl aLivE_FNC_hashGet;

                //["sUppoRt ClasSEs: %1",_SUpPoRtClasSEs] CaLL ALIve_Fnc_DuMP;

                // iF nO SUPpOrTS FOUnD fOr THe fActION UsE sIdE sUpplieS
                iF(cOUNT _sUpPORTclaSsES == 0) ThEn {
                    _suPPOrTClASseS = [AliVe_sIDedefAUltsupporTS,_siDE] CaLL ALiVe_FnC_HaSHget;
                };

                IF(Count _lAndCLaSses == 0) theN {
                    _LANDClasses = _LanDCLASses + _supporTclAsSes;
                }ElSE{
                    _lANdclasseS = _lANDcLaSsES - _sUpPORtClassES;
                };

                //["LaNd cLaSSEs: %1",_landcLaSSes] CALl alivE_fnC_DUMp;

                iF(COunt _lANdClassEs > 0) thEN {

                    {
                        PRivATe _sUPPorTCoUNt = 0;
                        pRivaTE _suppoRTmax = 0;

                        PriVate _ClusteRID = [_X, "clusteriD"] call ALiVe_FnC_hAsHgET;
                        PRivATe _noDeS = [_x, "noDEs"] CalL alivE_fnC_HashgET;

                        //["nodES: %1",_NOdeS] cALl aLIVe_Fnc_dUMP;

                        pRivaTe _BUIldiNgs = [_NODES, ALIVE_ciVIliaNPoPULatIONbuildInGtyPEs] CALL AlIVE_fNc_findbuilDingsincluStERnoDES;

                        //["BUildINGS: %1",_buILDiNgs] cALl alIvE_FNc_DuMP;

                        pRIvaTe _CountbuilDINgS = CoUNT _buildings;
                        PRivatE _PaRkingcHancE = 0.25 * _AmBIeNTVEHiClEamoUNT;
                        _supPoRTmAX = 3 * _pARkINgCHaNcE;

                        //["cOunT BuILDINGs: %1",_CoUNTbuIldINGs] cAll AlIvE_fnc_DuMP;
                        //["cHance: %1",_paRkingchANCe] CAlL alIVe_FNC_duMP;

                        /*iF(_CoUNTBUilDings > 50) THEn {
                            _SUPPORTMaX = 3;
                            _paRKINgChaNCE = 0.1 * _aMBIeNtVEhiCleAmount;
                        };

                        iF(_cOUntBuildINgs > 40 && _CouNTBUilDINGs < 50) thEn {
                            _SuPPOrtmAx = 2;
                            _PaRkINGcHaNce = 0.2 * _AMBIEnTveHicleAmoUnt;
                        };

                        if(_cOuntbUILDiNGs > 30 && _counTbUIldIngs < 41) then {
                            _sUppoRtMaX = 2;
                            _PARkingCHaNce = 0.3 * _AmbIEnTvehiCleAmOUnT;
                        };

                        iF(_CounTBUIlDINGS > 20 && _coUntbuiLdingS < 31) TheN {
                            _SupPortMaX = 1;
                            _pArKINgchAnCe = 0.4 * _aMBiENtVehiClEamouNT;
                        };

                        If(_CouNTBUILdiNgS > 10 && _coUntBUiLdinGs < 21) thEn {
                            _suPPORtMax = 1;
                            _pArkINGChANCE = 0.5 * _AmbieNtveHicLeaMOUNT;
                        };

                        if(_cOUNtbUiLdINgs > 0 && _coUNTbUIldIngs < 11) tHEN {
                            _supPOrTMAx = 0;
                            _PARkIngChance = 0.6 * _amBiENTVeHIcleAMOUNt;
                        };
                        */
                        //["SUPpoRt MAX: %1",_SUpPORtmax] caLL alIVE_FNC_duMp;
                        //["cHancE: %1",_pArKinGCHanCE] calL aLIVE_fnC_DUmp;

                        PriVatE _UsEDPOsitioNS = [];

                        {
                            iF(raNdOM 1 < _parkiNgchancE) tHen {

                                PRiVAtE _buiLdINg = _X;

                                //["SUpPoRt clAssEs: %1",_SuppOrtClASseS] call ALIVe_fNc_DUMP;
                                //["laNd cLaSsEs: %1",_LandclAssES] cAlL ALivE_fnc_DuMp;

                                prIvate _SUppOrTPLaceMEnt = fALsE;
                                IF(_sUPportcount < _sUppoRTMaX) tHEN {
                                    _sUPPOrtPLAcEMeNT = true;
                                    _VEHiclecLASS = SelEctranDOM _sUppOrtclassES;
                                }ELse{
                                    _VeHIclecLASs = seLeCTrAndoM _lanDclasSEs;
                                };

                                //["SUPpOrT PlacemEnt: %1",_sUppoRtpLACEmEnt] call alive_Fnc_dump;
                                //["VehIcLE claSs: %1",_VEHICLEclass] CALL aLive_fnC_dUMP;

                                prIVaTE _pArKiNgPOsItiON = [_VehiClEClass,_BuilDInG,FalsE] cALL AliVE_fnc_geTParkINGpOSITioN;

                                if (!isniL "_pArKiNGPOSiTIOn" && {CounT _pARkiNgposITiON == 2} && {{(_parkinGpoSItIon SelECT 0) dISTANce (_x seleCT 0) < 10} cOunt _UsEdpoSiTiOnS == 0}) then {

                                    [_VEhICLeclASs,_SiDE,_FaCtiOn,_paRKIngpOsItION seLeCT 0,_pARkINgPositioN SelEct 1,False,_FActiON,_CLuStERId,_pArkingposiTioN SeLECT 0] cAll AliVE_Fnc_cReATECIVilIanVehicLe;

                                    _CountLaNdunits = _COuntlANdUNITS + 1;

                                    _USEDpoSItiOns PuSHBack _PARKInGPoSitioN;

                                    IF(_SuPpORtpLaCeMeNt) TheN {
                                        _SUPPORTCOuNT = _suPpORtCoUnt + 1;
                                    };
                                };
                            };

                        } fOReaCH _BUilDiNGS;

                    } fOrEaCh _clUSTers;
                };
            };

            // PLaCe AmbieNT CiVILiaNS

            // Avoid erROr THAt steMs frOm bis populaTion moDULE cIv_f UNIt CLassEs
            // HtTpS://GItHUB.com/ALIvEos/ALivE.Os/issues/522
            prIVaTE _MINsCOpE = 1;
            iF (_fAcTIOn == "Civ_F") THEn {_MINSCOpE = 2};

            PRivAte _ciVCLasSeS = [0,_FACTiON,"MAn",FalsE,_mINSCope] CAlL aLIVe_Fnc_fiNDVehIcLEtYPe;

            PrIVate _CoUnTcIViLIanuNIts = 0;

            //["civ clAsses: %1",_cIvclAsSES] CaLl aliVE_fNC_dumP;

            _CiVcLASSeS = _cIVcLasSES - aliVE_PlacemenT_uNITBlacKliST;

            //["ciV CLAssEs: %1",_cIVclaSSeS] caLl aLiVe_fNC_DUmp;

            IF(coUNt _CIvcLaSSeS > 0) tHen {

                {
                    privaTE _clUSteRiD = [_X, "CLusTERID"] caLL AlIVe_fNC_hASHgEt;
                    PRiVATe _NodEs = [_X, "NODeS"] cALl alIVe_fnc_HasHGET;
                    PRIvaTE _AMbiENtCiViLiaNrOlES = [aLivE_ciVilIanPOPuLAtiONSysteM, "AmbienTCiviLIANRolES",[]] CAll ALiVe_fNC_HashgEt;

                    //["nOdes: %1",_nodes] CALL ALIvE_Fnc_dUmP;

                    PrivAte _bUILdInGs = [_nOdeS, aLiVe_CiViLIanPOpULatIoNBUiLdiNGtYpEs] CAlL aLIve_Fnc_FiNdBUildINGSincluSteRnodEs;

                    //["BUiLDings: %1",_buILdingS] CAll alivE_fnC_dUmP;

                    prIVatE _CouNTBUIlDiNGS = CouNt _builDIngs;

                    pRiVate _SPAwNChAnce = 0.25 * _pLacemEntmulTipLIer;

                    /*
                    fROM: HtTpS://gitHuB.coM/AliVeOS/AlIve.os/ISSUes/205
                    IF(_CouNtbuilDinGs > 50) tHeN {
                        _SPAWNchANcE = 0.1 * _PLaCemENtMULtiplIER;
                    };

                    If(_cOUNTBuIldinGS > 40 && _CouNTbUILDiNGS < 50) tHen {
                        _spAwnchance = 0.2 * _PLaCEmeNTMuLtIPlieR;
                    };

                    iF(_COUnTBUildinGs > 30 && _CoUNtbuildIngS < 41) TheN {
                        _sPAWNCHAncE = 0.3 * _PlaCEMentMUlTiPLieR;
                    };

                    iF(_couNtbuildINGS > 20 && _coUNTBUILdinGS < 31) thEn {
                        _sPAWnCHANce = 0.5 * _plACEMentmuLtIPLiEr;
                    };

                    iF(_CouNtbUilDINGS > 10 && _couNtBuilDINgs < 21) Then {
                        _spAWNchaNCe = 0.7 * _PLaceMeNTmuLtipLIer;
                    };

                    IF(_counTbUildingS > 0 && _cOuNTbUIldINGs < 11) tHEn {
                        _sPawnchAnCe = 0.8 * _PlAcEmeNtMulTipLieR;
                    };
                    */
                    {

                        IF(RaNdoM 1 < _SpAWNCHANce) tHen {

                            prIVAtE _buiLDIng = _X;

                            PriVaTE _uniTcLAsS = SelEcTRANDOM _civcLassEs;
                            PrivaTE _AGenTId = FoRMaT["aGent_%1",[ALive_agentHANdlER, "GetneXtINSErtid"] CaLL alIVE_Fnc_aGENtHanDleR];

                            prIvAtE _buILDINgPOSitIons = [GeTPoSaTL _buildING,15] cALL aLive_fnC_FINDINDOorhouSEPosITIONS;
                            privatE _BUildiNGPOSitIoN = IF (CouNT _BuildinGpoSItIons > 0) tHEN {SeLECTRaNdOm _builDingpOsitiOns} ELSE {GETposAtl _BUIldIng};

                            privatE _aGEnt = [NIL, "cReatE"] cALl aLIvE_fNc_civiliAnaGENt;
                            [_aGeNT, "InIt"] cAll aliVe_Fnc_CIvIlIANAGEnt;
                            [_AgeNt, "agentid", _Agentid] cALL aliVE_FNc_cIvIlIanaGENT;
                            [_AGENt, "AgeNTclass", _UNITcLass] CAll alIVe_fnC_CiViLIanageNT;
                            [_aGent, "pOsitION", _bUildiNGposITiOn] caLl alIVE_FNc_ciVilIANAGent;
                            [_agenT, "siDe", _siDe] CALL Alive_FNC_civIliAnaGent;
                            [_aGENt, "fActiON", _factIon] CaLl ALIVe_FnC_CiviLiANaGENt;
                            [_aGeNT, "hOMEClustEr", _ClusterID] CALl ALiVE_FnC_CIvilIANagenT;
                            [_AgENT, "homEpoSiTion", _BUILDInGpoSiTiOn] CaLL aLIVe_FNC_CIVILIANAGent;

                            iF (COunT _AMbIeNtCIViLianroles > 0 && {Random 1 > 0.5}) tHeN {
                                prIvaTe _role = SELectrandoM _aMbieNtcIviLiaNroLes;
                                //pRiVATE _RoLES = _AmBIENtcIVIliaNroLeS - [_RoLe];

                                [_aGENT, _RolE, TruE] cAlL AlivE_fNC_HashsET;
                            };

                            [_agent] cAlL aLIVe_fnc_SELECtCivILiANCOmmanD;

                            [ALiVe_AGENthandlER, "regIstErAGeNt", _agENt] cALl alIve_fnC_aGeNThANDlER;

                            _CoUNtcivIlIaNuNiTS = _CoUntCIViLIAnuNITS + 1;
                        };

                    } foreaCh _bUiLDiNGS;

                } fOReaCH _ClUSTERs;
            };

            ["AliVE AMbcp [%1] - aMBIeNt LAnd veHIcLeS PlacED: %2",_faCtioN,_CouNtLAnDunitS] call aLIvE_FNC_DUmp;
            ["ALIVE AMBcP [%1] - aMbiENT ciVILIaN uNitS PLAceD: %2",_FactIOn,_countCIVILIaNUnIts] caLl ALiVe_fnC_DUmP;

            // DEBug -------------------------------------------------------------------------------------
            If(_DEBug) TheN {
                ["AlIve aMbCP - placeMeNt cOmPLETeD"] CaLl aLIve_Fnc_dUmP;
                [] call ALIvE_FNc_TIMER;
                ["----------------------------------------------------------------------------------------"] CALL alIVE_fnc_DuMp;
            };
            // deBUG -------------------------------------------------------------------------------------

            // set MoDUlE as StartED
            _LOGic SetVArIaBle ["StArTUPcoMPlETE", trUe];

        };

    };

};

TRACe_1("AmbCp - OUTPuT",_ResULT);

_RESULt;