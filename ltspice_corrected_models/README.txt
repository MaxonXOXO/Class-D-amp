LTspice model/symbol folder

Keep the .asc schematic and these .asy/.lib/.spi files together, or add this
folder to LTspice's symbol and search paths. In the schematic use relative
directives:

.include NE5532.lib
.include IR2104_LTspice_beh.lib
.include irfb7545pbf.spi
.include tlv3501.lib

Use these symbol values:
  NE5532.asy:       NE5532
  IR2104_BEH.asy:   IR2104_BEH
  IRFB7545.asy:     irfb7545pbf
  TLV3501.asy:      TLV3501

Subcircuit pin orders:
  NE5532:      IN+, IN-, V+, V-, OUT
  IR2104_BEH:  LO, HO, COM, IN, VCC, VB, VS, NSD
  irfb7545pbf: D, G, S
  TLV3501:     IN+, IN-, SHDN, V+, V-, OUT

These are SPICE subcircuit pin orders. They are not the physical IC package
pin numbers. In particular, the NE5532 symbol is one op-amp section for
simulation, while a physical NE5532 is a dual device with package pin numbers.
The IR2104 file here is the LTspice behavioral substitute, not the official
Infineon macromodel. The MOSFET subcircuit is the supplied IRFB7545 model.
