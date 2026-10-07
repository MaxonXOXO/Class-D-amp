<#
  classd_stage41.ps1  -  run from D:\Class D amplifier
  UNTESTED: written without access to your LTspice or your existing netlists.
  Open the first .cir it writes in LTspice once to confirm it loads.

  .\classd_stage41.ps1 -Test ripple     # item A: ripple vs theory (ideal switches, fast)
  .\classd_stage41.ps1 -Test system     # item E: power / THD / efficiency sweep
  .\classd_stage41.ps1 -Test calc -Qg_nC 65 -Qrr_nC 40 -Qoss_nC 60 -Cboot_uF 1
                                        # items C/D analytic (datasheet numbers REQUIRED)

  Model: two half-bridges (BTL), ideal switches (Ron) + body diodes, per-leg L and C to ground,
  load across the two legs (this topology reproduces your Stage 39 AC numbers).
  Differential output peak ~= Vbus * m  (so Pout ~= (Vbus*m)^2 / (2*Rl) at low ripple).
#>
param(
  [ValidateSet('ripple','system','calc')][string]$Test = 'ripple',
  [string]$LT = 'D:\LTspice\LTspice.exe',
  [int]$TimeoutSec = 120,
  [double]$Fa = 2000,           # audio test tone (system test)
  [switch]$HardSwitch,          # use SPICE S-switches instead of smooth conductance switches
  [string[]]$Sel = @('A','B','C','D'),          # filters to run
  [double[]]$FsList = @(50e3,75e3,100e3),         # carrier frequencies
  [double[]]$XList = @(0,0.4,0.8),                # ripple test static duty offsets
  [double[]]$MList = @(0.1,0.2,0.37,0.6,0.85),    # system test modulation depths
  [double]$Vbus = 24,
  [double]$Rl = 4,
  [double]$Td = 420e-9,        # measured true dead time
  [double]$Rds_on = 0.006,     # ohms at temperature; CHECK datasheet
  [double]$Rdcr = 0.01,        # inductor DCR
  [double]$Cesr = 0.03,        # filter capacitor ESR (damps the common-mode LC ring)
  # calc-only inputs (datasheet values, no defaults on purpose)
  [double]$Qg_nC = 0, [double]$Qrr_nC = 0, [double]$Qoss_nC = 0,
  [double]$Cboot_uF = 1, [double]$Iqbs_uA = 100, [double]$Vcc = 12, [double]$Vf = 0.8
)

$Filters = @{ A=@(10e-6,1.5e-6); B=@(18e-6,2.2e-6); C=@(22e-6,2.2e-6); D=@(33e-6,1e-6); E=@(47e-6,1e-6) }

function Read-Meas($log) {
  $r = @{}
  foreach ($l in Get-Content $log) {
    if ($l -match '^\s*([A-Za-z_]\w*):\s.*?=\s*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)') { $r[$matches[1].ToLower()] = [double]$matches[2] }
    elseif ($l -match 'Total Harmonic Distortion:\s*([0-9.eE+-]+)%') { $r['thd_pct'] = [double]$matches[1] }
  }
  $r
}

