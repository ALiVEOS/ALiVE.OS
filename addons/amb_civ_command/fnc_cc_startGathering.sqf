#incLUDe "\x\ALiVe\ADdons\AMb_ciV_cOMmand\ScripT_COMPoneNT.hpP"
script(Cc_StArTGathErIng);

/* ----------------------------------------------------------------------------
funCTION: ALIVe_FNC_cC_sTaRtgaTHeRING

DEscRiPtiON:
STArT GAThEriNg cOMMAnD fOR CIVIliANs

Parameters:
pRofILE - ProFiLE
aRGS - ARrAy

rEtUrns:

exaMPles:
(BegIn exAmPlE)
//
_rEsUlt = [_aGent, []] call ALivE_fNc_Cc_staRtGatHERIng;
(eND)

SEe alsO:

AUthor:
ARJAY
---------------------------------------------------------------------------- */

PaRamS ["_aGeNTdATa","_ComMAndstATE","_COmmANDNAME","_arGS","_stAtE","_DebUg"];

pRIVATe _AgeNTiD = _Agentdata SeLeCt 2 SElecT 3;
pRIvAtE _AgEnt = _ageNTdaTA SElECT 2 sELeCt 5;

private _NEXTsTatE = _sTate;
PRivatE _neXtSTaTeaRGs = [];


// deBug -------------------------------------------------------------------------------------
if(_debUG) tHeN {
    ["aLiVe ManaGEd sCRipT cOMManD - [%1] cALLed aRgs: %2",_AGeNTID,_ARgs] cALL ALIve_fNc_duMP;
};
// dEbUg -------------------------------------------------------------------------------------

