# LTspice Simulation Models & Full Amplifier Schematics

This directory contains the complete graphical LTspice schematics (.asc), extracted netlists (.net), simulation logs (.log), component symbols (.asy), and verified SPICE behavioral macromodels (.lib, .spi) for the 24V / 4Ω / 10W BTL Class-D Audio Power Amplifier.

## Files Overview

| File | Type | Description |
| :--- | :--- | :--- |
| **ull_amp_10W_final.asc** | Schematic | **Final Locked Golden Schematic**: Validated 10W continuous sine output into a 4Ω speaker load with R32 (100kΩ) bias stabilization. Features 65 kHz carrier, differential PWM modulators, dual IR2104 gate drivers, IRFB7545 H-bridge, and LC output filter. |
| **ull_amp_10W_final.net** | Netlist | Generated SPICE netlist from ull_amp_10W_final.asc. |
| **ull_amp_10W_final.log** | Simulation Log | Final locked simulation log containing Fourier harmonic decomposition showing 4.71% partial THD, 7.98% total THD, 8.823V peak (9.80W) output, -5.6 mV DC offset, and 84.7% overall efficiency. |
| **ull_amp_10W_final.plt** | Plot Settings | LTspice waveform viewer layout configuration for differential output inspection. |
| **ull_amp_10W.asc** | Schematic | Intermediate 10W validated schematic. |
| **ull_amp_10W.net** | Netlist | Generated SPICE netlist from ull_amp_10W.asc. |
| **ull_amp_10W.log** | Simulation Log | Intermediate simulation log. |
| **ull amp.asc** | Schematic | Full development schematic with parametric signal conditioning. |
| **ull amp.log** | Simulation Log | Simulation log for the parametric development circuit. |
| **ull amp.plt** | Plot Settings | LTspice waveform viewer layout configuration for multi-pane probing. |
| **ull amp.fft** | FFT Data | Exported Fourier spectrum analysis dataset. |
| **IR2104_BEH.asy** | Symbol | Custom LTspice symbol for the IR2104 half-bridge driver. |
| **IR2104_LTspice_beh.lib** | Library | Behavioral macromodel of the IR2104 implementing internal ~520 ns fixed dead time, level shifting, and floating high-side gate drive. |
| **IRFB7545.asy** | Symbol | 3-terminal N-channel MOSFET symbol for IRFB7545PbF. |
| **irfb7545pbf.spi** | Model | Official Infineon/IR SPICE subcircuit for the 60V, 5.9 mΩ IRFB7545PbF power MOSFET. |
| **NE5532.asy** | Symbol | 5-terminal op-amp symbol mapped to SPICE subcircuit pins. |
| **NE5532.lib** | Library | Dual low-noise audio operational amplifier simulation macromodel. |
| **TLV3501.asy** | Symbol | 6-terminal symbol for the Texas Instruments 4.5 ns comparator with shutdown pin. |
| **	lv3501.lib** | Library | Texas Instruments vendor SPICE macromodel for TLV3501. |

## Subcircuit Pin Mapping Reference

When using or referencing these models, note that subcircuit pin orders map to SPICE netlist definitions (not physical dual-in-line IC package pins):

`	ext
Component     Symbol Value      SPICE Pin Order
----------------------------------------------------------------------
NE5532        NE5532            IN+, IN-, V+, V-, OUT
IR2104_BEH    IR2104_BEH        LO, HO, COM, IN, VCC, VB, VS, NSD
irfb7545pbf   irfb7545pbf       D, G, S
TLV3501       TLV3501           IN+, IN-, SHDN, V+, V-, OUT
`

## Running the Simulation

1. Keep all .asc, .asy, .lib, and .spi files together in this directory.
2. In LTspice, open [ull_amp_10W_final.asc](full_amp_10W_final.asc).
3. Ensure the simulation directives are active:
   `spice
   .include NE5532.lib
   .include IR2104_LTspice_beh.lib
   .include irfb7545pbf.spi
   .include tlv3501.lib
   .options method=gear gmin=1e-9 abstol=1e-9 reltol=0.003 trtol=7
   .tran 0 10m 0 20n startup
   .four 1k 9 V(OUT_DIFF)
   .meas TRAN I_avg AVG I(V6) FROM 8m TO 10m
   .meas TRAN Pin AVG -24*I(V6) FROM 8m TO 10m
   .meas TRAN Pout AVG V(OUT_DIFF)*V(OUT_DIFF)/4 FROM 8m TO 10m
   .meas TRAN Eff PARAM Pout/Pin
   `
4. Run the simulation. Press Ctrl + L to view the SPICE error log and examine the Fourier harmonic distortion report.
