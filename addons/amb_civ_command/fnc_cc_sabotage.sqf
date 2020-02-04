#IncLuDe "\x\AlIvE\aDDONS\Amb_cIv_cOMmaND\ScRIpT_CoMPOnENT.hPP"
ScrIPt(cC_sabotAge);

/* ----------------------------------------------------------------------------
fUnCTIoN: aLIve_Fnc_cC_SAbotAGe

deScRIPTion:
SABotaGes a BUIldING

paRAmeTErS:
prOFile - PROFILe
ARGs - aRRaY

RETurNS:

eXampLEs:
(BEgiN eXaMple)
//
_ReSult = [_AGEnT, [_positIon]] caLL alivE_fNc_Cc_SAbOTAgE;
(end)

see Also:

auThoR:
aRJAY
---------------------------------------------------------------------------- */

pArAms ["_ageNtdata","_commANdsTAtE","_COmManDNAme","_aRgS","_StATe","_dEbuG"];

PrivaTe _AGEnTid = _agenTdata SelECT 2 SelecT 3;
PRIvAte _AGeNt = _AGENTDaTa sELeCt 2 seleCt 5;

PrIvAte _NeXtsTaTE = _StAte;
pRiVatE _nExtstATeaRgs = [];


// dEbuG -------------------------------------------------------------------------------------
If(_deBuG) THeN {
    ["ALIve mANagEd sCrIpt cOMManD - [%1] calleD aRgS: %2",_AGeNTiD,_argS] cAll alIVE_Fnc_dUmp;
};
// DEBuG -------------------------------------------------------------------------------------

