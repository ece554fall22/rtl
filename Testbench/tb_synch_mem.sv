module tb_synch_mem();


logic clk, rst, failed;
logic overwrite;
logic [35:0] addr_req_in;
logic [35:0] addr_req_out;
logic [511:0] data_in;
logic [511:0] data_out;
logic [3:0] id_req_in;
logic [3:0] id_req_out;
logic [2:0] packet_type_req_in;
logic [2:0] packet_type_req_out;

logic [3:0] [31:0] synch_regs_expected;

// instantiation of unit
synch_mem dut(.*);


initial begin

  // set initial values
  addr_req_in = $random;
  data_in = $random;
  id_req_in = $random;
  packet_type_req_in = 0;
  synch_regs_expected[0] = 0;
  synch_regs_expected[1] = 0;
  synch_regs_expected[2] = 0;
  synch_regs_expected[3] = 0;
  failed = 0;
  clk = 0;
  rst = 1;
  @(posedge clk)
  rst = 0;
  @(posedge clk)

  // loop through and set random inputs 10000 times
  for(int i = 0; i < 10000; i++) begin
    @(negedge clk)
    if(!(addr_req_in===addr_req_out)) begin
      failed = 1;
      $display("addr_req_in is not equal to addr_req_out");
    end
    if(!(id_req_in===id_req_out)) begin
      failed = 1;
      $display("id_req_in is not equal to id_req_out");
    end
    if(packet_type_req_in===3'b111) begin
       if(!(data_out[31:0]===synch_regs_expected[addr_req_in[3:2]])) begin
         failed = 1;
         $display("ERROR while processing a fetch and add request output was not equal to expected");
       end
       if(!(packet_type_req_out===3'b110)) begin
         failed = 1;
         $display("ERROR while processing a fetch and add request did not put correct packet type into circ mem");
       end
       if(!(overwrite===1'b1)) begin
         failed = 1;
         $display("ERROR while processing a fetch and add request did not put contents into circ mem");
       end
    end else if (packet_type_req_in===3'b010) begin
      if(!(packet_type_req_out===3'b101)) begin
        failed = 1;
        $display("ERROR while processing write to shared mem request, did not put correct packet type into circ mem");
      end
      if(!(overwrite===1'b1)) begin
        failed = 1;
        $display("ERROR while processing write to shared mem request, did not put contents into circ mem");
      end
    end else if (packet_type_req_in===3'b100) begin
      if(!(data_out[31:0]===synch_regs_expected[addr_req_in[3:2]])) begin
        failed = 1;
        $display("ERROR while processing a read request, output was not equal to expected");
      end
      if(!(packet_type_req_out===3'b110)) begin
        failed = 1;
        $display("ERROR while processing a read request, packet type was not correct");
      end
      if(!(overwrite===1'b1)) begin
        failed = 1;
        $display("ERROR while processing a read request, did not put contents into circ mem");
      end
  end
  
  // sets the values to be random
  addr_req_in = $random;
  data_in[31:0] = $random;
  data_in[46:32] = $random;
  id_req_in = $random;
  packet_type_req_in = $random;
  @(posedge clk);

end

// if any output was incorrect at any cycle throughout the tests lifetime will not print yahoo
if (failed==0) begin
  $display("YAHOO! ALL TESTS PASSED!");
end else begin
  $display("One or more test failed, get debugging!");
end

$stop;

end

// clk
always begin
  #5 clk = ~clk;
end

// models the synchronization registers
always @(posedge clk) begin
  if(!rst) begin
  if(packet_type_req_in===3'b111) begin
    synch_regs_expected[addr_req_in[3:2]] = data_in[31:0] + {{17{data_in[46]}}, data_in[46:32]};
  end else if (packet_type_req_in===3'b010) begin
    synch_regs_expected[addr_req_in[3:2]] = data_in[31:0];
  end
  end


end

endmodule
