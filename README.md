# RISC-V 32-bit Single-Cycle Processor in VHDL

## 📌 About The Project
This repository contains the complete RTL design and simulation environment for a 32-bit Single-Cycle Microprocessor based on the open-source **RISC-V (RV32I)** instruction set architecture. 

The processor is entirely modeled in VHDL and verified using ModelSim. It features a Harvard architecture (separated instruction and data memories) and successfully executes R-Type, I-Type, S-Type, and B-Type instructions.

## ⚙️ Specifications
* **ISA:** RISC-V 32-bit Integer Base (RV32I)
* **Datapath:** Single-Cycle execution
* **Data Width:** 32-bit (Registers, ALU, Data Bus, Address Bus)
* **Registers:** 32 general-purpose registers (`x0` to `x31`), with `x0` hardwired to zero.

## 🛠️ Supported Instructions
The Control Unit and Datapath are capable of decoding and executing the following instructions:

| Type | Instructions |
| :--- | :--- |
| **R-Type** | `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT`, `SLL`, `SRL`, `SRA` |
| **I-Type** | `ADDI`, `ANDI`, `ORI`, `XORI`, `SLTI`, `SLLI`, `SRLI`, `SRAI`, `LW` (Load Word) |
| **S-Type** | `SW` (Store Word) |
| **B-Type** | `BEQ` (Branch if Equal), `BNE` (Branch if Not Equal) |

## 📁 Repository Structure

```text
RISC-V/
│
├── rtl/                  # RTL Hardware Sources
│   ├── alu.vhd           # Arithmetic Logic Unit
│   ├── ctrl_unit.vhd     # Control Unit
│   ├── datapath.vhd      # Main Datapath wiring
│   ├── datamem.vhd       # Data Memory (RAM)
│   ├── imm_gen.vhd       # Immediate Generator
│   ├── instr_mem.vhd     # Instruction Memory (ROM)
│   ├── pc.vhd            # Program Counter
│   ├── reg_file.vhd      # 32x32-bit Register File
│   └── cpu.vhd           # Top-Level Processor Module
│
└── tb/                   # Testbenches
    └── tb_cpu.vhd        # Simulation testbench for the Top-Level CPU