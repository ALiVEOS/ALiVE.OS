#incLude "\x\aliVe\AdDOns\Amb_Civ_command\ScriPT_cOMPonENT.hPp"
scrIpT(cC_rogue);

/* ----------------------------------------------------------------------------
FuNCTIon: AliVE_fNc_cc_SUIcIde

deSCrIPTIoN:
rOgUE agENt COMMaNd foR CIViLiaNs

PArameters:
PROfILe - profile
aRGs - ArrAY

RetuRNS:

ExamplEs:
(bEgin examPLe)
//
_reSuLt = [_AgeNt, []] Call alive_FnC_cC_roGUE;
(END)

seE AlSo:

AUthoR:
ArJay
---------------------------------------------------------------------------- */

paRaMs ["_AgeNtData","_COMMaNDStatE","_CoMMAnDname","_ArgS","_statE","_dEBUg"];

PRiVate _aGEntId = _aGEnTDaTa SeLeCt 2 selECT 3;
PrIVaTe _AgENt = _AGeNTdAta seLEct 2 SelEct 5;

prIVaTe _nEXtstaTe = _StAte;
PRIvaTe _neXtstaTEARGS = [];


// debug -------------------------------------------------------------------------------------
IF(_DEBuG) tHEN {
    ["ALIVE MaNAGeD sCRIpt coMmAND - [%1] CALLed aRGS: %2",_aGentId,_aRgs] cALL AlIve_FNc_DUmP;
};
// dEBuG -------------------------------------------------------------------------------------

