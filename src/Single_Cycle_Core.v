`timescale 1ns / 1ps
module Single_Cycle_Core(
    input  wire        clk, reset,
    input  wire [31:0] Instr,
    input  wire [31:0] ReadData,
    output wire [31:0] PC,
    output wire        MemWrite,
    output wire [31:0] ALUResult,
    output wire [31:0] WriteData
);

    wire        ALUSrc, RegWrite, Jump, Branch;
    wire        PCSrc; // not used at top-level now, kept for compatibility
    wire [1:0]  ResultSrc, ImmSrc;
    wire [3:0]  ALUControl;
	wire MemRead;

    // instantiate control unit (export Branch, Jump to datapath)
    Control_Unit Control (
        .op(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7b5(Instr[30]),
        .Zero(),               // datapath drives Zero, keep wire unused here
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
		.MemRead(MemRead),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Branch(Branch),
        .Jump(Jump),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl)
    );

    // Instantiate the datapath with named port mapping to avoid positional mismatch
    Core_Datapath Datapath (
        .clk(clk),
        .reset(reset),
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc),         // still present in datapath ports (unused internally)
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl),
        .Instr(Instr),         // IF-stage Instr from IMEM
        .ReadData(ReadData),
        .Branch(Branch),
        .Jump(Jump),
		.MemWrite(MemWrite),
		.MemRead(MemRead),
        .Zero(),               // datapath outputs Zero internally; not used at top-level
        .PC(PC),
        .ALUResult(ALUResult),
        .WriteData(WriteData)
    );

endmodule