sWiTch (_sTate) DO {

    CAsE "IniT":{

        // dEBUg -------------------------------------------------------------------------------------
        iF(_deBuG) theN {
            ["alIvE MANaGed scripT cOmMaND - [%1] sTATE: %2",_aGEnTID,_STaTe] cAlL ALIve_fnc_DuMp;
        };
        // DebuG -------------------------------------------------------------------------------------

        //_positIon = GETPOSAsl _AGEnT FINDemPtYpOsItIoN[10, 100, "O_ka60_F"];
        PriVATE _POs = geTpOSATl _agENt;
        priVATE _poSiTiON = [_poS,0,10,1,0,10,0,[],[_pOs]] cAll Bis_fNc_FindSaFePos;

        _aRgS pAramS ["_mIntimEOUT","_maxtimEoUt"];

        [_AGEnt] Call aliVE_fnC_AgentsELEcTSpeEdMoDe;
        [_agenT, _posITION] cALL alIVe_fNc_domoVEREmOTe;

        PRiVaTE _TIMEouT = _MintIMEOut + Floor(rANdOM _MAXTiMEoUt);
        priVAtE _TImEr = 0;

        _nExTsTAte = "trAvel";
        _NExTsTATEaRGs = [_TIMeOuT, _tImer];

        [_ComMandsTate, _AgEntID, [_AgentDAta, [_coMmaNDnAME,"manaGEd",_ArGs,_neXtstaTe,_nExtstAteArGs]]] CALL aLIve_FnC_hASHset;

    };

    CAse "TraveL":{

        // debUG -------------------------------------------------------------------------------------
        iF(_Debug) THen {
            ["aLIVE MAnaGeD SCRiPt CommAND - [%1] StATE: %2",_AGENTiD,_stATe] caLl AliVE_FNC_dumP;
        };
        // DEBug -------------------------------------------------------------------------------------

        if(_AGenT Call ALIvE_FnC_uNiTREADYReMOTe) then {

            _agEnt SetvaRiabLE ["aliVE_AGENTbuSY", TrUe, FALSE];

            pRIvaTE _AgeNTs = [alIVE_agEnThANDleR, "GeTaCtiVe"] CaLl alIVe_fnc_agentHaNDlER;
            _AgENTs = _agEnts SeLeCt 2;

            IF(CoUNT _AgENTS > 0) THen {
                prIVAtE _pArTNeRs = [];

                {
                    PrIVAte _PartNER = SELeCtRANDOM _aGENTs;
                    PRivATE _pARTnERageNt = _paRtnER sElEcT 2 sELECT 5;

                    IF(!(_PArtnerAGENt gEtVaRiaBLE ["alIve_AgenTgAthERiNgreQueStED",FaLSE]) && {!(_ParTneRagent GETVaRIABle ["AliVE_AgenTMEeTinGrEQUEsTEd",FAlSe])}) ThEn {
                        _partNEraGEnT SETVarIABle ["ALIVE_agentGaTherinGCOMPletE", FaLse, fAlsE];
                        _pARtNEraGeNt setvaRiaBLe ["alIve_ageNTgATherInGreqUesTeD", true, FalsE];
                        _paRtNErAGENT seTVaRiablE ["aliVE_ageNtgatHERiNgTArGET", _aGeNt, FAlsE];

                        _partNeRs PuShBacK _PArTNErAgEnT;
                    };
                } foReAcH _ageNtS;

                _neXTsTatE = "wAIT";
                _NEXTstatEarGs = _arGs + [_paRTNeRS];
                [_cOMmAndstAte, _AgEnTiD, [_agEnTdata, [_cOMmaNDnaME,"maNaGeD",_ARGS,_neXtSTate,_nEXtSTaTEarGS]]] call AlIVe_fNc_HaShSeT;
            }eLSe{
                _NEXtSTAtE = "DoNe";
                [_COMMANdStAte, _AGentId, [_AgENtdATa, [_CoMmAndnaMe,"mANaged",_arGs,_nEXtstATE,_nEXtsTATearGs]]] Call aLIVe_FNc_HAshset;
            };
        };

    };

    case "WAit":{

        // DEbUg -------------------------------------------------------------------------------------
        IF(_dEBUG) thEN {
            ["aLIvE manaGed sCrIPt ComMaNd - [%1] STAte: %2",_AgeNtid,_staTE] cAlL alive_FnC_dumP;
        };
        // deBuG -------------------------------------------------------------------------------------

        _aRgs PArAMs ["_TImEOUT","_TimeR","_PARtNers"];

        IF(_tIMEr > _tiMeouT) THEn
        {
            {
                _x SETvARiable ["ALive_aGENtGatHeRINgReQUESTed", fALSe, FAlsE];
                _X SetVariAbLE ["Alive_agENtGaThERingCOMplETE", True, FAlSE];
                _X SETvariABLe ["aliVe_AgeNTGatHeRinGtArgeT", oBJnULL, falsE];
            } FOREaCH _paRtnErS;

            _agEnT sEtVArIABlE ["aLIVe_AGentgatheRInGReQuEStEd", fALSE, FalSe];
            _agENT sETVAriaBLE ["alIVe_aGenTGAtHerInGcOMPLEtE", trUe, fAlsE];
            _Agent SetVariabLe ["AlIvE_AGeNTGathEriNgTARGeT", oBJnuLL, falsE];

            _neXtstATe = "donE";
            [_CoMMaNDsTaTe, _agENTID, [_AgeNTdAta, [_coMMAndnaMe,"MAnaged",_arGS,_NExTsTAtE,_nexTStatEArGs]]] caLl aLIvE_fnC_HashSET;
        }Else{
            _tiMER = _TimER + 1;

            _nexTsTaTeArgs = [_tImeoUT, _TimeR, _PARTneRS];

            [_CoMMandStAte, _agEnTiD, [_AGentDATa, [_commaNDNamE,"mAnAGEd",_arGS,_nExtSTATe,_nextsTaTEARGs]]] CALL aLiVe_fnC_HaShSEt;
        };

    };

    CasE "DoNE":{

        // DeBUg -------------------------------------------------------------------------------------
        IF(_dEBUg) then {
            ["aLive maNAGed scRIPT COMmANd - [%1] StAtE: %2",_aGentiD,_staTe] cALL alIve_fNC_dUMP;
        };
        // dEbUG -------------------------------------------------------------------------------------

        _AGEnT SEtVarIAblE ["ALiVe_aGEntBuSy", False, faLse];

        _nEXTStAtE = "coMplETE";
        _NEXtStaTEArgs = [];

        [_comMAndstate, _aGENtID, [_AgENTdatA, [_COmMaNDnAme,"ManAgED",_aRgS,_NEXtStaTE,_nEXtsTAteARgS]]] caLl aLivE_Fnc_hAsHset;

    };

};
