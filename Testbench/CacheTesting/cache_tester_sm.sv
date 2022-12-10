module cache_tester_sm(
input logic [35:0] wr_offset,
input logic mmioValid,
input logic clk, rst, mem_stall_in,
input logic [127:0] cache_data,
output logic [127:0] wr_data,
output logic [35:0] addr,
output logic r,
output logic [1:0] flushtype, w_type
);

logic [127:0] data_reg;
logic [13:0] ctr_next, ctr_reg;
logic w, done;
logic [35:0] wr_offset_reg;

assign addr = (w) ? {18'h00000 , ctr_reg, 4'h0} : wr_offset + {18'h00000, ctr_reg, 4'h0};

assign done = &ctr_reg;

assign flushtype = {done,done};

assign r = ~ctr_reg[0];
assign w = ctr_reg[0];

assign w_type[1] = ctr_reg[13] & w;
assign w_type[0] = (~ctr_reg[13]) | (ctr_reg[13] & ctr_reg[12]) & w;

assign ctr_next = (mem_stall_in) ? ctr_reg : ctr_reg + 1;


always_ff @(posedge clk) begin
  if(rst) begin
    $display("reseting");
    ctr_reg <= 0;
    wr_data <= 0;
    wr_offset_reg <= 0;
  end else if (~mem_stall_in & ~done) begin
    ctr_reg <= ctr_reg + 1;
    wr_data <= cache_data;
    wr_offset_reg <= wr_offset;
  end
end


endmodule
