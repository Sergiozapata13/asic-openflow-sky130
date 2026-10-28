# gcd: clock period sweep on sky130hd

The ORFS example `gcd` (about 250 cells) was run at three clock periods to learn
the flow. Only `clk_period` changes between runs.

| Run | Configuration | Period | WNS (ns) | TNS (ns) | Router violations | Timing closed |
| --- | --- | --- | --- | --- | --- | --- |
| `gcd` | ORFS stock `flow/designs/sky130hd/gcd` (not copied) | 1.1 ns | -1.40 | -62.69 | 0 | No |
| `gcd_t28` | `designs/sky130hd/gcd_t28` | 2.8 ns | -0.09 | -0.10 | 0 | No |
| `gcd_t32` | `designs/sky130hd/gcd_t32` | 3.2 ns | 0.00 | 0.00 | 0 | Yes, worst slack +0.03 ns |

All three runs produced a GDSII: the flow finishing is not the same as timing
closing. At 1.1 ns the critical path (`b_reg` to `a_reg`) needed about 2.5 ns.
At 2.8 ns the failing path ended at the output port `resp_msg`, which carries an
I/O delay of 20 % of the period. Periods between 2.8 and 3.2 ns were not tried.

The RTL (`gcd.v`) belongs to ORFS (derived from the OpenCelerity project) and is
not copied here; the configurations reference it as `$(DESIGN_HOME)/src/gcd/gcd.v`.
Extracts of each run, including layout images, are in `reports/<run>/`.
