`timescale 1ns / 1ps
module id_ex_reg(
  input clk, reset, flush,

  // Data from Decode
  input [31:0] pc_d, rs1_d, rs2_d, imm_d,
  input [4:0]  rs1_id, rs2_id, rd_id,

  // Control from Decode
  input        RegWrite_d, MemRead_d, MemWrite_d, MemToReg_d, Branch_d, Jump_d,
  input [2:0]  ALUOp_d,
  input        ALUSrc_d,
  input [3:0]  ALUControl_d,

  // Data to Execute
  output reg [31:0] pc_x, rs1_x, rs2_x, imm_x,
  output reg [4:0]  rs1_ex, rs2_ex, rd_ex,

  // Control to Execute
  output reg        RegWrite_x, MemRead_x, MemWrite_x, MemToReg_x, Branch_x, Jump_x,
  output reg [2:0]  ALUOp_x,
  output reg        ALUSrc_x,
  output reg [3:0]  ALUControl_x
);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Data
      pc_x <= 32'b0; rs1_x <= 32'b0; rs2_x <= 32'b0; imm_x <= 32'b0;
      rs1_ex <= 5'b0; rs2_ex <= 5'b0; rd_ex <= 5'b0;

      // Control
      RegWrite_x <= 1'b0; MemRead_x <= 1'b0; MemWrite_x <= 1'b0; MemToReg_x <= 1'b0;
      Branch_x <= 1'b0; Jump_x <= 1'b0;
      ALUOp_x <= 3'b000;
      ALUSrc_x <= 1'b0;
      ALUControl_x <= 4'b0000;
    end else if (flush) begin
      // Flush only control signals (insert bubble)
      RegWrite_x <= 1'b0; MemRead_x <= 1'b0; MemWrite_x <= 1'b0; MemToReg_x <= 1'b0;
      Branch_x <= 1'b0; Jump_x <= 1'b0;
      ALUOp_x <= 3'b000;
      ALUSrc_x <= 1'b0;
      ALUControl_x <= 4'b0000;
      // Keep data regs (rd_ex, rs1_ex, rs2_ex, etc.) unchanged
    end else begin
      // Data
      pc_x <= pc_d; rs1_x <= rs1_d; rs2_x <= rs2_d; imm_x <= imm_d;
      rs1_ex <= rs1_id; rs2_ex <= rs2_id; rd_ex <= rd_id;

      // Control
      RegWrite_x <= RegWrite_d; MemRead_x <= MemRead_d; MemWrite_x <= MemWrite_d; MemToReg_x <= MemToReg_d;
      Branch_x <= Branch_d; Jump_x <= Jump_d;
      ALUOp_x <= ALUOp_d;
      ALUSrc_x <= ALUSrc_d;
      ALUControl_x <= ALUControl_d;
    end
  end
endmodule
