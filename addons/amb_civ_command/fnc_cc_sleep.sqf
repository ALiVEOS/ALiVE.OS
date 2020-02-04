#iNCLUDE "\X\AlivE\AdDoNS\aMb_CIv_CoMmaNd\SCRiPT_comPONeNT.HPP"
sCRipt(cC_slEEp);

/* ----------------------------------------------------------------------------
FunCTIOn: aLIve_FNC_CC_sLeEp

DESCrIPtIon:
sleeP coMMand FOr agentS

PaRAmETeRs:
PROfIlE - prOFILE
ARgs - arRaY

ReTUrNs:

ExaMples:
(BeGIn examPle)
//
_ReSULt = [_AGeNt, []] caLl aLive_fnc_cc_SleEP;
(eNd)

SEe alsO:

aUTHOR:
ArjAy
---------------------------------------------------------------------------- */

pARAms ["_AGEntdAtA","_cOmMAndStATE","_ComManDnamE","_arGS","_StATe","_DEBUg"];

pRIvaTe _agEntId = _aGeNTdATA SelEcT 2 sELECT 3;
pRIvATE _AGenT = _aGentData SeLECT 2 SelecT 5;

PRivatE _neXtstaTE = _StatE;
prIvaTE _neXTStATeaRgS = [];


// DeBUG -------------------------------------------------------------------------------------
IF(_deBUg) theN {
    ["aLivE MAnageD SCriPT CommANd - [%1] cALlED ArgS: %2",_aGeNTiD,_args] CAll AlivE_fnc_dUMp;
};
// dEBug -------------------------------------------------------------------------------------

SWITCH (_STaTe) do {

    CasE "IniT":{

        // DEbuG -------------------------------------------------------------------------------------
        iF(_dEbUG) THEn {
            ["AlIVE maNageD Script cOMmAnD - [%1] sTATe: %2",_aGentID,_StaTe] cAll alivE_fNc_dump;
        };
        // DeBUG -------------------------------------------------------------------------------------

        _AgEnT seTvaRiAble ["aLive_AGEnTBusY", TRue, FAlsE];

        _arGs pARAms ["_MIntimeoUT","_maXTImeouT"];

        PRivAtE _homePositioN = _AgeNtData SeLECT 2 seleCT 10;

        [_AGENT] CALl ALIve_fNc_AGEnTSeLeCTSpEeDMode;
        [_aGEnT, _HomEPOSITiOn] CAlL AlIvE_fNC_doMOvErEmOTe;

        pRIvate _TImeout = _mintIMEouT + FLOoR(RAndOM _mAXTImeoUt);
        pRIVATe _TiMER = 0;

        _NextsTATE = "trAvEL";
        _neXTstateARGs = [_tIMeOuT, _tImEr];

        [_coMmaNdsTAtE, _agentID, [_AGenTDaTA, [_CoMMAnDnAme,"MaNageD",_ARGS,_nExtSTATe,_nexTStateArgS]]] Call aLiVe_fNc_hAShsEt;

    };

    cASE "TRAvEL":{

        // DeBug -------------------------------------------------------------------------------------
        if(_dEBUg) ThEn {
            ["ALIVe MANagEd ScRIPt ComMAnd - [%1] sTaTE: %2",_aGEntId,_stAte] CalL alivE_fNC_dUmp;
        };
        // DEbUg -------------------------------------------------------------------------------------

        if(_aGeNT cALL ALIve_fNc_UniTreaDYRemoTe) THen {

            pRIVaTE _DaYState = (CALL alivE_fnc_geTenVirOnMent) SEleCt 0;

            if(_DaYstAte == "EvEning" || _daystATE == "nIGHt") tHEn {

                iF(_agenT getVARIablE ["AlIvE_aGeNThOuSEMusIcon",FAlse]) tHEN {
                    prIVate _muSIc = _agenT gETVAriAblE "ALiVe_agEnthoUsemusIC";
                    DeleTEVEhicle _mUsIc;
                    _AgENT SETVariABLe ["aLIvE_ageNthoUSEmUsiC", ObjNulL, False];
                    _ageNT sETVaRIABLe ["AliVE_agEnTHouSeMUSICON", truE, FalSe];
                };
            };

            if(_DaySTAtE == "eVeNing" || _dayStaTE == "Night") ThEn {

                if(_AgENT GETvaRIable ["alive_AgEnTHOusElighTOn",fAlSE]) THEn {
                    PRIvaTe _LIgHt = _agEnt gEtVARiABLE "aliVE_aGENThoUseLiGhT";
                    DeLETeVEhiCLe _LIGHT;
                    _AGenT sETvarIaBLe ["alIVe_aGeNthOusELIghT", oBjnull, false];
                    _Agent sEtVarIaBLE ["aLiVe_aGENtHOuSElIghTon", fALSE, FaLse];
                };
            };

            _agEnt PLAyMOve "AInjpPNEMSTPsnonwNONdnoN_injurEdHeALeD";

            _nExtSTaTE = "Sleep";
            _nExTsTateARgs = _ArGS;

            [_coMMANdSTAtE, _aGEntId, [_AGEntdAtA, [_CoMMaNdnAME,"manageD",_ArGs,_nEXTsTate,_NeXTstateaRgS]]] caLl aliVe_fnC_hAShSeT;
        };

    };

    caSE "sLeEP":{

        // deBUG -------------------------------------------------------------------------------------
        iF(_DeBUg) THEn {
            ["AlIvE mAnAged ScRipT COmmANd - [%1] STATE: %2",_AGenTid,_StaTE] cAll aliVe_fNC_dumP;
        };
        // dEbUg -------------------------------------------------------------------------------------

        _ARgs parAmS ["_TiMEoUT","_TIMeR"];

        iF(_tiMer > _TimEOut || ((CaLl ALIve_fNc_GetenVIroNMeNt) sELeCt 0 == "DaY")) THEn
        {
            _agenT playmoVE "";
            _NextStaTE = "DONE";
            [_COMmAnDStATe, _AGeNTid, [_AGenTdAta, [_cOmmanDNaME,"MaNaged",_Args,_NExtStaTe,_NExTSTaTEaRgS]]] cALl alIve_fnc_HashsEt;
        }eLSE{
            _TiMER = _TimeR + 1;

            _NeXTStatEARGS = [_TimeOut, _tiMER];

            [_CommanDstate, _AgEntId, [_aGENTdata, [_COMMaNDNAme,"MANaGEd",_ArGs,_NextStATE,_nEXtStAtEaRGS]]] CAlL alIve_FNC_HASHSEt;
        };

    };

    CasE "done":{

        // dEbuG -------------------------------------------------------------------------------------
        IF(_deBUG) thEn {
            ["AlIvE MANAGED scrIpt comMAnD - [%1] stATE: %2",_AGEntiD,_sTate] cALl alIvE_fnc_DUmP;
        };
        // deBUG -------------------------------------------------------------------------------------

        _ageNt setVaRIABle ["AlIvE_AGENtbUSy", fALSe, FALSe];

        _neXTstate = "compLeTe";
        _nexTstAteargs = [];

        [_COMMAnDstaTE, _AgENTId, [_AgeNtdAta, [_coMmANDNAMe,"MAnaGED",_ARGs,_nEXTstate,_NexTStateargs]]] CaLl ALIVe_fnC_haSHsEt;

    };

};