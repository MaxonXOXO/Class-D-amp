# LTspice Simulation Models & Full Amplifier Schematics

This directory contains the complete graphical LTspice schematics (`.asc`), extracted netlists (`.net`), simulation logs (`.log`), component symbols (`.asy`), and verified SPICE behavioral macromodels (`.lib`, `.spi`) for the 24V / 4Ω / 10W BTL Class-D Audio Power Amplifier.

## Files Overview

| File | Type | Description |
| :--- | :--- | :--- |
| **`full_amp_10W.asc`** | Schematic | **Primary Golden Schematic**: Tuned for clean 10W continuous sine output into a 4Ω speaker load. Includes input audio buffer, Baxandall tone stack, gain stage, level shifter, 75 kHz carrier generator, differential PWM modulators, dual IR2104 gate drivers, IRFB7545 H-bridge, and LC output filter. |
| **`full_amp_10W.net`** | Netlist | Generated SPICE netlist from `full_amp_10W.asc`. |
| **`full_amp_10W.log`** | Simulation Log | Verification log containing Fourier harmonic decomposition (`.four 1k 9 V(OUT_DIFF)`) showing 7.93% THD, 8.73V peak (9.53W) output, and `I_avg` measurement (84.8% efficiency). |
| **`full amp.asc`** | Schematic | Full development schematic with parametric signal conditioning. |
| **`full amp.log`** | Simulation Log | Simulation log for the parametric development circuit. |
| **`full amp.plt`** | Plot Settings | LTspice waveform viewer layout configuration for multi-pane probing. |
| **`full amp.fft`** | FFT Data | Exported Fourier spectrum analysis dataset. |
| **`IR2104_BEH.asy`** | Symbol | Custom LTspice symbol for the IR2104 half-bridge driver. |
| **`IR2104_LTspice_beh.lib`** | Library | Behavioral macromodel of the IR2104 implementing internal ~520 ns fixed dead time, level shifting, and floating high-side gate drive. |
| **`IRFB7545.asy`** | Symbol | 3-terminal N-channel MOSFET symbol for IRFB7545PbF. |
| **`irfb7545pbf.spi`** | Model | Official Infineon/IR SPICE subcircuit for the 60V, 5.9 mΩ IRFB7545PbF power MOSFET. |
| **`NE5532.asy`** | Symbol | 5-terminal op-amp symbol mapped to SPICE subcircuit pins. |
| **`NE5532.lib`** | Library | Dual low-noise audio operational amplifier simulation macromodel. |
| **`TLV3501.asy`** | Symbol | 6-terminal symbol for the Texas Instruments 4.5 ns comparator with shutdown pin. |
| **`tlv3501.lib`** | Library | Texas Instruments vendor SPICE macromodel for TLV3501. |

## Subcircuit Pin Mapping Reference

When using or referencing these models, note that subcircuit pin orders map to SPICE netlist definitions (not physical dual-in-line IC package pins):

```text
Component     Symbol Value      SPICE Pin Order
----------------------------------------------------------------------
NE5532        NE5532            IN+, IN-, V+, V-, OUT
IR2104_BEH    IR2104_BEH        LO, HO, COM, IN, VCC, VB, VS, NSD
irfb7545pbf   irfb7545pbf       D, G, S
TLV3501       TLV3501           IN+, IN-, SHDN, V+, V-, OUT
```

## Running the Simulation

1. Keep all `.asc`, `.asy`, `.lib`, and `.spi` files together in this directory.
2. In LTspice, open [`full_amp_10W.asc`](full_amp_10W.asc).
3. Ensure the simulation directives are active:
   ```spice
   .include NE5532.lib
   .include IR2104_LTspice_beh.lib
   .include irfb7545pbf.spi
   .include tlv3501.lib
   .options method=gear gmin=1e-9 abstol=1e-9 reltol=0.003 trtol=7
   .tran 0 10m 0 20n startup
   .four 1k 9 V(OUT_DIFF)
   .meas TRAN I_avg AVG I(V6) FROM 1m TO 3m
   ```
4. Run the simulation. Press `Ctrl + L` to view the SPICE error log and examine the Fourier harmonic distortion report.
