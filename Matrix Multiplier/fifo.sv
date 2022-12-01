// fifo.sv
// Implements delay buffer (fifo)
// On reset all entries are set to 0
// Shift causes fifo to shift out oldest entry to q, shift in d

module fifo #(
  parameter int DEPTH=8,
  parameter int BITS=32
) (
  input wire clk,rst_n,en, wr,
  input wire [BITS-1:0] d,
  output wire [BITS-1:0] q
);
  logic [BITS-1:0] registers [DEPTH-1:0];

  // infers an array of chained flops. all flops stop registering their `d` when `~en`.
  always_ff @(posedge clk or negedge rst_n) begin
    for (integer i = 0; i < DEPTH; i++) begin
      if (!rst_n)
        registers[i] <= '0;
      else if (wr)

      else if (en)
        registers[i] <= (i == 0) ? d : registers[i-1];
    end
  end

  assign q = registers[DEPTH-1];
endmodule // fifo
