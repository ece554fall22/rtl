module cache_tester_sm(
input logic [35:0] wr_offset,
input logic go,
input logic clk, rst, mem_stall_in,
input logic [127:0] cache_data,
output logic [127:0] wr_data,
output logic [35:0] addr,
output logic r,
output logic [1:0] flushtype, w_type
);

logic [14:0] ctr_next, ctr_reg;
logic w, done, start;
logic [35:0] wr_offset_reg;
logic r_reg, r_new;
logic [1:0] w_type_reg, flushtype_reg, w_type_new, flushtype_new;
logic [127:0] wr_data_reg;
logic [35:0] addr_reg, addr_new;

always @(negedge mem_stall_in) begin
//  $display("sending new request to cache");
end

assign addr_new = (r_new) ? {19'h00000 , ctr_reg[13:1], 4'h0} : wr_offset + {19'h00000, ctr_reg[13:1], 4'h0};

assign done = ctr_reg[14];

assign flushtype = {done, 1'b0};

assign r_new = ~ctr_reg[0] & start;
assign w = ctr_reg[0] & start;

assign w_type_new[1] = ctr_reg[13] & w & ~done;
assign w_type_new[0] = ((~ctr_reg[13]) | (ctr_reg[13] & ctr_reg[12])) & w & ~done;

assign ctr_next = (mem_stall_in) ? ctr_reg : ctr_reg + 1;

assign addr = (mem_stall_in) ? addr_reg : addr_new;
assign wr_data = (mem_stall_in) ? wr_data_reg : cache_data;
//assign flushtype = (mem_stall_in) ? flushtype_reg : flushtype_new;
assign w_type = (mem_stall_in) ? w_type_reg : w_type_new;
assign r = (mem_stall_in) ? r_reg : r_new;


always @(posedge go) begin 
  $display("go signal has gone high");
end

always @(posedge clk) begin
  if(done) begin
//    $display("tester done");
  end
end


always_ff @(posedge clk) begin
  if(go) begin
//    $display("go signal has gone high");
  end
  if(rst) begin
//    $display("reseting");
//    $display("sending new request to cache");
    start <= 0;
    ctr_reg <= 0;
    wr_data_reg <= 0;
    wr_offset_reg <= 0;
    addr_reg <= 0;
    flushtype_reg <= 0;
    w_type_reg <= 0;
    r_reg <= 0;
  end else if (~mem_stall_in & ~done) begin
    if(start) begin
    ctr_reg <= ctr_next;
    wr_data_reg <= cache_data;
    wr_offset_reg <= wr_offset;
    addr_reg <= addr_new;
    flushtype_reg <= flushtype_new;
    w_type_reg <= w_type_new;
    r_reg <= r_new;
    end
    start <= go | start;
  end
end


endmodule
