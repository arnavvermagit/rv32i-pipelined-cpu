# rv32i-pipelined-cpu
32-bit 5-stage pipelined RISC-V CPU (RV32I) in Verilog HDL. Supports ADD, SUB, AND, OR, LW, SW, BEQ, BNE with hazard handling (forwarding, stalls, flushes). Verified using testbenches and GTKWave, achieving CPI ≈ 1.0 on hazard-free execution.
