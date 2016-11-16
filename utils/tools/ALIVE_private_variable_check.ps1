$path = 'P:\x\alive\addons\'
$output_file = 'P:\x\alive\utils\tools\private_variable_report.txt'
$stream = [System.IO.StreamWriter] $output_file

$ignorePaths = ('tests','clusters','indexes','data')

$files = Get-ChildItem $path  -Recurse -Include "*.sqf"

foreach ($file in $files)
{

    $parentPath = split-path $file -parent
    $parentPath = split-path $parentPath -leaf
    if($ignorePaths -contains $parentPath){
        continue
    }

    echo("FILE: "+$file)

    $stream.WriteLine("Parsing : " + $file)
    $content = Get-Content $file
    $lineNumber = 1
    $global = @()
    $private = @()
    $defined = @()
    $privateContinues = $false
    $paramsContinues = $false
    $subSwitch = $false
    $inCase = $false
    $isComment = $false
    $openingCount = 0
    $closingCount = 0

    foreach ($line in $content)
    {
        $line = $line.Trim()

        if($line.StartsWith('case')){
            if(!$inCase){
                $inCase = $true
                $private = @()
                $privateBlock = ""
                $openingCount = 0
                $closingCount = 0
                #echo ("CASE starts: " + $line + " line: "+$lineNumber)
            }
        }

        if($inCase){
            $openingCount += $line.Split("{").Count - 1
            $closingCount += $line.Split("}").Count - 1
            #echo("OPENS: "+$openingCount+" CLOSES: "+$closingCount)
            if($openingCount -eq $closingCount){
                #echo("CASE complete line: "+$lineNumber)
                $inCase = $false
            }
        }

        if($line.StartsWith("private")){
            if (!($line.contains("="))){
                $stripped = $line.Trim("private ")
                $stripped = $stripped.Trim('[')
                $stripped = $stripped.Trim('];')
                $stripped = $stripped.Replace('"','')
                $stripped = $stripped.Replace(' ','')
                $split = $stripped.split(",")

                if($inCase){
                    $private += $split
                    #echo ("PRIVATE: " + $private + " line: "+$lineNumber)
                }else{
                    $global += $split
                    #echo ("GLOBAL: " + $global + " line: "+$lineNumber)
                }

                if (!($line.EndsWith("];"))){
                    $privateContinues = $true
                }
            } else {
                $stripped = $line.Substring(0,$line.indexOf('='))
                $stripped = $stripped.Trim("private")
                $stripped = $stripped.Trim()

                if($inCase){
                    $private += $stripped
                    #echo ("PRIVATE: " + $private + " line: "+$lineNumber)
                }else{
                    $global += $stripped
                    #echo ("GLOBAL: " + $global + " line: "+$lineNumber)
                }
            }
        }

        if($privateContinues){
            $stripped = $line.Trim("private ")
            $stripped = $stripped.Trim('[')
            $stripped = $stripped.Trim('];')
            $stripped = $stripped.Replace('"','')
            $stripped = $stripped.Replace(' ','')
            $split = $stripped.split(",")

            if($inCase){
                $private += $split
                #echo ("PRIVATE: " + $private + " line: "+$lineNumber)
            }else{
                $global += $split
                #echo ("GLOBAL: " + $global + " line: "+$lineNumber)
            }

            if($line.EndsWith("];")){
                $privateContinues = $false
            }
        }

        if ($line.contains("params")){
            $tmp = $line.Substring(0,$line.indexOf('['))

            $stripped = $line.Trim($tmp)
            $stripped = $stripped.Trim(';')
            $stripped = $stripped.Trim()
            $stripped = $stripped.Trim('[')
            $stripped = $stripped.Trim(']')
            $stripped = $stripped.Replace('"','')
            $stripped = $stripped.Replace(' ','')
            $split = $stripped.split(",")

            foreach ($string in $split)
            {
                if ($string.contains("_")){
                    if($inCase){
                        $private += $string
                        #echo ("PRIVATE: " + $private + " line: "+$lineNumber)
                    }else{
                        $global += $string
                        #echo ("GLOBAL: " + $global + " line: "+$lineNumber)
                    }
                }
            }

            if (!($line.EndsWith("];"))){
                $paramsContinues = $true
            }
        }

        if ($paramsContinues){

            $quoteIndex = $line.indexOf('"')

            if ($quoteIndex.CompareTo(-1)){
                $tmp = $line.Substring(0,$line.indexOf('"'))

                $stripped = $line.Trim($tmp)
                $stripped = $stripped.Trim(';')
                $stripped = $stripped.Trim()
                $stripped = $stripped.Trim('[')
                $stripped = $stripped.Trim(']')
                $stripped = $stripped.Replace('"','')
                $stripped = $stripped.Replace(' ','')
                $split = $stripped.split(",")

                foreach ($string in $split)
                {
                    if ($string.contains("_")){
                        if($inCase){
                            $private += $string
                            #echo ("PRIVATE: " + $private + " line: "+$lineNumber)
                        }else{
                            $global += $string
                            #echo ("GLOBAL: " + $global + " line: "+$lineNumber)
                        }
                    }
                }

            };

            if($line.EndsWith("];")){
                $paramsContinues = $false
            }
        }

        if($line.StartsWith("/*")){
            $isComment = $true
        }

        if($line.EndsWith("*/")){
            $isComment = $false
        }

        if(!$isComment){
            if($line.StartsWith("_")){
                if($line.Contains("=")){
                    $var = $line.split("=")
                    $var = $var[0]
                    $var = $var.Trim()
                    $var = $var.Replace(' ','')
                    $defined = $global + $private
                    if($defined -notcontains $var){
                        #echo ("["+$lineNumber+"]LOCAL: " + $var)
                        $stream.WriteLine("error line: ["+$lineNumber+"] "+$var+" not defined")
                    }
                }
            }
        }

        $lineNumber++
    }
}

$stream.close()

echo " "
echo " "
Read-Host "Press ENTER to continue"