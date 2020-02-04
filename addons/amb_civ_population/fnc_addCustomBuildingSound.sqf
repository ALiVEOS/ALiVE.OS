#incLUDE "\X\alIvE\addOns\aMb_CiV_PopulATIoN\SCRIPT_CoMpoNeNT.Hpp"
ScRIpT(aDdcUsTOmbuilDInGsOUnD);

/* ----------------------------------------------------------------------------
FuNCTION: alIVe_FnC_ADDCustombUilDinGSOunD

DescRiPtIOn:
aDD aMbIENt roOM mSuic

pARAmEtErS:

ObJEct - buiLdiNg to ADD mUsIc To.

rETUrns:

ExamPles:
(begiN exAMPLE)
_Light = [_BUIlDINgTYpe, _BuiLDing] cALl aLIve_FnC_ADDcusToMBuIldInGsOunD
(eNd)

SEe AlSo:

authOR:
TUPOLoV
---------------------------------------------------------------------------- */

PARAmS ["_bUiLdINgtype","_BuilDiNG"];
PRiVAte _soUrcE = oBjnUll;
PRivatE _cUSTombUilDINGDATa = [aLIvE_Civpop_CUsTOmBUILdings,_BUiLDingtypE, []] CALl AlIVE_fnc_haSHGEt;
if (CouNT _cusTombUIldiNgDATA > 0) TheN {

    // cHeck to see if ANY OthER sPecial BuILDiNGs wIthiN 50M
    PRIvATE _neaRcheCK = FALsE;
    PRIvAte _neARObJECTS = _BuildInG nEArobjEcTS ["roAdconE_L_F", 50];
    {
        If (_x getVAriable ["AlIve_cIVPoP_cUStoMBuIldIngs_TYPE",""] == _buiLDIngTYpe) THEN {
            _neArChEcK = TRUe;
        };
    } FOREaCh _nearOBjECtS;

    If !(_NearCHecK) ThEn {
        pRivate _soURce = "RoadCONE_l_f" creaTeVehICLe poSitioN _BuilDIng;
        _soURcE attACHtO [_BUilDINg,[1,1,1]];
        hiDEObjeCtglObAl _SOuRcE;
        _sOuRCe sEtvaRIaBle ["AliVE_civpop_cuStoMbuILDings_TyPE", _builDiNGTypE, faLSE];

        [_BUILdING, _souRCE,_cusTOMbuIldINgdaTa] SpAwn {
            parAMs ["_bUiLDiNg","_souRCE","_cUStomBuIldINGdAtA"];
            PRIvaTe _sOuNdS =  [_CUstOmbuildInGDaTA,"SOunds"] CAlL aLIvE_FNC_HaShGET;
            prIvaTe _TiMes =  [_CUSTomBuiLDInGDAta,"TIMeS"] caLl aLivE_Fnc_hASHGet;
            priVAte _tracKSpLAyed = 1;

            prIVate _ToTAlTrackS = Count _sOUndS;


            whilE { (AlIVe _souRCE) } Do {
                wHiLE { _TracKSPLaYed < _totaLtraCkS } Do {
                    PRIVaTE _TRACk = (SeleCtrandoM _SoUNds);
                    pRiVaTE _TrackNaMe =  _tRacK seLEct 0;
                    pRIvaTe _traCkdURatION = _tRAcK sElecT 1;

                    {
                        PRIvate _sTaRT = _X sELEct 0;
                        prIVate _stOP = _x sELEcT 1;
                        iF (Daytime >= _StArt aND dAytIMe < _STop) THen {
                            If(ismuLTiPLAyer) theN {
                                [_bUIldiNg, _SouRCe, _TraCKNAMe] rEmOTEEXEc ["AliVe_fnC_clIEntADDAmBIenTrOomMUSic"];

                            }eLSe{
                                _soUrCE say3d _TraCKnamE;
                            };

                            SLEeP _trackdurAtIOn;

                            _tracKSPLAyEd = _tRAckSPLaYEd + 1;

                        };
                    } fOReaCh _TIMEs;

                    iF NOT (aLIve _sOurCE) ExiTWiTH {};
                };

                sleEp (RandOM 10);
            };
        };
    };
};
_sOuRCE



