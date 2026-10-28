# asic-openflow-sky130

RTL-to-GDSII experiments with open-source tools (OpenROAD-flow-scripts, Yosys,
OpenROAD, KLayout) on the SkyWater 130 nm PDK, high-density library (sky130hd).

## Status

| Design | Description | Result |
| --- | --- | --- |
| gcd | ORFS example design | GDSII; timing closed at 3.2 ns; 0 router violations |
| rvvlite_top | PicoRV32 + RVV-lite vector coprocessor (my own VPU, from my undergraduate thesis), memory as external port | GDSII; timing closed at 10 ns (100 MHz); 0 router violations; KLayout DRC 0 (ORFS runset, BEOL + off-grid); 0 antenna violations; LEC identical |
| MCL86 | 8086-compatible core by MicroCore Labs | Synthesized (119 327 um2); global route fails on congestion; no GDSII |

Independent DRC means the KLayout runset shipped with ORFS for sky130hd, not a
foundry signoff deck. LVS is not done yet.

## Repository layout (in progress)

- `designs/src/<design>/` - RTL used for each design
- `designs/sky130hd/<run>/` - `config.mk` and `constraint.sdc` for each run
- `reports/<run>/` - curated extracts of synthesis, timing, routing and DRC reports
- `docs/` - notes and analysis
- `scripts/` - helpers to copy designs into an ORFS checkout

## Environment

Windows with WSL2 (Ubuntu 24.04), ORFS run inside Docker (`openroad/orfs` image)
through `util/docker_shell`. ORFS itself is not included in this repository.

## Third-party code

`picorv32.v` is copyright Claire Xenia Wolf and distributed under its original
ISC-style license; its header is kept unchanged.
