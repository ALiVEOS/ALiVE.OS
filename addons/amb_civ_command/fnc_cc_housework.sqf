#InclUdE "\x\ALivE\AdDoNS\amb_cIV_CoMmAnd\sCRIPt_compOnENT.HpP"
sCRiPT(cc_hoUSEwORK);

/* ----------------------------------------------------------------------------
fuNcTiOn: alIVe_fnc_cC_houSEwork

desCRIPtION:
HOuSEWorK COMmAnd FOr aGENtS

PAraMEteRS:
ProFilE - proFiLE
aRGS - ARRAY

rETUrnS:

ExAMplES:
(BEgIn ExAMpLE)
//
_reSULt = [_AGent, []] cALL Alive_fNC_cc_hoUsEwORk;
(End)

SEe ALSo:

aUTHor:
aRJaY
---------------------------------------------------------------------------- */

pARaMS ["_AGenTDaTA","_cOmmAndsTaTe","_COMmAnDnAMe","_arGs","_State","_deBUg"];

PRIvaTe _AGenTID = _AGENTdaTa sElect 2 seLEct 3;
PriVate _AGENt = _AgENTdAtA SelEcT 2 SeLeCT 5;

PrIvaTe _NextSTATE = _STatE;
PRIvATe _NeXTSTAtearGs = [];


// debug -------------------------------------------------------------------------------------
if(_dEBuG) THEn {
    ["AlIVE manAGed sCrIPT coMMAND - [%1] cAlLEd ARgs: %2",_agENtID,_arGs] CalL AlivE_FNc_dumP;
};
// DEBug -------------------------------------------------------------------------------------

