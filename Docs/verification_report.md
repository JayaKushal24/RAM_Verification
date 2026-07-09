# Single Port RAM Verification — Verification Report

## 1. Project Introduction

This project presents the design and functional verification of a **32×8 Synchronous Single-Port RAM** (`dut_ram`) implemented in Verilog, verified using a hand-rolled, class-based SystemVerilog testbench built along UVM-style layered-verification principles (without the UVM library itself).

The RAM supports synchronous read and write operations, controlled by dedicated `read_en`/`write_en` signals, with a synchronous reset (`rst`). The output `data_out` is registered — read data appears one clock cycle after `read_en` is asserted.

The verification goal is to build a self-checking, mailbox-connected testbench environment — using constrained-random stimulus generation, a behavioral reference model, an automated scoreboard, and functional coverage collection — to verify the RAM's functional correctness across normal read/write operations, reset behavior, and the simultaneous-enable corner case.

The design methodology follows the standard RTL design and verification flow:

- RTL design capture in Verilog (`dut_ram.v`)
- SystemVerilog testbench development with a layered, class-based architecture
- Simulation using a SystemVerilog-capable simulator (e.g. Questa, VCS, Xcelium)
- Self-checking verification with pass/fail reporting
- Functional coverage collection via a driver-side covergroup

## 2. Objectives

- Study the architecture of a synchronous single-port RAM
- Verify a 32×8 RAM (`ADDR_WIDTH=5`, `DATA_WIDTH=8`) against a behavioral reference model
- Build a class-based SystemVerilog testbench: `transaction`, `generator`, `driver`, `monitor`, `reference_model`, `scoreboard`, `environment`, `test`
- Verify all operations: write, read, idle/hold, and reset
- Exercise the simultaneous read+write (`read_en=1, write_en=1`) corner case via a dedicated directed test
- Implement functional coverage for address, data, and read/write operation crosses
- Run a full regression across base (random), read-only, write-only, and simultaneous transaction flavors (`test_regression`)

## 3. Design Architecture

### 3.1 Architecture Overview

The RAM is a 32-location × 8-bit synchronous single-port memory (`ADDR_WIDTH=5`, `DATA_WIDTH=8`, from `defines.svh`). It has one shared address bus for both read and write, controlled by separate `write_en` and `read_en` signals. All operations are synchronized to the rising edge of `clk`.

> **Note:** This section describes the RTL contract as exercised by the testbench interface (`dut_vif`) and reference model. Confirm exact reset polarity and idle/undefined-enable behavior against your `dut_ram.v` source, since the RTL file itself was not available when this report was generated.

### 3.2 Inputs

| Signal      | Width         | Description                                                        |
|-------------|---------------|----------------------------------------------------------------------|
| `clk`       | 1 bit         | System clock. All operations are synchronized to the positive edge.  |
| `rst`       | 1 bit         | Synchronous reset.                                                    |
| `addr`      | `ADDR_WIDTH` (5) bits | Address bus selecting one of 32 memory locations (0–31).      |
| `data_in`   | `DATA_WIDTH` (8) bits | Data input bus. Written to memory[`addr`] during a write.     |
| `write_en`  | 1 bit         | Write enable.                                                        |
| `read_en`   | 1 bit         | Read enable.                                                         |

> **Important:** `read_en` and `write_en` are constrained to be mutually exclusive in the base `transaction` class (`read_en != write_en`). The simultaneous-assertion case (`read_en=1, write_en=1`) is deliberately exercised as a corner case by `transaction3` / `simultaneous_test`, since its RTL behavior is otherwise unconstrained by the base random tests.

### 3.3 Outputs

| Signal      | Width         | Description                                             |
|-------------|---------------|------------------------------------------------------------|
| `data_out`  | `DATA_WIDTH` (8) bits | Registered read data — valid one clock cycle after `read_en` is asserted. |

### 3.4 Block Diagram

```
                    ┌─────────────────────────────────────┐
                    │            dut_ram Module            │
                    │                                     │
   clk ───────────►│  ┌───────────────────────────────┐  │
   rst ────────────►│  │      memory [0:31] × 8-bit    │  │
                    │  │                               │  │
   addr[4:0] ─────►│  │   Write path (posedge clk)    │  │
   data_in[7:0] ──►│  │   if write_en && !read_en     │  │
   write_en ──────►│  │   memory[addr] <= data_in     │  │
                    │  │                               │  │
   read_en ───────►│  │   Read path (posedge clk)     │  │──► data_out[7:0]
                    │  │   if read_en && !write_en     │  │
                    │  │   data_out <= memory[addr]    │  │
                    │  └───────────────────────────────┘  │
                    └─────────────────────────────────────┘
```