function Invoke-Sim($name, $text) {
  $cir = Join-Path $PWD "$name.cir"
  $log = Join-Path $PWD "$name.log"
  foreach ($attempt in 1,2,3) {
    $t = $text
    if ($attempt -ge 2) { $t = $t -replace '\.options plotwinsize=0','.options plotwinsize=0 gmin=1e-9 abstol=1n reltol=0.003 method=gear' }
    if ($attempt -eq 3) { $t = [regex]::Replace($t,'td=([0-9.eE+-]+)',{ param($m) 'td=' + ([double]$m.Groups[1].Value*1.002).ToString('R',[Globalization.CultureInfo]::InvariantCulture) }) }
    Set-Content -Path $cir -Value $t -Encoding ASCII
    Remove-Item $log -ErrorAction SilentlyContinue
    Get-Process LTspice -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Milliseconds 500
    Start-Process -FilePath $LT -ArgumentList @('-b','-Run',"`"$cir`"") -WindowStyle Hidden | Out-Null
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $done = $false
    while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
      if ((Test-Path $log) -and (Select-String -Path $log -Pattern 'Total elapsed time' -Quiet -ErrorAction SilentlyContinue)) { $done = $true; break }
      Start-Sleep -Milliseconds 500
    }
    Get-Process LTspice -ErrorAction SilentlyContinue | Stop-Process -Force
    if ($done) {
      $res = Read-Meas $log
      if ($res.ContainsKey('ila_pp')) { return $res }
      Write-Host "  $name attempt ${attempt}: solver aborted, no measurements - retrying"
    } else {
      Write-Host "  $name attempt ${attempt}: not finished in $TimeoutSec s"
    }
  }
  $null
}

function G($r, $k, $d = 3) { if ($r -and $r.ContainsKey($k)) { [math]::Round($r[$k], $d) } else { 'N/A' } }

function New-Netlist($name, $fs, $L, $Cf, $m, $xdc, $tstop, $dtmax, $twin, $power) {
  $t1 = $tstop - $twin
  $V0A = $Vbus*(0.5+$xdc/2); $V0B = $Vbus*(0.5-$xdc/2); $I0 = $xdc*$Vbus/$Rl   # start at steady state
  $meas = @"
.meas TRAN ila_pp  PP I(LA)  FROM=$t1 TO=$tstop
.meas TRAN ila_max MAX I(LA) FROM=$t1 TO=$tstop
.meas TRAN ila_min MIN I(LA) FROM=$t1 TO=$tstop
.meas TRAN ila_avg AVG I(LA) FROM=$t1 TO=$tstop
.meas TRAN vdiff_pp PP V(oA,oB) FROM=$t1 TO=$tstop
.meas TRAN vdiff_avg AVG V(oA,oB) FROM=$t1 TO=$tstop
.meas TRAN vleg_pp PP V(oA) FROM=$t1 TO=$tstop
"@
  if ($power) {
    $meas += @"

.meas TRAN pout AVG V(oA,oB)*I(Rload) FROM=$t1 TO=$tstop
.meas TRAN pin  AVG -V(bus)*I(Vbus) FROM=$t1 TO=$tstop
.meas TRAN vrms RMS V(oA,oB) FROM=$t1 TO=$tstop
.four $Fa 9 2 V(oA,oB)
"@
  }
  if ($HardSwitch) {
    $swText = "ShA bus swA ghA 0 SWM`nSlA swA 0 glA 0 SWM`nShB bus swB ghB 0 SWM`nSlB swB 0 glB 0 SWM"
  } else {
    # smooth switches: conductance follows the (RC-smoothed) gate voltage, no discontinuity for the solver
    $swText = "BhA bus swA I=V(bus,swA)*(Gon*limit(V(ghA),0,1)+1e-7)`nBlA swA 0 I=V(swA)*(Gon*limit(V(glA),0,1)+1e-7)`nBhB bus swB I=V(bus,swB)*(Gon*limit(V(ghB),0,1)+1e-7)`nBlB swB 0 I=V(swB)*(Gon*limit(V(glB),0,1)+1e-7)"
  }
@"
* $name  BTL ideal-switch Class D
.param fs=$fs L=$L Cf=$Cf Rl=$Rl m=$m xdc=$xdc td=$Td Vb=$Vbus fa=$Fa
.param dl={2*fs*td}
.param Gon={1/$Rds_on}
Vbus bus 0 {Vb}
Vtri tri 0 PULSE(0 1 0 {0.5/fs-0.5e-9} {0.5/fs-0.5e-9} 1e-9 {1/fs})
Bra refA 0 V=0.5+0.5*(m*sin(2*pi*fa*time)+xdc)
Brb refB 0 V=0.5-0.5*(m*sin(2*pi*fa*time)+xdc)
Vdir dir 0 PULSE(0 1 0 1e-9 1e-9 {0.5/fs-1e-9} {1/fs})
Bgha rghA 0 V=if(V(tri)<V(refA)-dl*(1-V(dir)),1,0)
Bgla rglA 0 V=if(V(tri)>V(refA)+dl*V(dir),1,0)
Bghb rghB 0 V=if(V(tri)<V(refB)-dl*(1-V(dir)),1,0)
Bglb rglB 0 V=if(V(tri)>V(refB)+dl*V(dir),1,0)
Rgha rghA ghA 10
Rgla rglA glA 10
Rghb rghB ghB 10
Rglb rglB glB 10
Cgha ghA 0 100p
Cgla glA 0 100p
Cghb ghB 0 100p
Cglb glB 0 100p
$swText
DhA swA bus DBODY
DlA 0 swA DBODY
DhB swB bus DBODY
DlB 0 swB DBODY
LA swA oA {L} Rser=$Rdcr ic=$I0
LB swB oB {L} Rser=$Rdcr ic=-$I0
CA oA 0 {Cf} Rser=$Cesr ic=$V0A
CB oB 0 {Cf} Rser=$Cesr ic=$V0B
Rload oA oB {Rl}
.model SWM SW(Ron=$Rds_on Roff=10Meg Vt=0.5 Vh=0.1)
.model DBODY D(Is=1e-10 Rs=0.008 N=1.2)
.options plotwinsize=0
.save V(oA) V(oB) I(LA) I(LB) I(Rload) I(Vbus) V(bus)
.tran 0 $tstop 0 $dtmax uic
$meas
.end
"@
}

if ($Test -eq 'ripple') {
  # static differential duty xdc: 0 = zero-input (common-mode ripple only), 0.4/0.8 = differential ripple visible
  $rows = foreach ($f in $Sel) { foreach ($fs in $FsList) { foreach ($x in $XList) {
    $L,$C = $Filters[$f]
    $name = "s41_rip_${f}_$([int]($fs/1e3))k_x$([int]($x*100))"
    $net = New-Netlist $name $fs $L $C 0 $x 500e-6 20e-9 100e-6 $false
    $r = Invoke-Sim $name $net
    $D = 0.5 + $x/2
    [pscustomobject]@{
      Filter=$f; fs_kHz=$fs/1e3; xdc=$x
      Iripple_pp_A = G $r 'ila_pp'; Theory_A = $(if ($x -eq 0) { $f0 = 1/(2*[math]::PI*[math]::Sqrt($L*$C)); $z0 = [math]::Sqrt($L/$C); [math]::Round(2*($Vbus/2)/$z0*[math]::Tan([math]::PI*$f0/(2*$fs)),2) } else { 'n/a' })
      Ipeak_A = G $r 'ila_max'; Idc_A = G $r 'ila_avg'
      Vdiff_ripple_pp_V = G $r 'vdiff_pp' 4; Vleg_ripple_pp_V = G $r 'vleg_pp' 4
    }
  }}}
  $rows | Format-Table -AutoSize | Out-String -Width 250
  $rows | Export-Csv -NoTypeInformation s41_ripple.csv
}

if ($Test -eq 'system') {
  # Speakers: 10 W into 4 ohm needs Vpk ~ 8.9 V -> m ~ 0.37 at 24 V. Larger m is for a dummy load / headroom study only.
  $f = if ($PSBoundParameters.ContainsKey('Sel')) { $Sel[0] } else { 'B' }
  $L,$C = $Filters[$f]
  $rows = foreach ($fs in $FsList) { foreach ($m in $MList) {
    $name = "s41_sys_${f}_$([int]($fs/1e3))k_m$([int]($m*100))"
    $net = New-Netlist $name $fs $L $C $m 0 2e-3 100e-9 1e-3 $true
    $r = Invoke-Sim $name $net
    $eff = if ($r -and $r.ContainsKey('pout') -and $r.ContainsKey('pin') -and $r['pin'] -ne 0) { [math]::Round(100*$r['pout']/$r['pin'],2) } else { 'N/A' }
    $loss = if ($r -and $r.ContainsKey('pout') -and $r.ContainsKey('pin')) { [math]::Round($r['pin']-$r['pout'],3) } else { 'N/A' }
    [pscustomobject]@{
      Filter=$f; fs_kHz=$fs/1e3; m=$m
      Pout_W = G $r 'pout' 2; Vrms = G $r 'vrms' 2; THD_pct = G $r 'thd_pct' 3
      Eff_pct_conductionOnly = $eff; Loss_W = $loss; Ipk_A = G $r 'ila_max' 2
    }
  }}
  $rows | Format-Table -AutoSize | Out-String -Width 250
  $rows | Export-Csv -NoTypeInformation s41_system.csv
}

if ($Test -eq 'calc') {
  if ($Qg_nC -le 0 -or $Qrr_nC -le 0 -or $Qoss_nC -le 0) { throw 'Fill -Qg_nC -Qrr_nC -Qoss_nC from the IRFB7545 datasheet (no defaults on purpose).' }
  $Qg = $Qg_nC*1e-9; $Qrr = $Qrr_nC*1e-9; $Qoss = $Qoss_nC*1e-9; $Cb = $Cboot_uF*1e-6; $Iq = $Iqbs_uA*1e-6
  $rows = foreach ($fs in $FsList) {
    $minPulse = 520e-9
    $dmax = 1 - $minPulse*$fs                 # max duty before pulse dropping
    $Ton  = $dmax/$fs
    $Qneed = $Qg + $Iq*$Ton                   # charge drawn from Cboot per cycle
    $dV   = $Qneed/$Cb
    $Trech = (1-$dmax)/$fs                    # time SW is low per cycle at max duty
    $Irech = $Qneed/$Trech                    # average charge current needed in that window
    $Psw  = $fs*($Qrr+$Qoss)*$Vbus            # rough per-FET switching/recovery loss when body diode conducts
    $Pg   = $Qg*$Vcc*$fs                      # gate-drive power (dissipated in Rg/driver, not the FET channel)
    [pscustomobject]@{
      fs_kHz=$fs/1e3; DutyMax=[math]::Round($dmax,3); Cboot_uF=$Cboot_uF
      Boot_droop_V=[math]::Round($dV,3); Recharge_window_ns=[math]::Round($Trech*1e9,0)
      Recharge_I_needed_A=[math]::Round($Irech,3); Psw_est_W=[math]::Round($Psw,3); Pgate_W=[math]::Round($Pg,3)
    }
  }
  $rows | Format-Table -AutoSize | Out-String -Width 250
  "Note: at max duty the recharge window is only ~520 ns minus the driver dead time; check that the bootstrap diode + Rboot can deliver the 'Recharge_I_needed' value."
}
