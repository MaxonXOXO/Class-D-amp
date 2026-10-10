# 24V / 4Ω / 10W BTL Class-D Audio Amplifier

Engineering design, LTspice simulations, and parametric validation for a high-efficiency Class-D audio amplifier built around discrete MOSFETs and standard gate drivers.

---

## Architecture Overview

```text
Mobile Phone AUX (1 Vrms)
       │
       ▼
 NE5532 Audio Front-End (±12 V)
  ├── Input Buffer (Unity gain follower)
  ├── Baxandall Active Tone Control (Bass/Treble ±10 dB)
  └── Non-Inverting Gain Stage (Av = 3.3x / +10.37 dB)
       │
       ▼
 Volume Control & Passive Attenuator (Biased at +2.5 V DC)
       │
       ├─────────────────────────────────────┐
       ▼                                     ▼
 TLV3502 PWM Comparator (Leg A)        TLV3502 PWM Comparator (Leg B)
  Input: Non-inverted Audio             Input: Inverted Audio (5 - V_audio)
  Carrier: 0.5 - 4.5 V Triangle         Carrier: 0.5 - 4.5 V Triangle (shared)
       │ (Single-ended PWM A)                │ (Single-ended PWM B)
       ▼                                     ▼
 IR2104 Half-Bridge Driver A           IR2104 Half-Bridge Driver B
  Internal Dead Time: ~530 ns           Internal Dead Time: ~530 ns
  Bootstrap: Dfast + 220 nF             Bootstrap: Dfast + 220 nF
  Gate Resistors: 10 Ω                  Gate Resistors: 10 Ω
       │ (HO_A, LO_A)                        │ (HO_B, LO_B)
       ▼                                     ▼
 Half-Bridge A (2x IRFB7545)           Half-Bridge B (2x IRFB7545)
  Supply: 24 V DC Bus                   Supply: 24 V DC Bus
  Bulk Decoupling: 4700 µF              Bulk Decoupling: 4700 µF
       │ (Switch Node swA)                   │ (Switch Node swB)
       ▼                                     ▼
 Output Filter Leg A                   Output Filter Leg B
  Series Inductor: 18 µH / 22 µH        Series Inductor: 18 µH / 22 µH
  Shunt Capacitor: 2.2 µF to GND        Shunt Capacitor: 2.2 µF to GND
       │                                     │
       └──────────────┬──────────────────────┘
                      ▼
             4 Ω / 10 W Speaker (BTL)
```

---

## Design Specifications

* **Topology:** Bridge-Tied Load (BTL / Full H-Bridge)
* **Supply Voltage:** 24 V DC nominal (24 V, 3 A - 5 A SMPS)
* **Output Power:** 10 W continuous into 4 Ω
* **Modulation Depth:** $m \approx 0.37 - 0.41$
* **Carrier Frequency:** **75 kHz** (selected over 100 kHz to match IR2104 dead-time physics)
* **Gate Driver:** IR2104 (520 ns fixed dead time, dual DIP-8 / SOIC-8)
* **Power MOSFETs:** 4× IRFB7545PbF (60 V, 5.9 mΩ $R_{DS(on)}$, TO-220)
* **Output Filter:** Filter B (18 µH + 2.2 µF) or Filter C (22 µH + 2.2 µF)
* **Front-End Preamp:** NE5532 (Active Baxandall tone + gain stage)
* **PWM Comparators:** TLV3502 (4.5 ns high-speed dual comparator, 5 V supply)
* **Carrier Oscillator:** TLV3501 (0.5 V to 4.5 V linear triangle)

---

## Simulation Results Summary (BTL / 24 V / 4 Ω)

| Carrier Frequency | Dead Time | Output Power | Audio THD | Peak Inductor Current | Diff. Carrier Ripple | Status |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **75 kHz** | **530 ns (Nominal)** | **8.26 W** (scales to 10 W at $m=0.41$) | **7.14%** | **4.07 A** | **0.76 V pk-pk** | **RECOMMENDED & FROZEN** |
| 75 kHz | 400 ns (Min) | 8.67 W | 6.02% | 4.13 A | 0.76 V pk-pk | Pass |
| 75 kHz | 750 ns (Max) | 7.43 W | 9.00% | 3.97 A | 0.76 V pk-pk | Pass |
| 100 kHz | 530 ns (Nominal) | 5.27 W | 13.58% | 3.09 A | 0.40 V pk-pk | High THD / Power Loss |
| 100 kHz | 750 ns (Max) | 4.20 W | 14.01% | 2.95 A | 0.40 V pk-pk | Severe Degradation |

---

## Repository Structure

* `docs/`: Technical engineering reports, design notes, and stage-by-stage inference summaries.
  * [`final_validation_inference_report.md`](docs/final_validation_inference_report.md): Final parametric validation of IR2104 dead-time and carrier frequency selection.
  * [`simulation_inference_report.md`](docs/simulation_inference_report.md): Comprehensive review of earlier screening stages (1 through 30).
* `simulations/`: Parametric LTspice netlists (`.cir`), automated execution scripts (`.ps1`), measurement logs (`.log`), and sweep data (`.csv`).
  * `final_ir2104_test.cir`: Final validated BTL test netlist with IR2104 timing.
  * `classd_stage41.ps1`: Automated parametric sweeper for power, THD, and filter ripple.
  * `stage40_*.cir`: Full-chain simulation netlists including audio front-end and level shifter.
* `ltspice_corrected_models/`: Complete graphical schematic (`full amp.asc`), component symbols (`.asy`), and corrected SPICE simulation models (`.lib`, `.spi`) for the full Class-D amplifier.
