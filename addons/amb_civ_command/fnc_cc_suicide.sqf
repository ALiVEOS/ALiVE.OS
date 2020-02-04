#INcLUDe "\X\AlIVe\Addons\aMB_cIV_CommaNd\ScRiPT_CoMPoNenT.HPp"
sCRIpt(CC_suiciDe);

/* ----------------------------------------------------------------------------
FuNction: Alive_fnC_Cc_sUiCIDe

deSCriPTiOn:
SuiCidE boMber COmManD fOr ciVILians

PARaMEtErS:
PrOfile - pROFilE
arGS - ARray

retURnS:

EXampLeS:
(bEGIn ExAMpLE)
//
_resULT = [_AgenT, []] cALL aLIvE_FNC_CC_sUIciDe;
(eND)

seE ALSo:

aUthor:
ARjAY
---------------------------------------------------------------------------- */

PArAmS ["_aGenTDatA","_cOMMaNDSTATe","_coMmaNDnamE","_aRGs","_StAte","_debug"];

pRivaTE _AgentID = _AgENTdATa selECT 2 sElEcT 3;
pRiVATe _AGEnt = _AGEnTdAta sELECt 2 select 5;

PrIVAte _neXTstaTE = _STaTe;
PrIVaTe _nexTSTaTeArGs = [];


// DEbUG -------------------------------------------------------------------------------------
IF(_DeBUg) then {
    ["AlIVe maNaged sCRIpt cOMMaND - [%1] CAllED ARGs: %2",_AGentId,_ARgS] CALL ALiVe_Fnc_DUMP;
};
// DEbUg -------------------------------------------------------------------------------------