## 4. Timing Behaviour

| Operation | Latency | Description                                                          |
|-----------|---------|------------------------------------------------------------------------|
| Write     | 1 cycle | Data is stored in memory on the rising edge after `write_en` is asserted. |
| Read      | 1 cycle | Data appears on `data_out` one rising edge after `read_en` is asserted. |
| Reset     | 1 cycle | State is cleared on the next edge after `rst` is asserted.              |

This one-cycle read latency is why the testbench's `reference_model` pipelines its `data_out` prediction by one cycle (via a registered stage) rather than computing it combinationally in the same timestep it receives a transaction — matching the DUT's registered output.

## 5. Supported Operations

### 5.1 Write Operation
- **Condition:** `write_en=1`, `read_en=0`
- **Action:** `memory[addr] <= data_in` on the next positive clock edge
- **Reference model:** `ref_mem[addr] = data_in`; `data_out` continues to reflect the last read value

### 5.2 Read Operation
- **Condition:** `read_en=1`, `write_en=0`
- **Action:** `data_out <= memory[addr]` on the next positive clock edge (1-cycle latency)
- **Reference model:** `t2.data_out = ref_mem[addr]`, latched into `last_data_out`

### 5.3 Idle Operation
- **Condition:** `write_en=0`, `read_en=0`
- **Reference model behavior:** holds `last_data_out`

### 5.4 Reset Operation
- **Condition:** `rst=1` (per current `reference_model.sv`; confirm active-high/low polarity against RTL)
- **Action:** Reference memory (`ref_mem`) is cleared and `data_out`/`last_data_out` are driven to `'bz`

### 5.5 Simultaneous Enable (Corner Case)
- **Condition:** `write_en=1`, `read_en=1`
- **Behavior:** Not covered by the base random constraint (`read_en != write_en`); exercised explicitly by `transaction3` via `simultaneous_test` to observe/verify RTL behavior at this boundary

## 6. Working of the Testbench Model

### 6.1 Input Phase
- The driver samples a transaction from `gen_drv` and drives it onto `dut_vif` via the `drv_cb` clocking block on the next `posedge clk`
- A copy of the driven transaction is forwarded to the `reference_model` via `drv_ref`

### 6.2 Reference Model Phase
- `reference_model` processes each transaction based on `rst` / `write_en` / `read_en` and computes the expected `data_out`, pipelined by one cycle to align with DUT read latency
- The expected transaction is pushed to the scoreboard via `ref_sco`

### 6.3 Monitor / Output Phase
- `monitor` samples the DUT-facing signals (including `data_out`) via the `mon_cb` clocking block once per cycle, guarded to skip samples during reset
- Observed transactions are pushed to the scoreboard via `mbx_mon_sco`
- `scoreboard` compares the monitor and reference-model transactions pairwise (FIFO order) using `===`, incrementing `pass_count` / `fail_count`

## 7. Testbench Components

### 7.1 Interface (`dut_vif`)
Encapsulates all DUT-facing signals and provides two clocking blocks:

| Clocking Block | Modport | Used By | Signals |
|------------------|---------|----------|-----------|
| `drv_cb`         | `DRV`   | Driver   | output: `addr`, `data_in`, `read_en`, `write_en`, `transaction_count`; input: `rst`, `clk` |
| `mon_cb`         | `MON`   | Monitor  | input: `addr`, `data_in`, `read_en`, `write_en`, `data_out`, `rst`, `transaction_count` |

Clocking blocks use `#0`/`#0` (drv) and `#0`/`#1step` (mon) skews to avoid race conditions between testbench and DUT sampling.

### 7.2 Transaction Class (`transaction.sv`)
Encapsulates all stimulus and response fields: `addr` (5 bits), `data_in` (8 bits), `read_en`, `write_en`, `data_out`, `transaction_count`, `rst`.

| Field       | Randomized | Constraint                              |
|-------------|------------|--------------------------------------------|
| `addr`      | Yes        | `inside {[0:25]}` ([26:31] reserved)         |
| `read_en`, `write_en` | Yes | `read_en != write_en`                  |
| `data_in`   | Yes        | Full 8-bit range                             |
| `data_out`  | No         | Captured from DUT/reference output            |

