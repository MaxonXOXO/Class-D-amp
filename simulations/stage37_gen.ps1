param([string]$Name,[string]$Drv="2104",[double]$Fs=150000,[double]$Td=100,[string]$Net="delay",[string]$Crc="100p",
 [string]$Step=".step param Vin list 1.0",[double]$Vin=1.0,[double]$Rs=13000,[double]$Rf=23000,[double]$X=1,[int]$Snub=1,[string]$Cx="0",
 [double]$Vcc=12,[double]$Vee=-12,[double]$Hd=1.75,[string]$Tstart="5m")
# Stage 37 generator: BTL only. Smooth (tanh) comparator + gate path, no if() in the gate/dead-time path.
$mid = ($Vcc+$Vee)/2
$hdr = @"
* Stage 37 ($Name): driver=IR$Drv fsw=$Fs net=$Net td=$Td crc=$Crc Snub=$Snub  BTL, same front end as Stage 34 (Rf=$Rf Rlimit=$Rs)
.param Pvol=10k x=$X r={x**2.3} Ppot=100k bp=0.5 tp=0.5 Fsig=1k Rs=$Rs Rf=$Rf Vbus=24 Vin=$Vin Hd=$Hd
.param fsw=$Fs td={$Td*1n} crc=$Crc Cx=$Cx
.param wcmp={25n*fsw}
.param Vinpk={Vin*sqrt(2)}
Vmid mid 0 $mid
V5 v5 0 5
Vcc opvcc 0 $Vcc
Vee opvee 0 $Vee
Vbusraw braw 0 {Vbus}
Rbus braw bus 50m
Cbus bus 0 4700u Rser=0.05 IC=24
VccDrv vcc 0 12
Vsrc src 0 SINE(0 {Vinpk} {Fsig})
Rsource src s2 100
Cin s2 inp 2.2u IC=-$mid
Rb inp mid 47k
XBUF inp bufout bufout opvcc opvee NE5532_CLAMP
R1 bufout a 33k
R2 b toneout 33k
Rpa a w {Ppot*bp}
Rpb w b {Ppot*(1-bp)}
C1 a w 47n IC=0
C2 b w 47n IC=0
C3 bufout t1 3.3n
C4 t2 toneout 3.3n
Rta t1 tw {Ppot*tp}
Rtb tw t2 {Ppot*(1-tp)}
R5 tw w 8.2k
XTON mid w toneout opvcc opvee NE5532_CLAMP
Cg1 toneout gin 2.2u IC=0
Rgb gin mid 100k
XGAIN gin gfb gout opvcc opvee NE5532_CLAMP
Rfb gout gfb {Rf}
Rg gfb gx 10k
Cgx gx mid 47u IC=0
Rlimit gout psrc {Rs}
Rup psrc wip {Pvol*(1-r)+1}
Rlo wip mid {Pvol*r+1}
Cc wip c 1u IC=$($mid-2.5)
Ratt c cmp 150k
Rh v5 cmp 200k
Rl cmp 0 200k
Ccmp cmp 0 10p
Rpull osc v5 1
Bctrl ctrl 0 V=5-V(tri)
Ssch osc 0 ctrl 0 SCHMITT
.model SCHMITT SW(Ron=1m Roff=1G Vt=2.5 Vh=2)
Rintegrator osc sum 10k
Cintegrator tri sum {208.333p*150k/fsw}
Bop tri 0 V=limit(1e6*(2.5-V(sum)),0,5)
.model Dfast D(Is=2.52n Rs=0.568 N=1.9 Cjo=4p M=0.03 Tt=4n)
.model IRFB7545Model VDMOS(Vto=2.9 Kp=100 Rd=2m Rs=2m Rg=2.3 Cgs=6.3n Cgdmin=200p Cgdmax=1.8n Cjo=1n Is=1e-12 BV=60)
.subckt NE5532_CLAMP inp inn out vcc vee
E1 n1 0 inp inn 100k
R1 n1 n2 1k
C1 n2 0 1.59u
B1 out 0 V=min(max(V(n2),V(vee)+{Hd}),V(vcc)-{Hd})
.ends NE5532_CLAMP
"@
if($Drv -eq "2104"){ $drvp = ".param tonH=680n toffH=150n tonL=680n toffL=150n" } else { $drvp = ".param tonH=120n toffH=95n tonL=125n toffL=100n" }
function HB($s,$cmpexpr){
 if($Drv -eq "2104"){
  $net = "Bhl$s hl$s 0 V=V(pwm$s)`r`nBll$s ll$s 0 V=V(inv$s)"
 } elseif($Net -eq "delay"){
  $net = "Bhl$s hl$s 0 V=min(V(pwm$s),delay(V(pwm$s),td))`r`nBll$s ll$s 0 V=min(V(inv$s),delay(V(inv$s),td))"
 } else {
  $net = "Rhin$s pwm$s hin$s 1k`r`nChin$s hin$s 0 {crc}`r`nDhin$s hin$s pwm$s Dfast`r`nRlin$s inv$s lin$s 1k`r`nClin$s lin$s 0 {crc}`r`nDlin$s lin$s inv$s Dfast`r`nBhl$s hl$s 0 V=2.5*(1+tanh((V(hin$s)-3)/0.15))`r`nBll$s ll$s 0 V=2.5*(1+tanh((V(lin$s)-3)/0.15))"
 }
 $snub = ""
 if($Snub -eq 1){ $snub = "Rsn$s sw$s sn$s 10`r`nCsn$s sn$s 0 1n" }
@"
* ---- half-bridge $s ----
Bcmp$s pwm$s 0 V=2.5*(1+tanh(($cmpexpr-V(tri))/wcmp))
Binv$s inv$s 0 V=5-V(pwm$s)
$net
BdH$s dH$s 0 V=min(delay(V(hl$s),tonH),delay(V(hl$s),toffH))
BdL$s dL$s 0 V=min(delay(V(ll$s),tonL),delay(V(ll$s),toffL))
BdrvH$s drvH$s sw$s V=V(vb$s,sw$s)*V(dH$s)/5
BdrvL$s drvL$s 0 V=12*V(dL$s)/5
Rgh$s drvH$s gh$s 10
Rgl$s drvL$s gl$s 10
Cxh$s gh$s sw$s {Cx}
Cxl$s gl$s 0 {Cx}
Dboot$s vcc vb$s Dfast
Cboot$s vb$s sw$s 220n Rser=0.1 IC=11
Mhi$s bus gh$s sw$s IRFB7545Model
Mlo$s sw$s gl$s 0 IRFB7545Model
$snub
Lout$s sw$s out$s 68u Rser=0.15
Cout$s out$s 0 470n Rser=0.05

"@ }
$ps = (HB "A" "V(cmp)") + (HB "B" "(5-V(cmp))") + @"
Rload outA outB 4
Bspk vspk 0 V=V(outA,outB)
.ic V(tri)=4.5 V(sum)=2.4999955 V(osc)=5 V(outA)=12 V(outB)=12 V(inp)=$mid V(bufout)=$mid V(toneout)=$mid V(w)=$mid V(gin)=$mid V(gout)=$mid V(gfb)=$mid V(wip)=$mid V(cmp)=2.5 V(bus)=24
"@
$meas = @"
$Step
.tran 0 6m $Tstart 5n
.options method=gear gmin=1e-10
.four 1k 9 1 V(vspk)
.meas TRAN InputRMS RMS V(src) FROM=5m TO=6m
.meas TRAN GainMax MAX V(gout) FROM=5m TO=6m
.meas TRAN GainMin MIN V(gout) FROM=5m TO=6m
.meas TRAN CmpMax MAX V(cmp) FROM=5m TO=6m
.meas TRAN CmpMin MIN V(cmp) FROM=5m TO=6m
.meas TRAN ModIdx PARAM (CmpMax-CmpMin)/4
.meas TRAN SpkRMS RMS V(vspk) FROM=5m TO=6m
.meas TRAN SpkPower PARAM SpkRMS*SpkRMS/4
.meas TRAN IbusPk MAX (Id(MhiA)+Id(MhiB)) FROM=5m TO=6m
.meas TRAN IbusRMS RMS (Id(MhiA)+Id(MhiB)) FROM=5m TO=6m
.meas TRAN StPk MAX max(min(abs(Id(MhiA)),abs(Id(MloA))),min(abs(Id(MhiB)),abs(Id(MloB)))) FROM=5m TO=6m
.meas TRAN StRMS RMS max(min(abs(Id(MhiA)),abs(Id(MloA))),min(abs(Id(MhiB)),abs(Id(MloB)))) FROM=5m TO=6m
.meas TRAN StFwdPk MAX (min(max(Id(MhiA),0),max(Id(MloA),0))+min(max(Id(MhiB),0),max(Id(MloB),0))) FROM=5m TO=6m
.meas TRAN StFwdE INTEG (V(bus)*(min(max(Id(MhiA),0),max(Id(MloA),0))+min(max(Id(MhiB),0),max(Id(MloB),0)))) FROM=5m TO=6m
.meas TRAN StFwdnJ PARAM StFwdE/(fsw*1m)*1e9
.meas TRAN DeadFrac AVG (u(2.9-(V(ghA)-V(swA)))*u(2.9-V(glA))) FROM=5m TO=6m
.meas TRAN DeadNs PARAM DeadFrac/(2*fsw)*1e9
.meas TRAN BusVmin MIN V(bus) FROM=5m TO=6m
.save V(src) V(gout) V(cmp) V(tri) V(vspk) V(bus) V(ghA) V(swA) V(glA) Id(MhiA) Id(MloA) Id(MhiB) Id(MloB)
.end
"@
Set-Content -Path "D:\Class D amplifier\$Name.cir" -Value ($hdr + "`r`n" + $drvp + "`r`n" + $ps + "`r`n" + $meas) -Encoding ASCII


