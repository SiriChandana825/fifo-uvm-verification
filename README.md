# FIFO UVM Verification

A complete UVM testbench for a parameterized synchronous FIFO — built as part of a Design Verification portfolio.

## DUT — What it does
A synchronous FIFO with configurable depth (16) and data width (8-bit).
Key outputs: `full`, `empty` flags and `count`. Supports simultaneous read/write protection.

## Testbench Architecture
```
fifo_rand_test / fifo_corner_test
  └── fifo_env
        ├── fifo_agent (ACTIVE)
        │     ├── uvm_sequencer
        │     ├── fifo_driver   ──drives──▶ DUT (sync_fifo)
        │     └── fifo_monitor ◀─samples── DUT
        │           └── analysis_port
        │                 ├──▶ fifo_scoreboard
        │                 └──▶ fifo_coverage
```

## Files
| File | Description |
|------|-------------|
| `rtl/sync_fifo.sv` | Parameterized synchronous FIFO RTL |
| `tb/fifo_seq_item.sv` | UVM transaction class with constraints |
| `tb/fifo_driver.sv` | Drives DUT signals via clocking block |
| `tb/fifo_monitor.sv` | Passively observes DUT outputs |
| `tb/fifo_scoreboard.sv` | SV queue reference model + checker |
| `tb/fifo_coverage.sv` | Functional coverage collector |
| `tb/fifo_agent.sv` | Bundles sequencer, driver, monitor |
| `tb/fifo_env.sv` | Wires agent to scoreboard and coverage |
| `tb/fifo_sequences.sv` | Write, read, random, corner-case sequences |
| `tb/fifo_test.sv` | rand_test and corner_test |
| `tb/fifo_tb_top.sv` | Top module — DUT + interface + UVM kickoff |
| `tb/fifo_sva.sv` | SVA assertions + covergroups |

## How to Run (EDA Playground — free)
1. Go to [edaplayground.com](https://edaplayground.com) and create a free account
2. Paste `rtl/sync_fifo.sv` as the **Design** file
3. Paste `tb/fifo_tb_top.sv` as the **Testbench** file
4. Select **Cadence Xcelium** as simulator · check **Use UVM**
5. Add `+UVM_TESTNAME=fifo_rand_test` to run options
6. Click **Run**

## Tests Available
| Test | Description |
|------|-------------|
| `fifo_rand_test` | 100 constrained-random mixed read/write transactions |
| `fifo_corner_test` | Fill FIFO to full, then drain to empty |

## Results
- Functional coverage: **95%**
- RTL bugs caught by scoreboard: **2**
  - Bug 1: Data corruption on simultaneous read/write
  - Bug 2: `empty` flag asserted one cycle late after final read

## SVA Assertions
- No overflow — write to full FIFO is blocked
- No underflow — read from empty FIFO is blocked
- `full` and `empty` never both asserted simultaneously
- Count increments/decrements by exactly 1 per cycle

## Tools
- Simulator: Cadence Xcelium (EDA Playground)
- Language: SystemVerilog + UVM 1.2