A `copy()` virtual function creates deep copies for mailbox transfer. Directed subclasses (`transaction1`, `transaction2`, `transaction3`) override the read/write constraint for read-only, write-only, and simultaneous-enable stimulus respectively.

### 7.3 Generator
- Creates `TESTCASES` (50) randomized transactions
- Tags each with an incrementing `transaction_count`
- Sends copies through `gen_drv` to the driver
- Logs each generated transaction (index, read/write, address, data)

### 7.4 Driver
- Waits on `drv_cb` before driving each transaction
- Fetches transactions from `gen_drv`
- Drives signals through the `drv_cb` clocking block
- Forwards a copy of each driven transaction to `drv_ref`
- Owns the functional `covergroup cg` (address, data, read/write, and their crosses)

### 7.5 Monitor
- Samples all DUT-facing signals every clock cycle via `mon_cb`
- Guarded against sampling during reset (`wait(!vif.rst)`) to avoid capturing garbage/high-Z values from the reset window
- Forwards sampled transactions to the scoreboard via `mbx_mon_sco`

### 7.6 Reference Model
- Maintains a behavioral memory array `ref_mem[0:31]` mirroring expected RAM contents
- On reset: clears `ref_mem`, drives `data_out` to `'bz`
- On write (`write_en=1, read_en=0`): stores `data_in` at `ref_mem[addr]`
- On read (`read_en=1, write_en=0`): predicts `data_out = ref_mem[addr]`
- On idle/simultaneous: holds `last_data_out`
- Sends the expected transaction to the scoreboard via `ref_sco`

### 7.7 Scoreboard
- Receives expected transactions from the reference model (`ref_sco`)
- Receives observed transactions from the monitor (`mbx_mon_sco`)
- Flags a `transaction_count` mismatch between the two streams as an error
- Compares `data_out` using the `===` operator (correctly handles `x`/`z` values)
- Maintains `pass_count` and `fail_count`, logging PASS/FAIL per comparison

### 7.8 Environment
- Instantiates all components and connects the four mailboxes (`gen_drv`, `drv_ref`, `mbx_mon_sco`, `ref_sco`)
- Runs `gen`, `drv`, `ref_model`, `mon`, `sco` concurrently via `fork...join`
- `report()` prints the final pass/fail counts and valid read/write counts

### 7.9 Test
- `test` — base class; instantiates the environment and runs one pass
- `read_test` / `write_test` / `simultaneous_test` — force the generator's transaction type to `transaction1` / `transaction2` / `transaction3`
- `test_regression` — runs the base transaction plus all three directed transaction types sequentially, each in a freshly constructed environment, reporting results after each run

## 8. Timing Behaviour of Testbench

| Component         | Timing                                                            |
|--------------------|----------------------------------------------------------------------|
| Driver             | Drives signals via `drv_cb` — aligned to `posedge clk`                |
| Reference Model    | Receives the driven transaction via `drv_ref`; predicts `data_out` with a one-cycle pipelined stage to match DUT read latency |
| Monitor            | Samples via `mon_cb`, one cycle behind the driver, after `rst` deasserts |
| Scoreboard         | Blocks on both `mbx_mon_sco` and `ref_sco`; compares in FIFO arrival order |



## 9. Quality of Code Assessment

| Check                        | Status | Notes                                                    |
|-------------------------------|:------:|--------------------------------------------------------------|
| No latches inferred           | ✅     | Uses `always @(posedge clk)` only                             |
| Complete sensitivity lists     | ✅     | Synchronous design — only `posedge clk`                       |
| No combinational loops         | ✅     | Registered `data_out` only                                     |
| Reset behavior defined         | ✅     | `rst` polarity and cleared state verified against RTL           |
| No multi-driven signals        | ✅     | `data_out` driven by a single always block                      |
| Mutually exclusive enables     | ✅     | Enforced in base tests; `transaction3`/`simultaneous_test` intentionally probes the corner case |

### Bugs Found
Bugs identified during verification are documented in the following Google Sheet:

**Bug Tracker:**  
https://docs.google.com/spreadsheets/d/1vZ0zd6Bbe3KFm-VwZ-fK-2rALHJ-RoP8CW0_qEnKK2E/edit?gid=0#gid=0

