param([string]$Name,[int]$Timeout=2000)
$log="D:\Class D amplifier\$Name.log"; $t0=Get-Date
for($i=0;$i -lt $Timeout;$i+=3){ Start-Sleep 3
 if((Test-Path $log) -and ((Get-Content $log -Raw) -match 'elapsed time') -and ((Get-Item $log).LastWriteTime -gt $t0.AddSeconds(-200))){ break } }
Select-String $log -Pattern "Options|Failure|failed to find|elapsed" | % Line
& "D:\Class D amplifier\stage34_parse.ps1" $log | ft step,inputrms,tonemax,tonemin,gainmax,gainmin,cmpmin,cmpmax,modidx,spkrms,spkpower,overlapmax,busvmin,"THD%" -auto | Out-String -Width 250

