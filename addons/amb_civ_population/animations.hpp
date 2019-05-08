// Credits to IndeedPete for porting from Arma2 to Arma3

class CfgMovesBasic; // Reference CfgMovesBasic. This class is used by ArmA3 to store Actionsets, which will be covered at later time

class CfgMovesMaleSdr: CfgMovesBasic // Override CfgMovesMaleSdr class in which all animation states and gestures are stored. You can also make your own class but you need to make sure your unit will be using it. . Usually leave as is.
{
	skeletonName="OFP2_ManSkeleton"; // Skeleton indication. If you are doing animations for a T-rex, you will obviously use your custom skeleton for all moves. . Usually leave as is.
	gestures="CfgGesturesMale"; // Gestures class. Again, if you are using custom class, change it. Usually leave as is.

	class States
	{

		class AmovPercMrunSlowWrflDf;
		class AmovPercMstpSlowWrflDnon;
		class AmovPknlMstpSrasWrflDnon;
		class AmovPercMstpSnonWnonDnon;
		class CutSceneAnimationBase;
		class CutSceneAnimationBaseSit;
		class CutSceneAnimationBaseZoZo;

		class c5calming_apc: CutSceneAnimationBaseZoZo
		{
			actions = "NoActions";
			file = "x\alive\addons\amb_civ_population\anim\C5calming_apc";
			looped = 0;
			speed = 0.006384;
			collisionShape = "A3\anims_f\Data\Geom\Sdr\geom_empty.p3d";
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};

		class c5calming_fjodor: C5calming_apc
		{
			actions = "NoActions";
			file = "x\alive\addons\amb_civ_population\anim\C5calming_fjodor";
			looped = 0;
			speed = 0.006384;
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};

		class c5calming_zevl1: C5calming_apc
		{
			actions = "NoActions";
			file = "x\alive\addons\amb_civ_population\anim\C5calming_zevl1";
			looped = 0;
			speed = 0.006384;
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};

		class c5calming_zevl2: C5calming_apc
		{
			actions = "NoActions";
			file = "x\alive\addons\amb_civ_population\anim\C5calming_zevl2";
			looped = 0;
			speed = 0.006384;
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};

		class c5calming_zevl3: C5calming_apc
		{
			actions = "NoActions";
			file = "x\alive\addons\amb_civ_population\anim\C5calming_zevl3";
			looped = 0;
			speed = 0.006384;
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};

		class c5calming_zevl4: C5calming_apc
		{
			actions = "NoActions";
			file = "x\alive\addons\amb_civ_population\anim\C5calming_zevl4";
			looped = 0;
			speed = 0.006384;
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};

		class c5calming_zevl5: C5calming_apc
		{
			actions = "NoActions";
			file = "x\alive\addons\amb_civ_population\anim\C5calming_zevl5";
			looped = 0;
			speed = 0.006384;
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};

		class c5calming_zevl6: C5calming_apc
		{
			actions = "NoActions";
			file = "x\alive\addons\amb_civ_population\anim\C5calming_zevl6";
			looped = 0;
			speed = 0.006384;
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};

		class c5calming_zevl7: C5calming_apc
		{
			actions = "NoActions";
			file = "x\alive\addons\amb_civ_population\anim\C5calming_zevl7";
			looped = 0;
			speed = 0.006384;
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};

