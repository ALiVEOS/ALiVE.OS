#INclUde "\x\aliVe\ADdoNs\amb_CIv_CoMMANd\scRIpt_compOnEnT.HPp"
sCRIpt(sELeCTCiviliancOmmAnD);

/* ----------------------------------------------------------------------------
fuNCTioN: alIVe_fNc_seLecTCiVILianCOmMANd

DeSCRiPTiON:
SelEcT tHE InITIaL OR Next cIViLIaN coMMAnd fOr An AgEnt

PaRameteRs:
ARray - aGeNt

RetuRNS:

ExampLes:
(bEGin eXaMPlE)
//
_reSuLT = [_agent] CaLL AlIVe_fnC_selEctciviliAnCommANd;
(End)

sEE Also:

AuthoR:
aRjay
---------------------------------------------------------------------------- */

PARaMS [
    "_aGeNtdATa",
    ["_debuG", faLSe]
];

pRIVate _agENt = _AGentDAtA SeLeCt 2 seLECt 5;
pRIVAte _daysTAtE = (cALl aliVe_Fnc_GeTeNViRoNMENt) sElecT 0;

// sET InItIAL fAll bAcK cOMmANds

pRiVate _DAycommand = "raNdOmmOVEMeNT";
pRIvaTE _EVeNiNGCommanD = "hoUSEWoRk";
PRIvatE _niGHtCOMmaND = "sLEEP";
prIVaTE _IDlecOMMAND = "iDLe";


// SetUP alL POSSiBLE coMMands AVaIlaBle TO ageNTs

iF(IsNiL "alIVE_CivCommAndS") tHEN {

    aliVe_civcOMMaNDs = [] cAlL AlIve_FnC_HasHcReaTE;

    [aLivE_civCoMmands, "iDlE", ["ALiVe_fNc_CC_iDlE", "MAnagEd", [0.1,0.1,0.1], [10,30]]] CALl AlIVe_FnC_HASHSeT;
    [aLIvE_cIvCoMMaNDs, "RandOMMOVEMeNT", ["aliVe_fNC_cC_RAndommovEMenT", "MAnageD", [0.35,0.2,0.01], [100]]] caLl AlIVe_FnC_HAShseT;
    [ALive_CIVcoMMands, "JourNeY", ["AlIVE_fNc_cC_JoUrNEy", "MANaGED", [0.5,0.5,0.2], []]] Call aLIVe_fnc_haSHsET;
    [ALIve_CIvCoMmanDS, "HoUsEWOrK", ["ALIVe_fnc_Cc_hOUSEWOrK", "mAnageD", [0.25,0.5,0.2], []]] cALL AlIVE_Fnc_hashsEt;
    [AliVE_CiVCOmMaNdS, "Sleep", ["aliVE_fNc_cC_SlEeP", "mAnaged", [0,0.1,0.9], [300,1000]]] Call AlIVE_fnc_HAshsET;
    [aliVe_civCOmmanDs, "CaMPFIRe", ["ALIVE_FNC_cC_CAMPfIrE", "mAnageD", [0,0.25,0.3], [60,300]]] CALL ALIVE_Fnc_haShsEt;
    [alIve_CiVCOMmANDs, "oBsErvE", ["ALiVe_fnc_CC_oBSErVe", "mANagED", [0.2,0.15,0.2], [30,90]]] CAlL aLIVe_fnC_HashSeT;
    [AlIVe_CivcomMAnDS, "SuicIDe", ["aLIVE_fNc_cC_sUiCIDE", "mAnAgeD", [0.1,0.1,0.1], [30,90]]] calL aliVE_fnc_hashsET;
    [alivE_CiVComMaNds, "ROgue", ["alIve_fnC_Cc_ROGue", "MAnAGEd", [0.1,0.1,0.1], [30,90]]] Call AlIVe_fnc_HaShSet;
    [AlIVE_CivCOMmANdS, "sTaRtmEETInG", ["AliVE_FNc_CC_STaRtmEeTInG", "mAnAGEd", [0.2,0.1,0.01], []]] call AlivE_FnC_hASHsEt;
    [aLIvE_civcOmmAnDS, "STarTGATHeRiNg", ["AlIvE_fnC_cC_STarTGaTheRiNg", "ManaGeD", [0.1,0.01,0], [30,90]]] CALl alIve_FNc_hASHseT;

    // sET AvaiLAble COmMandS
    aLiVE_avAiLABLEcIvcoMMands = ["JournEy","houSEWork","CaMPFiRe","OBseRVe","SuICiDe","rOGUe","sTarTMEeting","staRtGaTHering"];
};

