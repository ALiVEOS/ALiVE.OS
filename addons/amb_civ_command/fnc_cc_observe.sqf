#IncLude "\X\alivE\adDOnS\aMB_CIV_COmmANd\scRiPT_coMPoNeNT.Hpp"
ScriPT(CC_ObSerVe);

/* ----------------------------------------------------------------------------
fuNCtIon: ALiVe_Fnc_cc_oBSERVE

DeSCRIptiOn:
obSeRVe ComMAND fOr cIviLIaNs

paRamETErs:
pROFIle - proFIlE
ARgs - ArraY

rEtURnS:

exAmPles:
(BeGIn eXaMpLe)
//
_rESUlT = [_AGent, []] call Alive_Fnc_cc_obSErve;
(eNd)

see aLsO:

authoR:
aRjAy
---------------------------------------------------------------------------- */

pArams ["_AGenTdATA","_cOmmAnDSTAte","_coMMANdnAMe","_aRgS","_sTate","_DEBuG"];

pRIvAte _AgENTid = _AGeNtDatA sElECt 2 sElecT 3;
PriVaTe _AGent = _aGEnTDaTa sElECT 2 SElECt 5;

pRivATe _NEXtSTATE = _sTatE;
PrIVaTE _nEXTStATeARgS = [];


// DeBuG -------------------------------------------------------------------------------------
IF(_DeBug) tHEn {
    ["aLIVe manAged Script CoMMand - [%1] CaLled ARGs: %2",_agentid,_ArgS] caLl ALIve_Fnc_DUmp;
};
// DeBug -------------------------------------------------------------------------------------

swItcH (_staTE) do {

    CAse "init":{

        // deBUG -------------------------------------------------------------------------------------
        If(_DEBug) tHeN {
            ["aLiVe managEd scRIpT cOMmAND - [%1] STaTe: %2",_agEntId,_StatE] Call alIVE_FNc_Dump;
        };
        // DebUG -------------------------------------------------------------------------------------

        _agEnT setVaRIablE ["AliVe_aGeNTbusY", TRuE, FaLSE];

        _argS pAraMs ["_mIntiMEOuT","_maxTImeouT"];

        pRiVatE _taRgeT = [gEtPosaSL _AGeNt, 50] caLl alIVe_fNc_getranDOMMANOrplAyernEar;

        If(coUnT _Target > 0) thEN {
            _tArgEt = _TARget selEct 0;
            [_agENt] cALL AlIve_FNC_aGENTselecTSpEedmOde;
            prIVaTe _POSitIon = (GetpOsAsL _tArgET) GetpOS [1+(raNdoM 5), randOm 360];
            [_AGenT, _poSiTIon] Call AliVe_FNc_dOmoVEREmoTe;

            PRIvATe _TiMeout = _mintiMeOuT + FlooR(RANdOm _maxTIMeoUt);
            prIvAte _Timer = 0;

            _nEXTStATE = "trAvEl";
            _NExtSTaTeArGs = [_TArGet, _tImeout, _TIMER];

            [_COmmANdSTATe, _AgeNtID, [_AGENtDAtA, [_cOmMaNdname,"mANaGED",_aRGS,_NeXTstaTE,_NExtstaTeArGS]]] cAll AlIvE_fNC_HaSHseT;
        }eLsE{
            _nExtSTAtE = "doNe";
            [_CoMmANdState, _agEntiD, [_agENtData, [_coMManDnAMe,"manageD",_arGS,_NExTstAte,_NeXtstateARGS]]] CAlL AlIVE_FnC_hAsHsET;
        };

    };

    cASE "tRAVEL":{

        // dEbUG -------------------------------------------------------------------------------------
        iF(_DeBuG) tHen {
            ["ALivE MaNageD ScRiPt ComMANd - [%1] STatE: %2",_aGenTid,_State] CAlL AlIvE_fnc_DumP;
        };
        // DEbuG -------------------------------------------------------------------------------------

        PRiVAtE _TaRGEt = _ARgS SEleCt 0;

        If(_aGENT Call AlIve_Fnc_UnitreADyReMoTe) THeN {

            If!(isnIL "_tArgEt") Then {
                _aGENt DOWATch _TaRgeT;
            };

            If(RaNDoM 1 < 0.3) tHen {
                [_AgEnT,"INbaSEMoVES_HaNdsbeHIndback1"] CALL AliVE_Fnc_sWiTCHmovE;
            };

            _NEXTsTAte = "WAiT";
            _NExtSTATEaRgS = _ARgS;

            [_commaNdstATe, _agentiD, [_aGEnTDATA, [_CoMmaNdNamE,"MaNaGED",_ARGs,_NeXtstAte,_NexTsTAtEaRgS]]] CalL aLive_fnc_HASHSET;
        };

    };

    CaSE "WaiT":{

        // DebUG -------------------------------------------------------------------------------------
        iF(_deBUg) Then {
            ["Alive maNageD SCript coMManD - [%1] StatE: %2",_AgENTId,_STaTe] CALL alIvE_FNc_DuMp;
        };
        // dEbuG -------------------------------------------------------------------------------------

        _args parAMS ["_taRgEt","_tiMeOut","_tImer"];

        If(_timer > _tIMeouT) thEN
        {
            _AgENt playMoVe "";
            _nExTsTATe = "DONe";
            [_cOMmANdstAte, _aGentiD, [_AGENtData, [_CoMmaNdNAme,"mANaGeD",_arGS,_neXtStaTe,_NextStaTearGS]]] calL ALIVE_fnC_hashSeT;
        }ELse{
            if(_aGenT calL AlivE_fNC_unITREAdyREMOte) Then {
                If(_ageNt DIsTAnce _tARGET > 7) tHen {
                    [_agENt] call AliVE_Fnc_AgEntsEleCtSPeEDmOdE;
                    PRIVate _PosiTion = (gETpoSaSL _TArgEt) gETpos [1+(randOm 5), raNdom 360];
                    [_agENT, _pOSitIoN] cALL alIve_FNc_DoMoVERemotE;
                }
            };
            _TiMER = _timEr + 1;

            _NeXtSTatEargS = [_TarGEt, _TIMeouT, _TimeR];

            [_coMmANdsTatE, _agENTid, [_aGEnTdAtA, [_ComMANDNaME,"ManAGed",_aRGs,_nExTsTaTe,_NextstaTEARgS]]] CAll alive_Fnc_haSHset;
        };

    };

    cASe "DonE":{

        // DeBUG -------------------------------------------------------------------------------------
        If(_deBUg) tHEN {
            ["alivE ManAged scriPt cOMmanD - [%1] StaTE: %2",_agEntID,_sTate] CALL alIVE_Fnc_DuMP;
        };
        // debUG -------------------------------------------------------------------------------------

        _agENT SetVArIabLE ["ALive_agentbUsY", FAlSE, fAlse];

        _nexTstaTe = "COmplEtE";
        _NexTStAteARgs = [];

        [_cOMmaNDstate, _AgenTId, [_AGENTdata, [_COMMANDNAme,"ManAgeD",_arGS,_nExTStATE,_NEXtstATEarGS]]] Call aLIve_fnc_HasHset;
    };

};