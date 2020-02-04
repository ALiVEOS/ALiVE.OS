#iNclUDe "\x\aLive\addonS\AMB_CiV_pOpuLAtiON\sCRIPt_coMpOneNt.hPP"
SCrIpT(aDdAMbIeNtroOMMusIc);

/* ----------------------------------------------------------------------------
fUNCtIoN: AlIVe_Fnc_adDAMbIENTROoMmUSIc

dEsCripTION:
ADd aMbIenT ROOM MSuiC

pArameTeRs:

objecT - buILding to Add musIC tO.

RetURns:

ExAMPlEs:
(begIn EXaMPlE)
_light = [_BUIldiNg, _fAcTIoN] cALL alivE_fnc_adDAmbieNTrooMMuSIc
(enD)

SEe alSo:

AuthOr:
ArjaY
---------------------------------------------------------------------------- */

PAramS ["_bUIldiNg",["_FACTiOn","cIv"]];

PRiVaTE _MusICsouRce = "roaDcONe_L_F" CREaTEVehICLE pOSItiON _buIlDInG;
_mUSICsOUrCE ATtachto [_BUildiNg,[1,1,1]];
hIdEobJectGLobal _MUsIcsOURCe;

[_BuiLDING, _MuSIcsourCE,_FACTIon] spAwN {
    parAMS ["_BuIlding","_mUSICsOuRce","_fActION"];
    privAte _tRaCkspLAYeD = 1;
    pRIVaTE _SourCe = [ALiVE_cIviLIAnfaCTIOnhoUsETRacKS, _FACTIoN, []] CAll AlivE_fNc_HaSHgeT;
    If (COUnt _SoURCe == 0) theN {
        _SOuRce = aLive_CIvIliANHoUsetracks;
    };
    PRiVate _toTAltRackS = cOuNt (_sOURce seLeCt 1);

    WhiLe { (aLiVe _MusicsOUrce) } dO {
        WhILe { _tRACksPLAYeD < _toTaLtrAcks } do {
            PriVaTe _tRAcknaME = seLECTRANdOM (_sOurCE SeleCt 1);

            // DON'T pLAy niGHT soUNDS dURiNG THE DAY
            IF (_TRacknAMe iN alIve_CIvpop_NiGhTsoUnDS && daytIME < 21 && dAYtiMe > 3) theN {
                _tracknAMe = "Alive_civPOP_audiO_19";
            };

            PRivAte _TrackdUrATioN = [_source, _TRaCknamE] caLl alIvE_FNC_HashGet;

            If(iSMUlTipLayER) then {
                [_BUiLdIng, _MusICSoURCE, _TRACknamE] remOTeexeC ["alivE_fnC_cliEntAdDAmbIenTROomMuSIC"];

            }eLsE{
                _musIcSoURcE saY3d _tRAcKname;
            };

            sleEp _TrAcKdURation;

            _trackspLayeD = _tRacKsPlaYed + 1;

            IF nOt (aLIVe _mUSiCSoURCe) EXItwitH {};
        };

        SLEep (rAnDoM 10);
    };
};

_mUSICSOUrce