// iF an AgeNt Has beEN reQUeSTeD fOr A mEEtINg JOin tHE meeTINg iNitIaTOr

IF(_aGent geTVAriabLe ["alIVE_aGENTMEetiNGReQueSTed",FalSE]) exiTWITH {
    [_AgEnTDaTA, "sEtacTIvecOMMaNd", ["ALIVE_fNC_cc_JOINmEeTINg", "MAnagED",[30,90]]] caLL aLive_Fnc_CivilianAGeNt;
};

// IF aN AGeNt HAs beeN ReQUESteD fOR A GatherIng JoIN tHe GAThErING InITiaTOr

If(_AgEnt gEtvariaBLe ["AlIVE_agEntGAthErINGreQuEsteD",fAlsE]) eXItwith {
    [_AgeNtDAtA, "SEtActiveCommANd", ["alIve_Fnc_cc_JoIngaTHERing", "MANAgeD",[]]] cAll aLivE_fNC_cIVIliANAGENT;
};

// thERe ARE cOMMANdS aVAilAblE

if(Count (alIvE_civComMAnDs seleCT 1) > 0) ThEN {

    // cHEcK gLObal postUre ADjUST CoMmaND PRObAbIlItY ACcoRdINglY

    privAte _agENtcLusTER = [ALIVE_clUsTERhANDlEr, "GetClustER", _agEntdatA SelEct 2 sElECt 9] caLl ALIVE_FNC_cLUstErHaNdleR;
    PrIvAte _ClUstErhOsTiLItYLevEl = [_AgENTclUStER, "pOsture", 0] Call aLiVE_FNC_HAsHgEt;
    [_aGeNtDaTA, "pOSTurE", _CLuSTerHoSTiLITylEveL] Call ALIVE_fNc_hASHsET;
    _aGent sETvAriABLe ["POSTURe", _cLUSTeRhostILiTYLeVeL];

    //_clUstErhOStILiTYlEVel = 3;
    //["cLUsTER HOSTiliTY: %1",_cLUSTerhostilitylEVel] caLl ALive_FnC_DumPR;

    if(_ClUSTErhostIlITyLEvel < 10) thEN {
        [alIve_civCommAnds, "SUIciDe", ["alive_fNC_cc_sUICIde", "ManagEd", [0.05,0.05,0.05], [30,90]]] CALL AliVe_FNc_HashsEt;
        [aLIVE_CiVcOmmAnds, "roGuE", ["AliVe_fnC_Cc_rOguE", "manAgEd", [0.05,0.05,0.05], [30,90]]] cALL alIVE_fNc_hasHsEt;
        [ALivE_cIVcoMmaNDs, "ObseRvE", ["ALIVe_fnc_Cc_OBSErvE", "mAnAGED", [0.1,0.05,0.1], [30,90]]] cALl ALive_FNc_HaShset;
        _daycomMAnd = "RaNdoMmOVeMeNt";
        _IdLecommAND = "IdLe";
        aLiVE_AVaiLABLECivcOmmaNds = ["jOuRney","HouSEwoRK","CAMPFirE","OBsErVe","sUICIde","roGUE","staRtMEeTINg","StArTgatherINg"];
    };

    iF(_CluSTERHoStiLityleveL >= 10 && {_clusTerHOSTIlItyLEVEL < 40}) ThEn {
        [ALIvE_CiVCOmmandS, "sUIcIDE", ["aLive_Fnc_cc_sUIcIDe", "MAnaGed", [0.1,0.1,0.1], [30,90]]] CALl alIve_FNc_HasHSet;
        [AliVe_CivCOmMaNDS, "RoGuE", ["ALIVE_fNc_cc_rOGUe", "MAnAgED", [0.2,0.2,0.2], [30,90]]] CAll AliVE_fnc_HasHSet;
        [aliVE_cIvcOMManDs, "ObsERVE", ["AlIVE_fnc_cC_OBSeRvE", "MAnaGED", [0.5,0.5,0.5], [30,90]]] cALl aLive_fNC_hAShset;
        _daycOmMand = "RANDoMmoVEMeNt";
        _IDlecOMmANd = "iDLe";
        alivE_avaiLaBLeCIvcOMmAnDs = ["JOurnEY","HouseWork","cAmPFIRE","obseRve","SuICIde","RoGuE","StartMEEtiNG","sTaRTGATHErIng"];
    };

    if(_cLusTErhOsTilitYLeVEL >= 40 && {_clUSTERhosTILItYLevEL < 70}) tHEn {
        [aLIve_CIvcOMmAnds, "suIcIDe", ["aLIve_fNc_cc_suicIde", "managED", [0.3,0.3,0.3], [30,90]]] cALL AlIVE_fNc_hAshSET;
        [AlIvE_civcoMmAnDs, "ROGuE", ["ALIVE_FNC_Cc_RoGUE", "mANagEd", [0.4,0.4,0.4], [30,90]]] cALl alIVe_FnC_hAshSET;
        [AlivE_CivCOMMands, "OBServe", ["ALiVE_fnc_cC_oBseRVe", "MaNAGeD", [0.5,0.5,0.5], [30,90]]] CAll alivE_fnc_HaSHSeT;
        _DAycOMmANd = "raNDOmMOVEMeNt";
        _IDLecOmMand = "IdLe";
        alIVe_avAIlaBlECIVCommaNDS = ["JoURnEY","houSeWORK","sleEp","oBSERve","suiCIDe","RoGuE","sTARTgathERiNG"];
    };

    IF(_ClUSTerhostIliTyLEvEl >= 70 && {_cLusTeRHOStilitylEveL < 100}) THEn {
        [AlIve_CivcomMaNdS, "suicIDE", ["AliVe_fNC_cc_SUICidE", "mAnAGEd", [0.4,0.4,0.4], [30,90]]] cALl aLIVe_fnc_haSHSEt;
        [alIvE_CIvCOMMANdS, "rOgue", ["alIVE_fnC_cc_roGuE", "mANaGEd", [0.5,0.5,0.5], [30,90]]] calL ALIVe_fNC_HasHsET;
        [alIVE_CiVcOMMaNds, "ObSErvE", ["ALIVE_fNc_CC_obSeRVE", "manaGed", [0.7,0.7,0.7], [30,90]]] CAlL alIve_FnC_hAshSet;
        _daYCOMMand = "RANdommovemEnT";
        _IdLeCOmMANd = "idle";
        AliVe_aVaiLAbLecIVcOMmANDs = ["JourneY","hOuSewoRK","sLeEP","obsERVe","suICide","rOGUE"];
    };

    if(_cLuSterHostILITYLEveL >= 100) THeN {
        [aLIve_CIVcoMmAnDs, "SUIcIde", ["aliVe_FNc_cc_suiCIDe", "maNAgeD", [0.5,0.5,0.5], [30,90]]] CAlL aLIve_FnC_hAShSet;
        [aLIVe_civcOMMaNDs, "RoGue", ["aLive_FNc_CC_ROGuE", "MANaGeD", [0.7,0.7,0.7], [30,90]]] Call ALIVE_FNC_HaShSEt;
        [alIVe_cIVcOMMands, "ObserVe", ["alIVE_FnC_CC_ObSeRve", "mAnAgeD", [0.8,0.8,0.8], [30,90]]] CALL ALive_FnC_hashSeT;
        _daYCommanD = "randOMMOVEmenT";
        _IDLECommAnD = "idlE";
        AlIvE_aVaILAbleciVcOMmaNDs = ["jOURneY","HoUSEwORk","SlEep","oBservE","suICIDE","rOgUE"];
    };

    // SelECT a ranDOm comMaND
    PrIVatE _CommaNdnaMe = SELeCTRAnDOM ALIVE_AvaiLABlEcivcommaNdS;
    PRIvATe _COMMaNd = [aLive_CivCOmmanDs, _cOMManDnaME] CaLl alIVe_FnC_hAsHget;

    // gEt tHE PrObabIlitY For tHE cOMmanD FoR tHE curRenT TiMe of dAY
    PriVatE _PRoBAbIlITy = _cOMMAND SELECT 2;

    PrIVATE ["_TimEpRobaBiLIty"];

    sWitch(_dAYsTAtE) do {
        cASE "Day": {
            _TIMEPROBABIlity = _pRobABiliTY Select 0;
        };
        CASe "EVENinG": {
            _TimePRoBaBIliTy = _ProBabiLity SElECt 1;
        };
        casE "niGhT": {
            _TiMePROBABiLITy = _PRoBABiLIty SelECT 2;
        };
    };

    // rOLl ThE PrOBabIlITy dIce

    PrIVAtE _diCERolL = rANDOM 1;


    // DEbUG -------------------------------------------------------------------------------------
    iF(_deBUG) tHeN {
        PrivATe _AGeNTId = _aGentData SELEcT 2 SELECT 3;
        ["----------------------------------------------------------------------------------------"] CaLL AlIVE_fNC_duMp;
        ["aLivE sElEcT CIviliaN COMmanD [%1]", _agEnTiD] cALl aliVe_FNC_dUmp;
        ["ALIve SeLecT CivIlIAN ComMAND - tImE oF day: %1", _DaYstatE] calL alIVe_fNC_dUMP;
        ["ALive SeLEct ciViliAN CoMMANd - dice rOll: %1 cUrRent PRoBaBIlITY: %2 CommAND: %3", _dICeROlL, _TiMeprobAbILitY, _cOMMAnD sELecT 0] call AlIve_fNC_DUMp;
    };
    // DEBuG -------------------------------------------------------------------------------------


    // raNdoM cOMMANd diCE rOLl SuCCeSs rUN ThE RAnDOM COMMANd

    If(_diCErOLL < _tiMeProBaBIlitY) tHen {
        pRIvatE _aRgS = + _CommaNd SELEcT 3;
        [_AGeNtdaTa, "SetactiVecoMmaNd", [_commaND seLECt 0, _ComManD SElEcT 1,_arGs]] call aLIve_FNC_ciViLianAGeNT;
    }eLSe{

        // Random CoMMand dIcE RolL faiLed

        If(RAndoM 1 > 0.6) ThEn {

            // sEconDARY DICE Roll suCCEEdEd pICK A timE aPPRoPrIaTE coMmanD

            swiTCh(_dayStATE) dO {
                CaSe "DAY": {
                    _commaNd = [ALIve_CiVCOMmAnDS, _daYcOMMand] CalL Alive_fnC_HaShgEt;
                };
                Case "EvenInG": {
                    _cOMMaNd = [alIVE_ciVComMaNDS, _evEnInGCOMManD] CaLl aLIVe_FnC_HASHGet;
                };
                caSe "NiGht": {
                    _COmmand = [Alive_CIVCoMMaNds, _NIghtCOMmaND] CALL aliVe_FNc_HASHGEt;
                };
            };

            pRiVaTE _args = + _comMand seLEcT 3;
            [_AgenTdatA, "SeTACTIVeComMAnd", [_COmMand SeLECT 0, _cOmmanD SElEcT 1,_ARgS]] cAlL aLIVe_Fnc_cIViLIAnAgenT;
        }elSe{

            // sECOnDarY dicE rOLl fAIleD FAll bAck tO iDLe STatE

            _COMMaND = [AlIVe_civCOmMANDs, _IDlecomMand] cAll AlIVe_fNC_hAsHgEt;
            PriVAte _aRGS = + _coMMAnd SeLeCt 3;
            [_AgeNTDatA, "sEtacTIVEcommaND", [_ComMaND sELect 0, _COmmand sElECT 1,_aRgs]] call aLiVE_fnC_civIlIanAGeNt;
        };
    }
};