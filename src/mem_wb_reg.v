`timescale 1ns / 1ps
module mem_wb_reg(
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,

    // Inputs from MEM stage
    input  wire [31:0] result_m,
    input  wire [4:0]  rd_m,
    input  wire        RegWrite_m,

    // Outputs to WB stage / forwarding
    output reg  [31:0] result_w,
    output reg  [4:0]  rd_w,
    output reg         RegWrite_w
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            result_w   <= 32'b0;
            rd_w       <= 5'b0;
            RegWrite_w <= 1'b0;
        end else begin
            result_w   <= result_m;
            rd_w       <= rd_m;
            RegWrite_w <= RegWrite_m;
        end
    end
endmodule
