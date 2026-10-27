# Schematics & PCB Design Layouts

This directory contains the production-ready Printed Circuit Board (PCB) designs, fabrication Gerber packages, schematic captures, and layer render previews for the **High-Efficiency 10W Discrete BTL Class-D Audio Power Amplifier**.

The hardware is designed as a **modular two-board architecture** separating the sensitive small-signal analog/PWM modulation circuitry from the high-current power switching and output filtering stage. This topology significantly isolates low-level audio from switching EMI and high-frequency ground bounce.

---

## Architecture: Modular 2-Board Design

| Board Subsystem | Fabrication Archive | Dimensions | Description |
| :--- | :--- | :--- | :--- |
| **Input Signal & PWM Generator** | [`Amp input.zip`](Amp%20input.zip) | ~101 mm × 67 mm | Analog input buffer, Baxandall bass/treble tone control, non-inverting gain stage, ~65 kHz triangle carrier generator, and dual high-speed differential PWM comparators. |
| **Power Output & Filter Stage** | [`Amp Output.zip`](Amp%20Output.zip) | 100 mm × 80 mm | Dual IR2104 half-bridge gate drivers with bootstrap networks, 4x discrete IRFB7545 N-MOSFET full H-bridge, 24V bus bulk decoupling, and dual 18 µH + 2.2 µF LC reconstruction filter. |

---

## 1. Input Board (`Amp input.zip`)

### Circuit Blocks Included
1. **Audio Input Buffer & Pre-amplifier:** Low-noise NE5532 unity-gain buffer for input impedance isolation.
2. **Active Baxandall Tone Control:** Independent Bass (100 Hz) and Treble (10 kHz) adjustment ($\pm 10\text{ dB}$).
3. **Gain Stage:** Non-inverting operational amplifier stage ($A_v \approx 3.3\times / +10.37\text{ dB}$).
4. **Volume & Biasing:** Logarithmic attenuation potentiometer and virtual ground level shifter (`VREF2V5` at +2.5V DC) stabilized by $R_{32}$ ($100\text{ k}\Omega$).
5. **Carrier Generator:** Precision TLV3501 Schmitt trigger oscillator paired with an NE5532 constant-current integrator producing a symmetrical ~65 kHz triangle waveform.
6. **Differential PWM Modulator:** Dual TLV3501 ultra-fast comparators (4.5 ns propagation delay) generating complementary `PWM_A` and `PWM_B` switching commands.

### Included Gerber Files
* `Gerber_TopLayer.GTL` — Top copper routing & ground fill
* `Gerber_BottomLayer.GBL` — Bottom copper signal & power traces
* `Gerber_TopSilkscreenLayer.GTO` — Component designators & polarities
* `Gerber_TopSolderMaskLayer.GTS` — Top solder mask openings
* `Gerber_BottomSolderMaskLayer.GBS` — Bottom solder mask openings
* `Gerber_BoardOutlineLayer.GKO` — Physical board perimeter (~101 mm × 67 mm)
* `Gerber_DocumentLayer.GDL` — Fabrication drawings
* `Drill_PTH_Through.DRL` — Plated component through-holes
* `Drill_PTH_Through_Via.DRL` — Inter-layer stitch vias

---

## 2. Power Output Board (`Amp Output.zip`)

### Circuit Blocks Included
1. **Gate Drivers:** Dual IR2104 half-bridge drivers featuring ~520 ns internal dead-time protection and fast recovery 1N4148 bootstrap diode pumps.
2. **H-Bridge Power Stage:** Four IRFB7545PbF 60V, 5.9 mΩ N-channel MOSFETs in TO-220 packages with heavy copper trace widths for low conduction losses.
3. **LC Reconstruction Filter:** Dual high-current 18 µH toroidal inductors and 2.2 µF metal film capacitors ($f_c \approx 17.8\text{ kHz}$) to reconstruct continuous analog output and suppress carrier hash.
4. **Power & Speaker Terminals:** Heavy-duty screw terminals for +24V DC input, logic supply header, and differential 4Ω speaker output (`OUT_A` / `OUT_B`).

### Included Gerber Files
* `Gerber_TopLayer.GTL` — High-current switching power planes
* `Gerber_BottomLayer.GBL` — Star ground return & low-side routing
* `Gerber_TopSilkscreenLayer.GTO` — Power terminal labels & component markings
* `Gerber_TopSolderMaskLayer.GTS` — Top solder mask
* `Gerber_BottomSolderMaskLayer.GBS` — Bottom solder mask
* `Gerber_BoardOutlineLayer.GKO` — Board perimeter (100 mm × 80 mm)
* `Gerber_MechanicalLayer.GME` — Mechanical clearance and mounting holes
* `Gerber_DocumentLayer.GDL` — Manufacturing notes
* `Drill_PTH_Through.DRL` — Plated holes for TO-220, terminals, filter inductors
* `Drill_PTH_Through_Via.DRL` — High-current thermal/power vias

---

## Recommended PCB Fabrication Specifications

| Parameter | Recommended Specification |
| :--- | :--- |
| **Layers** | 2 Layers |
| **Material** | FR-4 Standard ($T_g \ge 130-140^\circ\text{C}$) |
| **Board Thickness** | 1.6 mm |
| **Finished Copper Weight** | **1 oz (35 µm)** for Input Board; **1 oz or 2 oz (70 µm)** recommended for Output Board |
| **Surface Finish** | HASL with lead / Lead-Free HASL / ENIG |
| **Solder Mask** | Matte Black, Green, or Blue |
| **Silkscreen** | White |
| **Min Trace / Clearance** | 6 mil / 6 mil (0.152 mm) |
| **Min Hole Size** | 0.3 mm (via) |

---

## How to Order from PCB Manufacturers

The `.zip` files in this directory are directly uploadable to standard PCB manufacturing services (JLCPCB, PCBWay, OSH Park, NextPCB, etc.):

1. Download [`Amp input.zip`](Amp%20input.zip) and [`Amp Output.zip`](Amp%20Output.zip).
2. Go to your preferred PCB manufacturing portal (e.g. [JLCPCB Quote](https://cart.jlcpcb.com/quote)).
3. Click **Add Gerber file** and upload the respective `.zip` file.
4. Confirm the auto-detected dimensions (Input: ~101×67 mm; Output: 100×80 mm).
5. Select 2-layer, 1.6 mm thickness, and your preferred solder mask color.
6. For the Output board, 2 oz copper is recommended if running sustained 10W into 4Ω for long durations.
7. Save to cart and submit.

---

## Visual PCB Layout Previews

The preview renderings in this folder provide visual verification of the traces, ground pours, component placements, and mechanical dimensions:

* **Top & Bottom Layer Routing:** [`PCB 1.png`](PCB%201.png), [`PCB 2.png`](PCB%202.png)
* **Silkscreen & Pad Geometry:** [`PCB-1.png`](PCB-1.png), [`PCB-2.png`](PCB-2.png)
* **Detailed Board Revisions:** [`PCB-1(2).png`](PCB-1(2).png), [`PCB-1(3).png`](PCB-1(3).png), [`PCB-2(2).png`](PCB-2(2).png), [`PCB-2(3).png`](PCB-2(3).png)
