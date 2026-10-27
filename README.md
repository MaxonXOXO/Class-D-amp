# High-Efficiency 10W Discrete BTL Class-D Audio Power Amplifier

[![Design Status](https://img.shields.io/badge/Design%20Status-Verified%20%26%20Frozen-success.svg)](#simulation-results-summary)
[![Hardware](https://img.shields.io/badge/Hardware-Modular%202--Board%20PCB-success.svg)](#hardware--pcb-implementation-schematics--gerber-files)
[![Gerbers](https://img.shields.io/badge/Gerbers-Fabrication%20Ready-brightgreen.svg)](Schematics%20&%20PCB/)
[![Topology](https://img.shields.io/badge/Topology-BTL%20Full%20H--Bridge-blue.svg)](#architecture-overview)
[![Output Power](https://img.shields.io/badge/Output%20Power-10W%20continuous%20%40%204%CE%A9-orange.svg)](#design-specifications)
[![Supply Voltage](https://img.shields.io/badge/Supply-24V%20Single%20DC%20Bus-yellow.svg)](#design-specifications)
[![Carrier Frequency](https://img.shields.io/badge/Carrier%20Frequency-~65%20kHz%20Linear%20Triangle-purple.svg)](#carrier-frequency-optimization)
[![Simulation Tool](https://img.shields.io/badge/Simulator-LTspice%20XVII%20%2F%2026.x-red.svg)](#ltspice-simulation-guide)

An end-to-end discrete **Class-D audio power amplifier** engineered from first principles, featuring discrete power MOSFETs, dedicated half-bridge gate drivers, active analog front-end signal conditioning, and an optimized LC reconstruction filter. 

This repository contains the complete graphical LTspice schematics, verified component SPICE models, automated parametric sweep scripts, Fourier harmonic analyses, and exhaustive engineering validation reports, and manufacturing-ready PCB fabrication Gerber packages.

---

## Architecture Overview

The amplifier utilizes a fully differential **Bridge-Tied Load (BTL)** topology operating from a single +24 V DC supply. A high-fidelity analog front-end conditions standard consumer audio, level-shifts the signal to single-supply domain, and drives dual complementary high-speed PWM comparators.

```text
               +-------------------------------------------------------------+
               |                  Mobile AUX Input (1 Vrms)                  |
               +-------------------------------------------------------------+
                                              |
                                              v
           +---------------------------------------------------------------------+
           |                 NE5532 Audio Front-End (±12V Rails)                 |
           |  * Input Buffer (Unity-gain non-inverting follower)                 |
           |  * Active Baxandall Tone Control (Bass/Treble ±10 dB adjustment)    |
           |  * Clean Gain Stage (Av = 3.3x / +10.37 dB)                         |
           +---------------------------------------------------------------------+
                                              |
                                              v
           +---------------------------------------------------------------------+
           |                 Volume Control & Biasing Subsystem                  |
           |  * Logarithmic Volume Potentiometer (10 kΩ)                         |
           |  * Passive Attenuator & DC Level Shifter (Biased at +2.5V mid-rail) |
           |  * R32 Bias Stabilization (100kΩ to VREF2V5; DC offset: -5.6 mV)    |
           +---------------------------------------------------------------------+
                                              |
                     +------------------------+------------------------+
                     | (Non-inverted Audio)                            | (Inverted Audio)
                     v                                                 v
   +------------------------------------+            +------------------------------------+
   |   TLV3501 PWM Comparator (Leg A)   |            |   TLV3501 PWM Comparator (Leg B)   |
   | Input: Audio_Biased (+2.5V DC ref) |            | Input: Audio_Inverted (+2.5V ref)  |
   | Carrier: ~65 kHz Triangle (0.5-4.5V|            | Carrier: ~65 kHz Triangle (shared) |
   +------------------------------------+            +------------------------------------+
                     | (PWM_A)                                         | (PWM_B)
                     v                                                 v
   +------------------------------------+            +------------------------------------+
   |   IR2104 Half-Bridge Gate Driver   |            |   IR2104 Half-Bridge Gate Driver   |
   |  * Fixed Dead-Time: ~520 ns        |            |  * Fixed Dead-Time: ~520 ns        |
   |  * Bootstrap Supply: 1 µF + 1N4148 |            |  * Bootstrap Supply: 1 µF + 1N4148 |
   |  * Gate Dampening: 10 Ω            |            |  * Gate Dampening: 10 Ω            |
   +------------------------------------+            +------------------------------------+
          | (HO1)              | (LO1)                      | (HO2)              | (LO2)
          v                    v                            v                    v
   +------------------------------------+            +------------------------------------+
   |    Half-Bridge A (2x IRFB7545)     |            |    Half-Bridge B (2x IRFB7545)     |
   | Supply: 24V DC / 4700 µF Bulk      |            | Supply: 24V DC / 4700 µF Bulk      |
   | RDS(on): 5.9 mΩ per MOSFET         |            | RDS(on): 5.9 mΩ per MOSFET         |
   +------------------------------------+            +------------------------------------+
                     | (Switch Node SW_A)                              | (Switch Node SW_B)
                     v                                                 v
   +------------------------------------+            +------------------------------------+
   |     LC Low-Pass Filter (Leg A)     |            |     LC Low-Pass Filter (Leg B)     |
   | L1 = 18 µH (10 mΩ DCR, 5 kΩ Rpar)  |            | L2 = 18 µH (10 mΩ DCR, 5 kΩ Rpar)  |
   | C11 = 2.2 µF Film Cap to GND       |            | C12 = 2.2 µF Film Cap to GND       |
   +------------------------------------+            +------------------------------------+
                     |                                                 |
                     +-----------------> [ 4 Ω / 10W LOAD ] <----------+
                                       (OUT_A)       (OUT_B)
                                         V_diff = OUT_A - OUT_B
```

---

## Design Specifications

| Parameter | Value | Design Rationale & Implementation |
| :--- | :--- | :--- |
| **Output Topology** | **Bridge-Tied Load (BTL)** | 4-quadrant full H-bridge; eliminates large DC-blocking capacitors; quadruples available power for given bus voltage ($P_{BTL} = 4 \times P_{SE}$). |
| **Nominal Supply ($V_{BUS}$)** | **+24.0 V DC** | Standard commercial 24V (3A - 5A) SMPS brick or battery supply. |
| **Target Power Output** | **10.0 W continuous** | Measured 9.80 W continuous sine across $4\ \Omega$ load with modulation index $m \approx 0.37 - 0.41$. |
| **Load Impedance ($R_L$)** | **4.0 $\Omega$** | Standard automotive/marine/bookshelf speaker impedance. |
| **Carrier Frequency ($f_{SW}$)** | **~65.0 kHz** | **Chosen & Frozen.** Measured ~65 kHz ($R_{18}=15\text{ k}\Omega$, $C_8=278\text{ pF}$) to minimize the dead-time volt-second distortion penalty of the stock IR2104 driver ($520\text{ ns}$). |
| **Gate Driver ICs** | **2x IR2104(S)** | Robust high-voltage half-bridge drivers with internal cross-conduction shoot-through lock and level translation. |
| **Power MOSFETs** | **4x IRFB7545PbF** | N-channel HEXFET, $V_{DSS} = 60\text{ V}$, ultra-low $R_{DS(on)} = 5.9\text{ m}\Omega$, TO-220 package for minimal conduction losses. |
| **Output Filter** | **Dual 18 $\mu$H + 2.2 $\mu$F** | 2nd-order Butterworth LC reconstruction low-pass filter ($f_c \approx 25.2\text{ kHz}$) with parallel damping resistors. |
| **Audio Preamp / Tone** | **NE5532** | Low-noise dual audio operational amplifier configured for input buffering, Baxandall bass/treble boost/cut, and gain scaling. |
| **PWM Comparators** | **2x TLV3501** | 4.5 ns propagation delay rail-to-rail high-speed comparators powered from 5V logic supply. |
| **Carrier Oscillator** | **TLV3501 + NE5532** | Precision analog Schmitt trigger + integrator topology generating a linear 0.5 V to 4.5 V triangle waveform. |

---

## Detailed Signal Chain & Circuit Operation

### 1. Audio Pre-Amplifier & Tone Control (NE5532)
* **Buffer Stage:** An NE5532 section configured as a high input-impedance unity follower isolates source impedance variations from the tone network.
* **Baxandall Active Tone Stack:** Provides independent Bass ($100\text{ Hz}$) and Treble ($10\text{ kHz}$) boost and cut of $\pm 10\text{ dB}$, utilizing linear pots with feedback/feedforward RC networks.
* **Gain Stage:** Non-inverting gain stage set to $A_v = 3.3\times$ ($+10.37\text{ dB}$), elevating typical consumer line-level signals ($1\text{ V}_{rms}$) to the optimum modulation window.

### 2. Level Shifting, Biasing & DC Offset Stabilization
* The audio signal is AC-coupled via a $1\ \mu\text{F}$ capacitor into a resistive divider network tied to the $+5\text{ V}$ logic rail, establishing a $+2.5\text{ V}$ DC virtual ground (`VREF2V5`).
* **R32 (100kΩ, new):** Bias stabilization resistor from `SCALE_IN` to `VREF2V5`. This critical refinement reduced the differential output DC offset from $42.5\text{ mV}$ down to $-5.6\text{ mV}$ with negligible THD penalty.

### 3. Precision Carrier Generator
* A **TLV3501** high-speed comparator serves as a bistable Schmitt trigger with hysteresis set by $12.5\text{ k}\Omega / 15\text{ k}\Omega$ precision resistors.
* The output feeds an **NE5532** constant-current integrator ($R_{18}=15\text{ k}\Omega$, $C_8=278\text{ pF}$, $10\text{ M}\Omega$ DC stabilization feedback).
* The resulting triangle wave swings linearly between $+0.5\text{ V}$ and $+4.5\text{ V}$ at **~65.0 kHz**, exhibiting symmetrical slopes and negligible crest jitter.

### 4. Differential PWM Modulation
* An inverting op-amp stage generates the antiphasic audio signal $V_{audio,B} = 5.0\text{ V} - V_{audio,A}$.
* Two TLV3501 comparators compare the direct and inverted signals against the shared ~65 kHz triangle wave, generating complementary PWM signals `PWM_A` and `PWM_B` with 4.5 ns edge transitions.

### 5. Gate Driver & Dead-Time Protection (IR2104)
* The IR2104 gate driver accepts the 0-5V PWM logic input and drives both high-side and low-side N-channel MOSFET gates.
* **Internal Dead-Time:** Fixed internal dead time ($t_d \approx 520\text{ ns}$ nominal, $400\text{ ns} - 750\text{ ns}$ spread) prevents hazardous H-bridge shoot-through cross-conduction.
* **Bootstrap Circuit:** High-side floating well powered by a fast 1N4148 diode and $1\ \mu\text{F}$ low-ESR ceramic bootstrap capacitor from the $+12\text{ V}$ gate rail.
* **Gate Drive Network:** $10\ \Omega$ gate drive resistor (anti-parallel 1N4148 diodes optional; simulation confirmed external gate diodes cannot shorten internal IR2104 dead time).

### 6. Power Stage (IRFB7545) & LC Reconstruction Filter
* Four discrete IRFB7545 MOSFETs in full H-bridge configuration switch the 24V bus directly into the output filters.
* Conduction losses are virtually negligible due to the $5.9\text{ m}\Omega$ $R_{DS(on)}$ (total loop $R_{DS(on)} = 11.8\text{ m}\Omega$).
* The output low-pass filter on each leg employs an $18\ \mu\text{H}$ high-current toroidal inductor with $10\text{ m}\Omega$ DCR and $5\text{ k}\Omega$ parallel damping, followed by a $2.2\ \mu\text{F}$ metallized film capacitor to GND.
* The differential cutoff frequency is:
  $$f_c = \frac{1}{2\pi \sqrt{L \cdot 2C}} \approx \frac{1}{2\pi \sqrt{18\mu\text{H} \times 4.4\mu\text{F}}} \approx 17.8\text{ kHz}$$
  This effectively attenuates the ~65 kHz carrier while preserving full audio band response ($20\text{ Hz} - 20\text{ kHz}$) with low carrier residual.

---

## Carrier Frequency Optimization & Dead-Time Analysis

A major milestone of this design was resolving the dead-time volt-second distortion penalty of the stock IR2104 driver ($520\text{ ns}$ fixed internal dead time):

| Parameter | 150 kHz (tested) | 200 kHz (tested) | 300 kHz (tested) | ~65 kHz (chosen) |
| :--- | :---: | :---: | :---: | :---: |
| **Partial THD at 10W** | 0.19% (at 1W) | 2.47% | 15.0% | **4.71%** |
| **Total THD** | 1.06% (at 1W) | 2.53% | 15.0% | **7.98%** |
| **Dead-time fraction** | 8% | 10.6% | 16% | **~3.5%** |

*Note: The carrier oscillator stage ($R_{18}=15\text{ k}\Omega, C_8=278\text{ pF}$) produces the chosen $\sim 65\text{ kHz}$ triangle carrier. This keeps the dead-time fraction low ($\sim 3.5\%$) while significantly mitigating volt-second compression and keeping MOSFET switching losses minimal without requiring active heatsinking.*

---

## Verified Simulation Results (`full_amp_10W_final.asc`)

The complete circuit was validated under transient analysis with a 1 kHz sine wave into a $4\ \Omega$ load across 10 ms duration:

![Differential Output Waveform V(OUT_DIFF)](img/v_outdiff.png)

```text
Fourier components of V(OUT_DIFF)
Frequency: 1.000 kHz | Period: 10 ms | Solver: Gear (reltol=0.003)

Harmonic    Frequency       Fourier Component    Normalized Component
  1         1.000 kHz           8.823 V               1.000000
  2         2.000 kHz           0.141 V               0.016000
  3         3.000 kHz           0.061 V               0.006963
  4         4.000 kHz           0.047 V               0.005302
  5         5.000 kHz           0.254 V               0.028780
  7         7.000 kHz           0.283 V               0.032090

Partial Harmonic Distortion: 4.71%   (audio band)
Total Harmonic Distortion:   7.98%   (includes carrier ripple)
DC offset:                  -5.6 mV

Fundamental Output Amplitude:    8.823 V peak  →  6.238 Vrms
Continuous Sine Power Output:    P = Vrms² / R = 9.80 W into 4Ω
Average DC Bus Current:          I_avg = 0.482 A  →  Pin = 11.57 W
Power Stage Overall Efficiency:  η = 9.80 / 11.57 = 84.7%
```

---

## LTspice Simulation Guide

### Prerequisites
1. Download and install **LTspice** (XVII or LTspice 26.x).
2. Clone this repository locally.

### Directory Structure & Models
Keep the schematics and simulation models in the same directory (`ltspice_corrected_models/`) so LTspice resolves all relative `.include` directives:

```text
ltspice_corrected_models/
├── full_amp_10W_final.asc   # Final locked 10W validated Class-D schematic
├── full_amp_10W_final.net   # Extracted SPICE netlist
├── full_amp_10W_final.log   # Simulation log with .four & .meas metrics
├── full_amp_10W_final.plt   # Waveform viewer plot setting configuration
├── full_amp_10W.asc         # Intermediate 10W validated schematic
├── full amp.asc             # Parametric development schematic
├── IR2104_BEH.asy           # Behavioral symbol for IR2104 driver
├── IR2104_LTspice_beh.lib   # Custom behavioral subcircuit (dead-time + UVLO)
├── IRFB7545.asy             # Symbol for IRFB7545 N-MOSFET
├── irfb7545pbf.spi          # Infineon manufacturer SPICE subcircuit
├── NE5532.asy               # Symbol for NE5532 dual audio op-amp
├── NE5532.lib               # High-accuracy NE5532 macromodel
├── TLV3501.asy              # Symbol for TLV3501 4.5ns comparator
├── tlv3501.lib              # Texas Instruments vendor SPICE macromodel
└── README.txt               # Pin ordering and symbol configuration notes
```

### Simulation Instructions
1. Open LTspice.
2. Open [`ltspice_corrected_models/full_amp_10W_final.asc`](ltspice_corrected_models/full_amp_10W_final.asc).
3. Click **Simulate -> Run** (or press the Running Man icon).
4. The simulation runs transient analysis for `10 ms` with Gear integration.
5. Once complete, view the differential output by probing `V(OUT_DIFF) = V(OUT_A) - V(OUT_B)`.
6. Open **View -> SPICE Error Log** (or `Ctrl + L`) to inspect the FFT harmonic report (`.four 1k 9 V(OUT_DIFF)`) and efficiency measurements (`I_avg`).

---

## Hardware & PCB Implementation (Schematics & Gerber Files)

The amplifier hardware is implemented in a **modular two-board topology** to isolate sensitive low-level analog signal processing and modulation circuitry from high-current power switching noise:

| Subsystem Board | Dimensions | Gerber Archive | Key Circuit Blocks |
| :--- | :--- | :--- | :--- |
| **Input Signal & PWM Generator** | ~101 × 67 mm | [`Amp input.zip`](Schematics%20&%20PCB/Amp%20input.zip) | NE5532 input buffer, active Baxandall bass/treble tone stack (±10 dB), gain stage (Av = 3.3x), volume attenuator, +2.5V reference with R32 offset stabilization, ~65 kHz TLV3501+NE5532 triangle oscillator, and dual TLV3501 PWM comparators. |
| **Power Output & LC Filter** | 100 × 80 mm | [`Amp Output.zip`](Schematics%20&%20PCB/Amp%20Output.zip) | Dual IR2104 half-bridge gate drivers with bootstrap networks and internal 520 ns dead-time protection, 4x IRFB7545PbF (5.9 mΩ) MOSFET H-bridge, 24V DC bus bulk decoupling, and dual 18 µH + 2.2 µF Butterworth LC filter. |

* Complete layer previews, manufacturing specifications (1.6 mm FR-4, 1-2 oz copper), drill definitions, and ordering instructions are documented in [`Schematics & PCB/README.md`](Schematics%20&%20PCB/README.md).
* Previews of PCB copper routing and silkscreen: [`PCB 1.png`](Schematics%20&%20PCB/PCB%201.png), [`PCB 2.png`](Schematics%20&%20PCB/PCB%202.png), [`PCB-1.png`](Schematics%20&%20PCB/PCB-1.png), [`PCB-2.png`](Schematics%20&%20PCB/PCB-2.png).

---

## Repository File Map

* [`Schematics & PCB/`](Schematics%20&%20PCB/): Production PCB Gerber archives ([`Amp input.zip`](Schematics%20&%20PCB/Amp%20input.zip), [`Amp Output.zip`](Schematics%20&%20PCB/Amp%20Output.zip)), [hardware documentation](Schematics%20&%20PCB/README.md), and high-resolution layout preview images.
* [`img/`](img/): Waveform plots and simulation graph captures ([`v_outdiff.png`](img/v_outdiff.png)).
* [`ltspice_corrected_models/`](ltspice_corrected_models/): Complete graphical schematics (`full_amp_10W_final.asc`), custom component symbols (`.asy`), and corrected SPICE models (`.lib`, `.spi`).
* [`simulations/`](simulations/): Over 300 parametric netlists (`.cir`), automated PowerShell sweep scripts (`.ps1`), logs (`.log`), and raw measurement datasets covering screening stages 1 through 41.
  * [`final_ir2104_test.cir`](simulations/final_ir2104_test.cir): Final validated standalone BTL test netlist.
  * [`classd_stage41.ps1`](simulations/classd_stage41.ps1): Automated parametric sweeper for power, THD, and filter ripple.
* [`docs/`](docs/): Comprehensive engineering reports:
  * [`final_validation_inference_report.md`](docs/final_validation_inference_report.md): Parametric validation of IR2104 dead time, carrier frequency optimization, and tolerance bounds.
  * [`simulation_inference_report.md`](docs/simulation_inference_report.md): In-depth retrospective covering stages 1 through 30.

---

## Bill of Materials (Key Active & Passive Components)

| Reference Designator | Component / Part Number | Description / Package | Function |
| :--- | :--- | :--- | :--- |
| **U1, U2, U3, U5, U6** | **NE5532P** | Dual Low-Noise Audio Op-Amp (DIP-8 / SOIC-8) | Input buffer, tone control, gain, and carrier integrator |
| **U4, U7, U8** | **TLV3501 / TLV3502** | 4.5 ns High-Speed Rail-to-Rail Comparator (SOIC-8) | Triangle Schmitt oscillator and dual differential PWM generators |
| **U9, U10** | **IR2104PBF** | Half-Bridge Gate Driver (DIP-8 / SOIC-8) | High/low side MOSFET gate driving with 520ns internal dead-time |
| **U11, U12, U13, U14**| **IRFB7545PbF** | 60V, 5.9 mΩ N-Channel HEXFET (TO-220) | Output H-Bridge switching power stage |
| **L1, L2** | **18 $\mu$H / 10A** | High-Current Toroidal Inductor ($R_{DCR} \le 15\text{ m}\Omega$) | Output reconstruction low-pass filter inductor |
| **C11, C12** | **2.2 $\mu$F / 63V** | Metallized Polypropylene Film Capacitor (MKP/MKT) | Output reconstruction filter shunt capacitor |
| **C9, C10** | **1.0 $\mu$F / 25V** | Ceramic X7R / Film (1206 / Radial) | High-side gate driver bootstrap capacitor |
| **D1, D2** | **1N4148 / 1N5819** | Fast recovery / Schottky diode | High-side gate driver bootstrap charge pump diodes |
| **D3, D4, D5, D6** | **1N4148 (Optional)** | Fast recovery diode | Anti-parallel gate diodes. Tested in simulation; found not to reduce THD, as the IR2104's 530 ns dead time is internal and cannot be shortened by external gate circuitry. Retained in BOM as optional; omit for cost and simplicity. |
| **R32** | **100 k$\Omega$** | Precision Resistor (0.1% or 1%) | Bias stabilization resistor from `SCALE_IN` to `VREF2V5`. Reduced output DC offset from 42.5 mV to 5.6 mV with negligible THD penalty. |
| **Cbulk** | **4700 $\mu$F / 35V**| Low-ESR Aluminum Electrolytic | 24V bus bulk decoupling and ripple reservoir |

---

## License & Attribution

Designed and engineered by [MaxonXOXO](https://github.com/MaxonXOXO).  
Open-source under the [MIT License](LICENSE) - free for educational, DIY, and commercial adaptation with appropriate attribution.
