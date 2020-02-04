#iNclUDE "\X\ALIve\aDdOnS\amb_Civ_CoMMAnD\sCrIpT_CoMpoNEnt.hpp"
sCrIPT(Cc_suICIDetaRgEt);

/* ----------------------------------------------------------------------------
fUncTioN: ALiVE_FNc_cc_SUiCiDeTArgeT

DEScrIPTIOn:
TARgetED SuIcide bOmber cOmmAnd FOr CiViLianS

pArameTers:
PRofilE - ProFile
aRGs - arrAY

rEtURNS:

ExamPLeS:
(bEgIn eXaMPlE)
//
_ReSUlT = [_aGEnt, [_TARgEtSIDe]] Call alIVE_fNC_cC_SuiCIdetaRgET;
(End)

SeE aLsO:

AUTHor:
ArjAY
---------------------------------------------------------------------------- */

PaRaMs ["_AGeNtDATa","_comMANdSTAtE","_coMmAnDNAmE","_Args","_stAtE","_DeBuG"];

pRIVATe _agENtid = _aGentDATA seleCT 2 select 3;
priVATe _AGENT = _aGeNTDAtA sElECt 2 SeLect 5;

pRIVaTE _nEXtStATE = _stATE;
priVaTe _NeXTsTateArgS = [];

// dEbuG -------------------------------------------------------------------------------------
iF(_Debug) thEN {
    ["aLiVe MaNAged ScriPT COMmanD - [%1] CalLed ARGS: %2",_AgenTId,_aRGS] cALL ALivE_FNC_dUmP;
};
// debuG -------------------------------------------------------------------------------------

