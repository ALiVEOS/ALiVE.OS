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
			ConnectTo[] = {"c7a_bravo_dovadeni1",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravo_dovadeni3: CutSceneAnimationBaseZoZo
		{
			variantAfter[] = {1,1,1};
			variantsAI[] = {"c7a_bravo_dovadeni3",1};
			speed = 0.11583;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravo_dovadeni3";
			//actions = "CivilStandActions_dovadeni3";
			ConnectTo[] = {"c7a_bravo_dovadeni3",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravotleskani_idle: CutSceneAnimationBaseZoZo
		{
			variantsAI[] = {"c7a_bravoTleskani_idle5",0.2};
			variantAfter[] = {1,1,1};
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTleskani_idle";
			//actions = "CivilStandActions_crowdcheerspotlesk";
			equivalentTo = "c7a_bravoTleskani_idle";
			ConnectTo[] = {"c7a_bravoTleskani_idle5",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravotleskani_idle5: c7a_bravoTleskani_idle
		{
			speed = 0.133333;
			looped = 0;
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTleskani_idle5";
			ConnectTo[] = {"c7a_bravoTleskani_idle",0.01};
			InterpolateTo[] = {};
		};

		class c7a_bravotoerc_idle: CutSceneAnimationBaseZoZo
		{
			variantAfter[] = {4,4,4};
			variantsAI[] = {"c7a_bravoTOerc_idle8",0.018};
			file = "x\alive\addons\amb_civ_population\anim\c7a_bravoTOerc_idle";
			boundingSphere = 2;
			headBobMode = 0;
			enableDirectControl = 0;
			headBobStrength = 0;
			//actions = "CivilStandActions_crowdcheers";
			ConnectTo[] = {"c7a_bravoTOerc_idle8",0.01};
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

	};

};