`timescale 1ns / 1ps
module Single_Cycle_Top(
    input         clk, reset,
    output [31:0] WriteData, DataAddr,
    output [31:0] ReadData,
    output        MemWrite
);

    // instruction + PC wires
    wire [31:0] PC, Instr_if;
    wire [31:0] instr_id;   // from Core_Datapath

    // control nets
    wire [1:0] ResultSrc;
    wire       MemRead, MemWrite_ctrl, PCSrc, ALUSrc, RegWrite, Jump, Branch;
    wire [1:0] ImmSrc;
    wire [3:0] ALUControl;
    wire       Zero;

    // instruction memory
    Instruction_Memory Instr_Memory (
        .A(PC),
        .RD(Instr_if)
    );

    // Control unit decodes the instruction in ID stage (instr_id from datapath)
    wire [6:0] op       = instr_id[6:0];
    wire [2:0] funct3   = instr_id[14:12];
    wire       funct7b5 = instr_id[30];

    Control_Unit CU (
        .op(op),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .Zero(Zero),
        .ResultSrc(ResultSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite_ctrl),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl),
        .Branch(Branch)
    );

    // Core datapath receives Instr_if and produces instr_id after IF/ID
    Core_Datapath core (
        .clk(clk),
        .reset(reset),
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl),
        .Instr(Instr_if),
        .ReadData(ReadData),
        .Branch(Branch),
        .Jump(Jump),
        .MemRead(MemRead),
        .MemWrite(MemWrite_ctrl),
        .Zero(Zero),
        .PC(PC),
        .ALUResult(DataAddr),
        .WriteData(WriteData),
        .instr_id(instr_id)  // exported to CU
    );

    // data memory
    Data_Memory Data_Memory_inst (
        .clk(clk),
        .WE(MemWrite_ctrl),
        .A(DataAddr),
        .WD(WriteData),
        .RD(ReadData)
    );

    assign MemWrite = MemWrite_ctrl;

endmodule
