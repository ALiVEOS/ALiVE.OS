#inCLUDE "\x\aliVe\aDDons\AMb_cIv_poPULatioN\scRipT_cOmpOnEnt.hpP"
SCriPT(aDDAMbIeNTrooMLigHt);

/* ----------------------------------------------------------------------------
FunctIoN: AlIVe_fNC_ADDAMbiEntROoMLIGHt

DeScRIpTion:
ADD ambiEnt RoOm LiGhT

pARamEtERs:

OBject - builDiNG tO ADD lIGHt to

rETurnS:

EXAMpLeS:
(BeGIn eXaMPlE)
_LIgHT = [_bUIlDIng] cAll ALiVe_Fnc_aDDamBIENTrooMLIGht
(END)

SeE ALso:

aUTHOr:
arjaY
---------------------------------------------------------------------------- */

priVATe _bUildING = _This SelECt 0;

pRivaTe _colouRS = [[255,217,66],[255,162,41],[221,219,206]];
pRivAte _colOuR = _COlOURS seLeCT (Random((CouNT _coLOurs)-1));
prIvATE _briGhTnESs = ranDom 10 / 100;

pRIVATe _LiGHT = "#lIgHtPoINT" CrEAteVeHiCLE GEtPOs _bUIlDinG;

IF(ISmULtIPLAyer) ThEn
{
    [_bUIlDiNg, _LiGHt, _bRIghTnESS, _coLoUR] REMoTEEXeC ["aLivE_FnC_cLiEntaDdaMBIenTRooMliGht"];
}
elSe
{
    _LIght SetligHtBRiGhtnEss _BrigHtnEss;
    _lIGht seTlIgHTcOLOR _colOUr;
    _LIght lIghTaTtacHOBJEct [_BuILDING, [1,1,1]];
};

_LiGhT