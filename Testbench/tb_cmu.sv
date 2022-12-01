module tb_cmu();

logic [35:0] addr_circ_in, addr_circ_out, addr_req_in, addr_req_out, addr_circ_reg, addr_req_reg;
logic [3:0] id_circ_in, id_circ_out, id_req_in, id_req_out, id_circ_reg, id_req_reg;
logic [2:0] packet_type_circ_in, packet_type_circ_out, packet_type_req_in, packet_type_req_out;
logic [2:0] packet_type_circ_reg, packet_type_req_reg;
logic [511:0] data_circ_in, data_circ_out, data_req_in, data_req_out, data_req_reg, data_circ_reg;
logic overwrite, failed, clk, rst;

// declare cmu
circular_memory_unit dut(.*);

initial begin

// initialize values
addr_circ_in = $random;
addr_req_in = $random;
id_circ_in = $random;
id_req_in = $random;
packet_type_circ_in = $random;
packet_type_req_in = $random;
data_circ_in = $random;
data_req_in = $random;
clk = 0;
failed = 0;
rst = 1;
overwrite = 0;
@(posedge clk)

// end rst
rst = 0;
@(posedge clk)

// loop through 1000 values
for(int i = 0; i<1000; i++) begin
  @(negedge clk)
  addr_circ_in = $random;
  addr_req_in = $random;
  id_circ_in = $random;
  id_req_in = $random;
  packet_type_circ_in = $random;
  packet_type_req_in = $random;
  data_circ_in = $random;
  data_req_in = $random;

  // verify values
  if(overwrite) begin
    if(!(addr_circ_out===addr_req_reg)) begin
      failed = 1;
      $display("overwrite high but requestee addr not used - ERROR");
    end 
    if (!(id_circ_out===id_req_reg)) begin
      failed = 1;
      $display("overwrite high but requestee id not used - ERROR");
    end 
    if (!(data_circ_out===data_req_reg)) begin
      failed = 1;
      $display("overwrite high but requestee data not used - ERROR");
    end
    if (!(packet_type_circ_out===packet_type_req_reg)) begin
      failed = 1;
      $display("overwrite high but requestee packet_type not used - ERROR");
    end
  end else begin
    if(!(addr_circ_out===addr_circ_reg)) begin
      failed = 1;
      $display("overwrite low but circ addr not used - ERROR");
    end
    if (!(id_circ_out===id_circ_reg)) begin
      failed = 1;
      $display("overwrite low but circ id not used - ERROR");
    end
    if (!(data_circ_out===data_circ_reg)) begin
      failed = 1;
      $display("overwrite low but circ data not used - ERROR");
    end
    if (!(packet_type_circ_out===packet_type_circ_reg)) begin
      failed = 1;
      $display("overwrite low but circ packet_type not used - ERROR");
    end
  end
  overwrite = $random;
end

// if failed == 0 all tests have passed
if(failed === 0) begin
  $display("YAHOO! ALL TESTS PASSED!");
end


$stop;

end


// if these are ever not equal then this this is incorrect behavior
always @(posedge clk) begin
  if(!(id_req_out===id_circ_in)) begin
    failed = 1;
    $display("id_req_out isn't equal to id_circ_in");
  end else if (!(data_req_out===data_circ_in)) begin
    failed = 1;
    $display("data_req_out isn't equal to data_circ_in");
  end else if (!(packet_type_req_out===packet_type_circ_in)) begin
    failed = 1;
    $display("packet_type_req_out isn't equal to packet_type_circ_in");
  end else if (!(addr_req_out===addr_circ_in)) begin
    failed = 1;
    $display("addr_req_out isn't equal to addr_circ_in");
  end
end

// clk
always begin
  #5 clk = ~clk;
end

// reg inputs to be compared in verification
always @(posedge clk) begin
  data_req_reg = data_req_in;
  data_circ_reg = data_circ_in;
  addr_circ_reg = addr_circ_in;
  addr_req_reg = addr_req_in;
  id_circ_reg = id_circ_in;
  id_req_reg = id_req_in;
  packet_type_circ_reg = packet_type_circ_in;
  packet_type_req_reg = packet_type_req_in;
end

endmodule
