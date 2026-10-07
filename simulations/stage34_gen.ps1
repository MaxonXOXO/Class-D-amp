param([string]$Name,[string]$Topo="SE",[double]$Vcc=12,[double]$Vee=0,[double]$Rf=27000,[double]$Rs=4700,[string]$Step=".step param Vin list 0.3 0.5 1.0 1.5 2.0",[double]$Vin=1.0,[double]$X=1,[double]$Hd=1.75,[string]$Dc="470p")
$mid = ($Vcc+$Vee)/2
$hdr = @"
* Stage 34 ($Name): NE5532 buffer -> Baxandall (centred) -> NE5532 non-inv gain (1+Rf/10k) -> Rlimit -> volume (x^2.3) -> comparator -> $Topo power stage
* Opamp supply: Vcc=$Vcc V, Vee=$Vee V, mid=$mid V, clamp headroom $Hd V per rail. Screening models only.
.param Pvol=10k x=$X r={x**2.3} Ppot=100k bp=0.5 tp=0.5 deadcap=$Dc Fsig=1k Rs=$Rs Rf=$Rf Vbus=24 Vin=$Vin Hd=$Hd
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
* NEW Stage 34 gain stage: AC-coupled non-inverting, DC gain = 1 (Cgx) so mid-rail bias is preserved
Cg1 toneout gin 2.2u IC=0
Rgb gin mid 100k
XGAIN gin gfb gout opvcc opvee NE5532_CLAMP
Rfb gout gfb {Rf}
Rg gfb gx 10k
Cgx gx mid 47u IC=0
* Series limit resistor + volume pot (last)
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
Cintegrator tri sum 208.333p
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
function HB($s,$cmpexpr){ @"
* ---- half-bridge $s ----
Bcmp$s pwm$s 0 V=if($cmpexpr>V(tri),5,0)
Binv$s inv$s 0 V=if(delay(V(pwm$s),10n)>2.5,0,5)
Rhin$s pwm$s hin$s 1k
Chin$s hin$s 0 {deadcap}
Dhin$s hin$s pwm$s Dfast
Rlin$s inv$s lin$s 1k
Clin$s lin$s 0 {deadcap}
Dlin$s lin$s inv$s Dfast
BdrvH$s drvH$s sw$s V=V(vb$s,sw$s)*if(V(hin$s)>2.5,if(delay(V(hin$s),120n)>2.5,1,0),if(delay(V(hin$s),94n)>2.5,1,0))
BdrvL$s drvL$s 0 V=12*if(V(lin$s)>2.5,if(delay(V(lin$s),120n)>2.5,1,0),if(delay(V(lin$s),94n)>2.5,1,0))
Rgh$s drvH$s gh$s 10
Rgl$s drvL$s gl$s 10
CextraH$s gh$s sw$s 3.5n
CextraL$s gl$s 0 3.5n
Dboot$s vcc vb$s Dfast
Cboot$s vb$s sw$s 220n Rser=0.1 IC=11
Mhi$s bus gh$s sw$s IRFB7545Model
Mlo$s sw$s gl$s 0 IRFB7545Model
Lout$s sw$s out$s 68u Rser=0.15
Cout$s out$s 0 470n Rser=0.05
Bov$s ov$s 0 V=if(V(gh$s,sw$s)>2.1 & V(gl$s)>2.1,1,0)

"@ }
if($Topo -eq "SE"){
 $ps = (HB "A" "V(cmp)") + @"
Cblock outA spk 6800u Rser=0.08 IC=12
Rload spk 0 4
Bspk vspk 0 V=V(spk)
Bovl overlap 0 V=V(ovA)
.ic V(tri)=4.5 V(sum)=2.4999955 V(osc)=5 V(outA)=12 V(spk)=0 V(inp)=$mid V(bufout)=$mid V(toneout)=$mid V(w)=$mid V(gin)=$mid V(gout)=$mid V(gfb)=$mid V(wip)=$mid V(cmp)=2.5 V(bus)=24
"@
} else {
 $ps = (HB "A" "V(cmp)") + (HB "B" "(5-V(cmp))") + @"
Rload outA outB 4
Bspk vspk 0 V=V(outA,outB)
Bovl overlap 0 V=max(V(ovA),V(ovB))
.ic V(tri)=4.5 V(sum)=2.4999955 V(osc)=5 V(outA)=12 V(outB)=12 V(inp)=$mid V(bufout)=$mid V(toneout)=$mid V(w)=$mid V(gin)=$mid V(gout)=$mid V(gfb)=$mid V(wip)=$mid V(cmp)=2.5 V(bus)=24
"@
}
$meas = @"
$Step
.tran 0 6m 5m 100n
.options method=gear gmin=1e-10
.four 1k 9 1 V(vspk)
.meas TRAN InputRMS RMS V(src) FROM=5m TO=6m
.meas TRAN BufMax MAX V(bufout) FROM=5m TO=6m
.meas TRAN BufMin MIN V(bufout) FROM=5m TO=6m
.meas TRAN ToneMax MAX V(toneout) FROM=5m TO=6m
.meas TRAN ToneMin MIN V(toneout) FROM=5m TO=6m
.meas TRAN GainMax MAX V(gout) FROM=5m TO=6m
.meas TRAN GainMin MIN V(gout) FROM=5m TO=6m
.meas TRAN GainRMS RMS V(gout)-$mid FROM=5m TO=6m
.meas TRAN CmpMax MAX V(cmp) FROM=5m TO=6m
.meas TRAN CmpMin MIN V(cmp) FROM=5m TO=6m
.meas TRAN ModIdx PARAM (CmpMax-CmpMin)/4
.meas TRAN SpkRMS RMS V(vspk) FROM=5m TO=6m
.meas TRAN SpkPower PARAM SpkRMS*SpkRMS/4
.meas TRAN OverlapMax MAX V(overlap) FROM=5m TO=6m
.meas TRAN BusVmin MIN V(bus) FROM=5m TO=6m
.save V(src) V(bufout) V(toneout) V(gout) V(wip) V(cmp) V(tri) V(vspk) V(overlap) V(bus)
.end
"@
Set-Content -Path "D:\Class D amplifier\$Name.cir" -Value ($hdr + "`r`n" + $ps + "`r`n" + $meas) -Encoding ASCII