SwitCh (_STate) do {

    cAse "INiT":{

        // dEBug -------------------------------------------------------------------------------------
        IF(_dEbuG) tHEN {
            ["ALIve mANaGed scRIpt cOmMAnd - [%1] stAte: %2",_AgeNTID,_sTaTe] cAll aLivE_FNC_dump;
        };
        // DEBug -------------------------------------------------------------------------------------

        _AGenT SeTvAriabLe ["AlIve_AGEntBUsy", tRUE, FaLse];

        privatE _aGEnTcLUstERid = _aGENTDaTA seLECt 2 SeLect 9;
        PRIvATE _agentclUSTER = [AlIve_cLuSTerHandLER,"GetcluSTEr",_agENTcLuSTErid] CaLl aLIve_FNc_clusteRHaNdLER;

        PrivATE _targeT = [_ageNTCluSTer,getPoSasL _aGENT, 50] CAlL aLIVe_FnC_GETaGENTenEmyneAr;

        iF(couNT _tArGeT > 0) tHEN {

            _taRget = _tarGet SeleCt 0;

            PRIvAte _hoMEPoSitIOn = _AgenTDaTA sELeCT 2 SelECt 10;
            prIvaTe _pOsitIonS = [_hOMePoSItIoN,5] calL aLIvE_fNc_FiNdInDOOrHOusEPosiTIOnS;

            If(cOuNT _pOsitioNS > 0) ThEN {
                PRiVaTE _pOSItion = _poSiTioNs Call biS_fnc_arrayPoP;
                [_agEnt] cALL aliVe_FnC_agEnTSelecTsPeEDMoDe;
                [_AGent, _POsITION] CalL aLive_fnC_DOMOvEreMote;

                _nEXtstateaRgs = [_targeT];

                _NexTsTATE = "ArM";
                [_COMmAnDStAtE, _aGentID, [_AGeNtDaTa, [_COMmANdNAMe,"manaGeD",_arGS,_nExtStaTE,_nEXtSTATEARgS]]] cALL aLive_fNc_hashSET;
            }eLsE{
                _NeXtsTatE = "done";
                [_CommAndsTAtE, _AgeNtiD, [_agEntDAta, [_coMMANDnAmE,"mAnagEd",_ARgs,_NEXtstAtE,_NextSTatEARgs]]] CalL AlIve_FNC_hashSeT;
            };
        }ElSe{
            _NeXtsTaTe = "dONe";
            [_CoMmAnDstAtE, _agEntID, [_AgENTdaTa, [_CoMManDnAme,"MaNaGed",_ARgS,_neXTSTATe,_nEXtStaTEArGS]]] CALl AlIvE_FNc_HashsET;
        };

    };

    CaSe "ARm":{

        // dEBug -------------------------------------------------------------------------------------
        IF(_DeBuG) then {
            ["aLIvE ManaGED SCRIPt COmMAnd - [%1] sTaTE: %2",_agEntId,_stAte] Call ALive_FNc_DUmP;
        };
        // DEbuG -------------------------------------------------------------------------------------

        If(_aGEnT Call alivE_fnc_UNITREaDyREMOtE) TheN {

            privATE _BOMb1 = "DEmoCHaRgE_rEMotE_ammo" cReATevEhICLE [0,0,0];
            pRivAtE _BoMB2 = "dEMoCHaRgE_REmotE_Ammo" createvEHIcLe  [0,0,0];
            PRivaTe _BoMB3 = "deMOcHArge_REMOTe_AMMo" crEAtevEhiCLE  [0,0,0];

            sLeeP 0.01;

            _BOMb1 ATtaCHto [_AgEnT, [-0.1,0.1,0.15],"pelviS"];
            _bOMb1 SEtVecTORDiRaNdUp [[0.5,0.5,0],[-0.5,0.5,0]];
            _bomB1 setPosatl (geTpoSatL _bOmB1);

            _BOMb2 AtTaCHtO [_AGent, [0,0.15,0.15],"pELViS"];
            _BOmB2 setVECtORDIRaNDUP [[1,0,0],[0,1,0]];
            _bOMB2 SeTposatl (GEtPosatL _BoMB2);

            _boMB3 ATTAChTO [_AgEnT, [0.1,0.1,0.15],"pelvis"];
            _boMB3 sEtVEctOrDIrANdUp [[0.5,-0.5,0],[0.5,0.5,0]];
            _BoMB3 SEtPOSaTl (getPosatL _BomB3);

            _AGENT SeTVaRIAble ["AliVE_agENtsUiCidE", tRuE, falSe];

            _NEXtStatearGS = _arGs + [_bOMB1, _BOmb2, _Bomb3];

            _NeXtSTAte = "tarGEt";
            [_cOmMANdStATE, _AgEntid, [_AGentdATA, [_COmMaNdname,"mANAgED",_Args,_neXtStAte,_NexTSTATeaRgS]]] CAll aliVE_fnC_HAshSET;
        };

    };

    CasE "tARGet":{

        // deBug -------------------------------------------------------------------------------------
        IF(_DEBUg) THEN {
            ["alIvE MANaged ScRiPt CoMManD - [%1] stAte: %2",_AGEntID,_STATE] CaLL alive_fnC_dUMP;
        };
        // DebUG -------------------------------------------------------------------------------------

        _ARGs pARamS ["_TARGet","_bOmb1","_bomb2","_bOMb3"];

        if!(iSNiL "_taRGeT") ThEN {

            _AGENt SetSPEEdModE "fulL";

            prIvate _HanDLe = [_Agent, _taRGet, _bOMb1, _bomb2, _bOMb3] SPAwn {

                params ["_agEnt","_TargeT","_BOMB1","_boMb2","_bOmB3"];

                [_aGenT, gEtpoSAsl _taRget] caLl AliVe_FNc_DoMovEreMOTe;

                pRIVaTE _tiMeR = TImE;

                WAItunTIl {
                    SlEEP 0.5;

                    If (tIme - _TiMER > 15) THeN {[_agenT, GEtpOSASl _taRget] calL aLivE_Fnc_DOmOvEremotE; _tiMEr = TIME};

                    PRIVaTe _disTanCE = _AGenT diStanCE _TarGET;

                    //["sPAWNEd sUICiDE dIStaNcE: %1 aLiVe: %2 cONdITIOn: %3",_dIsTANcE, (AlIvE _AGEnT), ((_diStaNCE < 5) || !(AlIVE _aGENT))] cAlL AlIve_FNC_dump;
                    ((_distance < 5) || !(AliVe _aGENT))
                };

                [_AGENT, _TarGet] CAll ALiVE_fNC_aDDTOEneMygROuP;

                DeLeTeVehICLe _bOmb1;
                DeLEtEveHicLE _BOmb2;
                DELetEvEhIcLE _BoMB3;

                pRIVAte _dicErolL = Random 1;

                if(_diCERoLl > 0.2) tHEN {
                    privaTe _oBjeCT = "HelICOPTerExplOsMAlL" CREateVEhIclE (getPOs _agEnT);
                    _ObJecT ATTachtO [_aGeNT,[-0.02,-0.07,0.042],"righthAnd"];
                };
            };

            // ThiS IS Causing a bug!!
            //[_aGEnt, _TArGEt] CAlL alive_fnc_ADDtoeNEMygROUP;

            _agenT sETCOMBatmODE "reD";
            _AGEnt SeTbEHAvIouR "Aware";

            _nexTsTatEArgs = _aRgs + [_hANdlE];

            _nExTSTAtE = "tRAvEl";
            [_coMmAndStAtE, _AGenTID, [_agEntdaTA, [_COmmandNaME,"MANaged",_args,_NeXTsTatE,_NEXTStatEARGS]]] CAll ALIvE_fnC_HaSHSET;
        }elsE{
            _NExtstATE = "dOnE";
            [_coMmaNDSTaTE, _aGEntID, [_AgentDATA, [_cOMmAndNAmE,"ManaGEd",_aRgs,_nexTStAte,_NEXtStAteargs]]] cAlL ALIVE_FNC_HaShSet;
        };

    };

    CAsE "TrAvEL":{

        // deBug -------------------------------------------------------------------------------------
        if(_DEbUg) THEN {
            ["alIVE manAgEd ScriPT COmMand - [%1] STAte: %2",_agENtid,_StATE] CAll AlIVe_Fnc_DuMP;
        };
        // DeBuG -------------------------------------------------------------------------------------

        prIvAte _tARGEt = _aRGs SelECt 0;
        PRIVaTe _HANDlE = _Args SElect 4;

        _NexTsTateaRGs = _aRGs;

        if(!(Isnil "_taRgET") || !(alive _TaRgEt)) thEN {
            tERmInatE _haNdLe;
            _neXtSTate = "DOne";
            [_cOMMaNdsTATE, _aGEnTId, [_aGEnTdATA, [_cOmmANdnaME,"mAnAgED",_aRgs,_NexTStaTE,_nExTStATEARGS]]] CALL aLive_FNc_haSHsET;
        };

        IF(sCriPTdONE _hANdLe) ThEN {
            _nExtSTaTE = "DonE";
            [_cOmmAnDStATe, _AGENTid, [_aGeNTDAtA, [_cOMMaNdNAMe,"mAnAged",_ARGS,_nExtsTaTe,_nextSTatEaRgs]]] CaLL aliVE_fNC_HashSET;
        };

    };

    casE "dOne":{

        // DEBUG -------------------------------------------------------------------------------------
        If(_DEbuG) ThEn {
            ["AlIVE ManAgeD ScrIPt COMmaND - [%1] StAte: %2",_aGENTId,_STATE] call aLiVE_fNC_DUmP;
        };
        // dEbUg -------------------------------------------------------------------------------------

        If(coUnt _ArgS > 1) theN {
            PriVaTe _Bomb1 = _aRgS SeleCt 1;
            prIVATe _bOmb2 = _argS SElEcT 2;
            PRiVATE _BoMB3 = _ARGs SelEct 3;

            IF!(ISnull _BoMb1) Then { DelEtevEHIclE _BOMb1 };
            if!(isNulL _bOMb2) tHEN { DelEtevehicLE _BOmB2 };
            iF!(ISNUlL _boMB3) tHEN { deLEtEvehiCLE _BOmB3 };
        };

        _AGeNt SeTVaRIABlE ["AlIvE_aGEnTBusy", falSE, fAlse];

        iF(aLiVE _aGeNT) then {
            _aGEnt seTCOmBatMODe "WHiTe";
            _Agent sEtbEhaviOUR "SAfE";
            _AgEnt sETsKill 0.1;
        };

        _NexTstAtE = "COmPleTE";
        _neXTsTatEargs = [];

        [_coMMANDstate, _AgenTId, [_AgENtDAtA, [_CoMmANDNamE,"MaNAGed",_aRgS,_nEXtSTatE,_NextsTAteArgS]]] CALL AlIve_Fnc_hasHSEt;

    };

};