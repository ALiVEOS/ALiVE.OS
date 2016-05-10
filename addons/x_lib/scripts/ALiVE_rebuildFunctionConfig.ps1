
#-----------------------------------------------#
#	ALiVE: Rebuild Function Config				#
#		   Version 1.0							#
#		   By Naught							#
#-----------------------------------------------#
#	Description:								#
#		Rebuilds a functions config file in a	#
#		specified directory, loading all files	#
#		from a main function directory.			#
#-----------------------------------------------#

# Settings -------------------------------------#

$mod_root = "..\";
$mod_prefix = "ALiVE";

$addon_root = "\x\alive\addons\x_lib";
$functions_folder = "functions";
$function_config = "config\CfgFunctions.hpp";

$build_function_list = $true;
$function_list = "functions\function_list.txt";

# Functions ------------------------------------#

function EchoSpaced([string]$text)
{
	echo " ";
	echo $text;
	echo " ";
};

function EndScript
{
	echo " ";
	echo " ";
	Read-Host "Press ENTER to continue";
};

function StripFunction($file)
{
	$fileNameWE = [System.IO.Path]::GetFileNameWithoutExtension($file.fullname).Split('_', 2);
	$extName = [System.IO.Path]::GetExtension($file.fullname);
	return @($fileNameWE[1], $extName);
};

# Script ---------------------------------------#

EchoSpaced "Starting 'Rebuild Function Config' Script.";

$change_path = $false;
if ($mod_root -ne "")
{
	$change_path = $true;
	$save_path = Get-Location;
	Set-Location $mod_root;
};

New-Item $function_config -ItemType file -Force | Out-Null;
echo "Created new function configuration file.";

$functionData = Get-ChildItem $functions_folder -recurse -force;
echo "Retrieved function data.";

$funcCfgStream = [System.IO.StreamWriter] ($mod_root + $function_config);
echo "Opened the function configuration file for writing.";

if ($build_function_list)
{
	$lastDir = "";
	$funcListStream = [System.IO.StreamWriter] ($mod_root + $function_list);
	echo "Opened the function list file for writing.";
};

foreach ($func in $functionData)
{
	if (
		!(Test-Path $func.fullname -pathtype container) -and
		((split-path $func.fullname -leaf) -ne (split-path $function_list -leaf))
	) {
		$data = StripFunction $func;
		
		$file = Resolve-Path $func.fullname -Relative;
		$file = $addon_root + $file.Substring(1);
		
		$class = $data[0];
		$ext = $data[1];
		
		$funcCfgStream.WriteLine("`nclass $class`n{`n`tfile = ""$file"";`n`text = ""$ext"";`n`trecompile = RECOMPILE;`n};");
		
		if ($build_function_list)
		{
			$cur_dir = [System.IO.Path]::GetDirectoryName($func.fullname) | split-path -leaf
			
			if ($cur_dir -ne $lastDir)
			{
				$funcListStream.WriteLine("`n$cur_dir`n");
				$lastDir = $cur_dir;
			};
			
			$funcName = $mod_prefix + "_fnc_" + $data[0];
			$funcListStream.WriteLine("`t$funcName");
		};
	};
};

if ($build_function_list)
{
	echo "Finished writing to function list file.";
	$funcListStream.close();
};

echo "Finished writing to function configuration file.";
$funcCfgStream.close();

if ($change_path)
{
	cd $save_path;
};

EchoSpaced "Script 'Rebuild Function Config' finished.";

EndScript;
