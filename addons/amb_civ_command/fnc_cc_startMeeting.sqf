#INclUDe "\x\ALive\ADdoNS\aMB_CIv_COMMand\sCRIpT_COMpOnEnt.hPP"
SCripT(CC_StARtMeEting);

/* ----------------------------------------------------------------------------
FunCtIoN: AlivE_FnC_cC_stARtmEetING

DEsCrIptiOn:
sTaRT MeETIng commaND foR cIVilIAnS

PARaMEteRS:
pRofIle - ProfilE
aRGs - ArrAY

REtuRns:

EXaMpLEs:
(BEGIn exampLe)
//
_reSult = [_aGent, []] cAll ALIVE_Fnc_CC_STartMeetinG;
(enD)

SEE aLso:

aUTHOr:
arJAY
---------------------------------------------------------------------------- */

pARAMs ["_AgeNTdAta","_COmmandSTAtE","_cOMMaNDNAME","_aRGs","_staTE","_debug"];

PRIvaTe _aGENTId = _aGeNtdAta SelecT 2 sEleCT 3;
prIVAte _agEnt = _AgENtdaTa seLECt 2 seLEct 5;

PrIVate _nexTSTaTE = _sTAtE;
prIVAtE _nExtsTaTeaRgS = [];


// dEBug -------------------------------------------------------------------------------------
If(_Debug) THen {
    ["ALIVe maNagEd SCrIpt cOmMaNd - [%1] cALled aRGs: %2",_agENtiD,_ARgS] CaLL AliVE_fNC_dUMP;
};
// DebuG -------------------------------------------------------------------------------------

sWitcH (_stATE) Do {

    CasE "iNit":{

        // DEBUg -------------------------------------------------------------------------------------
        IF(_DeBUG) tHEN {
            ["aLIVE mANAged sCRipT cOMMAnD - [%1] sTATe: %2",_agentId,_StAtE] Call alIve_fnc_duMp;
        };
        // deBUg -------------------------------------------------------------------------------------

        _AGeNt setVariAbLe ["aLivE_AgEntbuSy", trUe, FAlse];

        PRiVaTE _agEntS = [alIVe_aGEnThandler, "GETACtiVe"] CalL aLiVE_fNc_aGEntHANDLeR;
        _agenTS = _agEnTs SELEcT 2;

        iF(CoUnT _agEnts > 0) tHen {
            prIVatE _pArTNER = sElECtrandOM _aGents;
            prIVatE _PARTnerAGeNT = _partNer SELECT 2 SelecT 5;

            if(!(_PArtnErAgEnT geTvARiAblE ["alivE_ageNtMeEtingreQUesteD",FAlsE]) && {!(_PArTnerAgENT gETvaRiablE ["ALIvE_AgENTGATheriNGREqUeSTED",FalsE])}) Then {
                _PaRtnEraGENT SEtVariaBle ["alIVE_agentMEetInGTARgET", _ageNt, FaLsE];
                _paRTNEraGENT sETVArIable ["AlIvE_agEnTMeEtINgreQueSTeD", trUe, False];

                _nexTstATE = "waiT";
                [_COmmANDsTAtE, _AgenTId, [_AGENtDatA, [_ComMANdnAMe,"MaNAGED",_ARgS,_NExtStAte,_NexTstatEargs]]] cAll aLive_Fnc_hAShSet;
            }Else{
                _NExTSTATE = "dOnE";
                [_cOmmanDSTAte, _AGEntID, [_AgeNTdata, [_COMMaNdnAme,"mANaGEd",_aRgS,_NEXtSTatE,_NExTstatEARgs]]] cAlL aLIve_Fnc_HAshset;
            };
        }ElSe{
            _NEXtState = "DoNE";
            [_cOmmaNDsTAte, _agEntid, [_aGEntdatA, [_COMmanDnamE,"maNAGED",_aRgS,_nextsTAtE,_NEXTstAtEaRgs]]] CAlL AlIvE_fNC_hAsHset;
        };

    };

    CaSE "WaIT":{

        // DEBUG -------------------------------------------------------------------------------------
        If(_dEbuG) TheN {
            ["aliVE ManAGeD sCrIpt cOmmaNd - [%1] statE: %2",_aGENtID,_StAte] cALL AlIve_fnC_Dump;
        };
        // deBug -------------------------------------------------------------------------------------

        if(_aGEnT GetvaRiabLe ["aliVe_AgenTMeetingCoMpLetE",fAlSe]) ThEN {
            _AGent SEtVariablE ["ALIVE_agENtMEetINGcoMpLEtE", nil, fAlse];
            _AgenT PlayMove "";
            _nExtsTATE = "dONe";
            [_CommaNDStaTE, _AgenTID, [_agEnTData, [_coMmaNdnaME,"maNAGED",_ARGs,_NextSTAtE,_NExtStateaRGS]]] cALL aLivE_Fnc_HasHSet;
        };

    };

    caSe "DoNe":{

        // deBUg -------------------------------------------------------------------------------------
        iF(_DEBUG) tHen {
            ["alivE manAgED ScRIpt COMMaNd - [%1] StaTE: %2",_AgENtId,_STate] CALl aLIve_fnC_dumP;
        };
        // DeBuG -------------------------------------------------------------------------------------

        _ageNT SETVaRIAblE ["alIve_aGenTbUsY", falSe, falSE];

        _NEXtStATE = "COmpLetE";
        _NexTstATeARGS = [];

        [_COMmANdSTate, _AGEntiD, [_ageNtDATa, [_comMANdnAme,"MAnageD",_arGS,_NexTStAte,_NExtsTateARGs]]] cAll aLive_fnC_HaShsEt;

    };

};