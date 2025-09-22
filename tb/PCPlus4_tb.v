`timescale 1ns / 1ps
module PC_Plus_4_tb;

   reg [31:0] PC;
   wire [31:0] PCPlus4;

   PC_Plus_4 PC_Plus_4_tb_inst (.PC(PC), .PCPlus4(PCPlus4));

   initial begin
      PC = 32'd0;
      #10;
      PC = 32'd12345678;
      #10;
      PC = 32'd17291729;
      #10;
      PC = 32'd87654321;
      #10;
      $finish;
   end 

   initial begin
      $monitor("At time %d, PC = %d, PCPlus4 = %d", $time, PC, PCPlus4);
   end

endmodule