swITCH (_StaTe) dO {

    CASe "iNit":{

        // DEbuG -------------------------------------------------------------------------------------
        if(_deBUg) tHEn {
            ["ALIVe MaNageD ScriPT cOMmanD - [%1] stAtE: %2",_aGeNtId,_StaTe] CAlL alIVE_Fnc_duMp;
        };
        // dEBuG -------------------------------------------------------------------------------------

        _aGenT SETVArIaBLe ["aLive_aGEntBUsY", tRUE, FAlse];

        pRiVaTe _aGenTclUsteRiD = _AGEntDaTA seLeCt 2 sELECt 9;
        pRIVatE _AgentCLustER = [AlIve_cLusTERhanDlER,"gEtcLUSTer",_aGeNTcLuSTerID] CALl AliVE_FNc_clusterhAnDLer;

        PriVaTe _TARGet = [_agentclUSteR,getPosaSl _AGENT, 50] CaLL aLIve_fnC_geTAGenteNEmyNEAR;

        if(Count _taRgET > 0) TheN {

            _TARGET = _tARget seleCT 0;

            PRivaTE _ArMEd = _AGeNt gEtvARIabLE ["ALiVe_agEntarMed", FAlSE];

            iF(_Armed) theN {
                 _nEXTStatEargs = [_TArgeT];

                _neXTStAte = "TARGET";
                [_coMmanDsTATe, _AGENTId, [_aGEntDaTA, [_cOmMandname,"maNAgED",_aRGs,_NexTSTaTe,_nextstATeargS]]] CAlL ALive_fnc_haSHSet;
            }ElSE{
                pRIVATE _hOMepoSItion = _agENTDatA seLECt 2 SelEct 10;
                pRIvAte _pOsItIONs = [_HOmEPOsItIon,5] CALL AlIve_fnC_fIndinDooRhOUSepOsitIONS;

                if(cOUnt _positIonS > 0) theN {
                    prIvAtE _pOSitIoN = _pOSitIons cALl BIs_fNC_ArraypoP;
                    [_aGent] caLL aLIve_fNC_AGentSELeCTspEeDMODE;
                    [_aGent, _POsITIoN] CalL AlIVe_fNC_DoMOvereMOtE;

                    _nextsTateaRgS = [_TARgeT];

                    _NextsTaTe = "aRM";
                    [_CommANdstATe, _agEntID, [_aGEnTdAtA, [_ComMANDNaMe,"mANAGED",_ARGs,_nEXtstATe,_NEXtsTATEaRgS]]] cALL ALIve_fNC_hashSet;
                }elSe{
                    _NEXtstAte = "dONE";
                    [_CoMmaNdstaTE, _ageNTId, [_AgENtDAta, [_COMmANDnAMe,"manAgEd",_aRGs,_nexTSTAtE,_nEXtSTATEArgs]]] CALl aLIvE_fNc_hAsHSET;
                };
            };
        }ELSe{
            _nExTsTaTE = "done";
            [_cOMMANDStAte, _agEnTId, [_agenTData, [_commaNdnaME,"mANAGED",_ArGS,_NExtStaTE,_neXTSTaTeARgS]]] CAlL aLivE_Fnc_hASHseT;
        };

    };

    cAsE "ArM":{

        // dEBuG -------------------------------------------------------------------------------------
        iF(_dEbUg) THEN {
            ["AlivE managED scRIPt coMmand - [%1] sTAte: %2",_AGEnTID,_StAtE] cAll Alive_fnc_Dump;
        };
        // DebUG -------------------------------------------------------------------------------------

        if(_AGeNt cAlL aLiVe_fNc_uNITReadyremotE) then {

            //ARM
            pRiVate _FACTiOn = _AGeNTdATA seLeCt 2 SELEct 7;
            PRIvaTE _WeapOnS = [aLIVe_cIviliAnweAponS, _FacTIOn,[["HgUN_pIsTOl_heaVy_01_F","11rNd_45acP_MaG"],["hGUn_pdW2000_F","30RNd_9x21_MaG"],["smg_02_ARCo_PoInTg_f","30RnD_9X21_MAg"],["ARiflE_tRg21_f","30RnD_556x45_sTAnAG"]]] Call alive_FnC_HasHGeT;

            if(CounT _WeAPOnS == 0) THen {
                _WeAPONs = [AlIvE_cIviLIAnweaPonS, "cIV"] CAll AliVe_fNc_HaShgEt;
            };

            if(counT _WeaPOnS > 0) tHeN {
                privaTe _wEapONgROUP = SELecTRaNDOm _WeaPoNs;
                PRiVate _weApOn = _wEaPOngrOUp sElECT 0;
                pRiVaTe _AMMO = _WEApOngRoUP sELect 1;

                _ageNt AddWEApON _weaPOn;
                _AGEnT ADDMaGaZiNe _ammo;
                _AGEnt AddMAgazINE _AMMO;

                _AgEnT SETVARiABLE ["alIve_AgEnTaRMeD", True, falSE];

                _nExTSTAteARGs = _args;

                _NexTStAte = "taRgET";
                [_COmMandstAtE, _AGeNTiD, [_agentdATa, [_CoMMANdnaMe,"MANaGEd",_args,_neXtstATe,_nEXTStatEARGS]]] caLL alivE_fNC_HashsET;
            }eLSe{
                _NExtstate = "dOnE";
                [_COMmaNDstATe, _aGeNtid, [_aGeNTData, [_CommANDNamE,"MaNAGEd",_arGS,_nExTState,_nExtSTateaRGS]]] Call ALiVE_FNc_hASHSet;
            };
        };

    };

    Case "Target":{

        // DEbUG -------------------------------------------------------------------------------------
        if(_DeBUg) THEN {
            ["alIve MaNAGed ScRiPT CommAND - [%1] stATE: %2",_aGentID,_STaTe] cALl alIve_fNC_dUMp;
        };
        // DebUG -------------------------------------------------------------------------------------

        PrIVate _TARgEt = _aRGS seLecT 0;

        IF!(IsNil "_taRGet") thEn {

            _AGEnT setskiLL 0.3 + ranDOm 0.5;

            [_AGenT] caLl alIvE_FNC_AGenTSeLECtSpEEdMODe;
            [_aGeNt, GetPOsasl _TArgeT] cALL ALiVe_fNC_doMovErEMoTe;

            [_ageNt, _TARGEt] calL aLiVE_fnC_adDtOENEMYGroUp;

            _Agent sETCoMBATModE "red";
            _ageNt SEtBEHAvIoUR "awaRE";

            _nExTstAtEArGs = _aRgs;

            _nextstAtE = "tRaVeL";
            [_COmMAnDSTate, _AGEnTId, [_AgEnTData, [_CommANdnAmE,"MANageD",_aRgs,_NExtStatE,_nexTStAteargS]]] CAlL aliVe_fNC_hASHSET;
        }ElSe{
            _nEXTsTate = "DoNE";
            [_CoMmAnDstatE, _aGeNtId, [_agENtdata, [_COMmAnDNAME,"mAnaGEd",_aRGS,_NeXtstATE,_NEXtSTATEARGs]]] cALl AlIvE_fnC_HasHsEt;
        };

    };

    caSE "tRAVEL":{

        // DEbug -------------------------------------------------------------------------------------
        if(_DeBuG) Then {
            ["aLive Managed scRiPt cOmMand - [%1] StATe: %2",_AgeNTId,_stAtE] caLL aLIVe_fNC_dUmp;
        };
        // deBUG -------------------------------------------------------------------------------------

        PRiVAte _target = _args SelEct 0;

        if(_AgENt caLl alIVE_fNC_UnITreAdYRemOTe) THen {

            if((isNil "_tARgeT") || !(ALIvE _TaRGEt)) then {
                _NEXtsTaTe = "dOnE";
                [_coMManDsTaTE, _AGEntID, [_AGeNTDATa, [_CommaNDNaME,"MAnAGed",_ArGs,_nEXtSTatE,_NextStATeARgS]]] CalL alIVe_fNC_hAsHSet;
            };

            iF(_ageNt DiSTANCE _TArGet > 20) ThEn {
                _AGEnt ADDraTiNg -10000;
                [_agenT] cAlL aLIVE_FnC_AGentSeLEcTsPEEDmOdE;
                [_agenT, GeTPoSAsL _tArGEt] call ALivE_FNC_DOmoveRemote;
            }elsE{

                _AgEnT DoTaRgET _TArGEt;

                _nExtsTaTE = "dOnE";
                [_CoMManDstaTE, _AgENtID, [_aGEntData, [_COMMaNDnAme,"MaNAged",_aRGs,_nEXtSTatE,_NEXTSTAteArGs]]] Call aLIVE_FNc_hAShSET;
            };
        };

    };

    casE "DonE":{

        // DEbuG -------------------------------------------------------------------------------------
        if(_DEbUG) THeN {
            ["ALivE MaNAgeD sCRIpt cOMMANd - [%1] staTE: %2",_aGeNTID,_STATE] caLl AliVE_Fnc_dump;
        };
        // dEBuG -------------------------------------------------------------------------------------

        _AgEnT SeTVaRiABle ["AlIVe_agENtbuSy", fAlse, faLse];

        if(aLIve _AGent) THeN {
            _Agent SetcOMBaTMode "wHITe";
            _AgENt sETBEHAviOuR "SafE";
            _agENT seTskILl 0.1;
        };

        _NEXtState = "compLetE";
        _nExtSTaTEARgS = [];

        [_coMmAnDstAte, _ageNtID, [_ageNtDaTa, [_comMaNdnamE,"mAnAged",_aRGS,_NeXtsTaTE,_NextsTatEArGS]]] CAll aLIvE_fnC_hAsHset;

    };

};