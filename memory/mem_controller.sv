module mem_controller #(
parameter DEPTH = 512
)
(
input logic empty, rd_done, full, wr_done, clk, rst,
output logic rd_go, rd_en, wr_go, wr_en, overwrite,
input logic [35:0] addr_in,
output logic [35:0] rd_addr, wr_addr, addr_out,
output logic [15:0] wr_size, cache_lines,
input logic [511:0] rd_data,
output logic [511:0] wr_data,
input logic [DEPTH-1:0] data_in,
output logic [DEPTH-1:0] data_out,
input logic [3:0] id_req_in,
output logic [3:0] id_req_out,
input logic [2:0] packet_type_req_in,
output logic [2:0] packet_type_req_out
);

logic valid_req, circ_available, next_read, next_write, wb_rst, next_writeback, wr_ctr_en;
logic [3:0] read_index, write_index, circ_index;
logic [15:0] [DEPTH-1:0] buffer_data;
logic [15:0] [35:0] buffer_addrs;
logic [15:0] buffer_r, buffer_w, buffer_r_we, buffer_w_we, buffer_written;
logic [15:0] buffer_wb_rst, buffer_circ_w_we, buffer_circ_r_we;
logic [15:0] [3:0] buffer_valids;
logic [2:0] write_to_buffer;
logic [1:0] wr_ctr;
logic [511:0] buffer_write_mod_data;

enum {idle, working} 
read_state, next_read_state, write_state, next_write_state, writeback_state, next_writeback_state; 

assign wr_size = 16'h0001;
assign cache_lines = 16'h0001;
assign id_req_out = circ_index;
assign addr_out = buffer_addrs[circ_index];


// hal interface!! changes needed here probably
assign rd_addr = buffer_addrs[read_index];
assign wr_addr = buffer_addrs[write_index];
assign wr_data = buffer_data[write_index];

