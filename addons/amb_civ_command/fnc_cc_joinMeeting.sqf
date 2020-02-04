#iNclUde "\x\ALIVE\AddonS\aMb_Civ_CommAnD\scriPT_coMponenT.HpP"
sCRIpT(Cc_joInMEEtinG);

/* ----------------------------------------------------------------------------
functIoN: aLIve_Fnc_cC_jOinMeETINg

DeScriPTIOn:
sTarT meEtIng cOmMAnd FoR CiViLiANs

PArAmeTeRs:
PrOFILE - PrOFile
arGs - ARraY

rEtURNS:

eXAmpleS:
(beGin EXaMPlE)
//
_reSulT = [_AgenT, []] CaLL ALIve_fnc_cC_jOINmEETInG;
(End)

sEE aLso:

autHoR:
ArJaY
---------------------------------------------------------------------------- */

PAraMs ["_AGentdaTa","_CommAndSTaTE","_cOmManDnAme","_ARGs","_sTatE","_dEbUG"];

pRIvatE _agENTID = _agentdaTa sELEcT 2 SeleCt 3;
PrIVatE _aGEnt = _aGENtDATa sELEct 2 seLecT 5;

PRivAtE _nExtstaTe = _sTaTe;
PrIvaTe _nExtStAtEaRGS = [];


// dEBug -------------------------------------------------------------------------------------
if(_debuG) tHeN {
    ["aliVe ManagED ScrIPT COmmaNd - [%1] CaLled ARGs: %2",_aGeNtID,_ARGS] CALl alive_Fnc_duMp;
};
// deBug -------------------------------------------------------------------------------------

