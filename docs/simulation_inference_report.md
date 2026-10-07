# Class-D Amplifier Simulation Inference Report

**Prepared:** 5 October 2026  
**Basis:** LTspice netlists, simulation logs, and native waveform data in the project folder.

## Executive summary

The simulations screened the proposed analog volume/bias network, a 150 kHz PWM carrier and oscillator candidate, the RC-diode dead-time network, and one IR2110 half-bridge using either an IRFB7545 or IRFB7546.

The input conditioning reached about 0.70–4.30 V at maximum volume around a 2.5 V center. The ideal-carrier PWM check therefore stayed within the modeled 0.5–4.5 V carrier range. The separate RC oscillator candidate reached about 149.5 kHz, but its ramp made PWM duty nonlinear. The dead-time sweeps favored 470 pF among the tested values in the simplified models. The final selected half-bridge runs showed no interval with both modeled gate voltages above 2.1 V.

These are simulation-screening results, not proof of hardware safety or a finalized design. The comparator and IR2110 were behavioral models; the MOSFETs used simplified VDMOS cards rather than manufacturer macromodels. The oscillator still needs correction, and the final power-stage results need verification with actual device models and a full bridge.

## Parts and circuit values represented

| Block | Candidate or simulated values |
|---|---|
| PWM comparator | TLV3502 for left/right channels |
| Oscillator comparator | TLV3501 candidate |
| Gate driver | IR2110; modeled typical propagation delays 120 ns turn-on and 94 ns turn-off |
| MOSFETs | IRFB7545 or IRFB7546, one high-side and one low-side in a single simulated half-bridge |
| Volume control | 10 kΩ potentiometer; position law r = x^2.3; stepped x = 0.2, 0.5, 0.8, 1.0 |
| Audio/coupling | 4.5 V peak input about a 6 V midpoint; 1 µF coupling capacitor |
| Comparator bias/attenuator | 150 kΩ series resistor; 200 kΩ to 5 V and 200 kΩ to ground; 10 pF input capacitance |
| PWM carrier | Ideal triangle 0.5–4.5 V, 150 kHz, period 6.667 µs |
| RC oscillator candidate | 15.2 kΩ timing resistance, 100 pF timing capacitance; 25 kΩ / 100 kΩ feedback/reference network |
| Dead-time input network | 1 kΩ per input, steering diodes, 220 / 330 / 470 pF capacitors; behavioral 10 ns inverter delay |
| Driver and bootstrap | 12 V driver supply; 220 nF bootstrap capacitor |
| Power bus/output | 24 V bus; 10 Ω gate resistors; 22 µH series inductor; 470 nF output capacitor; 8 Ω load to the 12 V midpoint |

The MOSFET models were approximations. The IRFB7545 card used Vto=2.9 V, Rd=Rs=2 mΩ, Rg=2.3 Ω, Cgs=6.3 nF, Cgdmin=200 pF and Cgdmax=1.8 nF. The IRFB7546 card used Vto=2.9 V, Rd=Rs=2.5 mΩ, Rg=2.3 Ω, Cgs=4.8 nF, Cgdmin=150 pF and Cgdmax=1.4 nF. Extra capacitance of 3.5 nF and 2.9 nF, respectively, represented the maximum gate-charge cases in the sweeps. This is a rough gate-charge approximation, not a validated nonlinear gate-charge model.

