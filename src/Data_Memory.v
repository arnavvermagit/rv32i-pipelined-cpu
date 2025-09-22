`timescale 1ns / 1ps
module Data_Memory(
    input  wire        clk,
    input  wire        WE,             // Write enable
    input  wire [31:0] A,              // Address
    input  wire [31:0] WD,             // Write data
    output wire [31:0] RD              // Read data
);

    reg [31:0] RAM [0:63];             // 64 words

    // Combinational read (word-aligned)
    assign RD = RAM[A[31:2]];

    // Synchronous write
    always @(posedge clk) begin
        if (WE)
            RAM[A[31:2]] <= WD;
    end

    // Initialize to zero for predictable behavior
    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1)
            RAM[i] = 32'b0;
    end

endmodule