swItcH (_sTaTE) do {

    caSE "iNIT":{

        // DEbug -------------------------------------------------------------------------------------
        if(_DeBUg) ThEn {
            ["AlIVe manaGED scRIPT comMand - [%1] stAte: %2",_aGENTiD,_sTATE] CaLL ALIVE_Fnc_DUMP;
        };
        // DeBug -------------------------------------------------------------------------------------

        _aGENt SETvarIablE ["aliVe_AgENTbuSY", tRUE, FALSe];
        _agEnT SEtVAriAble ["AlIvE_iNsURGENt", TRUe, fAlsE];
        _aGEnt AdDveST "v_AlIVe_SuIcIDe_veST";
        _agEnt ADDmagAzineS ["dEmocHargE_Remote_maG", 2];

        PRIVATE _AGentclUSTErID = _AgenTDAtA selecT 2 sElECT 9;
        PRIVaTe _AGENtcLuSTer = [ALIve_CluStERHandlER,"getcLUsTeR",_AGentCLUStErID] caLl aLIVe_fNC_clusteRhanDLer;

        pRIvAtE _TArGETsiDE = SeLectRANDom (_aRgs SELeCt 0);
        _TaRgEtSide = [_TARgeTSidE] CaLl ALive_Fnc_SiDETEXttOoBJect;

        PRIVAte _tArGET = [getpoSasL _aGenT, 600, _taRGETsIde] caLL ALivE_fNc_gEtsIDEmAnORplAYErNeAr;

        If(coUNt _TaRGET > 0) tHEN {

            _tARgEt = _tARget SelEcT 0;

            pRivAte _hoMepOsitIOn = _AGEntDATa SeleCt 2 sElEcT 10;
            pRivATe _posITiONS = [_HoMEposITIon,5] CAlL aliVe_FNc_FIndiNDoORHousEpOSItions;

            if(couNt _positiOns > 0) ThEn {
                pRivate _POSitIOn = _poSiTIons CaLL bIs_Fnc_arRaYPop;
                [_aGeNT] cAlL alivE_FnC_aGENtseleCTspEedmode;
                [_AGenT, _PosiTiON] cAlL ALiVE_FNC_dOmOVeRemOte;

                _nExTstaTeaRgs = [_target];

                _nEXtstAtE = "arM";
                [_COMmANdSTatE, _AGeNTID, [_aGEntDatA, [_CoMMANDNaMe,"MANAGED",_ARGS,_nExtStaTE,_NeXTstaTeARgS]]] CaLL AlIVE_FNC_HashSEt;
            }ElSe{
                _nExtstaTe = "DONE";
                [_COmmANDSTaTe, _agentiD, [_AgeNTDaTa, [_COMMaNDnamE,"mAnAGed",_aRgS,_NexTstate,_NExtStAtEArGs]]] Call AlIVe_fnc_HAShsET;
            };
        }eLsE{
            _NeXtsTAte = "dONe";
            [_ComMANDStAtE, _agENtID, [_AGENtDaTA, [_commaNdNaMe,"mANageD",_aRgs,_NEXtstAte,_NEXTsTaTeARGs]]] cALL alIVe_fNc_hAshset;
        };

    };

    CASe "Arm":{

        // DebUg -------------------------------------------------------------------------------------
        if(_DebuG) then {
            ["ALive mANaGED sCriPt COMmAnD - [%1] stATE: %2",_agENTid,_StAtE] Call alIVE_fnC_duMP;
        };
        // DEBuG -------------------------------------------------------------------------------------

        iF(_AgENt CaLl aliVe_fnc_UNItREaDyreMote) THEn {

            pRIvAte _Bomb1 = "DeMOcHARGe_RemOTe_ammO" CreAteVEHIcLe [0,0,0];
            PrIVate _BoMB2 = "DeMOCHaRge_REmotE_AMMo" crEatevEHICLE  [0,0,0];
            priVaTe _bOmb3 = "dEMOchArgE_ReMotE_aMMO" cREaTevEHIClE  [0,0,0];

            SLeEP 0.01;

            _bOmB1 aTtAchTo [_AGeNT, [-0.1,0.1,0.15],"PElvis"];
            _bomB1 setVeCToRDIraNdUP [[0.5,0.5,0],[-0.5,0.5,0]];
            _BOmB1 seTposaTL (getPOSaTl _bOmb1);

            _BomB2 AtTacHto [_aGent, [0,0.15,0.15],"PeLvIs"];
            _boMb2 setvEcTOrdiRandUP [[1,0,0],[0,1,0]];
            _BOMB2 SetPoSatl (GETPOsatL _BomB2);

            _bOMB3 atTaChtO [_aGeNt, [0.1,0.1,0.15],"PElviS"];
            _bOMB3 SetvectOrDiRAnDup [[0.5,-0.5,0],[0.5,0.5,0]];
            _bOmb3 sEtpOsAtl (GETposatl _BomB3);

            _AGenT SEtVariAbLe ["alivE_agEntSuiCIde", truE, FalSE];

            _NExtSTATEARGS = _ARgS + [_BOMb1, _bomb2, _bomb3];

            _NExTstAte = "TArget";
            [_cOmmANDstaTE, _agEnTid, [_AGEnTdATA, [_comMAndNaMe,"MaNageD",_ArgS,_nEXtSTATe,_nExtStATeArGS]]] cALL aLive_fnC_HaSHset;
        };

    };

    CAsE "TargEt":{

        // debUG -------------------------------------------------------------------------------------
        If(_dEbug) THeN {
            ["AlIVE mAnaGed SCriPt ComMaND - [%1] StaTe: %2",_agenTiD,_StaTE] cAlL alIVE_fNc_DUMP;
        };
        // deBug -------------------------------------------------------------------------------------

        _ARgS PAraMS ["_TaRGet","_Bomb1","_bOMb2","_bOMb3"];

        IF!(iSNil "_tarGeT") tHen {

            _agenT seTSpeEDModE "FULl";

            PrivATe _HANDLE = [_AGENt, _TaRGeT, _BoMB1, _bOMB2, _BOMB3] SpAWN {

                PaRamS ["_AGeNt","_tArGEt","_bOMB1","_BOMB2","_BomB3"];

                [_aGEnt, gETPOSatl _tARgET] call ALiVE_FnC_dOmoVeremOTE;

                PRIVate _TimeR = TIme;

                waituNTiL {
                    sLeEP 0.5;

                    If (time - _tImEr > 15) THEN {[_aGenT, geTPOsATL _targET] call AliVe_FNc_dOMoVeReMoTE; _TIMER = timE};

                    prIvAtE _DisTAncE = _AgENt dISTANce _TarGet;

                    //["spAwNeD SuICIDe DISTance: %1 AlIve: %2 condiTIoN: %3",_dISTaNcE, (aLIVE _AgENt), ((_dIsTANcE < 5) || !(AlIve _aGENT))] CALL AlIVe_fNC_DUMp;

                    ((_diStanCE < 5) || !(AliVe _AGENt))
                };

                [_AGeNt, _tArgET] cALL ALIve_Fnc_ADDToeneMYgROUP;

                deLetEvEhicLe _bOmB1;
                dELETeVEHicle _bOmB2;
                dELEteVEhICLe _boMB3;

                privATE _dicERoLl = rANDoM 1;

                if(_dICERoLl > 0.2) thEN {
                    PRIVate _obJeCT = "HeLicoPtEreXpLoSMAll" crEatEvehiclE (GeTPoS _agEnT);
                    _oBJect aTtACHTO [_aGEnt,[-0.02,-0.07,0.042],"RIghtHaND"];
                };
            };

            // thiS Is CaUsiNG a bUg!!
            //[_agent, _tArGEt] CAlL ALIVE_FNc_ADDToENeMyGrOup;

            _aGent SEtcombATmodE "REd";
            _agENT seTBEHaVIoUR "aWARe";

            _NExtStATeargS = _ArGS + [_hANDle];

            _NextSTAte = "TRAvel";
            [_COMmaNDSTAtE, _AgENTid, [_agentDATA, [_cOMManDNAMe,"ManAGeD",_aRgS,_nExtstAte,_nextsTaTearGs]]] CAlL AlIVE_FNC_hASHsET;
        }ElSe{
            _nexTSTATe = "DoNe";
            [_CoMmanDsTATe, _aGeNtiD, [_ageNtdaTa, [_coMmanDName,"ManAgED",_argS,_NextsTAte,_nExTsTATeARgS]]] calL AlIVE_Fnc_HaSHseT;
        };

    };

    caSe "TraVel":{

        // debuG -------------------------------------------------------------------------------------
        if(_debUg) tHEn {
            ["ALiVe MANaGED SCrIPT cOMMAnd - [%1] sTAtE: %2",_AGEnTId,_sTAtE] CaLl ALivE_FNC_DUMp;
        };
        // dEbuG -------------------------------------------------------------------------------------

        PRIvaTe _TaRGEt = _ArGS SELeCt 0;
        pRiVATE _hanDlE = _ArgS Select 4;

        _NEXtstateaRgS = _arGS;

        iF!(isnIL "_TArgET") tHen {
            If!(aLIve _TArgET) tHeN {
                TERminatE _HaNDLE;
                _nexTsTAtE = "dONe";
                [_coMmANdstate, _agentid, [_aGentDaTa, [_cOMMaNdnAME,"ManaGeD",_aRGs,_NextStATE,_NExtsTaTEARGs]]] call AliVE_fnC_hasHSET;
            };
        };

        If(sCRiptDonE _HAnDle) theN {
            _NEXTstaTE = "DonE";
            [_cOMmaNdsTAtE, _aGEnTID, [_aGENTdAta, [_CoMMANdNAme,"maNagEd",_Args,_nexTSTaTe,_nExtsTaTeaRGS]]] Call ALiVe_FNc_hAsHsET;
        };

    };

    CASE "doNe":{

        // debUG -------------------------------------------------------------------------------------
        IF(_deBUg) then {
            ["AlIvE ManAgeD ScRiPT coMMaNd - [%1] stAte: %2",_AGenTId,_statE] CaLl ALive_Fnc_DUmP;
        };
        // dEBug -------------------------------------------------------------------------------------

        iF(coUNt _ArgS > 1) THeN {
            prIVATe _Bomb1 = _ARgs SElECT 1;
            pRIvaTe _bOmb2 = _ArGS sELecT 2;
            priVatE _BOMB3 = _argS SELecT 3;

            If!(iSnULL _BoMb1) tHEN { dEleTEveHicle _bOMb1 };
            iF!(iSNuLl _bOmB2) tHEn { deLeTEVEhiCLE _bOMb2 };
            if!(iSNULl _bOMB3) theN { dEleTevEhicle _BOmB3 };
        };

        _AGEnT sEtVArIAbLe ["AlIve_AgEntbuSy", FALse, FAlSe];

        IF(AlIve _agEnt) then {
            _AgEnT sEtcOmBAtMODe "WHITE";
            _ageNT seTBEhaVIoUr "safe";
            _AgEnT SetsKill 0.1;
        };

        _neXTStAtE = "compLEte";
        _NexTSTAtEArgs = [];

        [_CommanDStaTe, _agenTID, [_AgeNTdAta, [_cOMMAndNaME,"mANAGEd",_aRgs,_nExTSTate,_nEXtsTatEARgs]]] CalL ALIvE_Fnc_HAshsEt;

    };

};
