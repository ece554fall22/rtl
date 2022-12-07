module tb_mem_controller();

//
// This module tests the mem_controller by initiating 17 circular memory units,
// and then having all of them not connected to the mem controller send read/write requests
// then wait on those requests and validate that they went through properly
//

logic empty, rd_done, full, wr_done, rd_go, rd_en, wr_go, wr_en, overwrite, clk, rst, mmioWrValid;
logic [27:0] mmio_addr;
logic [35:0] addr_in, addr_out; //rd_addr_sans_mmio, wr_addr_sans_mmio
logic [63:0] wr_addr, rd_addr;
logic [15:0] wr_size, cache_lines;
logic [511:0] rd_data, wr_data;
logic [511:0] data_in, data_out;
logic [3:0] id_req_in, id_req_out;
logic [2:0] packet_type_req_in, packet_type_req_out;

enum {idle, stalling, working} hal_write, hal_write_next, hal_read, hal_read_next;

logic [16:0] overwrites;
logic [16:0] [35:0] addrs_circ_in, addrs_req_in, addrs_circ_out, addrs_req_out;
logic [16:0] [511:0] datas_circ_in, datas_circ_out, datas_req_in, datas_req_out;
logic [16:0] [4:0] ids_circ_in, ids_req_in, ids_circ_out, ids_req_out;
logic [16:0] [2:0] packet_types_circ_in, packet_types_circ_out, packet_types_req_in, packet_types_req_out;
logic [5:0] rand_delay_read, rand_delay_write;
logic [5:0] rand_read, rand_write;
logic [15:0] rand_bits;
logic write_dec, read_dec;
logic [15:0] read_write_state;
logic [15:0] state, next_state;
logic [15:0] [35:0] expected_addrs;
logic [15:0] [511:0] expected_wr_datas;
logic [15:0] write_done;
logic failed, set_rand_delay_write, set_rand_delay_read;

int requests_received;
int requests_sent;

//assign rd_addr = {rd_addr_sans_mmio, mmio_addr};
//assign wr_addr = {wr_addr_sans_mmio, mmio_addr};
assign mmio_addr = 28'h0000000;
assign mmioWrValid = 1'b1;

assign packet_type_req_in = packet_types_req_out[16];

mem_controller dut(.*);

