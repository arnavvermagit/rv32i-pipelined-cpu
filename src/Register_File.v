`timescale 1ns / 1ps
module Register_File(
		     input wire 	clk, WE3,
		     input wire [4:0] 	RA1,RA2,WA3,
		     input wire [31:0] 	WD3,
			 input wire reset,
		     output wire [31:0] RD1,RD2
		     );

   reg [31:0] 				REG_MEM_BLOCK[31:0];
   // Simulation-only initialization to avoid X values
integer i;
initial begin
  for (i = 0; i < 32; i = i + 1)
    REG_MEM_BLOCK[i] = 32'b0;
end


   always@(posedge clk)
     begin
	 if (reset) begin
	 for (i = 0; i < 32; i = i + 1)
                REG_MEM_BLOCK[i] <= 32'b0;
	 end else if(WE3)
	  REG_MEM_BLOCK[WA3] <= WD3;
     end

   assign RD1 = (RA1 != 0) ? REG_MEM_BLOCK[RA1] : 0;
   assign RD2 = (RA2 != 0) ? REG_MEM_BLOCK[RA2] : 0;

endmodule
