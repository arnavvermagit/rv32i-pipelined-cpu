`timescale 1ns / 1ps

module ex_mem_reg (
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,

    // Inputs from EX stage
    input  wire [31:0] alu_result_x,
    input  wire [31:0] rs2_x,
    input  wire [4:0]  rd_x,
    input  wire        RegWrite_x,
    input  wire        MemRead_x,
    input  wire        MemWrite_x,
    input  wire        MemToReg_x,
    input  wire        branch_taken_ex,
    input  wire [31:0] pc_target_x,   // NEW: branch target computed in EX

    // Outputs to MEM stage
    output reg  [31:0] alu_result_m,
    output reg  [31:0] rs2_m,
    output reg  [4:0]  rd_m,
    output reg         RegWrite_m,
    output reg         MemRead_m,
    output reg         MemWrite_m,
    output reg         MemToReg_m,
    output reg         branch_taken_m,
    output reg  [31:0] pc_target_m    // NEW: pipelined target to MEM
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_result_m   <= 32'b0;
            rs2_m          <= 32'b0;
            rd_m           <= 5'b0;
            RegWrite_m     <= 1'b0;
            MemRead_m      <= 1'b0;
            MemWrite_m     <= 1'b0;
            MemToReg_m     <= 1'b0;
            branch_taken_m <= 1'b0;
            pc_target_m    <= 32'b0;
        end else if (flush) begin
            // on flush, turn into NOP
            alu_result_m   <= 32'b0;
            rs2_m          <= 32'b0;
            rd_m           <= 5'b0;
            RegWrite_m     <= 1'b0;
            MemRead_m      <= 1'b0;
            MemWrite_m     <= 1'b0;
            MemToReg_m     <= 1'b0;
            branch_taken_m <= 1'b0;
            pc_target_m    <= 32'b0;
        end else begin
            alu_result_m   <= alu_result_x;
            rs2_m          <= rs2_x;
            rd_m           <= rd_x;
            RegWrite_m     <= RegWrite_x;
            MemRead_m      <= MemRead_x;
            MemWrite_m     <= MemWrite_x;
            MemToReg_m     <= MemToReg_x;
            branch_taken_m <= branch_taken_ex;
            pc_target_m    <= pc_target_x;
        end
    end

endmodule
