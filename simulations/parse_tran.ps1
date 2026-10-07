param($Log)
$t = Get-Content $Log
$data=@{}; $cur=$null
foreach($l in $t){
 if($l -match '^Measurement: (\w+)'){ $cur=$Matches[1]; $data[$cur]=@(); continue }
 if($cur -and $l -match '^\s+(\d+)\s+([-\d\.eE+]+)'){ $data[$cur]+= [double]$Matches[2] }
 elseif($cur -and $l -match '^\s*$'){ $cur=$null }
}
foreach($k in $data.Keys) {
    Write-Output "$k : $($data[$k] -join ', ')"
}
