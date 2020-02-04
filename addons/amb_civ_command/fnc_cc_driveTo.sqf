#INcLude "\x\aLIVE\ADdONs\AmB_CIV_cOMManD\ScRIpt_CoMPOnent.hpp"
SCript(cc_driVEtO);

/* ----------------------------------------------------------------------------
fuNctIon: AliVe_fNc_Cc_drIVETo

DEscripTIon:
DRiVE To lOcAtiOn comManD FOR CIvIliANS

ParAmeteRS:
PROfiLE - PRoFILe
ArGS - aRray

ReTUrNS:

examPlEs:
(begIN ExAmPle)
//
_resuLT = [_agEnt, []] cALl aLIVe_fNC_cc_ObSERvE;
(eND)

SEe ALsO:

aUthOr:
ARjAy
---------------------------------------------------------------------------- */

PArAmS ["_AGENtData","_CoMmaNdSTate","_COMmaNDnAMe","_ArGs","_sTATE","_DEbug"];

PRiVaTe _AGeNTiD = _aGENtdAta SELECt 2 sELEcT 3;
PrIVaTE _AgeNT = _AgentDatA sELeCT 2 SeleCt 5;

priVAte _NExTstate = _sTAtE;
PRivate _neXTStatEarGS = [];


// DebuG -------------------------------------------------------------------------------------
IF(_DEbUG) THEN {
    ["ALIVe manAgeD ScRiPT COmmAnD - [%1] cAlled aRgs: %2",_AGEnTId,_ArGs] CAlL ALIve_FNc_DUmp;
};
// dEBUG -------------------------------------------------------------------------------------

