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
module Control_Unit( 
    input wire [6:0]  op,
    input wire [2:0]  funct3,
    input wire        funct7b5, Zero,

    output wire [1:0] ResultSrc,
    output wire       MemRead,MemWrite, PCSrc, ALUSrc, RegWrite, Jump,
    output wire [1:0] ImmSrc,
    output wire [3:0] ALUControl,
	output wire Branch
);

    wire [1:0] ALUop;
    


   
    Main_Decoder Main_Decoder_inst(
        .op(op),
        .ResultSrc(ResultSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .ImmSrc(ImmSrc),
        .ALUop(ALUop)
    );
   
    ALU_Decoder ALU_Decoder_inst(
        .opb5(op[5]),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .ALUOp(ALUop),
        .ALUControl(ALUControl)
    );

    // Branch decision logic (BEQ, BNE implemented)
    reg take_branch;
    always @(*) begin
        case (funct3)
            3'b000: take_branch = Zero;      // BEQ
            3'b001: take_branch = ~Zero;     // BNE
            default: take_branch = 1'b0;     // others not yet implemented
        endcase
    end

    assign PCSrc = (Branch & take_branch) | Jump;

endmodule