switCh (_StATe) dO {

    caSE "inIt":{

        // debug -------------------------------------------------------------------------------------
        if(_deBUG) THEN {
            ["aLive MaNAged ScrIPT COMMAnd - [%1] StATE: %2",_agENTiD,_stATe] cALL AlIVE_FNC_Dump;
        };
        // deBug -------------------------------------------------------------------------------------

        _arGS pARams ["_mINtImeout","_MAxTIMeoUt"];

        _aGEnt SetvarIaBlE ["alivE_AgenTBuSy", true, false];

        PRiVAte _tArget = _AGenT GeTvariaBle ["aLivE_agENTMeeTINGtARgET",ObJNULL];

        IF (IsNIL "_taRGeT" || ISNull _TaRgET) tHEN {
            _nextSTatE = "dONE";
            _NeXTsTAteArGs = [OBjNuLl,0,0];
            [_commaNdSTaTe, _aGeNTId, [_AGENTData, [_commaNdnAme,"mAnAGED",_ARgS,_nEXTsTatE,_nextstAteArgS]]] CAlL alIVe_FNC_hAsHSeT;
        }ELse{
            PRiVaTe _poSitIOn = GeTPOSaSl _taRGet;
            [_aGeNt] CAlL alIVe_FNc_AgENtSElecTSPEEDMoDE;
            [_AgeNT, _POSITiON] CALL alIVe_FNC_DOmovEReMoTE;

            PrivATE _TiMEouT = _MINtImEoUt + flOor(rAnDOm _maXTImEoUT);
            PRivaTE _TIMEr = 0;

            _nExTStatE = "trAvEL";
            _nEXTStateArgS = [_tarGEt, _tImEOUt, _TiMer];

            [_COMmaNdSTATe, _aGenTiD, [_AgentDAta, [_comMAndname,"MANaged",_ArGs,_neXTsTate,_nexTSTAteaRGS]]] CaLL AliVe_fNc_hAShSEt;
        };

    };

    CAse "TRavel":{

        // DEBug -------------------------------------------------------------------------------------
        iF(_DEBUg) THen {
            ["ALivE mANAGED sCripT CoMMANd - [%1] stAtE: %2",_agentId,_state] cALL aLiVe_fnC_DUMp;
        };
        // DEBUg -------------------------------------------------------------------------------------

        pRivatE _tArget = _ArGs SELeCt 0;

        iF(_aGENt CAlL aLiVe_fNC_uNItrEAdYRemotE) THEN {

            _AgENT lOOkAT _TaRGet;
            _TArget LOOKAT _agENT;

            iF!(_AgENT diSTaNCe _TarGEt > 10) tHEN {
                if(RandOm 1 < 0.5) THeN {
                    [_aGEnt,"ACTS_PoiNTinglEFTunarMeD"] calL alive_fnC_swITchmoVE;
                    [_taRgET,"Acts_sTANDiNgSPEAKiNGUNaRmeD"] CALl alIVE_Fnc_swiTChmoVE;
                }elSE{
                    [_agENT,"ACTs_STaNdinGspEakiNGunaRMEd"] Call AlIVE_Fnc_swITcHmOVE;
                    [_TARGeT,"aCTs_PoINTInGLEfTuNArMeD"] cALl ALIVe_Fnc_SWITCHMove;
                };
            };

            _nextsTaTE = "WAIT";
            _NEXTStatEarGS = _arGS;

            [_CoMMaNdsTaTe, _aGeNTiD, [_aGeNtdAtA, [_ComMAnDNaME,"mANagED",_ARGS,_neXTsTaTe,_NExTsTAteARGS]]] call ALiVe_fNc_haShseT;
        };

    };

    CAsE "wAIT":{

        // DeBug -------------------------------------------------------------------------------------
        If(_DEbUG) then {
            ["alIve MaNaged sCriPt cOMmAnD - [%1] StAte: %2",_ageNtId,_staTE] CaLL aLiVE_fNC_DUMP;
        };
        // dEbUG -------------------------------------------------------------------------------------

        _aRGs ParAMS ["_tArGet","_timeout","_tiMEr"];

        IF(ISnIL "_tARGEt" || {isnUlL _targeT}) tHEN {
            _nExTStAtE = "DoNe";
            _nExTstaTEaRgs = _ARgS;
            [_CoMMANDstaTe, _AgEnTID, [_AgENTData, [_commANDnaME,"MAnageD",_argS,_nEXTsTAtE,_nextSTaTEargs]]] cAlL ALive_fnc_hAshSET;
        }ELSe{
            if(_timer > _TIMEOut) Then
            {
                _nExtSTAte = "doNe";
                _NeXTSTateaRgS = _argS;
                [_cOMMaNdstATE, _AGentid, [_AGENTData, [_CoMMaNdNaMe,"ManagEd",_aRgs,_nExTStaTE,_nEXtsTaTeaRgs]]] call ALiVE_fnC_hAshSet;
            }eLSE{
                _timeR = _tiMEr + 1;
                _NEXtStAteArGS = [_TaRgeT, _tIMeOUT, _TIMer];
                [_CommaNdsTAtE, _aGENtID, [_agEnTdata, [_COmmandnaMe,"managED",_aRgs,_nExtstATE,_NeXtsTATEarGs]]] CALL Alive_fNc_hasHseT;
            };
        };

    };

    cAsE "dONE":{

        // DebUg -------------------------------------------------------------------------------------
        if(_DebuG) THEN {
            ["aLiVe mANaGED ScRiPT coMMAnd - [%1] STATE: %2",_AgentiD,_staTe] caLl AlivE_fNc_dUmP;
        };
        // DEBUg -------------------------------------------------------------------------------------

		_args PARaMs ["_TARgEt","_TIMEoUt","_TImEr"];

        _AGeNT SwiTchMOVe "";
        _AGEnT SETvarIABlE ["AliVE_aGENtmEEtINGReqUESTED", nIL, faLse];
        _Agent SEtVAriaBle ["alive_AgENtMeeTINgtARGet", Nil, falSe];
        _AGeNt sEtvarIAbLe ["AlIVE_AGENTBuSy", fALsE, fALse];
        
        _TaRgeT seTvarIABle ["AliVe_aGENTMeetiNgcomplETe", tRue, FalSe];

        _nExTstaTE = "comPletE";
        _NeXtstAtEArGs = [];

        [_cOmMANDSTaTe, _AGenTid, [_Agentdata, [_comManDNAMe,"MANagED",_aRgs,_nexTState,_NexTsTateARgs]]] cALl aliVE_fnC_hashsEt;

    };

};