assign valid_req = (id_req_in==3'b011) | (id_req_in==3'b001);
assign circ_available = valid_req | (id_req_in==3'b000);

always_ff @(posedge clk, posedge rst) begin
  if (rst) begin
    read_index <= 0;
  end else if (next_read) begin
    read_index <= read_index + 1;
  end
end

always_ff @(posedge clk, posedge rst) begin
  if (rst) begin
    write_index <= 0;
  end else if (next_write) begin
    write_index <= write_index + 1;
  end
end

// read fsm
always_comb begin
  
  // defaults
  next_read = 1'b1;
  write_to_buffer[0] = 1'b0;
  rd_go = 1'b0;
  rd_en = 1'b0;
  next_read_state = idle;
  
  case(read_state)
    idle: begin
      if ((~|buffer_valids[read_index]) & (buffer_r[read_index])) begin
        next_read_state = working;
        rd_go = 1'b1;
        next_read = 1'b0;
      end
    end

    working: begin
      rd_en = ~empty;
      write_to_buffer[0] = ~empty;
      if (rd_done) begin
        next_read_state = idle;
      end else begin
        next_read = 1'b0;
        next_read_state = working;
      end
    end
  endcase
end

// write fsm
always_comb begin
  
  // defaults
  next_write = 1'b1;
  write_to_buffer[1] = 1'b0;
  wr_go = 1'b0;
  wr_en = 1'b0;
  next_write_state = idle;
  
  case(write_state)
    idle: begin
      if ((&buffer_valids[write_index]) & (buffer_w[write_index]) & ~buffer_written[write_index]) begin
        next_write_state = working;
        wr_go = 1'b1;
        next_write = 1'b0;
      end
    end

    working: begin
      wr_en = ~full;
      if (wr_done) begin
        write_to_buffer[1] = 1'b1;
        next_write_state = idle;
      end else begin
        next_write = 1'b0;
        next_write_state = working;
      end
    end
  endcase
end

// writeback fsm
always_comb begin
  
  // defaults
  next_writeback = 1'b1;
  write_to_buffer[2] = 1'b0;
  next_writeback_state = idle;
  
  case(writeback_state)
    idle: begin
      if (buffer_w[circ_index] & buffer_written[circ_index]) begin
        next_writeback_state = idle;
        next_writeback = circ_available;
        write_to_buffer[2] = circ_available;
        overwrite = circ_available;
        packet_type_req_out = 3'b101;
      end else if (buffer_r[circ_index] & (&buffer_valids[circ_index])) begin
        if(DEPTH == 512) begin
          next_writeback_state = idle;
          next_writeback = circ_available;
          write_to_buffer[2] = circ_available;
          overwrite = circ_available;
          packet_type_req_out = 3'b110;
        end else if (DEPTH == 128) begin
          next_writeback = 1'b0;
          overwrite = circ_available;
          packet_type_req_out = 3'b110;
          wr_ctr_en = circ_available;
          next_writeback_state = working;
        end
      end
    end

    working: begin
      packet_type_req_out = 3'b110;
      wr_ctr_en = circ_available;
      write_to_buffer[2] = circ_available;
      if (&wr_ctr & circ_available) begin
        next_writeback = 1'b1;
        next_writeback_state = idle;
      end else begin
        next_writeback = 1'b0;
        next_writeback_state = working;
      end
    end
  endcase
end

genvar i;
generate
  for(i = 0; i < 16; i++) begin

    assign buffer_r_we[i] = buffer_r[i] & (write_to_buffer==3'b001) & (read_index==i);  
    assign buffer_w_we[i] = buffer_w[i] & (write_to_buffer==3'b010) & (write_index==i);
    assign buffer_circ_w_we[i] = (id_req_in==i) & (packet_type_req_in==3'b001);
    assign buffer_circ_r_we[i] = (id_req_in==i) & (packet_type_req_in==3'b011);
    assign buffer_wb_rst[i] = (circ_index==i) & (write_to_buffer==3'b100);
  
    if (DEPTH == 512) begin
    assign buffer_write_mod_data = wr_data;
    end // else if (DEPTH == 128) begin // this is commented out because compiler didn't like
     // case(addr_in[5:4]) 
   //     2'b00: assign buffer_write_mod_data = {buffer_data[i][511:128], wr_data};
   //     2'b01: assign buffer_write_mod_data = {buffer_data[i][511:256], wr_data, buffer_data[i][127:0]};
   //     2'b10: assign buffer_write_mod_data = {buffer_data[i][511:384], wr_data, buffer_data[i][255:0]};
   //     2'b11: assign buffer_write_mod_data = {wr_data, buffer_data[i][383:0]};
   //   endcase
  //  end

    always_ff @(posedge clk, posedge rst) begin
      if (rst) begin
        buffer_data[i] <= 0;
        buffer_addrs[i] <= 0;
        buffer_valids[i] <= 0;
        buffer_written[i] <= 0;
        buffer_r[i] <= 0;
        buffer_w[i] <= 0;
      end else if (buffer_wb_rst[i]) begin
        buffer_data[i] <= 0;
        buffer_addrs[i] <= 0;
        buffer_valids[i] <= 0;
        buffer_written[i] <= 0;
        buffer_r[i] <= 0;
        buffer_w[i] <= 0;
      end else if (buffer_r_we[i]) begin
        buffer_data[i] <= rd_data;
        buffer_valids[i] <= 4'hF;
      end else if (buffer_w_we[i]) begin
        buffer_written <= 1'b1;
      end else if (buffer_circ_w_we[i]) begin
        buffer_data[i] <= buffer_write_mod_data;
        buffer_w[i] <= 1'b1;
        buffer_addrs[i] <= addr_in;
        if (DEPTH == 512) begin
          buffer_valids[i] <= 4'hF;
        end else if (DEPTH == 128) begin
          buffer_valids[i][addr_in[5:4]] <= 1'b1;
        end else if (buffer_circ_r_we[i]) begin
        buffer_r[i] <= 1'b1;
        buffer_addrs[i] <= addr_in;
        end
      end
    end
  end
endgenerate

// state flops
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    read_state <= idle;
    write_state <= idle;
    writeback_state <= idle;
  end else begin
    read_state <= next_read_state;
    write_state <= next_write_state;
    writeback_state <= next_writeback_state;
  end
end

// read index counter
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    read_index <= 0;
  end else if(next_read) begin
    read_index <= read_index + 1;
  end
end

// write index counter
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    write_index <= 0;
  end else if(next_write) begin
    write_index <= write_index + 1;
  end
end

// writeback index counter
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    circ_index <= 0;
  end else if(next_writeback) begin
    circ_index <= circ_index + 1;
  end
end


// writeback index counter
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    circ_index <= 0;
  end else if(next_writeback) begin
    circ_index <= circ_index + 1;
  end
end

// writeback ctr
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    wr_ctr <= 0;
  end else if(wr_ctr_en) begin
    wr_ctr <= wr_ctr + 1;
  end
end
endmodule