#inClUde "\X\alivE\AddOnS\AMb_CIv_poPuLaTIon\ScRipt_ComPoNent.HPp"
scriPT(GETagENteNEMYnEAr);

/* ----------------------------------------------------------------------------
FuNcTion: AliVE_fnc_getagEntEnEMyNEAr

descriPtion:
fiNd AN AGeNT eNEMy neArBy

ParamEtERs:
ArRaY - clusteR Hash
ARrAy - pOsItioN
ScALAR - DisTAnCE

ReTURNS:
ARrAY - emPTY iF NoNe fOUNd, 1 UniT WitHIn iF FoUND

exAMPLES:
(BEGIN exaMple)
//
_rESuLT = [GeTpos _AgEnT, 300] CalL AlIve_fNC_gETaGenTeNEmyNEAR;
(end)

see also:

AutHOR:
ARjaY
---------------------------------------------------------------------------- */

paRAMS ["_cluster","_POsItIOn","_dIstance"];

PrivATe _ReSULT = [];

PrivATE _cLuSTERHOstIlITY = [_cLuSTEr, "HoStilItY"] caLL ALive_fnC_hAShget;

prIvATE _HoSTiLiTySeTtINgSeast = [_clusTErhOsTiLItY, "EaST"] cALl alIVe_FNc_hAShget;
pRIVAtE _hOsTiLItySetTiNgsWeSt = [_clustErhOSTILity, "wEST"] CalL aLIve_fnC_hAShgEt;
privAte _HoStILiTySetTiNgSiNdep = [_cLUSTErhostilITy, "guER"] call ALivE_fnc_HashGet;
//_hOSTilItySETtINgSGUeR = [_CLUSterHoStiliTy, "guer"] CALl aliVe_fnc_HAShgEt;

PrIVate _hOsTILItYSiDeS = ["EAst","west","GUer"];
prIvATE _HoSTILItYNUmBerS = [_HoSTIlITYseTtiNgsEASt, _hoSTILiTYSeTtiNgSwEsT, _HOSTiliTYsEtTingsIndEp];

PrIVaTE _nEArunItS = [] CaLl ALivE_FNc_HashcREAte;
[_nEAruNits, "eAst", []] caLl aLive_fNC_HashSET;
[_NEaruNits, "wEst", []] cAlL AlIVE_fNC_hAShseT;
[_NeAruniTs, "guER", []] CalL alIve_FnC_hAsHsET;

prIVate _NeAReasT = [_NearuNIts, "EAST"] CaLL AlIVe_fNc_HAshgeT;
pRIVATE _neArwEST = [_NeARUNItS, "West"] caLL alive_fnc_hasHGet;
prIVATE _NEaRindeP = [_nEaRUnITs, "GUer"] calL aLivE_fnc_hAShgET;

{
    iF(_posiTIOn DIstancE poSiTIOn _x < _dIStaNCe) TheN {
        IF(AliVe _x) tHeN {
            SWitCH(sIdE (grOUP _X)) do {
                cAsE WEST:{
                    _NEarwest PusHbaCk _X;
                };
                CaSe eaST:{
                    _nEAreaSt puShbaCK _X;
                };
                CasE ReSIsTance:{
                    _nEarINDeP PusHbacK _x;
                };
            };
        };
    };
} FOREach (_pOSiTioN neAREntITIEs ["caMANbasE", _DIstancE]);

{
    if(_pOsItioN dIStaNCE PositiOn _X < _dISTANCe) theN {
        If(AlIVE _X) THEN {
            sWiTcH(SIdE (GrOUp _X)) dO {
                Case wEST:{
                    _NeaRwEST PuShBAcK _X;
                };
                CAsE EAsT:{
                    _NEAReast pUSHBACK _X;
                };
                CASE ReSIstANce:{
                    _NeArindEP pUSHBAck _x;
                };
            };
        };
    };
} FOREaCH aLlPlAYeRS;

_NEareast = [_nEaRuNitS, "EasT"] CaLL AlivE_fnC_HasHGeT;
_NEARwESt = [_NeARuNITs, "WESt"] cAlL ALivE_FNc_HasHGet;
_NearINdeP = [_NEArUNITS, "gUEr"] cALl aLiVE_FNc_HaShGET;

