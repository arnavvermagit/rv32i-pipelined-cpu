`timescale 1ns / 1ps
module hazard_unit(
    input  wire        MemRead_ex,        // load in EX stage
    input  wire [4:0]  rd_ex,             // destination register in EX
    input  wire [4:0]  rs1_id,            // source 1 in ID
    input  wire [4:0]  rs2_id,            // source 2 in ID
    output reg         pcwrite_hz,        // control PC write enable
    output reg         ifidwrite_hz,      // control IF/ID write enable
    output reg         stall_flush_hz     // flush control for ID/EX
);

    always @(*) begin
    // default: no hazard
    pcwrite_hz     = 1;
    ifidwrite_hz   = 1;
    stall_flush_hz = 0;

    // detect load-use hazard
    if (MemRead_ex &&
       ((rd_ex != 5'b0) && ((rd_ex == rs1_id) || (rd_ex == rs2_id)))) begin
        pcwrite_hz     = 0;  // stall PC
        ifidwrite_hz   = 0;  // stall IF/ID
        stall_flush_hz = 1;  // flush ID/EX
    end

    // Debug
    $display("T=%0t | MemRead_ex=%b rd_ex=%0d rs1_id=%0d rs2_id=%0d | pcwrite=%b stall=%b",
             $time, MemRead_ex, rd_ex, rs1_id, rs2_id, pcwrite_hz, stall_flush_hz);
end


endmodule
