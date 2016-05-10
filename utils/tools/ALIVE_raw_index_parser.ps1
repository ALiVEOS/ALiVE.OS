$index_path = 'P:\x\alive\addons\fnc_strategic\indexes\'

$index_names = (
    'pandora'
    #'mske'
    #'lingor3'
    #'panthera3'
    #'pja308'
    #'mog'
    #'smd_sahrani_a3'
    #'esseker'
    #'isladuala3'
    #'anim_helvantis_v2'
    #'wake'
    #'panthera3'
    #'colleville'
    #'bornholm'
    #'imrali'
    #'sara',
    #'sara_dbe1',
    #'saralite'
    #'taviana',
    #'napf'
    #'sturko',
    #'wamako'
    #'dariyah',
    #'kalukhan'
    #'caribou',
    #'stratis',
    #'altis'
    #'fata'
    #'koplic'
    #'baranow',
    #'france',
    #'ivachev',
    #'panovo',
    #'staszow'
    #'altis',
    #'stratis'
    #'hellskitchen',
    #'hellskitchens'
    #'celle',
    #'chernarus',
    #'carraigdubh',
    #'clafghan',
    #'desert',
    #'desert_e',
    #'desert2',
    #'fallujah',
    #'fdf_isle1_a',
    #'isladuala',
    #'lingor',
    #'mcn_hazarkot',
    #'mbg_celle2',
    #'namalsk',
    #'isoladicapraia',
    #'pja305'
    #'panthera',
    #'provinggrounds_pmc',
    #'sara',
    #'sara_dbe1',
    #'saralite',
    #'shapur_baf',    
    #'smd_sahrani_a2'
    #'takistan',
    #'thirsk',
    #'thirskw',
    #'tigeria',
    #'torabora',
    #'tup_qom',
    #'utes',
    #'zargabad'
    )

$black_list = (
    'barel',
    'garbage',
    'tree',
    'smd_roads',
    'smd_veg',
    'smd_sahrani_veg',
    'rocks_f',
    'plants_f',
    'signs_f',
    'rocks_e',
    'plants_e',
    'rocks2',
    'plants2',
    '\\pond\\',
    'cwr2_plants',
    'cwr2_rocks',
    'mb_veg',
    'plants',
    'rocks',
    'palm',
    'ibr_plants',
    'brg_africa',
    'ns_plants',
    'a2_veg',
    'vegetation',
    'shrub',
    'palm',
    'calvaries',
    'rowboat',
    'salix2s',
    'humilis',
    'boulder',
    'fraxinus',
    'sambucas',
    'sambucus',
    'fagus',
    'drevo',
    'acer2',
    'craet',
    'corylus',
    'sign',
    'picea1s',
    'pinus',
    'torzo',
    'picea',
    'fallentree',
    'pmugo',
    'wheat',
    'sorbus',
    'quercus',
    'betula',
    'quercus',
    'populus',
    'cst_veg'
    )

foreach ($index_name in $index_names){
    
    $index_file = $index_path + 'objects.' + $index_name + '.sqf'
    $parsed_index_file = $index_path + 'parsed.objects.' + $index_name + '.sqf'
    $ignore = $false;

    echo ("Parsing : " + $index_file)

    $reader = [System.IO.File]::OpenText($index_file)
    $stream = [System.IO.StreamWriter] $parsed_index_file
    try {
        for(;;) {
            $line = $reader.ReadLine()
            if ($line -eq $null) { break }
            $in_black_list = $false
            if($line -match '"'){
                echo $(" -- Block : " + $line)
                for ($o = 0; $o -lt $black_list.count; $o++) {
                    if ($line -match $black_list[$o]) {
                        $in_black_list = $true
                    }
                }
                if($in_black_list){
                    $ignore = $true
                }else{
                    $ignore = $false
                }
                if($ignore){
                    echo $(" ----- Ignoring : " + $line)
                }
            }
            if(!$ignore){
                $stream.WriteLine($line)    
            }
        }
    }
    finally {
        $reader.close()
        $stream.close()
    }
}

Start-Sleep -s 10

foreach ($index_name in $index_names){
    $index_file = $index_path + 'objects.' + $index_name + '.sqf'
    $parsed_index_file = $index_path + 'parsed.objects.' + $index_name + '.sqf'

    if (Test-Path $index_file){
        Remove-Item $index_file
    }

    if (Test-Path $parsed_index_file){
        Rename-Item $parsed_index_file -newname $index_file
    } 

}

#lols
Add-Type -AssemblyName System.Speech
$synth = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
$synth.Speak('Parsing complete')

echo " "
echo " "
Read-Host "Press ENTER to continue"