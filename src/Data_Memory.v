`timescale 1ns / 1ps
/*
 * Copyright (c) 2023 Govardhan
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
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