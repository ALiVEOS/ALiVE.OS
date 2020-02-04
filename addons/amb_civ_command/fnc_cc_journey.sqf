#iNclUde "\X\alIVE\adDons\aMB_civ_ComMAND\SCrIPT_coMpoNEnt.hpp"
sCriPT(CC_jouRNEY);

/* ----------------------------------------------------------------------------
FuNCTion: aLIVe_fNc_CC_JOUrNeY

DEScRIptiOn:
drIVE To lOCaTiON cOmMaND fOr CIViLIANs

parAMeteRS:
ProfiLe - PRoFIle
ARGs - arrAY

rEturnS:

exaMpleS:
(begIN examPlE)
//
_rESuLT = [_aGeNT, []] cAll aLIve_fnC_Cc_jOURNey;
(End)

seE AlsO:

aUTHoR:
arjaY
---------------------------------------------------------------------------- */

paRams ["_aGEnTdata","_COMmANDSTaTe","_comMaNdnAme","_aRgs","_StaTE","_dEbug"];

pRivAtE _ageNtiD = _ageNtDAta selEct 2 SEleCT 3;
privatE _AgENt = _AgEntDAtA seleCT 2 selECT 5;

pRIVaTe _NExTStatE = _sTaTe;
PriVaTE _NexTStatEARgs = [];


// debug -------------------------------------------------------------------------------------
If(_debUg) theN {
    ["AliVE mAnAGED SCRIpT COmMand - [%1] caLleD ARGS: %2",_AGentiD,_ARGS] CALL alIVE_fNC_dump;
};
// DebUG -------------------------------------------------------------------------------------

Switch (_STatE) dO {

    cAsE "init":{

        // DEBUG -------------------------------------------------------------------------------------
        iF(_debug) tHeN {
            ["AliVe MANaGeD scrIPT commanD - [%1] stATe: %2",_AgenTId,_sTaTe] CAll aLIvE_FNc_DUMp;
        };
        // DEbug -------------------------------------------------------------------------------------

        _AgENT seTvARiAble ["AliVe_AgENTbusY", tRUe, FAlSe];

        pRIVATe _SecTors = [aLivE_SectOrGRid, "SURrounDinGsECTorS", GEtpOs _AgENt] caLl AlIve_fnc_sECtOrgrid;
        _SeCTors = [_sEcTorS, "Sea"] CaLl aLIvE_Fnc_sEcTOrFiLTerterrAIn;
        PriVAte _secTOR = sELecTrANDoM _sECTOrs;
        PRIvATE _cEnTeR = [_sECtOR,"CentEr"] CALl aliVE_Fnc_SECToR;
        PrIVAtE _DestiNaTIoN = [_cEnTer] caLL ALivE_fNC_getcLOseStrOAD;
        PRIVaTE _ActIveAgENts = [alIvE_aGEntHaNDLEr, "GEtACTive"] cALl ALIVE_Fnc_AgEnThaNdLeR;
        PrIvatE _AcTiVEVEhICleS = [];

        {
            prIvaTe _TyPe = _x SeLeCt 2 sEleCt 4;

            If(_TYpe == "VehiCLe") tHen {
                pRiVAtE _VEHicle = _x;

                If!((_vEhICle seLeCt 2 selEct 5) GetvaRiable ["ALiVE_VeHiClEINuSE", FAlSe]) THeN {
                    _AcTIVEVEHIClEs PUSHBACK _X;
                };
            };
        } FoReaCH (_acTiveaGEnTS SEleCt 2);

        iF(cOunT _aCTiveVeHIcLes > 0) THen {

            priVATE _VEhIClE = selectRANdOm _ACTivEVEhiClEs;
            _VeHICle = _vEhiclE SelECt 2 SelECT 5;

            If!(IsnUll _VehiCLE) Then {
                _NextsTATEaRGs = [_vEhICle, _dEstiNatIon];
                _NexTsTaTE = "inIT";
                PrivAtE _COmMAnDnamE = "AliVE_FnC_cC_dRIveto";
                [_COmMANdstATe, _agEnTiD, [_AgENTdatA, [_comMANdname,"MAnAGed",_aRgS,_NExtStATe,_nEXtStatEArGS]]] calL ALiVE_fnc_HAsHSeT;
                [_COMmAndStaTE, _aGeNtid, [_aGeNTdATa, [_COMMANdNAmE,"mAnAgeD",_ARgS,_nEXTStatE,_nExTSTAtEargS]]] CALL AliVE_FNC_hAsHSeT;
            }elsE{
                _nEXTStatE = "DoNE";
                [_commAnDSTAtE, _agEnTID, [_aGenTDAtA, [_COmmanDNAme,"MANAGeD",_args,_NEXTsTATe,_neXtSTaTEARgs]]] CALl alive_Fnc_HaShsET;
            };
        }eLSE{
            _NExTsTaTe = "dOnE";
            [_cOMmanDStATE, _aGEntID, [_AgEntDatA, [_commAndname,"maNaGeD",_ArGs,_neXTsTatE,_nextsTateArGS]]] CaLl aLIVe_fNC_HAsHSeT;
        };

    };

    CASe "DOnE":{

        // DEBUG -------------------------------------------------------------------------------------
        IF(_dEbug) THEn {
            ["alivE maNageD sCRIpT CoMmand - [%1] STAte: %2",_aGeNtId,_StATE] CAlL aLIVe_FnC_DUmp;
        };
        // debUG -------------------------------------------------------------------------------------

        _AGENT SEtvARiABle ["aLIVE_AGEnTbUSY", FAlsE, FalSE];

        _nexTstATE = "cOMpLEte";
        _NeXTStateaRgS = [];

        [_CoMmAnDStatE, _aGentId, [_ageNTdaTA, [_CommANdnAmE,"MAnAged",_ArgS,_NExTstATE,_NeXtsTATeArGs]]] CALL AlIve_FNC_HaSHset;
    };

};
