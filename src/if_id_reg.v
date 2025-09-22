module if_id_reg (
  input        clk,
  input        reset,
  input        en,    // enable (used for stalls) — for now tie to 1
  input        flush, // set to 1 to insert a NOP
  input  [31:0] pc_in,
  input  [31:0] instr_in,
  output reg [31:0] pc_out,
  output reg [31:0] instr_out
);
  // NOP for RV32I is 0x00000013
  localparam [31:0] NOP = 32'h00000013;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pc_out    <= 32'b0;
      instr_out <= NOP;
    end else if (flush) begin
      pc_out    <= 32'b0;
      instr_out <= NOP;
    end else if (en) begin
      pc_out    <= pc_in;
      instr_out <= instr_in;
    end
  end
endmodule
