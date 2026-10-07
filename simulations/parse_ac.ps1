$t = Get-Content stage40_ac.log
$data=@{}; $cur=$null
foreach($l in $t){
 if($l -match '^Measurement: (\w+)'){ $cur=$Matches[1]; $data[$cur]=@(); continue }
 if($cur -and $l -match '^\s+(\d+)\s+([-\d\.eE+]+)'){ $data[$cur]+= [double]$Matches[2] }
 elseif($cur -and $l -match '^\s+(\d+)\s+\(([-\d\.eE+]+)dB'){ $data[$cur]+= [double]$Matches[2] }
 elseif($cur -and $l -match '^\s*$'){ $cur=$null }
}
foreach($k in $data.Keys) {
  if($data[$k].Count -ge 2) {
    Write-Output "$k : 4ohm=$([math]::round($data[$k][0],3)) , 8ohm=$([math]::round($data[$k][1],3))"
  } else {
    Write-Output "$k : $($data[$k])"
  }
}
