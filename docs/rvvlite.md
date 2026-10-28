# rvvlite_top: PicoRV32 + RVV-lite VPU on sky130hd

`rvvlite_top` is the SoC from my undergraduate thesis (PicoRV32 with an RVV-lite
vector coprocessor on the PCPI interface, originally on a Nexys A7 FPGA), adapted
for an ASIC flow. It closes timing at 10 ns (100 MHz) with a clean KLayout DRC.

## Changes from the FPGA top

| FPGA `top.v` | ASIC `rvvlite_top.v` | Why |
| --- | --- | --- |
| 64 KiB RAM loaded with `$readmemh` | Removed; one external memory port `ext_mem_*` | 524 288 bits would become flip-flops without a memory macro |
| UART, GPIO, address decoding | Removed | They belong outside the core, on the memory map |
| Bus arbiter with `lsu_valid_prev` | Kept unchanged | The VPU load/store unit depends on it |
| Reset synchronizer with `rst_ff = 4'h0` | Same synchronizer, no initial value | Flip-flops have no power-up value in silicon |
| `REGS_INIT_ZERO = 1` | `REGS_INIT_ZERO = 0` | Same reason |
| `initial` loop clearing `vreg` in `vpu_alu.v` | Removed in this copy only (5 lines) | Same reason; firmware must write a vector register before reading it |

All other RTL files are identical to the thesis repository (checked with `diff`).
Port contract: `ext_mem_ready` arrives at least one cycle after `ext_mem_valid`,
one pulse per transaction, as the original block RAM did.

## Cost of the VPU (synthesis only, 20 ns clock)

`pico_solo_top` is the same PicoRV32 configuration with `ENABLE_PCPI = 0`, so the
difference measures the VPU, the PCPI interface and the arbiter.

| | PicoRV32 only (`pico_s20`) | PicoRV32 + VPU (`rvvlite_s20`) |
| --- | --- | --- |
| Total area (um2) | 80 717 | 260 823 |
| Sequential area (um2) | 43 492 | 93 900 |
| Flip-flops | 1536 | 3256 |
| Cells | 5925 | 23 595 |

The VPU is 69 % of the synthesized area, mostly combinational logic: four 32 x 32
multipliers (one per lane), a 128-bit ALU and the read and write multiplexers of
the 8 x 128-bit vector register file.

## Full flow

| | `rvvlite_s20` | `rvvlite_s10` |
| --- | --- | --- |
| Clock period | 20 ns | 10 ns (100 MHz) |
| Worst setup slack | +10.25 ns | +0.80 ns |
| WNS / TNS | 0.00 / 0.00 | 0.00 / 0.00 |
| Router violations | 0 | 0 |
| Antenna violations | 0 | 0 |
| Final logic equivalence | IDENTICAL | IDENTICAL |
| Final cell area (um2) | 285 086 | 286 896 |
| KLayout DRC, ORFS runset | not run | 0 |
| Runtime | 28.6 min | 42.8 min |

In both runs the critical path goes from a VPU operand register through a
multiplier into the vector register file (`op_b_r[10]` to `vreg[1][28]` at 10 ns).
Wire delays on it are 0.00 to 0.01 ns, so the minimum period is set by logic
depth, not by placement. The synthesized netlist is identical at both periods;
the 0.55 ns gained at 10 ns comes from timing repair after CTS. A much shorter
period would need a pipelined multiplier.

The KLayout runset shipped with ORFS checks BEOL and off-grid rules; FEOL rules
are disabled in it, so this is not a foundry signoff. LVS was not run.
