`timescale 1ns / 1ps
module Core_Datapath(
    input         clk, reset,
    input  [1:0]  ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input  [1:0]  ImmSrc,
    input  [3:0]  ALUControl,
    input  [31:0] Instr,
    input  [31:0] ReadData,
    input         Branch,
    input         Jump,
    input         MemRead,
    input         MemWrite,

    output        Zero,
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData,
    output [31:0] instr_id   // NEW: expose IF/ID instruction for CU
);

    // IF/ID outputs
    wire [31:0] pc_id;
    wire [31:0] instr_id_internal;
    assign instr_id = instr_id_internal;

    // ID/EX pipeline register wires
    wire [31:0] pc_ex, rs1_ex_val, rs2_ex_val, imm_ex;
    wire [4:0]  rs1_ex, rs2_ex, rd_ex;
    wire        RegWrite_ex, MemRead_ex, MemWrite_ex, MemToReg_ex, Branch_ex, Jump_ex;
    wire [2:0]  ALUOp_ex;
    wire        ALUSrc_x;
    wire [3:0]  ALUControl_x;

    // EX/MEM pipeline register wires
    wire [31:0] alu_result_m, rs2_m;
    wire [4:0]  rd_m;
    wire        RegWrite_m, MemRead_m, MemWrite_m, MemToReg_m;
    wire        branch_taken_ex, branch_taken_m;

    // pc target pipeline
    wire [31:0] pc_target_ex;
    wire [31:0] pc_target_m;

    // MEM/WB wires (for forwarding)
    wire [31:0] result_w;
    wire [4:0]  rd_w;
    wire        RegWrite_w;

    // forwarding control
    wire [1:0] forwardA, forwardB;

    // other datapath wires
    wire [31:0] PCnext, PCplus4, PCtarget;
    wire [31:0] ImmExt;
    wire [31:0] SrcA, SrcB;
    wire [31:0] Result;
    wire [31:0] mem_result_m;

    // hazard signals
    wire pcwrite_hz, ifidwrite_hz, stall_flush_hz;
    wire [4:0] rs1_id = instr_id_internal[19:15];
    wire [4:0] rs2_id = instr_id_internal[24:20];

    // ---- IF stage ----
    PC PC_inst (.clk(clk), .reset(reset), .en(pcwrite_hz), .PCNext(PCnext), .PC(PC));
    PC_Plus_4 PCPlus4_inst (.PC(PC), .PCPlus4(PCplus4));
    PC_Target PCTarget_inst (.PC(PC), .ImmExt(ImmExt), .PCTarget(PCtarget));

    PC_Mux PCmux_inst(
        .PC_Plus_4(PCplus4),
        .PC_Target(pc_target_m),
        .PCSrc(branch_taken_m),
        .PC_Next(PCnext)
    );

    // IF/ID pipeline register
    if_id_reg u_if_id (
        .clk(clk),
        .reset(reset),
        .en(ifidwrite_hz),
        .flush(branch_taken_m),
        .pc_in(PC),
        .instr_in(Instr),
        .pc_out(pc_id),
        .instr_out(instr_id_internal)
    );

    // ---- ID stage ----
    Register_File Register_inst (
        .clk(clk),
        .WE3(RegWrite_w),
        .RA1(instr_id_internal[19:15]),
        .RA2(instr_id_internal[24:20]),
        .WA3(rd_w),
        .WD3(result_w),
        .RD1(SrcA),
        .RD2(WriteData)
    );

    Extend Extend_inst (
        .Instr(instr_id_internal[31:0]),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );

    // ---- ID -> EX pipeline register ----
    id_ex_reg u_id_ex (
        .clk(clk),
        .reset(reset),
        .flush(stall_flush_hz),

        .pc_d(pc_id),
        .rs1_d(SrcA),
        .rs2_d(WriteData),
        .imm_d(ImmExt),

        .rs1_id(instr_id_internal[19:15]),
        .rs2_id(instr_id_internal[24:20]),
        .rd_id(instr_id_internal[11:7]),

        .RegWrite_d(RegWrite),
        .MemRead_d(MemRead),
        .MemWrite_d(MemWrite),
        .MemToReg_d(1'b0),
        .Branch_d(Branch),
        .Jump_d(Jump),
        .ALUOp_d(ALUControl[2:0]),
        .ALUSrc_d(ALUSrc),
        .ALUControl_d(ALUControl),

        .pc_x(pc_ex),
        .rs1_x(rs1_ex_val),
        .rs2_x(rs2_ex_val),
        .imm_x(imm_ex),

        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_ex(rd_ex),

        .RegWrite_x(RegWrite_ex),
        .MemRead_x(MemRead_ex),
        .MemWrite_x(MemWrite_ex),
        .MemToReg_x(MemToReg_ex),
        .Branch_x(Branch_ex),
        .Jump_x(Jump_ex),
        .ALUOp_x(ALUOp_ex),
        .ALUSrc_x(ALUSrc_x),
        .ALUControl_x(ALUControl_x)
    );

    hazard_unit hazard_u (
        .rs1_id(instr_id_internal[19:15]),
        .rs2_id(instr_id_internal[24:20]),
        .rd_ex(rd_ex),
        .MemRead_ex(MemRead_ex),
        .pcwrite_hz(pcwrite_hz),
        .ifidwrite_hz(ifidwrite_hz),
        .stall_flush_hz(stall_flush_hz)
    );

    // ---- FORWARDING UNIT ----
    forwarding_unit fwd_u (
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_m(rd_m),
        .rd_w(rd_w),
        .RegWrite_m(RegWrite_m),
        .RegWrite_w(RegWrite_w),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    wire [31:0] alu_in_A;
    assign alu_in_A = (forwardA == 2'b10) ? alu_result_m :
                      (forwardA == 2'b01) ? result_w : rs1_ex_val;

    wire [31:0] alu_in_B_reg;
    assign alu_in_B_reg = (forwardB == 2'b10) ? alu_result_m :
                          (forwardB == 2'b01) ? result_w : rs2_ex_val;

    wire [31:0] alu_in_B;
    assign alu_in_B = ALUSrc_x ? imm_ex : alu_in_B_reg;

    ALU ALU_inst (
        .A(alu_in_A),
        .B(alu_in_B),
        .ALUControl(ALUControl_x),
        .Zero(Zero),
        .Result(ALUResult)
    );

    assign pc_target_ex = pc_ex + imm_ex;
    assign branch_taken_ex = Branch_ex & Zero;

    ex_mem_reg u_ex_mem (
        .clk(clk),
        .reset(reset),
        .flush(1'b0),

        .alu_result_x(ALUResult),
        .rs2_x(alu_in_B_reg),
        .rd_x(rd_ex),
        .branch_taken_ex(branch_taken_ex),
        .pc_target_x(pc_target_ex),

        .RegWrite_x(RegWrite_ex),
        .MemRead_x(MemRead_ex),
        .MemWrite_x(MemWrite_ex),
        .MemToReg_x(MemToReg_ex),

        .alu_result_m(alu_result_m),
        .rs2_m(rs2_m),
        .rd_m(rd_m),
        .branch_taken_m(branch_taken_m),
        .pc_target_m(pc_target_m),

        .RegWrite_m(RegWrite_m),
        .MemRead_m(MemRead_m),
        .MemWrite_m(MemWrite_m),
        .MemToReg_m(MemToReg_m)
    );

    assign mem_result_m = MemToReg_m ? ReadData : alu_result_m;

    mem_wb_reg u_mem_wb (
        .clk(clk),
        .reset(reset),
        .flush(1'b0),

        .result_m(mem_result_m),
        .rd_m(rd_m),
        .RegWrite_m(RegWrite_m),

        .result_w(result_w),
        .rd_w(rd_w),
        .RegWrite_w(RegWrite_w)
    );

    Result_Mux Result_Mux_inst (
        .ALUResult(ALUResult),
        .ReadData(ReadData),
        .PC_Plus_4(PCplus4),
        .ResultSrc(ResultSrc),
        .Result(Result)
    );

endmodule