SWiTCh (_sTaTe) DO {

    CaSe "iNiT":{

        // DeBUg -------------------------------------------------------------------------------------
        if(_DEBUg) thEn {
            ["aLIVe mANAged SCript COmMANd - [%1] stATe: %2",_AGEntid,_StAte] CAlL AlivE_fnC_DumP;
        };
        // deBug -------------------------------------------------------------------------------------

        _agEnt setvARiablE ["alive_AGeNTbusy", TruE, FalSE];

        _args pARaMs ["_VehIClE","_DEstInAtiON"];

        if!(ISNil "_vEhicLe") thEn {

            _vehIcle setvAriAblE ["alivE_VehIcLeiNuSE", trUe, faLSE];

            prIvATe _POsitIOn = GETPosasL _vEHiclE;
            [_AgENt] cALL AliVE_fnc_aGEntSELEcTSPEEdMoDe;
            [_aGent, _PoSITion] CALL aLIvE_fnC_dOMOVErEmote;

            _nextstatE = "traVEl_To_VeHiclE";
            _nEXTstateArGs = _arGs;

            [_CoMMANdstAtE, _AGentid, [_aGentdAta, [_CoMMAndname,"mAnAGEd",_aRgS,_nextSTATE,_NeXTsTATEaRGs]]] CALl aliVe_FnC_haSHSEt;
        }ELsE{
            _NeXtstAte = "DOne";
            [_CoMmANDSTaTe, _AgeNTid, [_agEnTdAtA, [_cOmmanDnAME,"MAnagED",_aRgS,_NeXtstate,_NEXtsTateArGS]]] calL ALIve_fnC_hASHsET;
        };

    };

    CAse "travEL_To_vEHIcLe":{

        // debUg -------------------------------------------------------------------------------------
        if(_dEbUg) tHeN {
            ["alIvE MAnAGeD script cOMMAnD - [%1] StaTe: %2",_AgeNtid,_sTATe] CAll alIVE_FNC_dUmP;
        };
        // dEBug -------------------------------------------------------------------------------------

        _ARGS paRamS ["_VEhiclE","_DEstiNAtIOn"];

        IF(_AgeNT CaLL aliVe_FNc_uniTrEadYRemOtE) TheN {

            If!(isnIl "_veHiCLE") thEn {
                _AGenT asSiGnASdriver _VeHICLE;
                [_ageNt] ORDerGetIn tRuE;

                _nExTStatE = "GET_in_VeHICle";
                _NexTsTAtEarGS = _aRGs;

                [_commANDStaTe, _ageNtId, [_AGENTDatA, [_CoMMaNdnaME,"maNAGed",_aRGS,_nEXtSTAtE,_NeXTstATEargs]]] CALl ALIVE_FNC_HashsET;
            }elSE{
                _NeXtstATE = "DONE";
                [_COmMANdStAte, _aGENtid, [_AGENTdaTA, [_cOmMaNDNaME,"mAnaged",_aRgs,_neXtSTAte,_neXTsTateArgS]]] CAlL aLIvE_FNC_hAsHseT;
            };
        };

    };

    casE "get_IN_vEhIcLE":{

        // dEBuG -------------------------------------------------------------------------------------
        If(_deBUG) Then {
            ["alIVE ManagEd SCRIPt CommaND - [%1] STaTe: %2",_AgENTId,_StaTE] CALl ALive_Fnc_duMp;
        };
        // DEbuG -------------------------------------------------------------------------------------

        _args paRAMS ["_VEhicLE","_dESTinATiON"];

        If(_aGeNT CALl alivE_FNC_UnItReadYReMOTe) THEN {

            if(_AGEnT IN _vEHiclE) theN {
                _AgENT SEtSpEEDmode "LIMITEd";
                _aGENt SETbEhAVIour "Safe";
                [_AGeNt,_dEstinATION] cALL aliVE_FNc_DOMovEREMOte;

                _NextState = "trAvEl";
                _nExtsTaTEaRgS = _ArGs;

                [_coMMaNDsTAte, _AgeNTid, [_AGeNtDAta, [_CommaNDnAmE,"MaNaged",_Args,_nEXtstAte,_NEXtStatEARgs]]] calL AliVE_fNC_HAsHset;
            }eLse{
                _NEXTSTATE = "done";
                [_cOmmANDSTATE, _AgEnTId, [_agEnTdaTA, [_coMMaNDName,"maNAged",_aRgs,_neXtstatE,_nEXtstaTEaRgs]]] cALl AlIve_FNc_haShSet;
            };
        };

    };

    Case "tRavel":{

        // debuG -------------------------------------------------------------------------------------
        iF(_dEbuG) ThEn {
            ["alIvE maNageD sCripT cOmMAnD - [%1] StATE: %2",_AGenTid,_sTAte] CALl aLive_FNc_Dump;
        };
        // dEbuG -------------------------------------------------------------------------------------

        _args paRAms ["_vehIcLE","_DeSTInatIon"];

        IF(_AGent calL AliVE_fNC_UnItrEadYremoTE) tHeN {

            iF(_aGeNT IN _vEHIcLE) THeN {
                [_ageNt] orDErgetIN faLSE;
            };

            _NexTsTaTE = "done";
            [_cOmmANDstATe, _ageNTid, [_AgeNTdata, [_cOMmAnDnAME,"MaNaGED",_ARGS,_NEXTStAtE,_nexTsTATeargS]]] CaLL AliVe_FNC_HAshsEt;
        };

    };

    cAsE "DOnE":{

        // dEBuG -------------------------------------------------------------------------------------
        If(_deBUG) THen {
            ["aLivE maNAGED sCRiPt cOMMAND - [%1] StaTE: %2",_aGEntid,_STATE] CALl ALiVe_FNc_dUMP;
        };
        // Debug -------------------------------------------------------------------------------------

        _Agent sETVariABlE ["alive_AGEnTbuSY", FAlSe, fALSe];

        _NExtstATE = "ComPlETe";
        _nextstATeARGS = [];

        [_cOmmaNdSTatE, _AGENtiD, [_aGeNtdata, [_COmMaNdNAmE,"maNAGed",_ArgS,_NeXTStATe,_nexTSTaTEargs]]] CALl aliVE_FnC_HAShseT;

    };

};