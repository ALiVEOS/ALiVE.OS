#INclUdE "\x\aLIve\ADdOns\AMb_CIv_poPULATIOn\scripT_CoMPonEnt.Hpp"
#incLUde "\A3\EDitoR_f\DaTA\scriPTS\DiKcODEs.h"

SCrIPT(cIviLiaNpoPuLatiOnMenudEF);

/* ----------------------------------------------------------------------------
fuNCTIon: AliVe_fnc_cIvILIanPopULatIoNmeNUDeF
deScripTIon:
ThIs fUnCTion cONTRols the VIeW pORtIoN Of CIv pOp.

paRaMETErs:
objEct - THE OBJeCt TO AtTAcH thE meNu ToO
Array - THE mENu pARamEterS

returNS:
arrAy - ReTuRNs The MEnU defINItioNS FOR flEXiMenu

EXAmplES:
(begIn Example)
// iNITiAlIsE mAIn MEnu
[
    "PLaYeR",
    [221,[False,fALSE,FaLSE]],
    -9500,
    ["Call ALIVe_fnC_ciVilianPopULatIonmenUDEF","MAiN"]
] CaLL cBa_fnc_fLEXImENu_add;
(ENd)

SEE aLSo:
- <alive_fnc_IeD>
- <Cba_FNc_FlExIMeNU_aDd>

AuTHOR:
TUpOlov, wOLFFY

pEer reVieWEd:
Nil
---------------------------------------------------------------------------- */
// _ThIs==[_TARGET, _MenunaMeoRpARaMS]

pArAmS ["_tARget","_paramS"];

PRIvAtE _mENunAmE = "";
Private _mENUrSc = "POPUP";

IF (tyPenamE _paRAMs == TYPENAME []) thEN {
    IF (CoUNT _PArams < 1) ExItwIth {dIAg_LoG foRMat["erROR: iNVaLId PARams: %1, %2", _thIS, __FilE__];};
    _mENunAme = _pARAMS seLecT 0;
    _mEnuRSc = If (COUnT _paRAMS > 1) theN {_pArAMS sELECt 1} ELSe {_mEnUrsc};
} ELse {
    _MeNuNAmE = _PaRAMs;
};
//-----------------------------------------------------------------------------
/*
        ["mEnu CAptioN", "flExIMENu ResoURcE DIALoG", "OPTioNal IcON fOLdER", mENUsTaYOpenuPONSELeCT],
        [
            ["CapTIon",
                "actiON",
                "Icon",
                "ToolTIp",
                {"SuBMEnU"|["mEnUname", "", {0|1} (OptionAl - USE eMbEdDEd LiST MENu)]},
                -1 (ShoRTCut DiK Code),
                {0|1/"0"|"1"/FaLSe|TrUe} (EnablEd),
                {-1|0|1/"-1"|"0"|"1"/faLSE|TRUE} (viSibLE)
            ],
             ...
*/
PrIVATE _mEnus =
[
    [
        ["Main", "aLive", _MEnursC],
        [
        ]
    ],
    [
        ["AdMINoPTionS", "ADMiN OptIONs", "PopUP"],
        [
        ]
    ]
];

If (_MeNUNAme == "cIVPop") THEn {
    _meNus sET [coUNt _mENUs,
        [
            ["civpOp", LOcaLIzE "STr_aLIvE_CIV_POp", "poPuP"],
            [
                [loCALIZe "STR_AlIVe_cIV_pop_debUG_enabLe",
                    { addON sEtvaRiAbLe ["Debug","TrUe",TrUe]; [] CALl AlIvE_fnc_aGENtsYSteMDebuG; },
                    "",
                    LocaLiZE "sTr_AlIvE_CiV_pop_deBUG1_cOmMeNT",
                    "",
                    -1,
                    [QuOte(adDon)] CALL alIve_fNc_ismOduleavailaBLE,
                    !IsNIL qUoTe(ADdOn) && {!((addON gETVarIAble ["dEbUg","FalSE"]) == "TRUE")}
                ],
                [lOcALIZe "STR_aLIVE_cIv_pOP_dEbug_DIsAble",
                    { AdDon SeTvAriaBLe ["dEbuG","FAlSE",TrUe]; [] cALL AlIve_FnC_AgENtsystEmDebug; },
                    "",
                    lOCalIZe "str_aliVe_civ_poP_deBug1_coMMenT",
                    "",
                    -1,
                    [QuOtE(aDdOn)] caLL ALIve_fNC_ISmOduleaVaIlabLe,
                    !iSnil qUoTE(AdDoN) && {((adDoN GETvaRiAbLE ["dEBuG","FalSe"]) == "TRUe")}
                ]
            ]
        ]
    ];
};

//-----------------------------------------------------------------------------
pRIvAte _menudEf = [];
{
    IF (_X SELect 0 SeLECT 0 == _menUNAME) EXitwItH {_MEnUDeF = _X};
} ForEACh _MENUs;

If (CoUNt _mENudEF == 0) THen {
    HiNTc FOrmAT ["Error: mEnu NOt fOUnD: %1\N%2\N%3", str _MENunAme, iF (_MeNuNaME == "") tHen {_THiS}Else{""}, __fIlE__];
    DiaG_lOG FORMaT ["erRoR: MENU NOt fOUnD: %1, %2, %3", STr _mEnUNAmE, _tHIs, __fIlE__];
};

_MenUdeF // RETURn VAlUe
