`timescale 1ns / 1ps
module PC (
    input  wire        clk,
    input  wire        reset,
    input  wire        en,       // new: enable/PCWrite
    input  wire [31:0] PCNext,
    output reg  [31:0] PC
);

    always @(posedge clk or posedge reset) begin
        if (reset) PC <= 32'b0;
        else if (en) PC <= PCNext;
        else PC <= PC; // hold when en==0
    end

endmodule
