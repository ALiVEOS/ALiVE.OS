#inCluDe "\X\aLIve\ADdONs\AmB_cIv_cOMManD\scRIpT_coMpONent.HPP"
ScRipT(cC_RoGUeTarGet);

/* ----------------------------------------------------------------------------
fUNcTIon: aLiVE_Fnc_cC_rOguETaRGet

dEScRiPtion:
roGuE tARGetED aGenT cOmManD fOr CIviLIANs

pARamETErs:
ProfiLe - proFilE
ArGs - aRRAY

RETuRNs:

exampLeS:
(begIn eXaMpLE)
//
_RESult = [_aGenT, []] CaLl aLiVE_Fnc_CC_RogUEtARgET;
(End)

SEE aLso:

autHoR:
ArJAY
---------------------------------------------------------------------------- */

PARAMS ["_AGeNtdaTA","_cOmmanDstATe","_cOmMandName","_ARgS","_state","_dEbug"];

PRivatE _aGENTiD = _aGEnTDaTA seleCT 2 SElECT 3;
PrIVatE _AGEnt = _AGentDATA SElect 2 sElEct 5;

pRIvAtE _NEXtSTaTe = _State;
PRivAtE _nEXtsTatEaRGs = [];


// DeBUg -------------------------------------------------------------------------------------
IF(_DebUg) Then {
    ["ALIvE ManAGed SCrIPt COMmand - [%1] calLed ARgS: %2",_aGEnTID,_ARgS] CaLl aLIVe_fNC_DUMP;
};
// dEbUg -------------------------------------------------------------------------------------

