# 32-bit 5-Stage Pipelined RISC-V CPU (RV32I)
32-bit 5-stage pipelined RISC-V CPU (RV32I) in Verilog HDL. Supports ADD, SUB, AND, OR, LW, SW, BEQ, BNE with hazard handling (forwarding, stalls, flushes). Verified using testbenches and GTKWave, achieving CPI ≈ 1.0 on hazard-free execution.
# Overview
This project implements a 32-bit, 5-stage pipelined RISC-V CPU (RV32I) in Verilog HDL.  
The design follows the classic pipeline stages — Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory (MEM), and Write Back (WB).

# Features
- Supports a subset of RV32I instructions:
  - Arithmetic/Logical: ADD, SUB, AND, OR  
  - Memory: LW, SW  
  - Branches: BEQ, BNE  
- Hazard handling mechanisms:
  - EX/MEM and MEM/WB forwarding  
  - One-cycle stall for load-use hazards  
  - One-cycle flush for branch hazards  
- Achieves CPI ≈ 1.0 for hazard-free execution

# Verification
- Directed test programs were loaded into instruction memory via `$readmemh`.  
- Functionality verified by simulating with Icarus Verilog (`iverilog` + `vvp`).  
- Waveforms analyzed in GTKWave for cycle-accurate inspection of pipeline behavior.

# Tools Used
- Verilog HDL  
- Icarus Verilog (simulation)  
- GTKWave (waveform analysis)

# Repository Structure
- `src/` → Verilog source files (datapath, control, hazard units)  
- `tb/` → Testbenches  
- `programs/` → Test programs in hex format  
- `docs/` → Block diagrams and waveform captures  

# Learning Outcomes
- Practical understanding of CPU microarchitecture and pipelining.  
- Experience implementing hazard detection and forwarding logic.  
- Hands-on verification using open-source tools (Icarus Verilog + GTKWave).  
*This project demonstrates the fundamentals of computer architecture and serves as a solid reference for learners exploring pipelined CPU design in Verilog.*