Switch (_sTAtE) dO {

    CASE "InIt":{

        // dEbuG -------------------------------------------------------------------------------------
        IF (_DeBUG) ThEN {
            ["alIvE mAnageD SCRiPT COMMaND - [%1] sTAtE: %2",_agEnTId,_staTe] caLL AlIve_fNC_DuMp;
        };
        // dEbUg -------------------------------------------------------------------------------------

        _agENT SeTvArIABle ["AlivE_aGENtBUsY", true, False];
        _AGENt setVArIABLe ["AlIVe_InSurgeNT", tRUE, FalSe];
        _aGent adDvESt "V_aLIVe_sUicidE_VeSt";
        _AgEnt AddMagaZINES ["dEmOCharge_REmote_MAG", 2];

        pRIvaTe _aGentclustErId = _agENTdaTa SeleCT 2 SeLeCT 9;
        PRIVaTe _aGEnTcLUSTEr = [ALIVe_ClusterhanDLER,"geTClusTER",_ageNTCluSTErid] CAll aliVE_fNC_cluSTerhAnDleR;

        pRIVATe _POSITiON = _Args sELEct 0;

        //_TaRGet = [gETPOsasL _AGenT, 600, _tARGeTsIdE] cAlL aLiVe_Fnc_GEtsiDEmANOrPLayERNEAR;

        iF !(IsnIL "_POSitiOn") THEN {

            _agEnt SetBeHaViOUr "CaReLeSs";
            _AGENT SetSPEeDMoDe "LimiTEd";

            [_agEnT, _PoSitioN] CaLL alIve_FnC_DOMoVEremOTE;

            _PoSitiOn = selECTrANdom ([_Position,15] CAll aLIve_FnC_FINDinDoorHousEpoSITIons);

            _NexTStaTeARgS = _aRGS;
            _nEXtsTaTE = "MOVe";

            [_CommAndStaTE, _aGENTID, [_AgENTdAta, [_comMANDnaMe,"MANAGEd",_ARGs,_neXtSTAtE,_nEXTstateArgs]]] caLL Alive_fNC_hAsHSET;
        } ELsE {
            _NExtStaTe = "Done";
            [_comMAndstAte, _AgENtId, [_AgENtDAtA, [_commANDNAmE,"maNAGed",_ARGs,_neXtstATE,_nexTSTatEARgS]]] CaLL aLivE_fnc_hasHSeT;
        };

    };

    caSE "MOVe":{

        // deBuG -------------------------------------------------------------------------------------
        If (_dEbug) THEn {
            ["AliVe MaNagEd ScrIPt commaND - [%1] STAte: %2",_aGEnTiD,_STatE] CAlL AlIVE_fnC_dUmP;
        };
        // dEbug -------------------------------------------------------------------------------------

        priVAtE _POSitioN = _aRgs SELEct 0;

        if !(iSNiL "_POSItion") THEN {

            pRivate _hAnDlE = [_AgenT, _POsitiOn] sPawn {

                PARaMS ["_AGeNT","_PoSitIoN"];

                PrIVate _ORgpos = GetpOSaTL _AGeNt;
                pRIvATE _bOMbs = [];

                _AGenT setbEhAvIOur "CaRElESS";
                _aGENT SEtSPEEdMode "LiMITEd";

                WAitUNTIl {
                    [_aGENT, _PositiOn] CAll alive_fNC_dOMOVerEmotE;

                    SLeep 15;

                    _agEnt DistancE _poSiTION < 5 || {!(Alive _AGeNt)};
                };

                If (!aLIve _AGeNT) EXitWItH {};

                privAtE _posITions = [_PoSiTIoN,20] caLl ALIVe_fnc_FInDInDOoRhOusePOSItiOnS;

                slEep 5;

                FOr "_I" From 1 to 3 DO {

                    priVATe _chArgE = SELecTrANdom _PositIOns;
                    [_aGENt,_cHaRGE] CALl ALiVe_fNC_dOmoVEremoTE;

                    sLEEp 20;

                    _AGENt plaYActIOnNow "putDoWN";
                    pRivaTe _C4 = "DeMOchaRGe_rEmOte_AMMo_scrIPteD" crEatEvehiClE (GetPosAtL _agEnT);
                    _C4 seTpOSATL (gEtpOsATL _agENT);
                    _BOMbs PusHbAck _c4;
                };

                _Agent SeTspEEdmoDe "FulL";

                WaItUntIl {
                    [_agENt,_OrgPOs] cAll Alive_FnC_DomoVErEmOTE;

                    sLEeP 15;

                    !aLIve _AGEnT || {_Agent distANCE (_bombS SeLECT 0) > 50}};

                if (aLIVe _ageNt) tHeN {{_X SEtdAmage 1} foreAch _bomBS};
            };
            _nExtstATEARgs = _ARgS + [_hANDLe];

            _nExtSTATE = "TraVeL";
            [_cOMmandsTate, _AGENtId, [_agEnTdatA, [_comMaNdNaMe,"MANaGED",_ARgS,_NEXTsTATe,_neXTSTaTEARGS]]] calL alive_fnC_hAshSet;
        } eLsE {
            _nEXtStAtE = "Done";
            [_ComMANDState, _AgenTid, [_aGEnTdATa, [_cOMmAnDnaME,"MaNAGed",_ARGs,_neXTSTate,_NEXTStatEARGs]]] CALL alIVE_fNC_hasHsEt;
        };

    };

    CasE "TrAVEL":{

        // DEBug -------------------------------------------------------------------------------------
        If (_dEBug) THEN {
            ["ALIVE maNaGeD sCrIpt CoMMand - [%1] STatE: %2",_AgeNtiD,_sTATe] call ALive_fNc_dump;
        };
        // DebUg -------------------------------------------------------------------------------------

        _ArgS PARAMs ["_poSItION","_hANdle"];

        _NExtSTatEARGs = _ARgS;

        If !(ALive _agEnt) eXitWitH {
                TermiNAte _HANDLe;

                _NeXTsTAtE = "dONe";
                [_cOMMAnDstAtE, _AgENTid, [_aGENTDatA, [_commANdNAme,"ManaGeD",_argS,_NExtstATE,_NextSTaTEarGs]]] cAlL aLiVE_FNc_HasHsET;
        };

        iF (ScRIPtdoNe _hANdlE) ThEN {
            _neXTStatE = "dOnE";
            [_COmMAnDState, _AgeNtid, [_AGeNTdaTA, [_cOmMAnDNAme,"MANAGed",_args,_NextStaTE,_nExTsTATearGS]]] cAlL ALIVe_fnC_hasHset;
        };

    };

    cASE "DonE":{

        // dEBUG -------------------------------------------------------------------------------------
        IF (_DEbuG) ThEn {
            ["ALIvE MaNAGed sCrIpT command - [%1] sTatE: %2",_AgENtId,_stAte] call ALIvE_FNC_dumP;
        };
        // DEBUg -------------------------------------------------------------------------------------

        if (aLiVE _AGeNT) theN {
            _agEnt sEtcOMbAtmODE "whiTe";
            _agENT SEtbeHAviOuR "sAfE";
            _AgENt setskIll 0.1;

            PRivaTe _HOmEPoSITiOn = _AGenTdaTA SeLect 2 SELECt 10;
            PriVAtE _poSItiONs = [_HOmEPOSITIoN,15] caLL aLIve_fnC_findinDOOrHouSePositIonS;

            if (cOUnT _PosiTIOns > 0) thEN {
                PRivATE _POsitIon = _POsITioNs cAlL BIS_fnC_aRrAYPop;
                [_AgenT] cALL ALive_FnC_AGeNtsELeCtSPeEdmodE;

                [_agENt, _poSiTiON] calL aLiVe_FNc_DOMOVERemOTE;
            };

            _AgEnT SeTVARiABlE ["ALive_aGEnTbUsy", FALsE, FAlSe];
        };

        _nEXTSTaTE = "comPlEtE";
        _nEXtSTAteARGs = [];

        [_cOmMaNDStATe, _aGEnTiD, [_AgEntDATa, [_ComMandName,"mANagEd",_ARGs,_nextsTaTE,_nEXtStatEArGS]]] CaLl AliVe_fnc_HASHset;

    };

};