		class c7a_bravo_dovadeni1: CutSceneAnimationBaseZoZo
		{
			variantAfter[] = {1,1,1};
			variantsAI[] = {"c7a_bravo_dovadeni1",1};
			speed = 0.105263;
			//looped = 1;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravo_dovadeni1";
			//actions = "CivilStandActions_dovadeni1";
			equivalentTo = "c7a_bravo_dovadeni1";
			ConnectTo[] = {"c7a_bravo_dovadeni1",0.01,"c7a_bravo_dovadeni1TOerc",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravo_dovadeni3: CutSceneAnimationBaseZoZo
		{
			variantAfter[] = {1,1,1};
			variantsAI[] = {"c7a_bravo_dovadeni3",1};
			speed = 0.11583;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravo_dovadeni3";
			//actions = "CivilStandActions_dovadeni3";
			ConnectTo[] = {"c7a_bravo_dovadeni3",0.01,"c7a_bravo_dovadeni3TOerc",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravotleskani_idle: CutSceneAnimationBaseZoZo
		{
			variantsAI[] = {"c7a_bravoTleskani_idle1",0.2,"c7a_bravoTleskani_idle2",0.2,"c7a_bravoTleskani_idle3",0.2,"c7a_bravoTleskani_idle4",0.2,"c7a_bravoTleskani_idle5",0.2};
			variantAfter[] = {1,1,1};
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTleskani_idle";
			//actions = "CivilStandActions_crowdcheerspotlesk";
			equivalentTo = "c7a_bravoTleskani_idle";
			ConnectTo[] = {"c7a_bravoTleskani_idle1",0.01,"c7a_bravoTleskani_idle2",0.01,"c7a_bravoTleskani_idle3",0.01,"c7a_bravoTleskani_idle4",0.01,"c7a_bravoTleskani_idle5",0.01,"c7a_bravoTleskaniTOerc",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravotleskani_idle1: c7a_bravoTleskani_idle
		{
			speed = 0.136364;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTleskani_idle1";
			ConnectTo[] = {"c7a_bravoTleskani_idle",0.01,"c7a_bravoTleskaniTOerc",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravotleskani_idle2: c7a_bravoTleskani_idle
		{
			speed = 0.075758;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTleskani_idle2";
			ConnectTo[] = {"c7a_bravoTleskani_idle",0.01,"c7a_bravoTleskaniTOerc",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravotleskani_idle3: c7a_bravoTleskani_idle
		{
			speed = 0.074813;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTleskani_idle3";
			ConnectTo[] = {"c7a_bravoTleskani_idle",0.01,"c7a_bravoTleskaniTOerc",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravotleskani_idle4: c7a_bravoTleskani_idle
		{
			speed = 0.075949;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTleskani_idle4";
			ConnectTo[] = {"c7a_bravoTleskani_idle",0.01,"c7a_bravoTleskaniTOerc",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotleskani_idle5: c7a_bravoTleskani_idle
		{
			speed = 0.133333;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTleskani_idle5";
			ConnectTo[] = {"c7a_bravoTleskani_idle",0.01,"c7a_bravoTleskaniTOerc",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravotleskanitoerc: CutSceneAnimationBaseZoZo
		{
			speed = 0.588235;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTleskaniTOerc";
			ConnectTo[] = {"AmovPercMstpSnonWnonDnon",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravotoerc_idle: CutSceneAnimationBaseZoZo
		{
			variantAfter[] = {4,4,4};
			variantsAI[] = {"c7a_bravoTOerc_idle1",0.09,"c7a_bravoTOerc_idle2",0.018,"c7a_bravoTOerc_idle3",0.018,"c7a_bravoTOerc_idle5",0.09,"c7a_bravoTOerc_idle6",0.018,"c7a_bravoTOerc_idle7",0.018,"c7a_bravoTOerc_idle8",0.018,"c7a_bravoTOerc_idle9",0.012,"c7a_bravoTOerc_idle10",0.012,"c7a_bravoTOerc_idle11",0.012,"c7a_bravoTOerc_idle12",0.018,"c7a_bravoTOerc_idle13",0.018,"c7a_bravoTOerc_idle14",0.09,"c7a_bravoTOerc_idle15",0.018,"c7a_bravoTOerc_idle16",0.01,"c7a_bravoTOerc_idle17",0.09,"c7a_bravoTOerc_idle18",0.09,"c7a_bravoTOerc_idle19",0.09,"c7a_bravoTOerc_idle20",0.09,"c7a_bravoTOerc_idle21",0.09,"c7a_bravoTOerc_idle24",0.09};
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle";
			boundingSphere = 2;
			headBobMode = 0;
			enableDirectControl = 0;
			headBobStrength = 0;
			//actions = "CivilStandActions_crowdcheers";
			ConnectTo[] = {"c7a_bravoTOerc_idle1",0.01,"c7a_bravoTOerc_idle2",0.01,"c7a_bravoTOerc_idle3",0.01,"c7a_bravoTOerc_idle5",0.01,"c7a_bravoTOerc_idle6",0.01,"c7a_bravoTOerc_idle7",0.01,"c7a_bravoTOerc_idle8",0.01,"c7a_bravoTOerc_idle9",0.01,"c7a_bravoTOerc_idle10",0.01,"c7a_bravoTOerc_idle11",0.01,"c7a_bravoTOerc_idle12",0.01,"c7a_bravoTOerc_idle13",0.01,"c7a_bravoTOerc_idle14",0.01,"c7a_bravoTOerc_idle15",0.01,"c7a_bravoTOerc_idle16",0.01,"c7a_bravoTOerc_idle17",0.01,"c7a_bravoTOerc_idle18",0.01,"c7a_bravoTOerc_idle19",0.01,"c7a_bravoTOerc_idle20",0.01,"c7a_bravoTOerc_idle21",0.01,"c7a_bravoTOerc_idle24",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravotoerc_idle1: c7a_bravoTOerc_idle
		{
			speed = 0.086705;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle1";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle2: c7a_bravoTOerc_idle
		{
			looped = 0;
			speed = 0.075377;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle2";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle3: c7a_bravoTOerc_idle
		{
			speed = 0.067873;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle3";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle4: c7a_bravoTOerc_idle
		{
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle5: c7a_bravoTOerc_idle
		{
			speed = 0.056604;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle5";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle6: c7a_bravoTOerc_idle
		{
			speed = 0.041958;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle6";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle7: c7a_bravoTOerc_idle
		{
			speed = 0.041958;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle7";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle8: c7a_bravoTOerc_idle
		{
			speed = 0.094044;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle8";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravotoerc_idle9: c7a_bravoTOerc_idle
		{
			speed = 0.092879;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle9";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle10: c7a_bravoTOerc_idle
		{
			speed = 0.085714;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle10";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle11: c7a_bravoTOerc_idle
		{
			speed = 0.049423;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle11";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle12: c7a_bravoTOerc_idle
		{
			speed = 0.09009;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle12";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle13: c7a_bravoTOerc_idle
		{
			speed = 0.049423;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle13";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle14: c7a_bravoTOerc_idle
		{
			looped = 0;
			speed = 0.039113;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle14";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle15: c7a_bravoTOerc_idle
		{
			speed = 0.172414;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle15";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle16: c7a_bravoTOerc_idle
		{
			speed = 0.14218;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle16";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle17: c7a_bravoTOerc_idle
		{
			speed = 0.081744;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle17";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle18: c7a_bravoTOerc_idle
		{
			speed = 0.061224;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle18";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle19: c7a_bravoTOerc_idle
		{
			speed = 0.057034;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle19";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle20: c7a_bravoTOerc_idle
		{
			speed = 0.056285;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle20";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle21: c7a_bravoTOerc_idle
		{
			speed = 0.098039;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle21";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};
		class c7a_bravotoerc_idle24: c7a_bravoTOerc_idle
		{
			speed = 0.063694;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle24";
			ConnectTo[] = {"c7a_bravoTOerc_idle",0.01};
			InterpolateTo[] = {};
		};

	};

};