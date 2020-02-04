#INclUde "\x\ALivE\Addons\aMb_cIv_cOmMAnd\SCRIPT_compoNEnt.HPP"
SCripT(CC_JoINgATHeRING);

/* ----------------------------------------------------------------------------
FUNCTiON: alIve_fNc_cC_jOingATHeriNG

DesCRiPTioN:
stARt GAtheRiNG ComMAnD FOr cIvILiaNS

pARaMETeRS:
proFiLe - PRoFiLe
args - ARRaY

reTURns:

exAMples:
(BegIn eXamPLe)
//
_resuLt = [_aGeNT, []] caLl ALIve_fNc_CC_jOiNgAthERiNG;
(enD)

sEe aLsO:

auThor:
arJAY
---------------------------------------------------------------------------- */

PaRAmS ["_agEnTDATA","_cOmmaNdstAte","_coMmandname","_arGS","_sTatE","_DEBug"];

PrIVATe _aGenTID = _AGeNtdATA SELEcT 2 SelECT 3;
PrIvAte _AGENT = _AgeNTDAtA SELEcT 2 seLEcT 5;
pRivaTe _hoMepoSItIoN = _AgEntdAta SeLEcT 2 SELeCT 10;

PrIVATE _nExtStAte = _staTe;
pRIvate _neXTSTatEARgs = [];


// deBug -------------------------------------------------------------------------------------
If(_DebUg) tHEn {
    ["aliVe mAnAGED ScRiPt COMmaND - [%1] CAlleD ARgS: %2",_agENtID,_ArGS] CAll aLIVE_FnC_Dump;
};
// deBUg -------------------------------------------------------------------------------------

SWItcH (_StaTE) Do {
    cASE "iniT":{

        // dEbUG -------------------------------------------------------------------------------------
        if(_debug) THEN {
            ["alIvE manAGed ScrIPt coMmanD - [%1] sTatE: %2",_agEnTId,_stATE] CaLL AliVe_fnC_dUmP;
        };
        // dEBUG -------------------------------------------------------------------------------------

        _aGent SetVaRIAble ["ALIvE_agEntBuSY", TrUe, FAlSe];

        pRiVaTe _TargEt = _AgENt GEtVaRIAbLe ["alIve_AGenTGaTheriNGtargET", obJnulL];

        if (!ISNIL "_tARgEt" && {!IsnULL _tArget}) thEn {
            PRivATE _POsITiON = (GEtPOSATl _taRGEt) GeTpOS [ranDOM 4, randoM 360];
            [_AgENT] call AlIvE_fnC_aGeNtSeLEctSpeeDmode;
            [_AGENT, _posITiOn] CAlL ALIvE_FnC_DoMOVErEMoTe;

            _NeXTstaTe = "TrAVEl";
            _NExtsTAtEarGS = [_TArGEt];

            [_coMMANdsTATE, _aGeNtId, [_AGEnTdata, [_cOmMAnDnAMe,"mAnaged",_ArgS,_NEXtSTaTe,_NeXTSTAtearGs]]] cALl alIVE_fNC_HasHSEt;
        }else{
            _AGent sETvAriAble ["AlIve_agenTGathERingCoMPLEtE", True, fALse];
            _AgENt seTVaRiaBlE ["alive_agEnTGathERiNGRequEStED", FAlSe, FAlSE];
            _NExTsTaTe = "dONE";
            [_COMmaNdStaTe, _AgentId, [_agEntdATA, [_COMMANDNaME,"manaGED",_ARgS,_nExTSTAtE,_nexTStATEArGS]]] CaLL AlIVE_FNC_HAsHSEt;
        };

    };

    cASE "TrAvEL":{

        // deBug -------------------------------------------------------------------------------------
        If(_debug) ThEN {
            ["aliVE MAnaGed ScRIpT COMmanD - [%1] STaTe: %2",_agentId,_statE] CALl ALiVE_fnC_DUMp;
        };
        // DebUg -------------------------------------------------------------------------------------

        pRIVAte _TaRGEt = _aRgS SeLecT 0;

		if (!isNIl "_TaRGEt" && {!IsnulL _TarGEt}) then {

        	IF(_AGENt cALl aLIve_FNc_uNITREADyremOte) tHeN {
                
                _agENT lOOkaT _tARGEt;
                _TARget LoOkaT _aGenT;

                if (_agent DisTAnCE _tArGet < 5) thEN {
                    If(rAnDom 1 < 0.5) THEn {
                        [_ageNT,"aCts_pOiNtinglefTuNaRmed"] cALl aLIvE_fNC_sWITcHmOVE;
                    }Else{
                        [_AgEnt,"ActS_sTANDInGsPeAKINgUNARMEd"] Call alIvE_FNc_swITCHmoVE;
                    };
                };

                _nExtStATE = "wait";
                _NExTstaTeARGS = _ArGs;

                [_cOmMAndsTaTe, _AGENtid, [_aGENtdaTA, [_cOmmANDName,"maNAgEd",_arGS,_NExTsTAte,_NexTStaTeaRGS]]] CALL ALivE_FNC_hASHsEt;
            };
        } ElSE {
                _agEnT SetvaRIAbLE ["ALiVe_aGEntGAthERiNGCoMPlETE", trUe, FALSe];
                _AGENt sEtvaRIabLE ["aLIVe_AgENtgATHErINgreQuEsted", FAlsE, faLse];
                _NEXTSTATe = "doNe";
                [_cOMMANdstATe, _agenTId, [_agEntDAtA, [_COmManDnaME,"maNAGeD",_ARGS,_NExTstAte,_NexTsTateaRGS]]] CAlL aliVe_Fnc_HaShseT;
        };
    };

    cAsE "Wait":{

        // dEBug -------------------------------------------------------------------------------------
        If(_DeBug) tHeN {
            ["AlIVe MAnaGEd ScrIPt coMMand - [%1] StATe: %2",_AgentID,_STatE] caLl aliVE_fNC_DUMp;
        };
        // dEbUg -------------------------------------------------------------------------------------

        if(_AGeNt getVarIablE ["alivE_aGentgAtherINgcOmpLETE",FAlSE]) Then {
            _nEXtsTAtE = "DoNe";
            [_COmmaNDsTATE, _aGEnTID, [_AgenTDaTa, [_cOmMandNamE,"manaGeD",_ArGs,_nExTstATe,_NextSTAtEarGs]]] CALL ALIve_fNc_HaSHsEt;
        };

    };

    Case "DoNE":{

        // debug -------------------------------------------------------------------------------------
        if(_DEBug) then {
            ["ALIvE mAnAged ScRIpT cOMmaND - [%1] stAte: %2",_aGENTid,_state] CalL Alive_fNc_dump;
        };
        // DeBuG -------------------------------------------------------------------------------------

		_agent sWITChMOVe "";
        IF (_HOmepOsitiON DIsTancE [0,0] > 500) Then {[_AgEnT,_HOmePOsITion] Call AlIvE_Fnc_DOmOvEReMOTE};
        _aGEnT SetVARiaBLe ["alIve_agenTBusy", FaLse, falsE];
        

        _nextsTAtE = "ComPLeTe";
        _NextstatEARGS = [];

        [_COmmAnDsTaTe, _AgentId, [_AgenTDAta, [_cOmmAndnaME,"mANaGed",_ARGs,_nEXtState,_NEXTstAteaRGs]]] cALl aLiVe_fnc_HaSHSET;

    };

};