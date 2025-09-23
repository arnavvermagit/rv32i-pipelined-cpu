`timescale 1ns / 1ps
module Single_Cycle_TB();

reg clk = 0; reg reset=0;
wire [31:0] WriteData, DataAddr;
wire MemWrite;

always #10 clk = ~clk;

Single_Cycle_Top DUT(
	.clk(clk),
	.reset(reset),
	.WriteData(WriteData),
	.DataAddr(DataAddr),
	.MemWrite(MemWrite)
);
  
initial begin
    // Dump all signals to a VCD file
    $dumpfile("dump.vcd");
    $dumpvars(0, Single_Cycle_TB);

    // Apply a clean reset at the start
    reset = 1;
    #20; // Hold the reset for 20ns
    reset = 0;
end

// Check for the passing condition and end the simulation
always @(posedge clk) begin

    if (MemWrite) begin
        if (DataAddr == 100 && WriteData == 25) begin
            $display("PASSED: Data 25 written when Data Address is 100");
            $finish; // Use $finish to exit the simulator on success
        end
    end
end

// Add a timeout to prevent the simulation from running forever
initial begin
    #200000; // Let the simulation run for a long time (200000 ns)
    $display("FAILED: Simulation timed out.");
    $finish;
end

endmodule
