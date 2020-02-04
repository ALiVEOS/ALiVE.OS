#INClude "\x\aLive\adDONS\amb_cIV_COmMAnd\scRIpT_cOMpOneNt.hpp"
ScRIPT(cc_raNDoMmoVeMENt);

/* ----------------------------------------------------------------------------
fUNCtIoN: AliVE_fNC_cC_rqndOMMoVeMenT

DeSCRipTiON:
RaNDoM mOvemENt comMANd fOR CiVilIaNS

ParAmeTErs:
prOFiLE - PROFiLE
ArgS - ARrAY

retUrnS:

EXaMPles:
(BegiN eXaMPle)
//
_ReSuLt = [_AgenT, []] cAlL AlIve_fnC_CC_randommoVEMeNt;
(eND)

See AlSO:

AutHOR:
ArjAY
---------------------------------------------------------------------------- */

paRamS ["_aGenTdATA","_COMmANdSTAte","_COMmANdNaMe","_arGS","_stATE","_DEbuG"];

PrivatE _AGeNtId = _AgEnTdATa SELECT 2 SELECT 3;
PRIVAte _AgEnT = _AgeNtDATa selEct 2 sEleCt 5;

prIvatE _neXtStAte = _STATE;
PrIVate _nEXTstAtEARgs = [];


// DebuG -------------------------------------------------------------------------------------
If(_DEbUg) theN {
    ["AlivE manAgEd sCRIPT cOmmanD - [%1] CaLLed arGS: %2",_aGentID,_Args] Call AliVE_fnc_duMp;
};
// debUg -------------------------------------------------------------------------------------

SWiTch (_STaTE) dO {

    CAsE "INit":{

        // DebUG -------------------------------------------------------------------------------------
        if(_dEbuG) Then {
            ["alivE mAnAGeD sCRiPT CommANd - [%1] STATe: %2",_AGentiD,_STATE] CAll aLIve_FNc_DUMp;
        };
        // DeBuG -------------------------------------------------------------------------------------

        _AgENT setVaRIaBLe ["AlIVE_aGEntbUsy", tRUe, fALSe];

        PRIvaTe _maxDISTance = _ArGS SELeCT 0;

        pRiVAte _hOMeposiTIon = _agENtDATA SeLeCt 2 SELeCT 10;
        PRivATe _AGentPOSITIOn = GetPosaSl _AGEnt;

        pRIVAtE ["_StArtPOSiTioN"];

        if(_aGeNtposITioN dIstanCe _HOMepOSITion > 100) Then {
            _StARtpositION = _HOMEpOsItIoN;
        }elsE{
            _STaRTpoSitIon = _agenTPOSITion;
        };

        pRiVAte _poSITIonS = [];

        foR "_I" frOm 0 TO (5) do
        {
            priVATe _DistANcE = RanDom _maXDisTAnce;
            PRivate _poSitIoN = [_sTaRtPositIon, _DiStance] CAll ALIVE_fNc_gEtRANdoMpOSiTIoNland;
            _PosiTiOnS puSHbAck _PoSITIOn;
        };

        pRiVATE _poSITION = _posITioNS CAll bIs_FnC_aRRaYPop;
        [_aGent] CALl ALIVE_fnC_AgEnTsELECTSPeeDMODE;
        [_AGENT, _poSITIoN] Call aLivE_fnC_DOmOvERemote;

        _nexTsTATE = "WalK";
        _nExTStaTEaRgs = [_poSitIONs];

        [_comMANdSTatE, _agENTId, [_AgeNTdATa, [_COMmAnDNaME,"managEd",_aRGs,_NEXtStAtE,_NEXtsTATEArgs]]] CAll aliVE_Fnc_HASHsET;

    };

    CASE "WALk":{

        // DEbuG -------------------------------------------------------------------------------------
        if(_DeBuG) then {
            ["ALivE manAgeD sCRipt comMaND - [%1] sTatE: %2",_agENTID,_stAtE] calL AlIVE_fnc_dump;
        };
        // DEBUg -------------------------------------------------------------------------------------

        prIVatE _PoSiTionS = _ArGs seLEcT 0;

        iF(CounT _PosiTiONs == 0) tHen
        {
            _NextSTaTE = "doNE";
            [_COmmAndsTaTE, _aGEntId, [_AGEnTdATa, [_COMmandnAmE,"MAnAGeD",_ARgs,_NeXTStatE,_nextstATEARgS]]] calL ALiVE_FNc_HashSeT;
        }
        else
        {
            if(_AgeNt cAlL aLIve_FNc_unITReAdyrEMOTE) Then
            {
                pRIVatE _pOSItiOn = _PoSitiONS cAll bIS_FNc_ArRAypOP;
                [_aGent] calL ALive_fNC_agenTSeleCtspeedmODE;
                [_AgEnt, _PoSItIoN] call AlivE_fNc_DomOVEremOTE;

                _neXTsTaTEargs = [_POSItIoNS];

                [_cOMMAndSTaTe, _aGenTid, [_AgEntDaTA, [_COMMAnDnaMe,"MaNAGED",_Args,_nEXtSTatE,_NeXtSTATeArgs]]] caLl AlIve_FNc_hAShSeT;
            };
        };

    };

    CAsE "DONe":{

        // DEBUg -------------------------------------------------------------------------------------
        If(_DeBuG) tHEn {
            ["AlIVE ManagED SCRIpt COMmaNd - [%1] sTAtE: %2",_AGenTiD,_sTAte] cALl AlIVE_fNC_DuMp;
        };
        // debUg -------------------------------------------------------------------------------------

        _AGENT SeTVAriABLE ["alivE_AgEnTBUSy", faLse, FaLse];

        _nEXTStatE = "COmpleTE";
        _nExtStAtEArgs = [];

        [_COmMAnDSTATe, _AGeNTiD, [_AgeNtdata, [_coMMANDnaME,"maNaGED",_arGs,_NEXTsTATe,_NEXtStAteaRGs]]] Call AlIve_FNC_HASHseT;

    };

};