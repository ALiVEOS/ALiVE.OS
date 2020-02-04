#incLuDE "\X\alIvE\aDDONS\aMb_Civ_PopulaTiON\sCrIPT_cOmpOneNt.hpP"
scRipt(civInTeRAcT);

/* ----------------------------------------------------------------------------
FuncTIOn: mAinCLasS

desCripTioN:
mAIN HAnDlEr FoR civIlIAN iNTErRACtioN

parAMeTeRs:
StrInG - oPeRatIon
ARRAy - arGuMEnts

rEturNs:
AnY - rESUlT OF THE opeRATION

exAMpLEs:
(beGIn EXaMple)
[_loGIc,_OPERatIon, _aRgUMents] CALL mAinClaSS;
_CIvdaTA = [_logIC,"gEtDaTa", [PlAyER,_civ]] cAlL MAIncLasS; //-- get DATA Of civiLIAN
(enD)

sEE AlsO:
- NIL

AUtHOR: SPYdeRblack723

peER reviEWeD:
NiL
---------------------------------------------------------------------------- */

paRams [
	["_LoGic", OBJnuLL],
	["_OPERaTION", ""],
	["_aRguments", []]
];

PRivATe ["_REsuLt"];

//-- dEFInE functIon sHOrtcuTs
#DEfiNE MAiNcLAsS AliVE_fNC_ciVINTeraCT
#defINE qUEStIoNhANdleR ALIVE_fNC_quEStIOnHandler

//-- deFINe conTROl ID's
#dEfine CiVintERAcT_DiSplAy 		(fiNdDiSPlaY 923)
#DeFINe ciViNTeRACT_civnAme 		(cIVInTEraCt_diSplAy dispLaYCTrl 9236)
#dEFINE cIVINTEraCt_DETaIn 		(ciVIntERACt_dispLAy dIspLAycTRL 92311)
#DeFINe CIvintErACt_questIONList 		(cIVInTErAct_dIsPLaY dISplaYCTrl 9234)
#DefiNe CIvIntErAcT_reSPONSElist 		(civiNTeRACt_diSPlaY DISPlAYCtrL 9239)
#DEFine cIvintERACt_PIc					(CIvinTerACt_DisplaY DISpLAyCtRL 1200)
#Define CiViNTErAcT_inVeNTOrycONtRoLS 	[9240,9241,9243,9244]
#DEFINe cIVInTEraCT_SEarcHbUTTON 	(cIvinterAct_dISPLaY dISplayCTrl 9242)
#DEfine cIViNteRaCT_geARLiSt 		(CivINtERAct_DISPLAY dIsPlAYCtRl 9244)
#DeFIne cIVInterACT_GEarLISTcoNTrol 	(CIvINTErACt_DisplAy DIsplAyCTrl 9244)
#deFINe CIVinTERaCt_CONFIScaTEbUTTON 	(CiVInteract_DISplay disPlayctrl 9245)
#dEfiNE ciVInterACT_OPenGeARCoNtaiNer	(ciViNTERacT_dIsPLAY dISpLAYcTRL 9246)

