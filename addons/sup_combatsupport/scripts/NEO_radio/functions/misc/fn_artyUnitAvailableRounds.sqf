private ["_result"];
_result = switch (true) do
{
	case (_this in
	[
		"B_MBT_01_arty_F","O_MBT_02_arty_F"
	]) :
	{
		["HE", "SADARM", "LASER", "SMOKE","CLUSTER","MINE","AT MINE"]
	};

	case (_this in
	[
		"O_Mortar_01_F", "B_Mortar_01_F",
		"B_G_Mortar_01_F", "I_Mortar_01_F"
	]) :
	{
		["HE", "WP", "ILLUM", "SMOKE"]
	};

	case (_this in
	[
		"BUS_MotInf_MortTeam", "BUS_Support_Mort"
	]) :
	{
		["HE", "ILLUM", "SMOKE"]
	};

	case (_this in
	[
		"B_MBT_01_mlrs_F"
	]) :
	{
		["ROCKETS"]
	};

	// RHS SUPPORT

	case (_this in
    [
        "rhs_2s3_tv"
    ]) :
    {
        ["HE", "LASER", "SMOKE", "ILLUM"]
    };


    case (_this in
    [
        "RHS_BM21_MSV_01","RHS_BM21_VDV_01","RHS_BM21_VMF_01","RHS_BM21_VV_01"
    ]) :
    {
        ["ROCKETS"]
    };


    case (_this in
    [
        "rhsusf_m109_usarmy","rhsusf_m109d_usarmy"
    ]) :
    {
        ["HE", "SADARM", "MINE", "CLUSTER", "SMOKE", "LASER", "AT MINE"]
    };

	case DEFAULT { [] };
};

_result;