Infineon lists typical gate charge of about 75 nC for IRFB7545 and 58 nC for IRFB7546; see the [IRFB7545 datasheet](https://www.infineon.com/assets/row/public/documents/24/49/infineon-irfb7545-datasheet-en.pdf) and [IRFB7546 datasheet](https://www.infineon.com/assets/row/public/documents/24/49/infineon-irfb7546-datasheet-en.pdf).

## Test results and inferences

### 1. Volume, coupling, and bias response — Stage 4

**Reason:** Inspect the input path frequency response and potentiometer scaling before PWM conversion.

**Method:** AC sweep from 1 Hz to 1 MHz for the four potentiometer positions. The network used a 10 kΩ pot, 1 µF coupling capacitor, 150 kΩ series attenuation, 200 kΩ / 200 kΩ bias network, and 10 pF input capacitance.

**Inference:** The circuit was set up to place the comparator signal around 2.5 V while the pot controls its amplitude. The screenshot supplied in the conversation showed a cursor reading near −3.96 dB at 11.5 Hz for the displayed trace. This was a response check, not a complete passband/tolerance analysis.

### 2. Initial ideal PWM and bridge timing exploration — Stage 5

**Reason:** Check the complementary PWM sequence and explore explicit dead-time values.

**Method:** 150 kHz carrier, 24 V bus, 100/200/300 ns delay steps, idealized voltage-controlled switches, 22 µH / 470 nF output filter, and 8 Ω differential load.

**Results:** Comparator input ranged approximately 0.699–4.299 V. The modeled overlap flag remained zero for each delay setting. The simplified output reached roughly ±19.8–20.9 V peak.

**Inference:** The switching sequence and delay values could be explored, but output amplitude is not a reliable power-stage prediction with ideal switches and behavioral drive. Later device-specific checks superseded this first model.

### 3. RC-diode dead-time network and charge sensitivity — Stages 6–7

**Reason:** Replace a fixed delay with a candidate input network and assess its sensitivity to capacitor value, input threshold, audio polarity, and gate charge.

**Method:** Each input used 1 kΩ, a diode, and a swept 220/330/470 pF capacitor. The gate model used a 10 Ω resistor and equivalent capacitance Qgate/12 V. Driver timing used 120 ns on / 94 ns off. Stage 6 swept threshold 2.0/2.5/3.0/3.2 V and audio ±1.8 V; Stage 7 added device-specific typical/maximum gate charge cases.

**Results:** The 4.5 V simultaneous-gate flag remained zero in the valid tested combinations. Transition-gap measurements varied with input polarity and edge ordering; some measurements failed or returned negative gaps when the specified trigger and target edges occurred in the opposite order.

**Inference:** The network creates non-overlap in this simplified model, but these first tests did not by themselves establish a robust capacitor value. The later VDMOS sweeps added a second, lower 2.1 V simultaneous-gate indicator.

### 4. Conditioned audio into ideal 150 kHz carrier — Stage 8

**Reason:** Verify the comparator input range over volume settings and see whether it fits the chosen carrier span.

**Method:** Ideal comparator behavior with a 0.5–4.5 V, 150 kHz triangle. Left audio was 1 kHz and right audio 1.3 kHz, both 4.5 V peak. Pot positions were x=0.2/0.5/0.8/1.0.

| Volume x | Left input minimum | Left input maximum |
|---:|---:|---:|
| 0.2 | 2.455 V | 2.545 V |
| 0.5 | 2.137 V | 2.863 V |
| 0.8 | 1.432 V | 3.566 V |
| 1.0 | 0.699 V | 4.299 V |

The measured carrier period was 6.666667 µs in each step.

**Inference:** The 2.5 V bias and attenuator produced a plausible range for the ideal-carrier PWM check. At full volume the conditioned input remained within the 0.5–4.5 V carrier limits. Comparator offset, propagation delay, output drive, and input common-mode behavior were not modeled, so this does not qualify the TLV3501/3502 implementation itself.

### 5. RC relaxation oscillator candidate — Stage 9

**Reason:** Check whether the candidate oscillator reaches the target frequency and whether its ramp gives the intended PWM linearity.

**Method:** 15.2 kΩ timing resistor, 100 pF timing capacitor, and feedback thresholds near 0.5 and 4.5 V. A behavioral comparator produced the oscillation; fixed input levels tested PWM duty.

**Results:** Period was 6.69 µs, approximately 149.5 kHz. Ramp minimum/maximum were 0.503/4.497 V.

| Input level | Ideal triangle duty | RC-ramp duty measured |
|---:|---:|---:|
| 0.7 V | 5% | 8.43% |
| 1.5 V | 25% | 30.70% |
| 2.5 V | 50% | 50.14% |
| 3.5 V | 75% | 69.40% |
| 4.3 V | 95% | 91.31% |

**Inference:** Frequency is on target, but the RC ramp is not sufficiently linear over the tested range to preserve the intended duty mapping. This oscillator candidate should be revised or replaced with a triangle/ramp oscillator before freezing the control design.

### 6. Device-specific dead-time capacitor sweeps — Stages 10–13

**Reason:** Compare the two MOSFET model cards under typical and maximum-charge assumptions, at both 90% and 80% modulation.

**Method:** 24 V bus, 12 V drive, 150 kHz switching, 1 kHz audio, one half-bridge, bootstrap, and the 22 µH / 470 nF / 8 Ω output network. Dead-time capacitors were 220/330/470 pF. Stage 10/11 covered 90% modulation; Stage 12/13 covered 80%. The overlap indicators separately checked simultaneous modeled gate voltages above 3.7 V and above 2.1 V.

At 80% modulation, the 2.1 V indicator results were:

| Device | 220 pF typical | 330 pF typical | 470 pF typical | 220 pF maximum charge | 330 pF maximum charge | 470 pF maximum charge |
|---|---:|---:|---:|---:|---:|---:|
| IRFB7545 | 1 | 0 | 0 | 1 | 0 | 0 |
| IRFB7546 | 0 | 0 | 0 | 1 | 0 | 0 |

Here, 1 means the modeled gates were simultaneously above the selected voltage at some point; 0 means no such interval was detected. The 3.7 V indicator stayed zero across the 80% sweeps. The maximum-charge 220 pF IRFB7545 cases showed a large peak current in the model (roughly 14 A), while the 470 pF maximum-charge case reduced it to about 3.3 A.

**Inference:** Of the tested values, 470 pF is the most conservative choice in these models. At 80% modulation it cleared the 2.1 V indicator for both MOSFETs and both charge cases. This is a model-specific screening result, not proof of zero shoot-through current or a safe hardware dead time.

### 7. Selected 80% half-bridge runs — Stages 14–15

**Reason:** Run longer individual transients for each device using the 470 pF setting and maximum-charge capacitance approximation.

**Method:** 24 V bus, 12 V driver, 220 nF bootstrap, 150 kHz carrier, 1 kHz audio at 80% modulation, 22 µH / 470 nF filter, 8 Ω load. Transient length was 1.1 ms, maximum timestep 10 ns; the reported measurement window started at 100 µs.

| Measurement | IRFB7545 | IRFB7546 |
|---|---:|---:|
| Maximum 2.1 V overlap indicator | 0 | 0 |
| Maximum 3.7 V overlap indicator | 0 | 0 |
| Minimum bootstrap voltage | 11.985 V | 12.000 V |
| Maximum high-side gate-source voltage | 12.114 V | 12.126 V |
| Maximum low-side gate-source voltage | 12.000 V | 12.000 V |
| Peak bus current magnitude | 3.295 A | 3.401 A |
| Peak high-side drain current magnitude | 3.295 A | 3.401 A |
| Peak low-side drain current magnitude | 3.581 A | 3.344 A |
| Switch-node minimum / maximum | −0.738 / 24.823 V | −0.737 / 24.824 V |
| Filtered load RMS voltage | 6.238 V | 6.143 V |
| Derived average power into 8 Ω | 4.865 W | 4.717 W |

The load power is derived from the measured RMS voltage as V_RMS²/8. It describes this one-leg simulated load referenced to the midpoint, not a complete BTL speaker power rating. No reliable switching-loss or efficiency result was produced.

**Inference:** In this selected simplified case, the two device models behaved similarly. IRFB7545 produced a little more filtered RMS output and a slightly lower peak bus current. The difference is not enough to make a defensible component selection without thermal and switching-loss analysis and better models.

## Overall conclusion and design implications

- The input conditioning range is plausible for a 0.5–4.5 V carrier, under ideal comparator assumptions.
- The proposed RC oscillator reaches approximately 150 kHz but has a nonlinear ramp-to-duty relationship. Fix this before finalizing the PWM/control stage.
- Of the tested dead-time capacitors, 470 pF performed best in the simplified overlap screens at 80% modulation, including maximum-charge approximations.
- Neither the dead-time result nor the selected half-bridge simulation proves hardware shoot-through safety. Gate threshold is not a sharp switch-off boundary, and the models omit important nonlinear and layout effects.
- The MOSFET comparison is preliminary. Infineon describes IRFB7545 for 100 kHz switching applications and lists IRFB7546 as discontinued and intended for below-100-kHz switching. These simulations used 150 kHz. [IRFB7545 product page](https://www.infineon.com/part/IRFB7545) · [IRFB7546 product page](https://www.infineon.com/part/IRFB7546)
- The IR2110 model used typical delay values only. Its listed typical delays are 120 ns turn-on and 94 ns turn-off, and Infineon currently marks the part “not for new design.” [IR2110 product page and specifications](https://www.infineon.com/part/IR2110)
- The results support the next design iteration but do not finalize the BOM. Correct the carrier waveform, then rerun the integrated PWM and complete bridge with manufacturer models and realistic gate-drive/layout parasitics.

## Native LTspice artifacts

The following raw files contain LTspice waveform data and can be opened in LTspice. No replacement plots were generated.

- [Stage 4 volume/bias AC netlist](</D:/Class D amplifier/stage4_vol.cir>)
- [Stage 8 PWM control netlist](</D:/Class D amplifier/stage8_pwm_control.cir>) · [Stage 8 waveform data](</D:/Class D amplifier/stage8_pwm_control.raw>)
- [Stage 9 oscillator netlist](</D:/Class D amplifier/stage9_relaxation_osc.cir>) · [Stage 9 waveform data](</D:/Class D amplifier/stage9_relaxation_osc.raw>)
- [Stage 6 dead-time netlist](</D:/Class D amplifier/stage6_rc_deadtime.cir>)
- [Stage 10 IRFB7545 90% sweep log](</D:/Class D amplifier/stage10_irfb7545_hb.log>) · [Stage 11 IRFB7546 90% sweep log](</D:/Class D amplifier/stage11_irfb7546_hb.log>)
- [Stage 12 IRFB7545 80% sweep log](</D:/Class D amplifier/stage12_irfb7545_80mod.log>) · [Stage 13 IRFB7546 80% sweep log](</D:/Class D amplifier/stage13_irfb7546_80mod.log>)
- [Stage 14 IRFB7545 selected-case netlist](</D:/Class D amplifier/stage14_irfb7545_selected.cir>) · [Stage 14 waveform data](</D:/Class D amplifier/stage14_irfb7545_selected.raw>)
- [Stage 15 IRFB7546 selected-case netlist](</D:/Class D amplifier/stage15_irfb7546_selected.cir>) · [Stage 15 waveform data](</D:/Class D amplifier/stage15_irfb7546_selected.raw>)

## Manufacturer references

- [TI TLV3501 page](https://www.ti.com/product/TLV3501) · [TLV350x datasheet](https://www.ti.com/lit/ds/symlink/tlv3501.pdf)
- [Infineon IRFB7545 page](https://www.infineon.com/part/IRFB7545) · [IRFB7545 datasheet](https://www.infineon.com/assets/row/public/documents/24/49/infineon-irfb7545-datasheet-en.pdf)
- [Infineon IRFB7546 page](https://www.infineon.com/part/IRFB7546) · [IRFB7546 datasheet](https://www.infineon.com/assets/row/public/documents/24/49/infineon-irfb7546-datasheet-en.pdf)
- [Infineon IR2110 page](https://www.infineon.com/part/IR2110) · [IR2110 datasheet](https://www.infineon.com/assets/row/public/documents/24/49/infineon-ir2110-datasheet-en.pdf)


## Addendum: requested reruns and review checks (5 October 2026)

### A. Actual 470 pF gate-edge gap

**Method:** Reprocessed the Stage 14 and Stage 15 transient waveforms over 100 µs–1.1 ms. Each crossing time was linearly interpolated at 2.1 V using the high-side gate-source voltage `V(gh,sw)` and low-side gate voltage `V(gl)`. The values below are the complementary intervals between the gate-off crossing and the next opposite gate-on crossing, summarized over 300 gaps.

| MOSFET model | Minimum gap | Median gap | Maximum gap |
|---|---:|---:|---:|
| IRFB7545 | 92.2 ns | 117.3 ns | 165.1 ns |
| IRFB7546 | 145.2 ns | 169.4 ns | 206.6 ns |

These are threshold-crossing intervals in the simplified device/driver models, not guaranteed physical dead time. 2.1 V is only a measurement threshold; MOSFET turn-off depends on gate charge, Miller plateau, current, temperature, and parasitics. The model cannot turn this into a hardware shoot-through guarantee.

### B. Linear integrator oscillator — Stage 17

**Reason:** Replace the nonlinear exponential ramp tested in Stage 9 with a substantially linear triangle for predictable PWM duty.

**Method:** Idealized behavioral op-amp integrator, 10 kΩ input resistor, 208.333 pF feedback capacitor, and Schmitt switching thresholds producing a nominal 0.5–4.5 V triangle. This is a functional topology check, not a real op-amp macromodel.

**Results:** 6.6723 µs period (149.87 kHz); ramp 0.500–4.500 V. At comparator input levels 0.7, 1.5, 2.5, 3.5, and 4.3 V, measured duties were 5.02%, 25.05%, 50.08%, 75.11%, and 95.10%, respectively. This is close to the ideal linear-triangle mapping and materially improves on Stage 9's RC ramp.

### C. Wide potentiometer sweep with 470 pF and revised LC — Stage 18

**Method:** Full modeled input-to-PWM-to-IRFB7545 half-bridge, with the Stage 17 integrator oscillator, 470 pF RC-diode input conditioning, 24 V bus, 12 V driver, 150 kHz switching, 1 kHz/4.5 V-peak source, and 8 Ω one-leg load. Volume control stepped x=0.1 to 1.0. The filter candidate was 68 µH + 0.15 Ω series resistance and 470 nF to the 12 V midpoint. Transient ran to 1.1 ms with 10 ns maximum step; measurements use 100 µs–1.1 ms.

| Pot x | Peak absolute inductor current | Peak absolute load current | Load RMS voltage | RMS-derived P into 8 Ω |
|---:|---:|---:|---:|---:|
| 0.1 | 0.309 A | 0.077 A | 0.381 V | 0.018 W |
| 0.2 | 0.330 A | 0.097 A | 0.410 V | 0.021 W |
| 0.3 | 0.369 A | 0.137 A | 0.541 V | 0.037 W |
| 0.4 | 0.427 A | 0.197 A | 0.814 V | 0.083 W |
| 0.5 | 0.499 A | 0.272 A | 1.219 V | 0.186 W |
| 0.6 | 0.614 A | 0.395 A | 1.844 V | 0.425 W |
| 0.7 | 0.763 A | 0.562 A | 2.755 V | 0.948 W |
| 0.8 | 0.933 A | 0.762 A | 3.899 V | 1.900 W |
| 0.9 | 1.126 A | 1.000 A | 5.284 V | 3.490 W |
| 1.0 | 1.337 A | 1.280 A | 6.949 V | 6.033 W |

Power is `V_RMS²/8` for the simulated one-leg load. These are not BTL output-power figures. The 2.1 V simultaneous-gate indicator stayed 0 for all ten pot positions, and minimum bootstrap voltage ranged from 12.005 to 12.028 V.

The Stage 18 current results also clarify the earlier 3.3–3.4 A bus-current peaks: Stage 18's peak inductor current is at most 1.337 A and peak load current 1.280 A over this range. In Stages 14–15, the 3.3–3.4 A `I(Rbus)` peaks occurred at switch-node commutation, not as sustained load current. The device drain-current vectors exported by those older runs were not reliable, so the simulations do **not** establish whether the brief bus spike is capacitive commutation, recovery, or another model artifact. The simplified VDMOS model omitted explicit body-diode reverse-recovery behavior. Do not use that peak as a validated device stress number; characterize it with manufacturer models and bench measurements.

### D. Output-filter comparison — Stage 16

For 470 nF and 8 Ω, the original 22 µH filter has a nominal undamped natural frequency of about 49.5 kHz and Q≈1.18. AC sweep results show about −18.7 dB gain at 150 kHz and about +1.97 dB resonant peaking. The alternatives measured:

| Series L | Approx. natural frequency | Gain at 150 kHz | Maximum peaking, 1–200 kHz |
|---:|---:|---:|---:|
| 22 µH | 49.5 kHz | −18.68 dB | +1.97 dB |
| 56 µH | 31.0 kHz | −27.36 dB | −0.14 dB |
| 68 µH | 28.2 kHz | −29.11 dB | −0.16 dB |

The 68 µH / 470 nF option is the best of these candidates for lower carrier feedthrough and a flat response in this simplified AC test. Stage 18 used it. It still needs inductor saturation/current-rating, DCR, capacitor ripple-current, tolerance, and real-load checks.

### E. Stage 4 low-frequency corner and midpoint clarification — Stage 19

For each potentiometer setting, the AC gain at 1 kHz was used as that setting's reference, and the frequency where gain fell by 3 dB was measured. For x=0.1 through 1.0 in 0.1 steps, the measured low-frequency corners were 1.591, 1.588, 1.582, 1.575, 1.566, 1.558, 1.553, 1.554, 1.565, and 1.592 Hz. Thus the screenshot point at 11.5 Hz / −3.96 dB is not itself the corner; with the modeled values the corner is around 1.6 Hz at every pot position. This is only the small-signal Stage 4 network response.

The source's 6 V reference is the audio/potentiometer midpoint. The 1 µF series coupling capacitor blocks that DC reference before the comparator input, whose separate divider biases it at 2.5 V from the 5 V rail. It is not a 6 V comparator supply.

### F. Design choices and remaining qualification

- **MOSFET:** Prefer IRFB7545 over IRFB7546 for procurement: the product status/lifecycle information favors 7545, while 7546 is discontinued. Both devices are still not qualified by this 150 kHz simplified simulation; manufacturer guidance and actual switching loss must be checked at the intended frequency.
- **Driver:** Do not treat the classic PDIP IR2110 as an unqualified new-design choice; Infineon marks that ordering part not-for-new-design. The IR2104 has internal 520 ns dead time and substantially weaker gate drive; at 150 kHz, 520 ns is 7.8% of the 6.667 µs period and exceeds the 333 ns pulse at 5% duty. Therefore it can clip the narrowest intended pulses. If choosing strictly between the two classic options, IR2110 is the better performance fit only if a suitable active ordering variant is available and the external dead-time design is validated; otherwise choose a currently supported gate driver with adequate source/sink current and suitable dead-time control. The present behavioral IR2110 model cannot qualify an exact purchase suffix.
- **Topology:** Stage 18 remains a one-leg-to-midpoint test. It does not predict BTL speaker power or the behavior of a complete two-leg bridge.
- **Stage 6:** Negative or failed gap measurements were trigger-order artifacts and are superseded by the explicit interpolated Stage 14/15 measurements above.
- **Limitations:** Oscillator op-amp, comparators, driver timing, and MOSFETs are idealized or simplified models. The report's results are screening evidence. Before freezing the BOM/layout, rerun with suitable manufacturer models, the full BTL power stage, realistic parasitics and tolerances, and a controlled low-voltage bench check.

## Additional native LTspice artifacts

- [Stage 16 filter AC comparison](</D:/Class D amplifier/stage16_lc_filter_ac.cir>)
- [Stage 17 integrator oscillator](</D:/Class D amplifier/stage17_integrator_osc.cir>) · [waveforms](</D:/Class D amplifier/stage17_integrator_osc.raw>)
- [Stage 18 full-chain wide sweep](</D:/Class D amplifier/stage18_fullchain_sweep.cir>) · [waveforms](</D:/Class D amplifier/stage18_fullchain_sweep.raw>)
- [Stage 19 low-frequency response sweep](</D:/Class D amplifier/stage19_stage4_lowcut_sweep.cir>)



## Addendum 2: 4-ohm design checks using TLV350x and IRFB7545 candidates (5 October 2026)

No comparator or MOSFET was replaced in these checks. The full-chain models used an ideal comparator transfer and the same simplified IRFB7545 VDMOS card as before; the datasheet checks below assess whether the requested real parts are plausible candidates, not whether LTspice has validated the real devices.

### 8. 4-ohm output filter AC check — Stage 20

**Values:** 33 µH series inductor with 0.15 Ω series resistance, 1 µF shunt capacitor, and 4 Ω load.

| Result | LTspice value |
|---|---:|
| Measured −3 dB frequency relative to 1 kHz passband | 27.80 kHz |
| Gain at 1 kHz | −0.322 dB |
| Gain at 150 kHz | −29.36 dB |
| Maximum gain from 1 kHz to 200 kHz | −0.322 dB |

There was no resonant peaking above the low-frequency passband in this AC model. This supports 33 µH / 1 µF as a 4 Ω candidate; inductor saturation, DCR, capacitor ripple current, tolerance, and layout are still hardware checks.

### 9. 4-ohm full-chain sweep and volume limit — Stages 21, 23, 24, and 29

**Model:** 24 V bus; 12 V IR2110-style behavioral driver; IRFB7545 high/low MOSFETs; integrator oscillator near 150 kHz; 470 pF RC-diode dead-time network; 33 µH / 1 µF filter; 2200 µF series output capacitor with 0.08 Ω ESR; 4 Ω load. The capacitor starts at zero differential voltage, and measured windows are after the transient starts. This is still a one-leg-to-midpoint simulation, not BTL.

Stage 21 with no added input resistor produced 6.786 V RMS at full pot (11.51 W by V²/R) and 2.63 A peak inductor current. That is close to Claude's ~2.5 A estimate and confirms that the unrestricted input can exceed the 7 W target.

The input resistor was placed between the audio source and the top of the 10 kΩ pot. The full-pot resistor sweep measured:

| Added series resistor | Load RMS | Power into 4 Ω |
|---:|---:|---:|
| 0 Ω | 6.786 V | 11.51 W |
| 1.0 kΩ | 6.084 V | 9.25 W |
| 2.0 kΩ | 5.514 V | 7.60 W |
| 2.7 kΩ | 5.167 V | 6.68 W |
| 3.3 kΩ | 4.903 V | 6.01 W |
| 4.7 kΩ | 4.378 V | 4.79 W |

With the output capacitor included, the 2.7 kΩ option measured 5.075 V RMS / 6.44 W at full rotation. The more conservative 3.3 kΩ rerun measured 4.818 V RMS / 5.80 W, leaving about 1.2 W of modeled headroom below the 7 W target. I recommend **3.3 kΩ as the next prototype value** because it provides more margin to source-level and component variation; it is not a substitute for a hardware volume limit if 7 W is a hard rating.

At 3.3 kΩ, the modeled comparator audio input ranged from 2.493–2.507 V at x=0.1 and 1.159–3.839 V at x=1.0. It stayed inside the 0.5–4.5 V triangle span. The 2.1 V simultaneous-gate indicator stayed zero for all ten pot settings. At full volume, peak filter-inductor current was 2.14 A and peak load current was 1.86 A. Bootstrap minimum was about 11.99 V. The 2.7 kΩ Stage 24 results were slightly higher (2.20 A inductor peak); both runs are below the proposed >3 A inductor saturation target in the simplified model.

| Pot x | Load RMS (3.3 kΩ) | V²/4 power | Peak absolute inductor current |
|---:|---:|---:|---:|
| 0.1 | 0.412 V | 0.042 W | 0.682 A |
| 0.2 | 0.430 V | 0.046 W | 0.717 A |
| 0.3 | 0.520 V | 0.068 W | 0.783 A |
| 0.4 | 0.737 V | 0.136 W | 0.876 A |
| 0.5 | 1.068 V | 0.285 W | 0.991 A |
| 0.6 | 1.443 V | 0.520 W | 1.103 A |
| 0.7 | 1.949 V | 0.950 W | 1.311 A |
| 0.8 | 2.716 V | 1.844 W | 1.558 A |
| 0.9 | 3.674 V | 3.375 W | 1.840 A |
| 1.0 | 4.818 V | 5.804 W | 2.141 A |

### 10. THD comparison — Stages 25, 26, and 30

LTspice's first `.FOUR` attempt included substantial carrier residue because the switching carrier was not exactly coherent with the 1 kHz analysis period. The final runs therefore Fourier-analyzed an **analysis-only four-pole RC low-pass** (each section 1 kΩ / 3.3 nF, about 48.2 kHz per pole) connected only to the measurement signal. It attenuates the 150 kHz carrier by about 41 dB and passes the 1–10 kHz harmonic band with less than about 1 dB change. The `.FOUR` results below are model-level audio-band estimates for the first ten harmonics, not hardware THD certification.

| Pot x | 470 pF network | No 470 pF network (diagnostic only) | 2.1 V overlap flag without network |
|---:|---:|---:|---:|
| 0.5 | 1.90% THD | 0.84% THD | 1 (overlap detected) |
| 1.0 | 2.99% THD | 0.25% THD | 1 (overlap detected) |

The no-network numbers are not a safe operating alternative: the model flagged simultaneous gate voltage above 2.1 V in both no-network steps. The 470 pF case had no such modeled overlap. Its higher simulated distortion is consistent with dead-time distortion, but the precise percentage is sensitive to the ideal comparator, simplified MOSFET and driver models, the small output stage, and the measurement filter. Treat it as a comparison signal, not a predicted finished-amplifier specification.

### 11. Output DC-blocking capacitor sweep — Stages 22 and 28

The 2200 µF capacitor was placed in series between the filtered output and the 4 Ω speaker load. The sweep varied only this output capacitor; the 33 µH / 1 µF filter remained in place.

| Series output capacitor | Relative −3 dB low corner | Gain at 20 Hz | Gain at 1 kHz | Gain at 150 kHz |
|---:|---:|---:|---:|---:|
| 2200 µF | 17.11 Hz | −2.87 dB | −0.48 dB | −29.52 dB |
| 3300 µF | 11.40 Hz | −1.71 dB | −0.48 dB | −29.52 dB |
| 4700 µF | 8.01 Hz | −1.13 dB | −0.48 dB | −29.52 dB |
| 6800 µF | 5.53 Hz | −0.81 dB | −0.49 dB | −29.52 dB |

Thus 2200 µF works as a starting model but is down almost 3 dB at 20 Hz into 4 Ω. If the goal is less than 1 dB loss at 20 Hz, 6800 µF is the tested value that meets that target. Its size, ESR, voltage rating, ripple-current rating, and polarity arrangement need checking; the simulated capacitor current at full volume with the 3.3 kΩ resistor was about 1.20 A RMS at 1 kHz and 1.84 A peak. Use a non-polarized capacitor or a suitable back-to-back arrangement unless the real circuit provides a verified DC bias across a polarized capacitor. If the final topology is BTL, revisit the need for an output series capacitor.

The 1 µF shunt filter capacitor current was about 0.29 A RMS and 0.64 A peak at full volume in the switching transient. Select a part with suitable high-frequency ripple rating, not just adequate capacitance and voltage rating.

### 12. Candidate-part checks and remaining limits

**TLV3502 / TLV3501:** TI lists the TLV350x devices for 2.7–5.5 V supply operation, rail-to-rail/beyond-rail input common-mode, and 4.5 ns-class propagation delay. The simulated 5 V rail is in range, and both the 0.5–4.5 V carrier and the measured 1.16–3.84 V maximum-volume audio input sit within that common-mode range. The comparator timing is fast compared with the 6.67 µs carrier period, so the TLV3502 remains a plausible PWM-comparator choice and the TLV3501 remains a plausible oscillator-comparator choice. [TI TLV350x datasheet](https://www.ti.com/lit/ds/symlink/tlv3502.pdf) · [TI TLV3502 product status](https://www.ti.com/product/TLV3502)

These full-chain simulations still use an ideal comparator transfer; they do not contain TI's PSpice macromodel, input offset, overdrive-dependent delay, output loading, or real oscillator comparator loop. Therefore they support keeping the TLV parts on the candidate list but do not qualify their exact behavior on the board. The integrator op-amp itself is also still idealized and not selected.

**IRFB7545:** Keep it as the preferred MOSFET candidate over IRFB7546. The peak-current and duty checks here are consistent with using it at this load and power level, but the VDMOS card is simplified. Infineon's datasheet switching-time figures are measured at 30 V, 57 A, 2.7 Ω gate resistance, and 10 V gate drive; it lists typical rise/fall times of 72/43 ns and typical total gate charge 75 nC (110 nC maximum). A rough datasheet-time estimate at 24 V, 2.14 A peak, and 150 kHz gives around 0.44 W switching loss per MOSFET if peak current is assumed through both edges; average loss should be lower, but the 10 Ω gate resistor and actual driver can lengthen edges. This is only an order-of-magnitude estimate and excludes layout, nonlinear Coss, diode recovery, temperature effects, and measured current waveforms. The diode has nonzero recovery (datasheet typical Qrr 36 nC under its stated 57 A/51 V test), an effect missing from the old simplified model. [Infineon IRFB7545 datasheet](https://www.infineon.com/assets/row/public/documents/24/49/infineon-irfb7545-datasheet-en.pdf)

**Driver:** The bridge runs still use a behavioral IR2110 timing model, not an IR2110 manufacturer macromodel. The model has no explicit output-current limitation and cannot establish the external 470 pF network's performance with the purchased driver's input thresholds. IRFB7545 and TLV350x remain viable candidates in this screen; driver suffix/lifecycle, gate-drive current, dead time, and thermal operation still need a final datasheet/model choice. Do not remove the 470 pF network based on the diagnostic THD comparison.

### New native LTspice files

- [Stage 20 4 Ω filter AC](</D:/Class D amplifier/stage20_4ohm_filter_ac.cir>)
- [Stage 21 unrestricted 4 Ω full-chain sweep](</D:/Class D amplifier/stage21_4ohm_fullchain.cir>)
- [Stage 23 series-resistor sweep](</D:/Class D amplifier/stage23_volume_limit_sweep.cir>)
- [Stage 24 2.7 kΩ 4 Ω volume sweep](</D:/Class D amplifier/stage24_4ohm_limited_sweep.cir>)
- [Stage 27 capacitor-current and THD checks, 3.3 kΩ](</D:/Class D amplifier/stage27_ripple_checks.cir>)
- [Stage 28 output-capacitor AC sweep](</D:/Class D amplifier/stage28_output_cap_sweep.cir>)
- [Stage 29 3.3 kΩ volume-limit sweep](</D:/Class D amplifier/stage29_3k3_limit_sweep.cir>)
- [Stage 30 3.3 kΩ audio-band THD](</D:/Class D amplifier/stage30_3k3_thd.cir>) · [native waveform data](</D:/Class D amplifier/stage30_3k3_thd.raw>)

