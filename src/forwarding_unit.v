`timescale 1ns / 1ps
module forwarding_unit(
    input  wire [4:0] rs1_ex,
    input  wire [4:0] rs2_ex,
    input  wire [4:0] rd_m,
    input  wire [4:0] rd_w,
    input  wire       RegWrite_m,
    input  wire       RegWrite_w,
    output reg  [1:0] forwardA,
    output reg  [1:0] forwardB
);
    // forward encoding:
    // 00 -> use ID/EX register value (no forward)
    // 10 -> forward from EX/MEM (alu_result_m)
    // 01 -> forward from MEM/WB (result_w)
    always @(*) begin
        // default no forward
        forwardA = 2'b00;
        forwardB = 2'b00;

        // EX/MEM hazard (highest priority)
        if (RegWrite_m && (rd_m != 5'b0) && (rd_m == rs1_ex)) begin
            forwardA = 2'b10;
        end
        if (RegWrite_m && (rd_m != 5'b0) && (rd_m == rs2_ex)) begin
            forwardB = 2'b10;
        end

        // MEM/WB hazard (lower priority)
        if (RegWrite_w && (rd_w != 5'b0) && (rd_w == rs1_ex) && (forwardA == 2'b00)) begin
            forwardA = 2'b01;
        end
        if (RegWrite_w && (rd_w != 5'b0) && (rd_w == rs2_ex) && (forwardB == 2'b00)) begin
            forwardB = 2'b01;
        end
    end
endmodule