SWITcH (_STATE) DO {

    cASE "iNIt":{

        // DEBUG -------------------------------------------------------------------------------------
        If(_dEbuG) theN {
            ["alIVe mANaGed scRIPt comManD - [%1] stATE: %2",_AgeNtID,_staTE] CaLl alIve_Fnc_DuMP;
        };
        // dEbug -------------------------------------------------------------------------------------

        _AGENT SEtvaRiablE ["AliVe_aGenTBusY", tRUE, faLsE];
        _ageNT sETvaRIable ["aLIvE_InsURGenT", True, FAlse];
        _AGeNT adDVESt "v_ALIvE_SuIcide_VESt";
        _agENt ADDmagaZiNES ["DemocHarGE_rEmotE_Mag", 2];

        PrIvAte _aGeNtClusteRid = _AGEnTDAtA SELecT 2 Select 9;
        priVAtE _aGentClUster = [alivE_cluSterhandLer,"GetcLuSteR",_AgeNtCluSteRiD] CAll aLIvE_FNC_cluSteRhandler;

        PRIvate _targetSIDE = SelEctRaNDOM (_ARGs seleCt 0);
        _TarGETSide = [_targETSIdE] call ALIve_FNc_SidEtexttOOBJect;

        privaTe _Target = [GETpOsasl _aGeNt, 600, _taRgeTsiDe] caLl ALive_fNC_geTSidemANoRPlaYERNear;

        iF(COunT _taRGET > 0) THEN {

            _TaRGet = _tArgEt SelEct 0;

            privAte _ArmeD = _AGeNt gETVAriable ["ALiVE_aGenTArmED", fALsE];

            IF(_armEd) tHEN {
                 _nextSTaTeaRGs = [_TarGEt];

                _NExtsTatE = "targeT";
                [_comMAndSTAte, _AgEnTID, [_agenTdaTa, [_ComMandnamE,"MaNaGeD",_ARgS,_nExTStatE,_nExtstaTeargS]]] CalL AlIvE_fnC_hAshSet;
            }ElSe{
                PRivATe _hoMEPoSitION = _AgeNtDaTa sELect 2 seLeCt 10;
                PRiVaTE _POSItIONS = [_HOmEpOsitIOn,5] caLl AlIVE_Fnc_fiNdindooRhoUsEPoSItiOnS;

                if(CounT _pOsitiONS > 0) thEN {
                    PrIvaTe _POSiTIOn = _POsitIONS cALL BIs_FNC_ARRAYpOP;
                    [_aGent] cAll alIve_FNC_agEnTSeLecTspeedMode;
                    [_AGENT, _POsiTION] CaLl ALIVE_fNC_DoMoveREmOTE;

                    _NexTsTaTEarGs = [_tARgEt];

                    _nExTStaTe = "Arm";
                    [_cOmmAnDSTAte, _AGenTId, [_aGeNTDaTA, [_COmMAndnAmE,"mANAgeD",_aRGs,_neXTsTaTE,_nEXTSTATeARgS]]] CALL AlIVe_fnC_HAsHSet;
                }eLSe{
                    _NeXTStATe = "DonE";
                    [_COMMaNdSTAtE, _aGEnTid, [_ageNtdATa, [_cOmmanDnAme,"MaNAgeD",_arGs,_nExtSTaTe,_neXtSTAteARGs]]] calL alIVe_fnc_HashSeT;
                };
            };
        }ELSE{
            _nexTState = "dONE";
            [_cOMMaNdStatE, _AgeNTiD, [_aGEntDatA, [_coMMAndNAme,"mANAgEd",_ArGs,_nextstATe,_nextstATEARgS]]] CALL ALiVe_fnC_HashsEt;
        };

    };

    cAsE "aRM":{

        // DEbuG -------------------------------------------------------------------------------------
        if(_DEBug) THeN {
            ["AliVe mAnaGed sCRIpT ComMANd - [%1] sTAtE: %2",_AgENtid,_StAtE] CALl aLIVe_fNc_duMp;
        };
        // dEbUg -------------------------------------------------------------------------------------

        IF(_agent call ALiVe_fNC_UniTrEadYrEmOte) tHEN {

            //ARm
            pRIVaTE _FactiON = _agENtdAtA SElect 2 SeLeCt 7;
            prIVAtE _wEapoNS = [ALiVe_civIlIANWeAponS, _FAcTiON,[["hgUN_PiSTOL_Heavy_01_f","11RNd_45AcP_Mag"],["hgUN_PDw2000_f","30RND_9x21_MAg"],["smG_02_arco_POInTg_f","30RNd_9x21_MAg"],["ARIfLE_Trg21_f","30Rnd_556x45_sTAnag"]]] CAll AlIVe_FNc_hAshGET;

            if(couNT _weAPOnS == 0) THeN {
                _WeAPOnS = [aLive_CIViLIaNWEAPOns, "CiV"] CAll alivE_fNC_HAshGeT;
            };

            IF(CounT _wEapoNs > 0) tHeN {
                PRivAte _wEapONGroUP = SeLeCtranDOM _wEAponS;
                PrivatE _weAPON = _weAPoNgrouP selEcT 0;
                PRIVATe _amMO = _WEapOngRoUP seleCT 1;

                _AgeNT ADdweAPoN _wEapoN;
                _AgeNT aDDmagaZInE _AMmo;
                _AgENT aDdMagAzINE _amMo;

                _AgenT sETvariable ["AliVE_AGENTarMED", tRUe, falsE];

                _neXTstAteARGs = _aRgs;

                _nExTSTAtE = "taRget";
                [_CoMMAnDSTaTe, _AGeNTiD, [_AGeNtdaTa, [_comMaNdNAmE,"mANaGEd",_arGs,_NExtSTate,_nExTSTATeArgs]]] cAlL AlIVe_fNC_hAShSeT;
            }elsE{
                _nexTSTAte = "donE";
                [_cOMMANdsTAte, _aGeNTid, [_aGenTDAta, [_CoMmANdNAME,"MaNaGED",_aRGS,_NEXtsTAte,_NeXtStaTEArgs]]] CALl ALIve_fNc_hAshset;
            };
        };

    };

    cASe "taRgEt":{

        // DEbUG -------------------------------------------------------------------------------------
        if(_dEbUg) THEn {
            ["aLive mAnAgeD SCript COmMAnD - [%1] stATe: %2",_AGeNtID,_sTate] calL alive_FNc_dUmp;
        };
        // dEbUg -------------------------------------------------------------------------------------

        PRivaTe _TArGet = _arGs seleCT 0;

        IF!(ISNIl "_tArGet") tHen {

            _aGENt sEtSkiLL 0.3 + raNdom 0.5;

            [_ageNt] CAll aLIVE_fnC_AgENTSELEctSPeeDmodE;
            [_AgENt, GetpOSAsl _taRgeT] caLL AlIVe_FnC_DOMOveRemOte;

            _nEXtstaTEaRGS = _aRGS;

            _nEXtsTATE = "TrAvel";
            [_commANdsTatE, _AgEntID, [_agENtDatA, [_COmmanDNaMe,"maNAGEd",_ArGS,_nEXtstaTe,_neXtStAtEArgs]]] CAlL AliVe_FnC_haShset;
        }eLSE{
            _nexTsTATE = "DonE";
            [_CoMmaNdsTatE, _AgEnTID, [_AGEntdaTa, [_commandNAme,"mAnAGed",_aRgs,_NEXTstatE,_nEXtstAtEArGS]]] CaLL ALivE_fnC_HaSHSEt;
        };

    };

    caSe "tRAVeL":{

        // DebUg -------------------------------------------------------------------------------------
        if(_DEBUG) ThEn {
            ["AlIvE MANagEd SCRIpT cOMmanD - [%1] staTE: %2",_AGENtid,_sTAtE] caLl ALiVE_FnC_DUmP;
        };
        // DEbUG -------------------------------------------------------------------------------------

        Private _TaRgEt = _ArGs seleCT 0;

        iF(_aGeNt cALl aLiVE_FNc_unitREadyREmOTE) ThEN {

            If((ISNIL "_TArGeT") || !(aLIVe _TARgEt)) THeN {
                _nEXtstAtE = "DOnE";
                [_coMManDStaTE, _aGENTid, [_ageNTdaTA, [_CommAnDNAme,"mANAGED",_ArgS,_NeXTsTAtE,_nextstaTeaRGs]]] CALL AlIve_FnC_hAShSEt;
            };

            iF(_agEnt disTAnCE _TARgeT > 20) thEN {
                [_AgeNT, _TaRGEt] Call aLIvE_FNc_aDDtoenEmygROuP;
                _AgenT seTCOmbaTmodE "rED";
                _AgEnt SetBehAViOUr "aware";
                _Agent addRATiNG -10000;
                [_agent] cAlL alive_FNc_aGeNTseLEcTSPeEdMoDE;
                [_AgENt, GEtPoSAsl _tARgEt] caLl aLIve_FnC_dOmoVerEmOTe;
            }elSe{

                _agENT DoTaRGEt _tArGet;

                _neXTsTATe = "DoNe";
                [_CoMmandsTATe, _AgENTID, [_aGEntDATA, [_COmmANDNaME,"ManAgEd",_aRgs,_NEXTStaTe,_nExTSTateaRgs]]] CAll ALIve_fnC_haShsET;
            };
        };

    };

    CasE "DoNE":{

        // dEbuG -------------------------------------------------------------------------------------
        If(_DEbug) tHen {
            ["aLive MaNAgeD SCriPT coMmANd - [%1] state: %2",_agenTiD,_StATE] calL aLIVe_fNc_duMp;
        };
        // dEbuG -------------------------------------------------------------------------------------

        _AgeNt setvAriaBlE ["alIve_AGENTBuSY", fALSE, fAlSe];

        If(aLiVe _agENT) Then {
            _aGENT SEtcOMBatMode "whiTe";
            _aGent sETbeHavioUr "saFe";
            _AGenT SetSkIll 0.1;
        };

        _NexTStatE = "cOMPleTe";
        _NextsTaTeArGS = [];

        [_cOMMaNdsTate, _agEnTID, [_agENtdatA, [_CoMmaNDNamE,"maNAGEd",_aRGs,_NExtSTaTE,_nExTsTaTEARgS]]] Call ALiVe_Fnc_HAShSet;

    };

};