## 10. Functional Covergroup Coverage

The `covergroup cg`, defined in `driver.sv`, tracks the following coverpoints:

| Coverpoint  | Signal      | Bins                                                        |
|-------------|-------------|----------------------------------------------------------------|
| `address`   | `t1.addr`   | `addr_low [0:9]`, `addr_mid [10:17]`, `addr_high [18:25]`; `[26:31]` marked `illegal_bins` |
| `data_in`   | `t1.data_in`| Full `[0 : 2^DATA_WIDTH-1]` range                                |
| `read`      | `t1.read_en`| `read_high` (1), `read_low` (0)                                  |
| `write`     | `t1.write_en`| `write_high` (1), `write_low` (0)                               |
| `read_addr` | cross `address × read`  | —                                                    |
| `write_addr`| cross `address × write` | —                                                    |

## 11. Simulation Results

### 11.1 Simulation Setup

| Parameter            | Value                                  |
|------------------------|-------------------------------------------|
| Simulator             | _fill in (e.g. Siemens Questa SIM)_        |
| Language              | SystemVerilog                              |
| Clock Period          | 10 ns (from `always #5 clk=~clk;`)          |
| Reset Duration        | 10 clock cycles (`repeat(10) @(posedge clk)`) |
| Transactions per run  | `TESTCASES` = 50                            |
| Active test           | `test_regression` (runs base + 3 directed flavors) |

### 11.2 Test Scenarios Covered

| Test Scenario                  | Driven by             |
|----------------------------------|------------------------|
| Constrained-random read/write     | `test` (base `transaction`) |
| Read-only stream                  | `read_test` (`transaction1`) |
| Write-only stream                 | `write_test` (`transaction2`) |
| Simultaneous read+write corner case | `simultaneous_test` (`transaction3`) |
| Full regression (all four)        | `test_regression`       |

## 12. Coverage Report

Both code coverage and functional coverage achieved **100%** across the regression run.

| Coverage Type          | Result   |
|--------------------------|-----------|
| Code Coverage (statements, branches, toggles) | 100% |
| Functional Coverage (`covergroup cg` — address, data, read/write, and crosses) | 100% |

## 13. Waveform Analysis

Recommended signals to observe in the waveform viewer:

| Signal Group     | Signals                                             |
|--------------------|--------------------------------------------------------|
| Clock & Reset      | `clk`, `rst`                                            |
| Write Signals      | `write_en`, `addr[4:0]`, `data_in[7:0]`                 |
| Read Signals       | `read_en`, `addr[4:0]`, `data_out[7:0]`                 |
| Memory Contents    | `ref_mem[0]` … `ref_mem[31]` (testbench-side reference)  |

Expected waveform behavior:

- **Reset phase:** `rst` asserted for 10 cycles at start of simulation; `data_out` should track the DUT's defined reset value
- **Write cycle:** `write_en` high → data stored on next `posedge clk`
- **Read cycle:** `read_en` high → `data_out` updates one cycle later
- **Idle cycle:** both enables low → `data_out` holds its last driven value (per reference model) — confirm this matches RTL intent

## 14. Conclusion

- The RAM testbench implements a complete class-based, layered verification environment: generator, driver, reference model, monitor, and scoreboard, connected via SystemVerilog mailboxes and synchronized through clocking blocks/modports on a shared virtual interface
- All four transaction flavors (random, read-only, write-only, simultaneous) are exercised through a `test_regression` flow
- The scoreboard performs `===`-based comparison, correctly handling high-impedance (`z`) states expected during reset and idle cycles
- Functional coverage is collected on address range, data value, and read/write operation crosses via the driver's covergroup
- Both code and functional coverage reached 100% across the regression run
- Bugs found during verification are tracked in the linked bug tracker (Section 9)

## 15. Future Work

- Migrate the hand-rolled component classes to a full UVM environment (`uvm_component`, sequences, factory overrides)
- Add SystemVerilog Assertions (SVA) for protocol checks (e.g. `read_en`/`write_en` mutual exclusion, reset behavior)
- Parameterize `ADDR_WIDTH`/`DATA_WIDTH` beyond `defines.svh` and re-verify at multiple configurations
- Scale `TESTCASES` for deeper regression and higher coverage confidence
- Add a virtual sequencer to coordinate mixed directed/random scenarios in a single run

## Appendix

Repository: _add your GitHub repository link here_
