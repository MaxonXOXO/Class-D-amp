param([string]$Log)
$t = Get-Content $Log
$thd = @($t | Select-String "Partial Harmonic Distortion:\s+([\d\.eE+-]+)%" | % { [double]$_.Matches[0].Groups[1].Value })
$data=@{}; $cur=$null
foreach($l in $t){
 if($l -match '^Measurement: (\w+)'){ $cur=$Matches[1]; $data[$cur]=@(); continue }
 if($cur -and $l -match '^\s+(\d+)\s+([-\d\.eE+]+)'){ $data[$cur]+= [double]$Matches[2] } elseif($cur -and $l -match '^\s*$'){ $cur=$null }
}
$names="inputrms","gainmax","cmpmin","cmpmax","modidx","spkrms","spkpower","ibuspk","ibusrms","stpk","strms","stfwdpk","stfwdnj","deadns"
$n=$data["spkrms"].Count
for($i=0;$i -lt $n;$i++){
 $o=[ordered]@{step=$i+1}
 foreach($k in $names){ if($data[$k] -and $data[$k].Count -gt $i){ $o[$k]=[math]::Round($data[$k][$i],3) } }
 $o["THD%"]= if($thd.Count -gt $i){[math]::Round($thd[$i],2)}else{$null}
 [pscustomobject]$o
}
