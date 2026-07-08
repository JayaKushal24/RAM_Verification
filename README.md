# RAM Verification

## Overview

This repository contains a SystemVerilog-based verification environment for a synchronous RAM. The verification environment is built using a layered testbench architecture with constrained-random stimulus generation, reference model, scoreboard, monitor, assertions, and functional coverage.

## Directory Structure

```text
RAM_VERIFICATION/
│
├── Docs/
│   └── verification_report.md
│
├── src/
│   ├── rtl/
│   │   └── dut_ram.v
│   │
│   └── tb/
│       ├── defines.svh
│       ├── interface.sv
│       ├── transaction.sv
│       ├── generator.sv
│       ├── driver.sv
│       ├── monitor.sv
│       ├── reference_model.sv
│       ├── scoreboard.sv
│       ├── environment.sv
│       ├── test.sv
│       └── testbench.sv
│
└── README.md
```

## Verification Environment

The testbench consists of:

- Generator
- Driver
- Monitor
- Reference Model
- Scoreboard
- Assertions
- Functional Coverage

## Test Scenarios

- Reset Verification
- Write Operations
- Read Operations
- Simultaneous Read/Write
- Random Transactions
- Address Boundary Testing
- Regression Testing

## Verification Report

The complete verification report is available in:

```
Docs/verification_report.md
```

## Bug Tracker

All bugs identified during verification are documented in the following spreadsheet:

**Google Sheet:**  
https://docs.google.com/spreadsheets/d/1vZ0zd6Bbe3KFm-VwZ-fK-2rALHJ-RoP8CW0_qEnKK2E/edit?gid=0#gid=0