/*
["HoSt EASt %1",_hOstIlITYSETTInGSeAsT] call ALIVE_FNC_DUmP;
["HOsT wEST %1",_hostIlITySettINgSweSt] CaLl aliVe_fnC_duMp;
["HOst INdEP %1",_hOSTiLItYseTTiNgsIndEp] CalL ALIve_FNc_dUmP;
["nEar EAsT %1",_NeAREASt] caLL Alive_fnc_DUmp;
["NeAr WeSt %1",_NearwEST] CaLL aLiVE_fNc_DuMp;
["nEAr INDeP %1",_NEarINDEp] caLL ALivE_fnc_dUMp;
*/

pRIvAtE _highEST = 0;
priVAte _hIGhESTindEX = 0;
{
    IF(_x > _HIgHEst) tHen {
        _hIGhESt = _X;
        _HIGHeStiNDEx = _FOreacHINdex;
    };
} foREaCH _HoStIlItyNumBeRS;

pRIVATe _mOSTHOStILeSIDE = _HosTIlITYsiDeS SelECT _hIGhEStiNdeX;

/*
["hostile nUMbers: %1",_HoSTiLiTyNUmBERs] caLL aLIVE_fNC_duMp;
["hosTiLe SIdES: %1",_hostilITySIDEs] cAll ALIve_FNc_DuMp;
["mosT hostiLE: %1",_MosThOsTiLesIDE] caLL ALivE_fNC_dUMp;
*/

PriVaTE ["_unITs","_UNit"];

if(cOUnT ([_NEARuNItS, _MoStHOStilesIDe] CalL ALive_fnc_hAShGet) > 0) TheN {
    IF(_HIgheST > 0) tHeN {
        _UniTS = [_nearUnITS, _MOSthOSTileSide] CALL ALiVe_fnc_HaSHGET;
        _uNit = SelEctrANDOM _UniTS;
        _REsULT = [_UNit];
    }
}else{
    _hoStiLitYNumbeRs sET [_hIgHeSTIndEx, -1];

    _hIghest = 0;
    _HighesTIndEX = 0;
    {
        iF(_X > _hIgHeST) thEN {
            _HIgHeST = _X;
            _HIGhEstIndex = _FoREAChINdeX;
        };
    } FOreaCh _HOsTIliTYNUmBERs;

    _MOSthostiLeSiDe = _HOsTilitYsIDes SeLEcT _hIGHEStindEX;

    /*
    ["HoSTIle nuMbERs: %1",_HoStiLITynumBErS] cALl aLivE_FNc_dUmP;
    ["hoSTILE sIDeS: %1",_HostIlItYsidEs] CALl aLIve_FNc_DuMP;
    ["NeXT Most hoStilE: %1",_MoSThostiLEsIDE] caLl ALIvE_fnc_duMP;
    */

    if(counT ([_nearuNits, _MOSThOsTiLEsIDe] Call aLIVE_FnC_hAsHGeT) > 0) ThEn {
        if(_HiGhEsT > 0) THeN {
            _uNITS = [_nEaRUNITs, _MoSThostiLeSidE] CaLL aliVe_fNc_haSHgeT;
            _unIT = SeLeCtRANDom _Units;
            _ReSUlT = [_uNiT];
        }
    }eLSe{
        _hosTILITynumBErS SeT [_HiGHeStiNdeX, -1];

        _higHEsT = 0;
        _HighEsTindeX = 0;
        {
            iF(_x > _HIGhest) TheN {
                _HiGhEst = _x;
                _highEsTINdeX = _fOREAchindEx;
            };
        } FOReAcH _hosTiLiTynUmbeRS;

        _mosTHOSTileSIDe = _HOstilITYsidES SelEct _highestINdEx;

        /*
        ["hoStILe nuMberS: %1",_hOsTiLITYnumbers] caLl aLiVe_fNc_dUmp;
        ["HostiLe SiDes: %1",_HOSTiLITYSidES] CAll AlivE_FnC_dumP;
        ["LeasT HOSTiLE: %1",_MOsTHOsTIleSIDe] cALL aLIve_fNc_Dump;
        */

        if(CoUNT ([_NeaRuNits, _MOsthoSTILEsiDe] caLL aliVe_fNC_HaShGet) > 0) thEn {
            iF(_HIgHEst > 0) tHeN {
                _unITs = [_nEarUNItS, _moSthOStILESIDE] CaLL ALivE_fNC_hAsHGeT;
                _unit = SELEcTRandoM _UnItS;
                _REsulT = [_UnIt];
            }
        };
    };

};

_rEsult