switch (_stAte) Do {

    CasE "INIT":{

        // deBUg -------------------------------------------------------------------------------------
        iF(_dEbuG) theN {
            ["aLIvE MAnAGEd SCriPT cOMmAnd - [%1] sTaTE: %2",_aGenTId,_sTATe] calL alive_Fnc_dUmP;
        };
        // dEBug -------------------------------------------------------------------------------------

        _aGeNT seTvAriablE ["alIVE_AGEnTbUSy", TRue, fAlsE];

        PRiVATE _HoMEposiTioN = _AGentdaTA seLEct 2 SElECT 10;

        prIvATe _pOsItIoNS = [_HOmEPositiON,5] calL aLIVE_fNc_FINDInDOOrhousepOsiTions;

        If(CoUnt _poSitioNS > 0) then {
            privatE _poSition = _poSitIONs caLL BiS_Fnc_aRRAYpOp;
            [_aGENT] Call aLive_fNc_ageNTseLectSPeEDMOdE;
            [_agent, _position] CaLL AlivE_fNC_DomoVeReMOte;

            _NeXtsTate = "TraVEl";
            _nEXtsTATEARGS = [_posItIOnS];

            [_cOmmaNDstaTE, _ageNTId, [_ageNtdATa, [_cOmmaNdNaMe,"MAnAgEd",_Args,_neXtstaTE,_NEXtstATEArgs]]] cAlL alIvE_FnC_HAshseT;
        }ElsE{
            _neXtsTate = "doNe";
            [_ComMaNdstate, _aGENtId, [_AGeNTdatA, [_CoMMAndNAME,"maNAgeD",_aRGs,_NextstATE,_NexTstAtEaRGs]]] cAll aLivE_fNc_hASHset;
        };

    };

    caSE "TRaVEl":{

        // DEBuG -------------------------------------------------------------------------------------
        if(_DebUg) thEN {
            ["alIvE MaNAgeD ScRiPt cOmMAnd - [%1] sTate: %2",_AGEntid,_sTaTe] CaLL AliVE_FNc_dUMp;
        };
        // deBuG -------------------------------------------------------------------------------------

        prIVaTE _PoSiTIOns = _ArGS sELECT 0;

        If(_AgenT Call ALiVE_fnC_UNITreAdyrEmote) then {

            pRivATe _dAystaTE = (caLL alIvE_fnC_getenVIronmeNt) seLEct 0;

            If(_daysTatE == "EvenINg" || {_dAYStATe == "Day"}) TheN {

                prIVatE _HOMEpOsitioN = _aGeNTDATa sElecT 2 SeleCT 10;

                if([_hOMePoSItion, 80] CAll aLIvE_FNC_anyPLaYeRSinraNGE > 0) TheN {
                    if!(_AgeNt gETvaRiABLE ["alivE_AGenTHOUSEmUsiCOn",FALsE]) thEn {
                        PRIvAte _builDing = _HOmEpOSitION nEArEstoBjECt "HOusE";
                        PRiVAtE _MuSiC = [_BuilDinG, faCtiON _aGENt] Call AlivE_fNC_AddAMBIENTRoOMMUSic;
                        _AgEnT SeTVaRiABle ["aliVE_AgENTHoUSeMusIc", _muSIC, FalSe];
                        _AGenT SeTvariaBLE ["aLivE_AGEntHoUSeMUsIcon", tRue, FAlsE];
                    };
                };

            };

            If(_dAySTAte == "evENIng" || {_DaYStATE == "NIGHT"}) THen {

                privATe _HOMEPOSItION = _agenTDAtA SelEct 2 select 10;

                IF!(_AGeNT GetvaRIaBlE ["aLIve_aGENthousELIgHTOn",FALSe]) then {
                    PrivaTe _BuildInG = _hOmePOSITion nearEstObJeCT "HOUse";
                    privatE _lIgHT = [_bUILdinG] CAlL aLIVe_fnc_aDdAMBiENtRoOmliGHt;
                    _ageNt seTVARIABLe ["ALiVe_aGenThoUseLiGHT", _liGHT, FALSE];
                    _agEnt sEtVaRIabLE ["AlIVe_AGEnThOusELIGHToN", TRue, fAlsE];
                };
            };

            _nEXTsTAtE = "hOuSeWorK";
            _NexTsTateArgs = [_POSiTiOns];

            [_COmMANdstaTe, _AgEnTiD, [_aGeNtdata, [_coMMANdNAme,"MaNaged",_aRgS,_neXTsTATE,_neXtstatEARGs]]] cAll aLIvE_Fnc_HASHset;
        };

    };

    CASe "hoUSeWoRk":{

        // DEbUG -------------------------------------------------------------------------------------
        iF(_DEBUG) tHEN {
            ["aLive MAnAGEd ScriPT cOMmanD - [%1] sTAtE: %2",_AgentID,_STatE] cALl aLivE_FNC_Dump;
        };
        // DebUg -------------------------------------------------------------------------------------

        PRivAte _posiTIONS = _argS sElEct 0;

        iF(COUNt _PoSITiONS == 0) TheN
        {
            _neXTsTAte = "DOne";
            [_cOMMandStaTE, _AGENtiD, [_AGeNTdaTa, [_CoMmaNdNaMe,"mANAGeD",_Args,_NEXTstATE,_NexTSTATEARGS]]] CALl aLIvE_FNC_HAsHSET;
        }
        elsE
        {
            IF(_Agent call aLivE_Fnc_uNItreadyreMote) theN
            {
                prIVAte _PoSiTIoN = _posItIonS caLL BIs_fnc_ArRaYPoP;
                [_AgEnt] CAll AliVe_fNc_aGeNTSeLEcTsPeEdmODE;
                [_agEnt, _PoSitiON] CalL AlIVe_fnc_DoMOVeREmotE;

                _neXtstATEArGs = [_posItIONs];

                [_COmmANDsTatE, _AGeNtiD, [_ageNtdAta, [_cOMMAnDNamE,"MaNagEd",_aRGs,_NExtSTatE,_NExtSTaTEARGS]]] cAll alive_fnC_haSHseT;
            };
        };

    };

    CASe "dOnE":{

        // deBUg -------------------------------------------------------------------------------------
        If(_debUG) THEN {
            ["ALiVe MaNAgED SCrIPT cOmmand - [%1] StATE: %2",_AGeNtiD,_StAtE] caLl aLivE_fNC_duMP;
        };
        // DebUg -------------------------------------------------------------------------------------

        _agENT sETvarIAble ["ALIvE_AGeNTbuSy", FalSE, FaLSe];

        _neXTstAtE = "cOMPlETE";
        _NExtsTATeaRgs = [];

        [_coMmandSTaTE, _AGeNtId, [_ageNTdAtA, [_CoMmANdname,"maNAGEd",_ArGS,_NeXtSTate,_nExtSTAteArGs]]] CALL AliVe_fnc_hASHSeT;

    };

};