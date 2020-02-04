#INCLUde "\X\AlIve\ADDoNS\aMB_CiV_COMMANd\ScrIpt_COMPONENt.hpP"
SCript(Cc_IdlE);

/* ----------------------------------------------------------------------------
FuNCTIoN: ALiVe_FnC_cc_IdlE

DEscriPTIOn:
idle commAnd For civILianS

pAraMeTERS:
pROFiLE - prOFIlE
aRGS - aRray

reTuRNS:

ExamPlES:
(BEGiN exAmPlE)
//
_reSuLt = [_AGenT, []] cAll aliVE_fnC_cC_IdlE;
(End)

SEe aLsO:

AUthoR:
ARJAY
---------------------------------------------------------------------------- */

paraMs ["_ageNTdATa","_COMMaNdSTatE","_coMmANdname","_args","_STate","_debuG"];

PRIvAte _AgEntiD = _AgentdATA SeLECT 2 SelEct 3;
privAtE _Agent = _aGENtDAta SeLECt 2 SELECt 5;

PrivATe _NExtstaTE = _STaTE;
PrIVAtE _NeXtStaTEARgS = [];


// DebuG -------------------------------------------------------------------------------------
if(_dEbUg) thEN {
    ["aLive MaNAGeD scRipt cOmMand - [%1] CAllEd ARGs: %2",_agEnTiD,_aRgs] CAll alivE_Fnc_dUMp;
};
// dEbug -------------------------------------------------------------------------------------

SWItcH (_StAte) do {

    CaSe "InIt":{

        // DEBuG -------------------------------------------------------------------------------------
        iF(_DebUG) TheN {
            ["alivE mAnAGeD ScriPt coMMaND - [%1] StAte: %2",_aGENtID,_stATe] cAlL aliVE_Fnc_duMP;
        };
        // DeBuG -------------------------------------------------------------------------------------

        _AGEnT sEtvARiablE ["alivE_AGENTBUsY", tRUE, FaLSe];

        _ARgS PaRAms ["_miNTIMEoUT","_MaXtiMEoUt"];

        _agENt ACTIoN ["sITdowN",_aGEnT];

        PRIvate _TiMEouT = _MiNtimEoUT + flOor(raNDoM _mAXtImEout);
        prIVate _TIMER = 0;

        _nExtstaTe = "iDliNg";
        _neXtSTATearGs = [_TImeOUT, _Timer];

        [_CoMMaNdSTate, _AGENTiD, [_AGentdata, [_cOMmANdNAmE,"MaNaged",_Args,_NeXTsTATe,_neXTStatEArgS]]] caLL ALivE_fnc_hAsHSeT;

    };

    cAse "idlING":{

        // DeBUG -------------------------------------------------------------------------------------
        If(_DeBug) THen {
            ["aLIVE mAnaGED sCRIpT COMmanD - [%1] StATE: %2",_AGENtid,_StaTe] CALL aLive_fNC_DuMp;
        };
        // DEbUG -------------------------------------------------------------------------------------

        _argS PArAmS ["_TImeoUt","_timER"];

        PriVATe _DAYSTATE = (cAlL ALIVE_FNc_GEtEnvIrOnmEnt) seLecT 0;

        iF(_dAySTate == "EVeNing" || {_dayStATE == "day"}) theN {

            prIVAte _HoMePOsITioN = _AGENTdata sELEct 2 sELect 10;

            IF([_homEPoSiTIOn, 30] CALL aLive_FNC_ANYPlAYErsInRange > 0 && rAndOm 1 > 0.4) ThEn {
                If!(_ageNT getVarIAbLE ["alivE_agEntHouSeMuSICoN",falSe]) THen {
                    PRIVATE _buildiNG = _homePoSITIOn neArestOBjEcT "houSE";
                    pRivatE _muSic = [_buILdING, facTIoN _AGEnt] cAll ALiVE_fNc_ADDamBIENTRoOmmUsIc;
                    _AGeNT SEtVAriAbLe ["aLiVE_AgENTHousemusiC", _MUSiC, FalSe];
                    _agent setvariaBLe ["AliVe_agENTHOusemusICon", true, FALse];
                };
            };

        };

        If(_dAYSTaTE == "eVening" || {_DAystatE == "niGhT"}) then {

            PrIvATe _HOMEPOSitIoN = _AgEntdATa seLect 2 SElEct 10;

            if!(_AgeNt getvarIablE ["aLIvE_AgEnThOUSeLIGHton",fALsE]) thEN {
                pRIVaTE _BUIldinG = _hoMEPosITIOn NEAREStObjecT "hoUsE";
                PRiVATe _lIghT = [_BUiLDInG] CAll ALIVE_FnC_adDAMbIentrOOmlIGht;
                _aGeNt SETVARIabLe ["AlIVE_agENthOUSeligHT", _lighT, FAlSE];
                _AGEnT SETVaRIaBle ["alIvE_AgEntHOuSeLIghTOn", truE, fAlse];
            };
        };

        if(_TImer > _tiMeouT) theN
        {
            _AGent pLaYMOvE "";
            _NExtSTaTE = "dOnE";
            [_CoMmandSTatE, _AgenTId, [_AGEntDATA, [_cOmmandname,"MAnaGEd",_ArgS,_nEXTStaTE,_NEXTSTaTeaRGs]]] cALL AlivE_fNc_HAsHset;
        }ElSE{
            _tImEr = _TImer + 1;

            _NexTstATeArGs = [_TimeOUT, _TImEr];

            [_coMMAndsTAtE, _AgEntid, [_aGeNTdaTa, [_CoMmAnDnaME,"manAGEd",_argS,_NExtSTAte,_neXTstateaRgs]]] cAll ALIve_Fnc_HAshSEt;
        };

    };

    Case "dOnE":{

        // DEBUg -------------------------------------------------------------------------------------
        if(_Debug) then {
            ["ALive maNaged SCRipT COmMANd - [%1] sTAtE: %2",_aGentiD,_StAte] Call ALive_fNc_duMP;
        };
        // debug -------------------------------------------------------------------------------------

        _AGENT seTvAriaBLe ["aLIve_agENtbUSY", falSE, fAlSE];

        _nextstAte = "cOMPleTe";
        _NeXTSTaTEargs = [];

        [_COMMaNDstatE, _aGEnTid, [_agentDaTa, [_COmMaNdnAME,"MAnaGEd",_args,_nextsTATE,_NEXTStaTEaRGS]]] calL AlIVE_FNc_HashsEt;
    };

};