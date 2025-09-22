 `timescale 1ns / 1ps
module Main_Decoder(
    input wire [6:0]  op,
    output wire [1:0] ResultSrc,
    output wire       MemRead, MemWrite, Branch, ALUSrc, RegWrite, Jump,
    output wire [1:0] ImmSrc, ALUop
);

    reg [11:0] control_signals;
   
    always @(*) begin
        // default: all zeros (safe values)
        control_signals = 11'b0_00_0_0_00_0_00_0;

        case(op)
        // RegWrite_ImmSrc_ALUSrc_MemWrite_MemRead_ResultSrc_Branch_ALUop_Jump

        7'b0000011: control_signals = 12'b1_00_1_0_1_01_0_00_0; // lw
        7'b0100011: control_signals = 12'b0_01_1_1_0_00_0_00_0; // sw
        7'b0110011: control_signals = 12'b1_xx_0_0_0_00_0_10_0; // R-type
        7'b0010011: control_signals = 12'b1_00_1_0_0_00_0_10_0; // I-type ALU
        7'b1100011: control_signals = 12'b0_10_0_0_0_00_1_01_0; // B-type (branch family)
        7'b1101111: control_signals = 12'b1_11_0_0_0_10_0_00_1; // jal
        7'b1100111: control_signals = 12'b1_00_1_0_0_10_0_00_1; // jalr
        7'b0110111: control_signals = 12'b1_00_1_0_0_00_0_11_0; // U-type lui
        7'b0010111: control_signals = 12'b1_00_1_0_0_00_0_01_0; // U-type AUIPC
        7'b0000000: control_signals = 12'b0_00_0_0_0_00_0_00_0; // reset condition
        default:    control_signals = 12'b0_00_0_0_0_00_0_00_0;
    endcase

    end

    assign {RegWrite, ImmSrc, ALUSrc, MemWrite,MemRead,
            ResultSrc, Branch, ALUop, Jump} = control_signals;	

endmodule