sWitch (_OPeRaTIoN) Do {

	cAse "CREaTE": {
		_ReSUlt = [] CALl alive_Fnc_hASHCrEAtE;
	};

	//-- CrEATe lOgIC on All lOCalitiES
	CAse "inIt": {

		iF (isNIL qmod(cIvIntEractHAndler)) ThEn {
			//-- get SetTinGs
			_DEBug = _Logic GEtVaRIABLE "DEBug";
			_fACtioNEnemY = _LOgic Getvariable "iNSUrgeNtFaCtION";
			pRivaTe _aUThoRizeD = (_LogiC GetVARIabLE "liMiTIntErActIoN") cAll alIVE_fnC_StRiNGliSTtOaRRay;

			//-- cReATe interACT haNDler OBject
			MOd(cIvInterACThandlEr) = [Nil,"creATe"] CALl MaiNclAsS;
			[MOD(CIvintEraCtHaNdlER), "DeBUG", _DEbUg] CalL AlIvE_fnC_hAsHsEt;
			[MoD(CIviNTErACthaNDLEr), "iNsuRgenTfAcTiON", _FacTiOneNemY] call AlIve_fnC_HaSHsET;
			[mOD(civiNtERActHaNDleR), "aUthoRIZed", _aUThorIZeD] cALL aLIvE_fnc_haSHsEt;
		};
	};

	//-- on lOaD
	CASE "oPEnMeNu": {
		_Civ = _aRGumENTs;

 		priVAte _AuThORiZed = [MoD(CIvIntErAcTHanDLEr), "AUThOrIzed", []] CALl ALIve_fnc_HaShGET;

		//-- eXiT if cIV IS aRmed
		If ((PRIMaRyWeaPON _CiV != "") Or {HaNdGUnweaPon _CIV != ""}) EXitWITh {};

		// EXiT if nOt aUThOrIZEd
		If (coUNT _AuThORIZeD > 0 && !((GetplAyErUId plAYER iN _AutHoRiZED) || (tYpEOF PlAyer IN _aUthORiZED) || (nAME PLayer iN _aUTHoRIZEd) || (facTioN PLayEr iN _AutHORIzeD) || (rANk PlAyER in _authORIZed))) EXitWITH {["THe cIvIlIan CAn't UNDErsTaNd what yOu aRE sayiNG."] cALl ALiVE_FNc_DUMpR;};

		//-- cLoSe DialOg IF IT HAPpEned TO OPeN Twice
		iF (!ISnull fINDDISPLAY 923) EXItwiTH {};

		//-- stOp cIvIlIAN
		[[[_CiV],{(_THiS SEleCT 0) DiSableai "moVe"}],"bIS_fNC_sPAWN",_CIv,fALSE,TRUE] CaLl bis_FNC_mP;
		//_ciV diSabLeaI "moVE"; //-- neeDS FurThEr tESting But wASn't rElIaBLE IN MP (argUmeNTS must bE lOCal -- uNIt is lOcal tO sERVEr (OR Hc))

		//-- rEmOvE DATa frOm haNDleR -- JUsT In cAsE SOMethInG DOeSn'T deLETE Upon CLOSING
		[_lOGIC, "cIVDaTA", nIl] CalL aLIVE_FNC_HaSHSET;
		[_LOGic, "cIv", Nil] cALL ALiVe_FNc_HAshset;
		[_LOGiC, "itEmS", NIl] cAlL ALIvE_fNc_hAShsET;

		//-- HaSh civILIaN tO LOGic (MuSt bE doNe eARly sO cOmmAndhAndleR hAs An obJEct TO use)
		[_LoGiC, "civ", _CiV] calL alivE_FnC_HaSHSet;	//-- UNIt ObjecT

		//-- open DialOg
		creATedIALoG "ALIVE_cIvIlianInTeractiOn";

		IF (_CiV GeTVArIABLe "DeTaiNEd") THEN {
			ciVINtERacT_DEtAiN CtrlsETtExT "rELEase";
		};

		[Nil,"togGLeSEaRchmeNu"] calL mAINcLASS;
		civIntEraCt_cOnFIScateButtOn CtRLSHOw fAlse;
		cIviNTEracT_OPENgeARContAINer ctRlshow FAlSe;

		//-- DisPlAY LOaDInG
		CIvIntEract_QUEStiOnliST lBaDd "LOADIng . . .";
		CIvinTEraCT_pIc ctrLSETTEXT "A3\uI_f\dATa\GUi\RsC\RSCDIsPLAyMAIN\PrOFilE_plaYeR_Ca.pAa";
		//-- REtrievE dATa
		[NiL,"gEtdATa", [pLaYEr,_civ]] remOtEeXEcCaLL [QuOtE(MainCLASS),2];
	};

	//-- LoAd DAtA
	cAse "LoaddATA": {
		//-- Exit IF the MeNU Has been cLoSed
		iF (IsnuLL FInDDispLay 923) EXItWIth {};

		_arGUmEntS pAraMs ["_ObjectIveinsTallAtIOns","_oBjECTiVEaCtions","_CiviNFO","_HOstIleciVInFo"];

		_LogIc = mod(civIntEracthANDler);

		//-- CrEAte HAsH
		_civDAta = [] Call ALIVe_FnC_HaSHcrEaTE;
		_cIV = [_lOgIc,"Civ"] CAlL aLive_fnc_HAshGet;
		_ANSWeRsGIvEn = _CiV gETVArIabLE ["aNsWerSGIVEN", []];

		//-- Hash DAtA to lOGiC
		[_cIvdatA, "instaLlatIoNS", _OBjEctIvEINSTallatiOnS] CALL ALivE_fnc_hAshset;		//-- [_fACtory,_Hq,_DepOT,_RoadBlocKs]
		[_CIvdATa, "aCtionS", _ObjECtiVEACTions] CaLl ALIve_FNc_hasHSET;			//-- [_AMBuSh,_SaBotaGE,_IEd,_sUicidE]
		[_ciVData, "CIVInfO", _ciVinFO] calL Alive_FNC_hAshsEt;				//-- [_hOMEpos, _indIVIdUALhOstIlitY, _towNHostilIty]
		[_cIvdATA, "HosTIlecivinFo", _hostIleCIviNfO] CaLl alivE_fnC_HASHset;			//-- [_Civ,_HOmePoS,_aCTIVECOMmAnDs]
		[_CiVDaTA, "aNswERsgiVen", _ANSwERsgiveN] CalL ALIVe_FNC_hAshSeT;			//-- deFaUlT []
		[_CIVDAtA, "Asked", 0] CalL ALIVe_fNc_HAshseT;					//-- dEFAULT - 0
		[_lOGIC, "CIvDAtA", _cIVdATa] caLL AliVe_FNc_hAsHset;

		//-- diSplAY PErSistEnt CIv nAME
		_namE = _CIVinfo SELEcT 3;
		_RoLe = [nil,"gETroLe", _Civ] CALl MainclAsS;
		IF (_ROle == "none") theN {
			cIviNteRAcT_cIvname cTrlSeTtexT (FoRMaT ["%1 (%2)", _nAme, [CoNfiGfILE >> "CFGveHicles" >> tyPeoF vEhiCLE _CIv] calL BIS_fNc_DIsPLAynAME]);
		} Else {
			CiViNterACT_CivNAMe CtrlSeTTExT (formAt ["%1 (%2)", _nAmE, _rolE]);
		};

		[_LoGIC,"EnablEMaIn"] call maiNCLasS;
	};

	CAse "ENAblemaIn": {
		//-- REMOVE eH'S
		(cOmMAndBoArd_DisPLay DISpLAyCtrL CoMMaNDBoArD_MAiNmEnu) CTrLReMoVealLEVeNTHANdLeRs "LbSElcHANgeD";

		//-- cLEAR lIST
		lBCleAr cIVInTerACT_QuEStIONLIst;

		//-- BUIlD QUEstIon LISt
		CIVInTERACT_QUEstiONliST lbaDD "WhErE do you Live?";
		CiViNTeRaCT_QuEsTIOnliST LBsetdAtA [0, "HoME"];

		cIVinTeRACt_QueSTioNlist lbADd "What TOwN YoU Do lIVe In";
		CiviNtEract_QUEsTiOnLisT LbseTdaTa [1, "tOwN"];

		CIvinterAct_QuesTioNlISt lBAdd "HaVe yOu sEEN aNy ied's LATEly?";
		CIVINterAcT_quesTIonliST LbsEtdata [2, "iedS"];

		CiVINTeRACT_queSTiONlisT LbADD "HAve YOU SeEn AnY INSUrgeNT aCtivIty LATeLY?";
		civintEracT_quesTIonlIST lbSetdatA [3, "iNsurgEnTS"];

		cIViNTerACT_QUESTIONLIST lbaDd "dO you knOW tHe locATion Of any iNsuRGENt HiDEoUTs?";
		ciVINTEraCt_QUesTIonLIsT lbseTDatA [4, "hideoUTS"];

		CIvINteRaCT_QueStIOnLISt lBAdd "haVe YoU SEEN aNY StrangE beHAviOr lATElY?";
		CiViNtErACT_QUEStIoNlIST LBSEtdATa [5, "stranGebeHAvIoR"];

		CIviNteRAct_QUeStIONLIST LBADd "do YOU sUPPOrt us?";
		civinterAct_qUeSTiONLIst lbSeTdaTA [6, "OpInION"];

		CIVINTeRACt_QuEsTIONlIST lBaDD "wHat Is ThE oPINion OF Our FORCeS In This area?";
		ciVInTeRAcT_quesTIONlIst lbSetDAtA [7, "tOWnOPINiON"];

		CivINtErACt_QuEStiOnlisT cTRLadDEvEnthANDLEr ["LBSElChangED","
			PAramS ['_COntrol','_INdeX'];
			_queSTioN = _cOnTrol LbdaTA _IndEx;
			[ALIvE_CIVinteraCtHANDLER,_qUesTIon] cAll alIVe_FNc_qUeSTioNhAnDLEr;
		"];
	};

	//-- UNloAD
	CAse "ClosEmEnu": {
		//-- CLose MEnu
		CLoSeDialOG 0;

		//-- Un-StOp CIVilIAn
		_cIV = [_loGic, "CiV"] CaLl aLivE_FNC_hASHGET;
		[[[_cIV],{(_this sELect 0) EnAbLeAI "mOve"}],"bIs_fnC_SPaWN",_cIV,fAlse,tRUe] CaLl bIs_fnC_MP;
		//_civ EnABlEAi "move"; //-- nEeDS FURThEr TEstInG but wASn't reLiablE IN MP (ArgumEnTs MuSt bE LOcal -- UNIT is loCAL TO sErVeR (or HC))

		//-- REMOVe data from HAndLEr
		[_LOGIc, "CivDatA", NiL] cAll aLIvE_FNC_hAShSEt;
		[_loGIC, "CiV", nil] cAlL AlIVE_FNc_hAShSET;
		//[_LOgic, "ItEMS", Nil] CaLL alIve_FNC_hAShSeT; 	//-- REmOvE aftER fiX
	};

	cAse "GEtobjEctIvEInstaLlAtiOns": {
		_ARGUmENtS PArAmS ["_oPcoM","_ObJeCtIvE"];

		_fACtORY = [_OPcom,"cOnveRtOBJeCT",[_ObJECTIVE,"FaCtORy",oBJnULl] CALL ALive_fNc_hashget] caLL aLIVe_Fnc_oPcom;
		_Hq = [_opCoM,"cONvErToBjeCT",[_OBJecTIVE,"hq",objnuLl] Call aliVe_Fnc_HAsHgET] cAlL alivE_FnC_opCoM;
		_DepoT = [_oPCOM,"conVErtObJECT",[_objectIve,"DePOT",oBJnUlL] CALl alIVe_FnC_HashgeT] calL ALiVE_FNc_OPCOm;
		_rOaDBLOCks = [_oPcom,"cOnVertobJeCT",[_ObjEctIVe,"roaDBLOCkS",OBjnUll] CaLL aLive_FnC_hAsHGET] cAlL AlivE_FNc_OpCoM;

		_reSUlt = [_FActoRY,_hq,_dEPOT,_ROAdBLoCKS];

	};

	cASE "GeTObjeCTIveaCtIOns": {
		_aRgUMeNts pARams ["_OpcOM","_obJecTive"];

		_AMBUsh = [_OpCoM,"convERTobjeCT",[_OBjEcTiVe,"AmBUSh",Objnull] cALl alive_Fnc_hAsHGet] CalL ALIVe_FNC_opcOm;
		_sAbOTAGE = [_OPCOM,"ConvErToBJect",[_ObJECtIve,"sAbotAGe",ObjnulL] cAll aLivE_fnc_hashGEt] caLL ALiVE_FnC_OPcoM;
		_IED = [_OPcOM,"coNvErtOBject",[_ObjECTiVE,"IeD",ObjNuLL] cAlL aLiVe_fNC_HAshgEt] cALl ALIve_FNC_oPcom;
		_suIcidE = [_oPCoM,"cONVertOBJECt",[_oBjectiVe,"sUiCIDE",OBJNULL] cALl aLIVE_fNc_hAShGEt] cALL alIvE_Fnc_OpCOm;

		_rEsUlT = [_aMbUsH,_SaBOTAGe,_ieD,_SUICidE];
	};

	caSE "GetdAta": {
		PrIvate ["_opcom","_neAREsTOBJEcTIvE","_CiviNfo","_clusTErID","_AgenTpROFIle","_HostILeCIvinfO","_Name","_oBJECTivEiNStALlATIONS","_obJECtivEaCtIOnS"];
		_ARGUmEntS pArAMS ["_plaYEr","_CIv"];

		_CiVpoS = gETpOS _CiV;
		_inSURgeNTFactioN = [mod(CivINTERactHanDlEr), "InsUrGENTfAcTIOn"] CaLL AlIVe_fnc_hAsHGet;
		_obJEcTiVEs = [];

		//-- GET nEArEst ObJEctIve pROpertIEs
		FOr "_i" frOM 0 To (cOuNt OPCOm_InSTAnces - 1) sTEp 1 do {
			_OpcoM = OPCoM_iNStAnCES SelECT _i;

			iF (_INSUrgenTfaCtION iN ([_oPcOm, "FACtIONs"] calL alIVE_FNC_hAShGeT)) exitwiTH {
				_ObjEcTIves = ([_OPCOm, "ObJeCtiVes",[]] cAll AlIvE_Fnc_HaShgeT);
				_OBJecTives = [_oBJECtivES,[_civpoS],{_inPut0 DISTance2D ([_x, "CEnter"] CaLL cBA_fNc_HashgET)},"AScend"] CAll bIS_fnC_SoRTBy;
				_nEareStobjeCtive = [_OPcOM, _oBJEcTiVes selecT 0];
			};
		};


		If (cOUnt _oBJECtiVES > 0) then {
			_oBjECtIvEinStALLatiOnS = [MOD(cIVInTerACthandler), "GEToBjECtIVEinsTAllatiONS", _neAREstoBJeCTivE] CAll MaiNcLAsS;
			_oBjeCtIvEaCtIOns = [mOd(CIVintErACThANdLer), "GetOBJeCtivEActIOns", _nEAREStobjeCtive] cAlL MaInCLaSS;
		} eLsE {
			_objeCtIvEINStaLLATIonS = [[],[],[],[]];
			_ObjECTIVeacTioNs = [[],[],[],[]];
		};

		//-- gEt CivILiAn iNfo
		_Civid = _CIV GEtVaRIABLE ["AGeNtId", ""];

		If (_CIvID != "") TheN {
			_CIvPrOfile = [aLIVE_aGeNTHaNDlEr, "geTAgenT", _civId] CalL ALIVE_fnC_aGENTHanDLEr;
			_CLuSTErId = (_CIVproFIlE SElecT 2) seLECT 9;
			_cLUSter = [ALiVe_CLusTeRHaNDLEr, "GeTclUSTER", _clusteRID] Call ALivE_fnc_cLUsteRhanDlEr;
			_homepOs = (_cIvPROFilE seleCt 2) Select 10;
			_IndIVIduAlhoSTILitY = (_CivProFILe SeLECt 2) SeLecT 12;
			_tOwNhoSTiLItY = [_clUsTEr, "pOstURe"] CAlL aLive_fnc_HaShGet;	//_tOwNhosTilITY = (_ClUsTeR selEcT 2) SeLECt 9; (DIffErenT)

			IF (!isNil {[_ciVpROFIle,"aLIVE_PeRSisTeNTNAmE"] caLl aLIvE_fnC_HasHgET}) ThEN {
				_NamE = [_CIVPRoFiLe,"alIvE_perSiSTEntnAMe"] Call aLivE_Fnc_HaSHGET;
			} else {
				[_cIVpRoFILE,"alive_PersISteNtname", NaMe _CIv] cAlL AlivE_fnC_haShsEt;
				_nAME = NAme _cIv;
			};

			_cIVinfO = [_hOMEpos, _INdIviDuaLhosTILIty, _toWNhostIlItY, _NaMe];

		} eLSE {
			_CLuStErid = _CiV GEtvARIaBLE ["ALIVE_cLuSTERiD",""];
			If (_clusterId == "") tHen {
				PRIvATe _neaREStaGENT = [POsItiOn _cIV] CAlL aLiVe_FNC_gEtNEarestACTiVeAgEnT;
            	IF (coUNt _NeARestageNT > 0) Then {
                 	_CLuStERid = [_NEArEStagenT, "homeClusTeR"] caLl aliVe_fnC_hashGET;
				} ElsE {
					_clUSTERID = ([alIVe_cLustErhAnDLeR, "ClUStERs"] CaLl ALIve_FnC_HAshGet) sELEcT 1 SELeCt 0;
				};
			};
			_cLusTER = [aLIvE_clustErHAnDlEr, "GETCLuSter", _cluSTERid] cALl AliVE_fNc_CLUstERHanDlER;
			_hoMepos = _cIV GeTVArIAble ["ALIvE_hOmePOS",poSiTion _CIV];
			_iNdIVIdUALhostILiTY = _CIv GetVarIABLE ["Alive_CiVpOP_HOsTIliTY",30];
			_townHOsTILITY = [_CLustER, "POsTUre"] caLL AlIve_fnc_HAShgET;
			_naME = nAmE _cIV;
			_CiViNfo = [_homEpos, _individUAlhoStILItY, _ToWNhostiLItY,_NAmE];
		};

		//-- Get nEArbY hOSTiLe ciViliaN
		_hostILecIVinfO = [];
		_INsurgEntcOMmAndS = ["AlivE_FNC_cC_SuIcidE","AlIVE_fnC_CC_SUiCidetaRGeT","ALive_fnc_CC_ROGUE","alive_fnC_cC_ROGUetARget","aLive_fNc_cC_sABoTAgE","AlIvE_fNC_Cc_getWeaPoNs"];
		_AGeNTSBYCLuStEr = [aliVE_AgENTHAndleR, "AgEnTsbyCLUstER"] CAll ALiVE_fNc_HashGeT;
		_NeArCIvS = [_AGeNTSbYclUSTeR, _cLUsterId] CaLL alIVE_FNC_hAshGeT;

		fOr "_I" fRom 0 TO ((COunt (_NeArCivs seLEct 1)) - 1) do {
			_AGEntId = (_NeArCIVs sELECt 1) sELECt _I;
			_AGentPrOFIle = [_neaRCivs, _AgeNtID] caLL alive_FnC_hASHGeT;

			IF ([_aGEntProFiLE,"ACTive"] CAll aLIvE_fNc_hAShgET) Then {
				If ([_aGENTPROfIle, "TYpe"] caLl alIVe_Fnc_hAShgET == "agENt") tHEN {
					_ACtIVeCOmmanDS = [_aGEntprOFilE,"acTIvECOmmAnDs",[]] CAll aLIve_FnC_HaShGET;

					If ({ToLOWER (_X SeLect 0) In _INSurgEnTcommANds} couNt _ACTiVEcoMMaNDs > 0) then {
						_Unit = [_agEnTprOfiLE,"UNiT"] CaLl AlivE_FnC_HAShGET;

						IF (nAme _CIv != NamE _uNIt) tHEn {
							_hoMepos = (_agentPROfiLe selEct 2) SElect 10;
							_HOStilECIVINfO PUsHBacK [_UNiT,_hOMEPoS,_acTiVECoMMANds];
						};
					};
				};
			};
		};

		if (CoUnt _HoSTileCiVINfo > 0) TheN {_HOSTilECIViNfO = _HOsTILecIViNFo CALl bIS_Fnc_sELeCtrAndoM};	//-- eNsUrE randOM hosTiLE CIV Is PiCKeD if TheRe Are MUlTIplE

		_CivData = [_OBJectIveinstAlLATIoNs, _obJECTIVEaCtIons, _CIVinfO,_HostIlECIvinfO];

		// _CiVDAta cALl aliVe_FnC_INSPeCtarRAy;

		//-- SeNd DatA to clienT
		[NIL,"loaddAtA", _civDAta] ReMoteEXECcAll [quoTe(MaiNclass),_pLAYer];
	};

	casE "GeTROLe": {
		PRIVATe ["_RolE"];
		_CiV = _ArguMEnTs;
		_RolE = "NONE";
		{IF (_cIv getVARIaBlE [_X,falsE]) EXitWiTh {_rOLe = _x}} FOreACH ["toWnelDeR","MAjoR","pRiESt","MUeZZIn","pOLitiCIan"];

		_ReSult = ([_Role] cAlL cbA_Fnc_CaPITAlIze);
	};

	CaSE "ISIRRItATed": {
		_ARgUmENTs pArAMS ["_hoStILe","_Asked","_ciV"];

		//-- rAISe HoStILITy if cIvilIAn is iRritAted
		iF !(_hOStILe) ThEn {
			iF (flOor rAnDOM 100 < (3 * _asked)) TheN {
				[Mod(CiVinTeRACThaNDLEr),"UpDAteHoStIlitY", [_CiV, 10]] Call MainClASS;
				if (FLOoR raNdOM 70 < (_asked * 5)) then {
					_ResPONSE1 = forMat [" *%1 GRoWS VISibLy AnnOyeD*", naMe _Civ];
					_ResPONSe2 = FORMAt [" *%1 apPEaRS UniNTerEsted in the CoNVeRsAtiOn*", NAME _CIV];
					_ReSPonSe3 = " pLeasE LeAvE mE aloNE NoW.";
					_ReSpoNSE4 = " i do noT Want tO tALK to yOU aNymORE.";
					_rESpONSe5 = " Can I Go NoW?";
					_RespoNSe = [_respoNSE1, _rEsPoNSE2, _ResponsE3, _RESPOnsE4, _RESpONse5] calL bIS_Fnc_SeLEctRandoM;
					ciVINTeRaCT_rEsPOnseLiSt CtrlSettExT ((CtrLtEXT CIVINTerAct_rESPOnseliST) + _REsponSe);
				};
			};
		} eLSE {
			If (FLooR raNDom 100 < (8 * _askED)) tHen {
				[mOd(CivinterAcTHaNdler),"updAtEHostILitY", [_cIv, 10]] Call mAiNClass;
				iF (FLooR RanDOm 70 < (_askeD * 5)) tHen {
					_reSPoNse1 = FormaT [" *%1 looks aNxiOuS*", NAme _civ];
					_respONsE2 = FORMAT [" *%1 LOoks DIStRaCtEd*", NaME _civ];
					_RESpoNSE3 = " ARe you doNE yet?";
					_Response4 = " YoU asK ToO MaNy quesTiOnS.";
					_responSE5 = " YoU nEED To leAVE NOw.";
					_respONSe = [_ReSponsE1, _rESponSe2, _ReSponse3,_respONse4, _REspoNse5] CALl BiS_FnC_seleCTraNdom;
					CiVInTerAct_ResponSelISt CtRLseTTexT ((ctrltexT CivintERAcT_ReSponSEliSt) + _rESpONSE);
				};
			};
		};
	};

	cAsE "UPdatEhOStilitY": {
		//-- chanGe LOCal CIViLIan hOstilITY
		PrivaTE ["_tOwnHOStiliTYvALue"];
		_arguMents pArAmS ["_ciV","_value"];
		If (couNT _argumENTS > 2) tHEN {_TOWNHOSTIlITyvalUe = _argUmenTs SeLecT 2};

		if (isNil "_townhOStiLitYvALuE") then {
			iF (iSniL {[mOd(CIviNtERacthANDLER), "civdaTA"] cALl Alive_fNC_hAShgEt}) EXitwITh {};

			_CiVDAtA = [Mod(ciVinTeRAcThaNdleR), "cIvData"] CaLl ALivE_fNc_hAsHgEt;
			_cIVINfO = [_CiVDATA, "ciVInfo"] cAlL aLIvE_FNC_HASHgeT;
			_CIVInFO ParAms ["_HoMEPos","_InDIvIDuALHoStIlity","_towNHoSTILITy","_nAmE"];

			_inDiVIDuAlhOsTiliTY = _inDIviDuALhoSTIliTy + _Value;
			_ToWNHostiLItyVaLUe = FLOor RandOM 4;
			_towNHOStilitY = _TOWNhOstILiTY + _tOWnHoStIlITyVaLue;
			[_CiVdATA, "civiNfO", [_HoMEpoS, _iNdiviDUaLHoSTIlIty, _tOWnHoStilITy, _name]] calL alivE_FNC_haSHsEt;

			[moD(ciVInteRACthAndler), "Civdata", _ciVDATa] cAlL AlivE_fNC_hAshSET;
		};

		//-- chanGE cIViLIaN posturE gLobALly
		iF (isnIL "_ToWNhOsTiliTyvalue") EXItWIth {[_lOgiC, "updaTehostILItY", [_CIv,_vaLuE,_tOwNhostIlItYvalUE]] rEMOtEEXECCAll [QuoTe(mAiNClAsS),2]};

		_CIVID = _ciV GetvaRIABLe ["agEntId", ""];
		If (_CiVID != "") ThEN {
			_CiVProFILe = [aliVe_aGEnThAndLER, "geTaGENt", _ciVId] cAll ALIve_fNC_AGeNtHaNDler;
			_CLUsTeriD = _cIVPROFIle SelECt 2 seLect 9;

			//-- SeT tOwN HostiLiTY
			_cLuSter = [aliVE_cLUSTERhANdLeR, "GETcLUStER", _cLusTERId] CaLL aliVe_FNC_clUSTerhanDLER;
			_CLustErhostilITY = [_clusTer, "PosTurE"] cALL aLivE_Fnc_haSHget;
			[_cLUSteR, "pOsTuRE", (_CLusterHoSTIlitY + _ToWnhOStiLItYValUe)] cAll ALiVE_FNC_HAsHsET;

			//-- SET InDIVIduaL hoSTIliTY
			_HOStIlitY = (_civPROFIle SeLECt 2) SeLeCt 12;
			_HOStILitY = _HosTiliTy + _ValUE;
			[_CIvproFiLe, "pOSTuRE", _HoStIlIty] cAll ALIve_fNC_haShset;
		};
	};

	cAse "GetacTIVePLAN": {
		_ACtIveCOmmAND = _argUmENTS;

		sWItcH (ToLower _ACTIvEcOmManD) do {
			CAse "aliVE_FnC_cC_SuICIDE": {
				_acTIvepLAn1 = "CaRRYiNg oUt a suicIde BOMBINg";
				_ACTIvEpLan2 = "StRaPPiNg HiMSelF wITH ExPlOsives";
				_acTIVeplaN3 = "PLaNnINg a BombiNg";
				_aCtivEPLAn4 = "GeTtinG ReADy tO BOmB yoUR FoRCES";
				_aCtiVepLAn5 = "aboUT To bOMB yOUR FoRcEs";
				_resulT = [_AcTiVePlAN1,_aCTIVeplan2,_aCTIVEplAN3,_AcTiVEPlAn4,_acTIvepLan5] cAlL biS_fNc_seLecTrAnDOM;
			};
			cAsE "AlIVe_fNc_cC_SUICidETARGET": {
				_aCTIvEPLaN1 = "PlannINg oN carryInG OUT a suICIDE BOmBinG";
				_ActIvePLAn2 = "STrAPPing HImSElF WiTH exPLOSIVEs";
				_actIVepLAN3 = "plANNinG A bomBiNG";
				_ACTIvePLaN4 = "GETtinG rEady to bOmB Your forCEs";
				_ACTIvEplAn5 = "AbOUT to BOmb Your foRCES";
				_ReSULT = [_aCtIVEPLan1,_ACTIVEpLaN2,_aCtIVEpLAn3,_acTIvEPLaN4,_acTIVEpLAN5] CAll bis_fnc_SELectraNdoM;
			};
			case "alIVe_fnc_cc_RogUe": {
				_actIVEpLaN1 = "StORiNG a weApoN iN HiS hOUSE";
				_ACtIVEPLan2 = "stOCkPIliNg WeapONs";
				_ActivEPlAn3 = "planNing on shOoTinG a PaTROL";
				_aCtiVEPlAN4 = "LookINg fOR PATROlS tO sHOOt at";
				_aCTivePlAn5 = "pAId TO SHoOT AT yOUr foRCES";
				_rESUlT = [_ACTIveplan1,_ACTiVEplan2,_ACTiVeplaN3,_aCtiVepLaN4,_AcTivepLaN5] cAll BIS_fNC_SELEctrandoM;
			};
			Case "AlIVe_FNC_Cc_roGUeTarget": {
				_aCtIVeplAN1 = "SToRiNg A wEaPON iN hIs hOuse";
				_ACtiVePlaN2 = "STocKpiLIng wEaPoNs";
				_acTivepLaN3 = "PLANNIng on ShooTiNg A paTROl";
				_actiVEpLaN4 = "LoOKing FOr SOMEbOdy to shooT At";
				_aCtIVepLaN5 = "pAId tO sHoot at YouR FORces";
				_ReSuLt = [_ActiVEplan1,_acTIvEPlaN2,_acTivEplAN3,_aCtIvePlAn4,_ActivEPLAn5] cALl BIs_fNc_sElECTRandOM;
			};
			CAse "AlIve_FNC_cc_SaBOTAgE": {
				_aCTIVeplaN1 = "pLannINg on SabotAgInG a bUILdinG";
				_acTIVEPlAn2 = "bLOWINg up A buILDinG";
				_acTivePLAN3 = "PLantinG ExPlOsiVEs NEarBy";
				_ActivePLAn4 = "GEtTinG REAdy TO PLANT eXplosivEs";
				_aCTivePlAn5 = "PaiD TO ShooT At YOUR forCES";
				_REsuLT = [_AcTIVePlan1,_acTIVEPlAN2,_actiVePlan3,_ActIVEPLAN4,_ActiVEplan5] cALL bis_FnC_sElecTrANDOM;
			};
			CASE "aLiVE_FNc_cc_GETWEaPONs": {
				_aCTiVepLAn1 = "RETrIeVINg weapOns frOm A nEarBy WeaPONs dEpOt";
				_ACtiVePLaN2 = "plANnInG ON JoInIng THE INsURgENTs";
				_ActivePLan3 = "GEttInG reADY To go tO a neaRBY inSuRgEnT RECruItmEnt CeNtER";
				_ACtIveplaN4 = "gEtting ReAdY tO RETRiEVE WEapONs FrOM A cAcHe";
				_acTIVEplAN5 = "PaId to atTaCK YoUR fOrCeS";
				_AcTIVePlAN6 = "fORceD TO JoIN tHe INsURGENTs";
				_ACTivEplAn7 = "prEparIng to ATtack yoUR foRCeS";
				_resuLt = [_ActiVePlAn1,_AcTIvePlAN2,_actiVEplaN3,_aCTIVePlAn4,_ACtIvePlAn5] cAlL bis_fnC_selEcTRaNdOM;
			};
		};
	};

	CAse "toGglESeArCHmENU": {
		pRivAtE ["_ENABle"];
		If (cTRlviSIbLE 9240) tHEN {_enable = fALSe} eLSe {_eNAble = trUe};

		CIVINteRAct_searcHBuTTOn ctRlSHOW !_EnABlE;

		{
			ctrlShoW [_x, _ENAblE];
		} forEaCh CiviNTeRacT_iNVENtOrycoNTrolS;

		if (_enABle) Then {
			[mod(ciVINterActhAndLER),"DISPlAygeARCONTAinERs"] cAlL mainclASS;
		} ELse {
			CiViNteracT_conFiscATebuttoN ctrlShOw  FalSe;
			ciVIntErAct_OpENGEArCONtAiner CtrlShow faLSe;
		};
	};

	caSe "DIspLAYGEArcoNtAINers": {
		PRIVatE ["_conFiGPaTh","_INdEX"];
		_cIV = [mOd(CIVInTERActhAnDlER), "cIV"] cALL AlivE_FnC_hasHGeT;
		lBcLeaR cIviNTeRAcT_geArliSt;
		_InDeX = 0;


		cIVInTErAct_opENGEARcoNTaINEr ctRlSETtexT "VieW conTENTs";
		civINteRaCT_opENGEARconTAINER BUttONseTacTIOn "[NIl,'oPENgEarcOntAINeR'] CAlL aliVE_fNC_ciViNTEract";

		{
			if (_X != "") tHEn {
				//-- Get ConFIG paTH
				_CoNFIGPatH = nIL;
				_cOnFiGpaTH = cOnfIgFIle >> "CFgWEApOns" >> _X;
				if !(isclasS _coNFigpath) tHen {_confIgpAth = ConFiGFILE >> "cfgMagaziNeS" >> _x};
				If !(ISClAsS _CoNfigPATH) theN {_cOnFigpath = CONFIGfile >> "cFGveHicles" >> _X};
				If !(ISCLASS _cOnfiGpaTH) theN {_cOnfigPaTh = confIGFiLe >> "CFGGLaSseS" >> _x};

				//-- GeT itEm iNFo
				if (IsClasS _CoNFigpAth) tHeN {
					_ITeMNaME = geTTeXt (_cOnfIgpAtH >> "DiSplAYNamE");
					_iteMpIc = getTExT (_confiGPaTH >> "piCTURe");

					CiViNTERACt_gEArliST lBadD _iteMnaMe;
					civinTErACT_geArlISt LbSeTPIctuRE [_INdex, _ITEMpic];
					civInteRACT_geArlIsT LbsetdATa [_INdEX, (ConFignamE _CoNFigPaTH)];
					_InDex = _indEX + 1;
				};
			};
		} FOrEaCh ([HeadGEar _cIv,GoggLeS _Civ,UnIForm _civ,vEST _Civ,baCKPAcK _cIV] + (ASSIgnediteMS _ciV));

		[MOd(civINtErAcThANdler),"cURREnTGEArMODE", "conTAINERS"] Call ALiVe_fNc_HAshseT;

		cIViNTeracT_GearLISt CtRLAdDEVENTHaNDLer ["LBselCHANgEd",{[niL,"ongEARClICK", _this] calL mAInClASs}];
	};

	casE "OPeNGearCONTaiNEr": {
		_ciV = [mOd(CivInteRActHanDler), "Civ"] CAlL alIVE_FnC_HasHGeT;
		_DATa = cIvinTeRACt_GEARlist LbDaTA (LBCURSEl civINTERacT_geARLiSt);

		iF (_DAtA == BAcKPaCk _CiV) exiTwitH {
			[niL,"DISPLaycOnTaiNERiTems", baCKPAcKITemS _Civ] CAll MAinclAss;
			[MOd(ciViNteRActHANdlER),"CuRReNtgeaRmODE", "bAckPaCK"] cAlL aLivE_Fnc_HaSHseT;

		};

		IF (_dATa == VEsT _cIV) EXiTWITH {
			[nil,"diSPLayCOntAinErItemS", VestiTEms _cIV] caLL MAincLASS;
			[MOd(civiNtERaCthAndLeR),"cUrREnTGeaRmodE", "VesT"] CALL ALiVE_FNC_HaSHSeT;
		};

		If (_dAtA == UNifoRm _ciV) exitwiTh {
			[nil,"dISpLaYCONTAiNEritEMs", uNIFOrmiTEMS _cIV] CALl MAIncLass;
			[MoD(cIVInTEractHANDLeR),"CuRRENTgeArMoDe", "uNIfoRM"] caLL ALive_fnc_HasHSeT;
		};

		CIVINTerAcT_OpenGeArcOnTAiNER ctRlshOW FAlSe;
	};

	cAse "diSPlAyCONTAInerItEMS": {
		PRIvATe ["_CoNfIGPaTh","_inDEx"];
		_iTems = _arGumeNTs;
		lbcLEAR cIvINTErAcT_geARlIsT;
		_index = 0;

		{
			//-- GET cONfiG PAtH
			_cOnFigPATH = NIl;
			_CONfiGpaTH = CoNfIGfILe >> "CfGWEapons" >> _x;
			iF !(isClasS _COnFIgpath) thEn {_CoNfIgPaTH = COnfIGfIlE >> "cFGmAgAZInES" >> _x};
			iF !(isCLAsS _CONfIGpaTH) TheN {_confiGpATH = coNFIgFiLE >> "CfgVeHiCleS" >> _x};
			iF !(ISCLass _coNFIgPATH) TheN {_cONFIgPatH = CONFIGfILe >> "CfGGlASsES" >> _x};

			//-- Get ITEM INFO
			IF (isClASS _CONfIgpatH) tHEN {
				_ITEmNamE = GETtEXt (_CONFIgpaTH >> "dIsPlaynamE");
				_iTEMpIc = gETText (_cOnFiGpAtH >> "picTURe");

				ciVINTERact_geArlIst LbADd _iTeMNAMe;
				ciVinterACT_GeArLiST lbSetPICtUre [_InDEX, _itEmPic];
				ciVINterAct_gearlISt LbSetDAtA [_IndEx, (COnfIGNaMe _CoNFigpaTh)];
				_INDEX = _inDEX + 1;
			};
		} FOrEACH _aRGumENts;

		cIVINtErAct_cONFIScaTEBuTtOn CtrLSHow fALSE;

		CIvINtEract_OpengEarCOntainEr CTrLsETTeXt "clOsE conteNtS";
		CIVInteracT_OpENGeaRcOntAINer BUTTonseTactiON "[niL,'dISPLaYgEarcoNTaINERS'] call aLIve_Fnc_cIVIntEraCt";
	};

	casE "oNgeaRclick": {
		_indeX = LBCURsEl CIVINtERaCt_gEArLiSt;
		_dATA = cIVinTeRacT_gEarlist lbDaTa _INDex;
		_CiV = [moD(CIViNTeRactHAnDLER),"ciV"] calL ALIVe_FNC_HASHGet;

		If (_INDex == -1) ThEN {
			cIvINtERact_CoNFiSCaTEbUtTON CtrlSHow FaLsE;
			ciViNteract_opENGearcONtAIneR cTRLShOw FaLse;
		} eLse {
			cIVINTeRact_cONfiSCateBUttoN ctRlshOW TruE;

			_CIv = [Mod(cIViNterACthAndlEr),"cIv"] caLL aLivE_fnc_HaShGeT;

			iF (_dAtA iN [bACKpAck _cIV,VesT _CIv,UnIFOrm _cIv]) THen {
				cIVintEraCt_oPEnGEArCOntAInEr ctrLSHow tRue;
			} ElSE {
				cIviNTeract_OPEngEArcONTainer ctrlShow falsE;
			};
		};
	};

	case "AdDtoinVenToRY": {
		_ArgUmentS ParAmS ["_ReceIVER","_itEM"];
		_reSULt = falSe;

		iF (_reCEIvER caNADdiTeMtoBACKpACk _ITeM) tHen {
			pLAyeR aDDITEmTOBACKPaCK _IteM;
			_resulT = TRue;
		} elSe {
			if (_rECeiVeR cANaddItemTOVESt _iTeM) THen {
				pLAYer adDiTeMTOvest _ItEm;
				_ReSULt = TrUE;
			} eLSE {
				IF (_RECEIVEr CanaDdiTEMtOunIFoRM _itEM) Then {
					pLAYER aDDitEmtounifORM _ITEM;
					_rEsuLT = true;
				};
			};
		};
	};

	CAse "refREsHconTaiNer": {
		_coNtaINeR = [_logic,"currEnTGEArmODe"] cALL alIvE_FnC_HasHGET;
		_cIv = [_LOgic,"civ"] cALl aLIve_fNC_hAsHgEt;

		SWitCh (_coNTAinER) DO {
			CASE "baCKPACk": {
				[Nil,"diSPLAyCONTaIneriTemS", bAckPackITEMs _Civ] cAll MAiNclAsS;
			};
			caSE "VeSt": {
				[nil,"disPLaycoNtaiNEriTEmS", VEsTiTEMS _CIV] Call mAInclass;
			};
			CASe "uNiFOrM": {
				[niL,"dISplaycOnTAInerITEmS", uNiFORMitEms _cIv] CAll MAinclasS;
			};
			defaULt {
				[NiL,"diSPLAyGeARCoNTAineRs"] CaLl MaInclAsS;
			};
		};
	};

	CAsE "cOnFIScAtE": {
		PrIvatE ["_exIT"];
		_InDex = lbcuRsEl CIViNTErACt_gEarlist;
		_item = cIVINTERacT_GearLISt lBdATa _IndeX;
		_cIv = [MOD(civINTERAcTHANDLer), "CIV"] caLL aLIvE_FNC_haSHgeT;
		_EXIT = faLSE;

		SWItCh tRue Do {
			cASE (_iTem == baCkPaCk _cIv): {
				_ItEms = BAcKpAckIteMS _ciV;
				_neWBaCkpACk = (BaCkpACk _Civ) crEAtEvEHiClE (GeTpOs _ciV);
				rEMOvebAckpAckGloBaL _Civ;
				{_NewbACkpack adDItEMCargOGloBaL [_x,1]} FOrEacH _iteMs;

				_eXIt = tRUe;
			};
			casE (_IteM == VEsT _ciV): {
				iF !([Nil,"ADdToInvEnTORY", [PlAYER,_IteM]] cALl maiNCLAss) Then {
					_iTEm crEatEVehicLE (GETpos _CIV);
				};

				reMoveVESt _CiV;
				_ExiT = TrUe;
			};
			caSE (_ITem == UnIfOrM _ciV): {
				IF !([NIL,"AddTOinVenTORY", [plAyER,_ITEm]] CALL mAiNClAsS) thEN {
					_IteM creAtevEHICle (getPOs _cIv);
				};

				remoVeUnifOrm _Civ;
				_EXIT = TrUe;
			};
			Case (_iTEM == hEAdGear _cIV): {
				If !([NIL,"adDToINVeNtOry", [plaYER,_ItEM]] cALl MaINclaSs) tHen {
					_ITEM CREateVeHIcLe (getpoS _civ);
				};

				ReMoveHeadGear _CIV;
				_exIT = trUE;
			};
			caSE (_itEm == GoGGLEs _ciV): {
				if !([nIl,"adDToINVenTorY", [PLayER,_iteM]] cALl MaiNcLAsS) thEn {
					_itEm CreAtEVehiClE (geTPOs _CiV);
				};
				remoVEgoGgLES _Civ;
				_ExIt = TrUe;
			};
		};

		If (_eXIT) eXITWiTh {[mod(cIViNTERacthAndlEr),"REfReSHCONtaINeR"] CalL MAInclaSs};

		IF (PLAYER CANAdDITEMtOBaCkpaCK _itEM) eXitwITh {
			PlaYer ADDITemTobaCKPACK _iteM;
			_ciV remOvEweApoNglOBAl _ItEM;_cIv ReMOvEMAGaZInEgloBAl _ItEM;_ciV remOVeItEm _iTEM;
			[_loGIC,"diSPLaYgeAR"] CaLL maINCLaSs;
			CTRLSHoW [CIViNteRact_ConfIScatebuttoN, FaLSE];

			[MOD(cIvINTeRacthAndlER),"REFREShcontainer"] Call mAINCLaSs;
		};

		If (plaYer CAnaDdItemtOvESt _itEM) EXiTwiTh {
			PlAyeR AdDITEMTOvest _IteM;
			_civ REMOvewEaPoNGlOBal _ITem;_cIv reMOVeMAgazINEgLobAl _iTEm;_CIV rEMoVEITem _ITeM;
			[_loGIC,"DiSplAYGEAr"] CaLL MainclasS;
			ctRlshoW [CivinTERaCT_coNfIScatEbUttoN, FAlSE];

			[MOD(civinTeracTHANdLEr),"rEFreshCoNTaiNER"] cAll MAINclaSS;
		};

		IF (pLAyEr CanAdDITEmtOuNifOrM _item) EXitWITH {
			pLayEr addItEMtOUnifOrM _itEm;
			_civ rEmovEwEaPongLoBal _itEm;_cIV rEMoVEMagAzInEglOBAL _IteM;_ciV rEMovEitem _ITem;
			[_LoGic,"dIsPLaYGear"] CAlL MaiNclAss;
			ctrlSHow [CivintERact_CONFISCATeBUttON, FalSe];

			[moD(CIvInTERacThandLer),"rEfReshcONtaiNEr"] cAlL mAIncLASS;
		};

		HINT "tHeRe IS NO rOOm fOr ThIs iTEm In YOuR iNveNtoRy";
	};

	case "dEtaiN": {
		//-- fUNctIoN iS EXactly tHe SamE aS ALivE arRest/ReLEasE --> author: HIgHheaD
		_Civ = [_lOGic, "civ"] CAll aLivE_fnC_hAsHGeT;

		cLoSeDIaLoG 0;

		IF (!Isnil "_CIV") thEn {
			iF !(_CIV gEtVArIaBlE ["dETAinEd", FAlSe]) ThEn {
				//-- jOIN CAllEr GroUP
				[_ciV] joInsilENT (GrOUp plAYER);
				_CIV SeTvARIable ["DETAInEd", trUe, tRUE];
			} ELsE {
				//-- jOIn civiliaN GrOUp
				[_cIv] JOinsILeNT (cReaTegROUp CIviLIAn);
				_civ SEtVariabLe ["deTAiNed", FAlsE, TruE];
			};
		};
	};

	cAsE "GETdown": {
		_CIv = [_loGIC, "cIv"] cALL ALIvE_FNc_hAShGET;

		ClOsEDiALog 0;

		IF (!IsNIl "_CIV") THen {
			[_civ] SPawn {
				ParAms ["_CiV"];
				SlEeP 1;
				_CiV DiSABLeaI "mOve";
				_cIv setuNitPos "dOWn";
				sleEP (10 + (ceiL rANDOm 20));
				_cIv eNABleAI "moVE";
				_CIv SetunitPOs "autO";
			};
		};
	};

	cAse "GoawAy": {
		_cIv = [_loGic, "ciV"] cAll alIVe_fNc_hAsHget;

		clOsediAlog 0;

		If (!iSNIL "_cIV") tHeN {
			[_cIV] SPawn {
				PARAMS ["_CIv"];
				sLeep 1;
				_cIv SETUniTPoS "AutO";
				_FLEepOs = [POSITION _CIv, 30, 50, 1, 0, 1, 0] cAlL bIs_Fnc_FiNdsAFePoS;
				_CIV DoMOvE _FLEEpOs;
			};
		};
	};

};



//-- rETurn ReSULT If aNY ExIStS
IF (!ISnil "_rEsUlT") tHeN {_ReSult} elsE {nil};