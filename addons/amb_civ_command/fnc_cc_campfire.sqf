#InClude "\x\aLIvE\ADdONS\AmB_civ_coMmand\sCripT_CoMpOnEnT.HPp"
scripT(cC_caMpfiRe);

/* ----------------------------------------------------------------------------
FUNCtiOn: aLiVe_fnc_cc_cAmpfiRe

dEScrIPTiOn:
CaMPfIrE COmManD fOr CIvILIaNs

pARamEteRs:
prOfile - pRoFiLe
argS - arRay

REturNs:

exaMples:
(bEgIn ExaMplE)
//
_reSULt = [_AGeNt, []] calL AlIVE_fNC_CC_cAmpFiRE;
(enD)

sEe also:

authoR:
ARjAY
---------------------------------------------------------------------------- */

paRaMs ["_agenTData","_coMMAndsTaTE","_COMMandNAme","_ARGs","_StaTE","_DEBUg"];

PRivaTE _AgENTid = _AGENTdATA seleCT 2 sEleCT 3;
priVatE _agenT = _AgentDatA sELEct 2 seLECt 5;

PrivATe _NexTstaTe = _stATE;
PRivAte _NeXTStaTEARGs = [];


// deBUG -------------------------------------------------------------------------------------
if(_dEbuG) THEn {
    ["aLIVe managEd sCrIPT cOmmAnd - [%1] CALlED argS: %2",_AGenTid,_ArgS] caLl alIve_Fnc_Dump;
};
// deBuG -------------------------------------------------------------------------------------

Switch (_sTATe) do {

    cASE "INIt":{

        // DEBuG -------------------------------------------------------------------------------------
        If(_DeBUg) ThEN {
            ["aLIVE ManageD ScrIPT coMmanD - [%1] stAte: %2",_agEnTID,_sTATe] CALL AliVe_fnC_DuMP;
        };
        // DEBuG -------------------------------------------------------------------------------------

        _aGeNt sEtVariAblE ["alIVe_AgENtBusy", trUe, fALSe];

        _ARGS PARaMs ["_mInTIMEout","_MAxTimEouT"];

        PRiVATe _pOs = geTPoSATl _AGeNT;
        priVATE _pOSItIoN = [_PoS,0,10,1,0,10,0,[],[_POS]] CALL bIs_fNc_findSaFePos;

        iF(COunT _pOsiTiOn > 0) THen {
            [_aGeNT] Call ALiVE_FnC_AgenTsElECtspEEDMOde;
            [_agENt, _pOSITioN] cALl AlIve_FnC_DoMoveREmote;

            prIvaTe _tIMEOUT = _mInTimeout + FLooR(RAnDOm _MAXtIMeOut);
            prIVatE _tiMeR = 0;

            _NextSTatE = "trAVEL";
            _nExtstATEARGs = [_tIMEOUt, _timer];

            [_COMMaNdsTatE, _aGeNTID, [_agEnTDaTA, [_cOmManDNAMe,"ManAGed",_args,_nextSTATe,_neXtSTAteaRGS]]] caLl aliVE_FnC_hAshsET;
        }ELse{
            _NEXtSTaTe = "DOne";
            [_COMmandstaTE, _AgeNtId, [_aGEntdATA, [_comMAndnamE,"mAnAGed",_aRGS,_nExTSTate,_NEXtstAteARgS]]] cALL aLivE_fNc_HAsHsET;
        };

    };
    CASE "TRAveL":{

        // DEbUg -------------------------------------------------------------------------------------
        iF(_dEbUg) tHen {
            ["alive MANaGEd SCRiPt cOmMaND - [%1] STAtE: %2",_AGenTid,_STATe] cALl AlIVe_fNC_DuMP;
        };
        // DEbuG -------------------------------------------------------------------------------------

        prIVate _posiTiONS = _ArgS sELeCt 0;

        if(_agent cAll Alive_fNc_UNITreADYrEMoTe) TheN {

            privATE _firE = "fIREPLAce_bUrNInG_F" CReateveHicle (pOSItIOn _AgeNt);

            _AGEnt LOokat _FIrE;

            _AgeNT ActIoN ["sitDOwn",_aGEnt];

            _neXtStAte = "WaiT";
            _NEXtSTatEARGS = _aRgS + [_FIRe];

            [_comMANdStaTE, _AGENtID, [_AgEnTdAtA, [_cOMmANDname,"maNageD",_Args,_NExtStaTE,_NeXtsTatearGS]]] CALL aLIvE_Fnc_hAshSet;
        };

    };

    CAsE "WaIT":{

        // Debug -------------------------------------------------------------------------------------
        IF(_deBug) tHeN {
            ["Alive mANAGEd sCRipt commAnd - [%1] STAte: %2",_aGEntiD,_STaTE] CaLL ALIVE_FNc_dump;
        };
        // debuG -------------------------------------------------------------------------------------

        _aRgS pArAMS ["_tiMEOut","_TimeR","_FirE"];

        IF(_TImER > _tiMEoUT) theN
        {
            _AGENT PLAyMoVe "";
            DeleTeVEhICLe _Fire;
            _NExTSTaTe = "DONE";
            [_COmmAnDSTate, _aGEnTID, [_aGenTDatA, [_commaNdnaME,"mANAGed",_arGS,_NExtStaTE,_nEXtsTatEaRGS]]] caLl alive_fnC_HaSHset;
        }Else{
            _TIMer = _TiMeR + 1;

            _nEXtSTAtearGs = [_TimeOUt, _tIMeR, _FIre];

            [_COmmaNDSTAte, _aGentiD, [_AGeNTDAta, [_CoMmanDnAme,"mANAgEd",_ArgS,_NextStAtE,_NexTsTATeaRgS]]] CalL ALivE_fNc_HAshseT;
        };

    };

    CASe "done":{

        // DebUG -------------------------------------------------------------------------------------
        IF(_DEbUG) theN {
            ["aLIve MAnaged ScRIpt commAnd - [%1] StATe: %2",_aGENTid,_stAte] CAll ALive_FNC_DUMp;
        };
        // deBUG -------------------------------------------------------------------------------------

        _AGENT sEtvARIABlE ["AlIVe_agENtbuSy", falSe, FaLSe];

        _NExtsTAtE = "comPleTe";
        _nExTsTateArgS = [];

        [_CommANDsTATe, _AgEnTID, [_AgeNtdATA, [_COmMANDnAmE,"mANagED",_args,_NExtstaTe,_neXTStAtEARgs]]] cAlL aLIve_FNC_hAShSeT;
    };

};