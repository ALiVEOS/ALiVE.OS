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
    #'everon2014'
    #'imrali',
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
    #'altis',
    #'stratis'
    #'baranow',
    #'france',
    #'ivachev',
    #'panovo',
    #'staszow',
    #--'abel',
    #'altis',
    #--'cain',
    #'celle',
    #'chernarus',
    #'carraigdubh',
    #'clafghan',
    #'desert',
    #'desert_e',
    #'desert2',
    #--'eden',
    #'hellskitchen',
    #'hellskitchens',
    #'fallujah',
    #'fata',
    #'fdf_isle1_a',
    #'isladuala',
    #'lingor',
    #'mcn_hazarkot',
    #'mbg_celle2',
    #'namalsk',
    #'isoladicapraia',
    #--'noe',
    #'pja305',
    #'panthera',
    #'provinggrounds_pmc',
    #'sara',
    #'sara_dbe1',
    #'saralite',
    #'shapur_baf',
    #'smd_sahrani_a2',
    #'stratis',
    #'takistan',
    #'thirsk',
    #'thirskw',
    #'tigeria',
    #--'tigeria_se',
    #'torabora',
    #'tup_qom',
    #'utes',
    #--'vostok',
    #--'vostok_w',
    #'zargabad'
    )



foreach ($index_name in $index_names){
    
    $output_file = $index_path + 'objects_list.' + $index_name + '.txt'
    $index_file = $index_path + 'objects.' + $index_name + '.sqf'

    echo ("Parsing : " + $index_file)

    $reader = [System.IO.File]::OpenText($index_file)
    $stream = [System.IO.StreamWriter] $output_file
    try {
        for(;;) {
            $line = $reader.ReadLine()
            if ($line -eq $null) { break }
            if($line -match '"'){
                echo $(" -- Block : " + $line)
                $stream.WriteLine($line)
            }
        }
    }
    finally {
        $reader.close()
        $stream.close()
    }
}

echo " "
echo " "
Read-Host "Press ENTER to continue"