# RISC-V 32-bit Single-Cycle Processor in VHDL

![github](https://github.com/afif-main/RISC-V_single-cycle)

## 📌 About The Project
This repository contains the complete RTL design and simulation environment for a 32-bit Single-Cycle Microprocessor based on the open-source **RISC-V (RV32I)** instruction set architecture. 

The processor is entirely modeled in VHDL and verified using ModelSim. It features a Harvard architecture (separated instruction and data memories) and successfully executes R-Type, I-Type, S-Type, B-Type, J-Type, and U-Type instructions. This allows for complex control flows, function calls, and the loading of 32-bit large immediate values.

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
| **I-Type** | `ADDI`, `ANDI`, `ORI`, `XORI`, `SLTI`, `SLLI`, `SRLI`, `SRAI`, `LW`, `JALR` |
| **S-Type** | `SW` (Store Word) |
| **B-Type** | `BEQ` (Branch if Equal), `BNE` (Branch if Not Equal) |
| **J-Type** | `JAL` (Jump and Link) |
| **U-Type** | `LUI` (Load Upper Immediate), `AUIPC` (Add Upper Immediate to PC) |

## 📁 Repository Structure

```text
RISC-V/
│
├── rtl/                  # RTL Hardware Sources
│   ├── alu.vhd           # Arithmetic Logic Unit
│   ├── ctrl_unit.vhd     # Control Unit
│   ├── datapath.vhd      # Main Datapath wiring
│   ├── datamem.vhd       # Data Memory (RAM)
│   ├── imm_gen.vhd       # Immediate Generator (Handles Sign & Zero Extensions)
│   ├── instr_mem.vhd     # Instruction Memory (ROM)
│   ├── pc.vhd            # Program Counter
│   ├── reg_file.vhd      # 32x32-bit Register File
│   └── cpu.vhd           # Top-Level Processor Module
│
├── tb/                   # Testbenches
│   └── tb_cpu.vhd        # Simulation testbench for the Top-Level CPU
│
└── sim/                  # Simulation Scripts
    └── run_sim.do        # ModelSim automated compilation