// sets up 16 circular memory units and their state machines just processing random read/write requests
genvar k;
generate
  for(k = 0; k < 17; k++) begin
    if(k==0) begin
      assign addrs_circ_in[k] = addrs_circ_out[16];
      assign datas_circ_in[k] = datas_circ_out[16];
      assign ids_circ_in[k] = ids_circ_out[16];
      assign packet_types_circ_in[k] = packet_types_circ_out[16];
    end else if (k==16) begin
      assign addrs_circ_in[k] = addrs_circ_out[k-1];
      assign datas_circ_in[k] = datas_circ_out[k-1];
      assign ids_circ_in[k] = ids_circ_out[k-1];
      assign packet_types_circ_in[k] = packet_types_circ_out[k-1];
      assign packet_types_req_in[k] = packet_type_req_out;
      assign packet_types_req_out[k] = packet_types_req_in;
      assign ids_req_in[k] = id_req_out;
      assign ids_req_out[k] = id_req_in;
      assign datas_req_in[k] = data_out;
      assign datas_req_out[k] = data_in;
      assign addrs_req_in[k] = addr_out;
      assign addrs_req_out[k] = addr_in;
    end else begin
      assign addrs_circ_in[k] = addrs_circ_out[k-1];
      assign datas_circ_in[k] = datas_circ_out[k-1];
      assign ids_circ_in[k] = ids_circ_out[k-1];
      assign packet_types_circ_in[k] = packet_types_circ_out[k-1];
    end
 
   // initiate the 17 circular memory units
   circular_memory_unit circ(.clk(clk), .rst(rst), .overwrite(overwrites[k]), .addr_circ_in(addrs_circ_in[k]), 
      .addr_circ_out(addrs_circ_out[k]), .addr_req_in(addrs_req_in[k]), .addr_req_out(addrs_req_out[k]),
      .data_circ_in(datas_circ_in[k]), .data_circ_out(datas_circ_out[k]), .data_req_in(datas_req_in[k]), 
      .data_req_out(datas_req_out[k]), .id_circ_in(ids_circ_in[k]), .id_circ_out(ids_circ_out[k]), 
      .id_req_in(ids_req_in[k]), .id_req_out(ids_req_out[k]), .packet_type_circ_in(packet_types_circ_in[k]), 
      .packet_type_circ_out(packet_types_circ_out[k]), .packet_type_req_in(packet_types_req_in[k]), .packet_type_req_out(packet_types_req_out[k]));
  
  // simple state machines run read/write requests to random addresses on repeat
  if(!(k==16)) begin
    always_comb begin
      // defaults
      packet_types_req_in[k] = 0;
      ids_req_in[k] = k | 4'h0;
      addrs_req_in[k] = $random;
      datas_req_in[k] = $random;
      overwrites[k] = 0;
      rand_bits[k] = $random;
      next_state[k] = 1'b0;

      // case statement
      case(state[k])
        1'b0: begin
          if(packet_type_req_out==3'b000) begin
            overwrites[k] = 1'b1;
            if(rand_bits[k]) begin
              packet_types_req_in[k] = 3'b001;
            end else begin
              packet_types_req_in[k] = 3'b011;
            end
          end
        end
        1'b1: begin
          if(packet_types_req_out[k]==3'b101 & read_write_state[k]) begin
            overwrites[k] = 1'b1;
            ids_req_in[k] = 0;
          end else if (packet_types_req_out[k]==3'b110 & ~read_write_state[k]) begin
            overwrites[k] = 1'b1;
            ids_req_in[k] = 0;
          end
          next_state[k] = 1'b1;
        end
      endcase
    end

      // state flop and the flop holding if the state machine is waiting on read or write
      always_ff @(posedge clk) begin
        if(rst) begin
          read_write_state[k] <= 0;
          state[k] <= 1'b0;
        end else begin
          if(next_state[k]==1'b1 & state[k]== 1'b0) begin
            read_write_state <= rand_bits[k];
          end
          state[k] <= next_state[k];
        end
      end
      // verification of reads and writes
      // whenever a read or write is requested it is stored and when one is received
      // it is compared against the expected
      always @(posedge clk) begin
        if(state[k]==1'b0 & next_state[k]==1'b1 & rand_bits[k]) begin
          expected_wr_datas[k] <= datas_req_in[k];
          expected_addrs[k] <= addrs_req_in[k];
          requests_sent += 1;
        end else if(state[k]==1'b0 & next_state[k]==1'b1 & ~rand_bits[k]) begin
          expected_addrs[k] <= addrs_req_in[k];
          requests_sent += 1;
        end
        if (state[k]==1'b1 & ids_req_in[k]==ids_req_out[k] & ~read_write_state[k]) begin
          requests_received += 1;
          if(!(packet_types_req_in[k]==3'b110)) begin
            $display("state machine expected a read but received something else");
            failed = 1;
          end
          if(!(addrs_req_out[k]==expected_addrs[k])) begin
            $display("got wrong addr for read");
            failed = 1;
          end
          if(!(datas_req_out[k]=={{476{1'b0}}, expected_addrs[k]})) begin
            $display("got wrong data for read");
          end
        end else if(state[k]==1'b1 & ids_req_in[k]==ids_req_out[k] & read_write_state[k]) begin
          requests_received += 1;
          if(!(packet_types_req_in[k]==3'b101)) begin
            $display("state machine expected a write ack but received something else");
            failed = 1;
            write_done = 1'b0;
          end
        end
        if(wr_done && (wr_addr ==expected_addrs[k])) begin
          if(!(data_out==expected_wr_datas[k])) begin
            $display("got a write request at hal but data was not correct");
            failed = 1;
            write_done[k] = 1'b1;
          end
        end
      end
    end
  end
endgenerate


// runs the test
initial begin
write_done = 0;
clk = 0;
failed = 0;
rst = 1;
requests_received = 0;
requests_sent = 0;
@(posedge clk);
rst = 0;
@(posedge clk);

  for(int i = 0; i < 10000; i++) begin
    @(posedge clk);
  end

if((requests_received + 16 < requests_sent) | (requests_sent < 50)) begin
  $display("either requests are not being sent enough, or some requests were sent but not received");
end

if(!failed) begin
  $display("YAHOO! ALL TESTS PASSED!");
end

$stop();

end



// simulate hal read interface
always_comb begin
  // defaults
  empty = 1'b0;
  rd_done = 1'b0;
  read_dec = 1'b0;
  hal_read_next = idle;


  case(hal_read)
    idle: begin
      if(rd_go) begin
        set_rand_delay_read = 1'b1;
        if(rand_delay_read) begin
        read_dec = 1'b1;
        hal_read_next = stalling;
        empty = 1'b1;
        end else begin
          if(rd_go) begin
            hal_read_next = idle;
            rd_done = 1;
          end else
          hal_read_next = working;
        end
      end
    end
    stalling: begin
      if(!(rand_delay_read)) begin
        if(rd_go) begin
           hal_read_next = idle;
           rd_done = 1;
        end else
        hal_read_next = working;
      end else begin
        hal_read_next = stalling;
        read_dec = 1'b1;
        empty = 1'b1;
      end
    end
    working: begin
      if(rd_go) begin
        hal_read_next = idle;
        rd_done = 1;
      end
        hal_read_next = working;
    end
  endcase
end

// hal state machine flops
always @(posedge clk) begin
  if(rst) begin
    hal_read <= idle;
  end else begin
    if(read_dec) begin
      rand_delay_read <= rand_delay_read - 1;
    end else if (set_rand_delay_read) begin
      rand_delay_read <= rand_read;
    end
      hal_read = hal_write_next;
  end
end

assign rd_data = (rd_done) ? {{448{1'b0}}, rd_addr} : {512{1'b0}};

// simulate hal write interface
always_comb begin
  // defaults
  full = 1'b0;
  wr_done = 1'b0;
  write_dec = 1'b0;
  hal_write_next = idle;

  case(hal_write)
    idle: begin
      if(wr_go) begin
        set_rand_delay_write = 1'b1;
        if(rand_delay_write) begin
        write_dec = 1'b1;
        hal_write_next = stalling;
        full = 1'b1;
        end else begin
          if(wr_go) begin
            hal_write_next = idle;
            wr_done = 1;
          end else
          hal_write_next = working;
        end
      end
    end
    stalling: begin
      if(!(rand_delay_write)) begin
        if(wr_go) begin
           hal_write_next = idle;
           wr_done = 1;
        end else
        hal_write_next = working;
      end else begin
        hal_write_next = stalling;
        write_dec = 1'b1;
        full = 1'b1;
      end
    end
    working: begin
      if(wr_go) begin
        hal_write_next = idle;
        wr_done = 1;
      end
        hal_write_next = working;
    end
  endcase
end

// hal read sm flops
always @(posedge clk) begin
  if(rst) begin
    hal_write <= idle;
  end else begin
    if(write_dec) begin
      rand_delay_write <= rand_delay_write - 1;
    end else if (set_rand_delay_write) begin
      rand_delay_write <= rand_write;
    end
      hal_write <= hal_write_next;
  end
end

// random values
always @(posedge clk) begin
  rand_write = $random;
  rand_read = $random;
end

// confirm writes
always @(posedge clk) begin
  
end

always #5
	clk = ~clk;

endmodule
