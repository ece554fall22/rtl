module data_cache_controller
#(parameter ID = 0)
(
input logic clk, rst, r, faa,
input logic [1:0] w_type, flushtype,
input logic [35:0] addr, mem_addr_in,
input logic [127:0] w_data,
input logic [511:0] mem_data_in,
input logic [3:0] id_req_in,
input logic [2:0] packet_type_req_in,
output logic [127:0] data_out,
output logic [511:0] mem_data_out,
output logic stall, overwrite, done,
output logic [35:0] mem_addr_out,
output logic [3:0] id_req_out,
output logic [2:0] packet_type_req_out
);

logic [11:0] flush_ctr;
logic [7:0] r_index, w_index;
logic [21:0] r_tag, w_tag, tag_out;
logic [5:0] r_line, w_line, fill_buffer_write_line;
logic [127:0] dcache_w_data, dcache_data_out, read_mod_write_data, store_buffer, fwd_data_reg;
logic [127:0] read_data_out, read_mod_write_data_32, read_mod_write_data_36;
logic [3:0] [127:0] fill_buffer, write_back_buffer;
logic [1:0] dcache_flushtype, w_way, way, w_type_reg, evict_way_reg, evict_line, fwd_reg, fwd;
logic [1:0] flushtype_reg, no_tagcheck_way;
logic w_tagcheck, hit, dirty, dcache_r, dcache_w, evict_way_capture, ctr_en, no_tagcheck_read;
logic fill_stall, fill_buffer_en, synch_buffer_rst, r_reg, fill_buffer_write;
logic flush_ctr_en, flush_ctr_en_4, flush_ctr_en_16;
logic [35:0] addr_reg, evict_addr_reg;
logic [3:0] fill_buffer_valids, fill_buffer_writtens, dirty_array, fill_buffer_writtens_next;

// instantiation of data cache module
data_cache dcache(.clk(clk), .rst(rst), .r_index(r_index), .w_index(w_index), 
                  .r_tag(r_tag), .w_tag(w_tag), .r_line(r_line), .w_line(w_line),
                  .w_data(dcache_w_data), .data_out(dcache_data_out),
                  .flushtype(dcache_flushtype), .w_way(w_way), .way(way),
                  .w_tagcheck(w_tagcheck), .hit(hit), .dirty(dirty),
		  .r(dcache_r), .w(dcache_w), .dirty_array(dirty_array), .no_tagcheck_read(no_tagcheck_read),
                  .no_tagcheck_way(no_tagcheck_way), .tag_out(tag_out));

assign no_tagcheck_way = (~|flushtype_reg) ? ((evict_way_capture) ? way : evict_way_reg) : flush_ctr[3:2];

enum {
idle, writing_back, write_back_ack_wait, 
sending_fill_req, waiting_on_fill,
flushing_line, flush_line_ack_wait,
flushing_dirty, flush_dirty_ack_wait,
flushing_clean, fetch_and_add_send,
fetch_and_add_receive, synch_write,
synch_write_ack_wait, synch_read_send,
synch_read_receive} 
state, next_state; 

logic done_reg;



always @(posedge overwrite) begin
//  $display("inserting/retreiving from cmu");
    if(packet_type_req_out==3'b001) begin
      $display("Sending wr to addr %h", mem_addr_out);
      $display("Sending wr data %h", mem_data_out);
    end
    if(packet_type_req_in==3'b110) begin
      $display("Receiving rd to addr %h", mem_addr_in);
      $display("Receiving rd data %h", mem_data_in);
    end
end

always @(posedge done) begin
  $display("test should be complete");
end

//always @(posedge clk) begin
//  $display("done has gone high!!");
//end

always @(posedge clk) begin
//  $display("done: %b", done);
end

always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    done_reg <= 0;
  end else if (done) begin
    done_reg <= 1'b1; 
  end
end


assign id_req_out = ID | 4'h0;
assign done = ((state==flush_dirty_ack_wait) | (state==flushing_dirty)) & (next_state==idle);

  always @(posedge clk) begin
// $display("current packet_type_req_in = %b", packet_type_req_in);
// $display("current packet_type_req_out = %b", packet_type_req_out);
//   $display("current id_req_in = %b", id_req_in);
//   $display("current id_req_out = %b", id_req_out);
//   $display("current addr_req_in = %b", mem_addr_in);
//   $display("current addr_req_out = %b", mem_addr_out);
//   $display("current overwrite = %b", overwrite);
//    if(state!=next_state)
//       $display("Controller - state = %b", state);
  end

// FSM state logic
always_comb begin
  // defaults
  r_index = addr[13:6];
  w_index = addr_reg[13:6];
  r_tag = addr[35:14];
  w_tag = addr_reg[35:14];
  r_line = addr[5:0];
  w_line = (fill_buffer_write) ? fill_buffer_write_line : addr_reg[5:0];
  dcache_w_data = (fill_buffer_write) ? fill_buffer[fill_buffer_write_line[5:4]] : read_mod_write_data;
  dcache_flushtype = flushtype;
  w_way = (fill_buffer_write) ? evict_way_reg : way;
  w_tagcheck = |w_type & ~fill_buffer_write;
  dcache_r = r | (|w_type);
  dcache_w = (|w_type_reg) | fill_buffer_write;
  next_state = idle;
  evict_way_capture = 1'b0;
  stall = 1'b0;
  ctr_en = 1'b0;
  packet_type_req_out = 3'b001;
  overwrite = 1'b0;
  mem_data_out = {dcache_data_out, write_back_buffer[2], write_back_buffer[1], write_back_buffer[0]};
  mem_addr_out = addr_reg;
  synch_buffer_rst = 1'b0;
  dcache_flushtype = 2'b00;
  no_tagcheck_read = 1'b0;
  flush_ctr_en = 1'b0;
  flush_ctr_en_4 = 1'b0;
  flush_ctr_en_16 = 1'b0;
  data_out = read_data_out;
  fill_buffer_en = 1'b0;
  
  case(state)

      // cache hits, read and writes should all be processed in idle
      idle: begin
//	      $display("Controller - idle");
//           if (~|addr[35:6]) begin
//             stall = 1'b1;
//             mem_data_out = {{48{8'h00}}, w_data};
//             if(faa) begin
//               overwrite = ~|packet_type_req_in;
//               packet_type_req_out = 3'b111;
//               next_state = (~|packet_type_req_in) ? fetch_and_add_send : fetch_and_add_receive;
//             end else if (|w_type) begin
//               overwrite = ~|packet_type_req_in;
//               packet_type_req_out = 3'b010;
//               next_state = (~|packet_type_req_in) ? synch_write : synch_write_ack_wait;
//             end else if (r) begin
//               overwrite = ~|packet_type_req_in;
//               packet_type_req_out = 3'b100;
//               next_state = (~|packet_type_req_in) ? synch_read_send : synch_read_receive;
//             end			
//           end else
           if (flushtype_reg == 2'b11) begin
             next_state = flushing_clean;
             evict_way_capture = 1'b1;
             stall = 1'b1;
             dcache_w = 1'b0;
             dcache_r = 1'b1;
             r_index = flush_ctr[11:4];
             r_line = {flush_ctr[1:0], 4'b0000};
           end else if (flushtype_reg == 2'b10) begin
             next_state = flushing_dirty;
             evict_way_capture = 1'b1;
             stall = 1'b1;
             dcache_w = 1'b0;
             dcache_r = 1'b1;
             r_index = flush_ctr[11:4];
             r_line = {flush_ctr[1:0], 4'b000};
             no_tagcheck_read = 1'b1;
           end else if (flushtype_reg == 2'b01 & hit) begin
             next_state = flushing_line;
             evict_way_capture = 1'b1;
             stall = 1'b1;
             dcache_w = 1'b0;
             dcache_r = 1'b1;
             r_line = {evict_line, 4'b0000};
           end else if (~hit & dirty &(r_reg | (|w_type_reg))) begin     // dirty miss means that writeback to memory is needed
//             $display("Initiating writeback from idle");
             next_state = writing_back;
             evict_way_capture = 1'b1;
             stall = 1'b1;
             dcache_w = 1'b0;
             dcache_r = 1'b1;
             no_tagcheck_read = 1'b1;
             r_line = {evict_line, 4'b0000};
           end else if (~hit & ~dirty & (r_reg | (|w_type_reg))) begin    // clean miss means that a fill operation must take place
//	       $display("Initiating fill req for invalid/clean line");
//	       $display("packet type in is %b", packet_type_req_in);
               if(~|packet_type_req_in) begin	
//		 $display("should end up in waiting_on_fill next??");
                 next_state = waiting_on_fill;
                 evict_way_capture = 1'b1;
                 //stall = fill_stall;
                 stall = 1'b1;
                 dcache_r = 1'b0;
                 dcache_w = 1'b0;
                 overwrite = 1'b1;
                 packet_type_req_out = 3'b011;
               end else begin		        // if circ mem is full have to wait for open slot to put in request
                 next_state = sending_fill_req;
                 evict_way_capture = 1'b1;
                 //stall = fill_stall;
                 dcache_r = 1'b0;
                 dcache_w = 1'b0;
                 stall = 1'b1;
               end
           end
      end

      // writes out cacheline to circ mem
      writing_back: begin
//	   $display("Controller - writing_back");
           dcache_w = 1'b0;
           stall = 1'b1;
           if((&evict_line) & (~|packet_type_req_in)) begin // when all writing is done must wait for ack from mem controller
             next_state = write_back_ack_wait;
             overwrite = 1'b1;
             ctr_en = 1'b1;
             dcache_r = 1'b0;
             mem_addr_out = evict_addr_reg;
           end else begin
             ctr_en = ~&evict_line;
             next_state = writing_back;
             dcache_r = 1'b1;
             r_line = {evict_line, 4'b0000};
             no_tagcheck_read = 1'b1;
	     //r_index = evict_addr_reg[35:28];
             //r_tag = evict_addr_reg[27:6];
           end
      end

      // wait on ack stall and disable reading and writing
      write_back_ack_wait: begin
//	$display("Controller - writing_back ack wait");
        if((packet_type_req_in==3'b101) & (id_req_in==id_req_out)) begin
          //stall = fill_stall;
          stall = 1'b1;
          dcache_r = 1'b0;
          dcache_w = 1'b0;
          next_state = waiting_on_fill;
          overwrite = 1'b1;
          packet_type_req_out = 3'b011;
          mem_addr_out = addr_reg;
        end else begin
          stall = 1'b1;
          dcache_r = 1'b0;
          dcache_w = 1'b0;
          next_state = write_back_ack_wait;
        end
      end
      
      // wait for open slot in circ mem to send the mem read request
      sending_fill_req: begin
//      $display("Controller - sending fill request");
        packet_type_req_out = 3'b011;
        dcache_r = 1'b0;
        dcache_w = 1'b0;
        if(~|packet_type_req_in) begin
//        $display("Controller - overwriting cmu");
          //stall = fill_stall;
          stall = 1'b1;
          next_state = waiting_on_fill;
          overwrite = 1'b1;
        end else begin
          next_state = sending_fill_req;
          stall = 1'b1;
        end
      end

      // waits for the read data from memory, doesn't go back to idle until all of them have been written
      // writes will be slotted in when cache write port isn't being used by processor, or if a miss occurs
      // and write must be completed to free the fill buffer
      waiting_on_fill: begin
//	$display("Controller - waiting on fill data");
        if(&fill_buffer_writtens) begin
          dcache_w = fill_buffer_write;
          stall = 1'b1;
          next_state = idle;
          synch_buffer_rst = 1'b1;
        end else if((packet_type_req_in==3'b110) & (id_req_in==id_req_out)) begin
          //stall = fill_stall;
          dcache_w = fill_buffer_write;
          dcache_r = 1'b0;
          overwrite = 1'b1;
          packet_type_req_out = 3'b000;
          stall = 1'b1;
          fill_buffer_en = 1'b1;
          next_state = waiting_on_fill;
        end else begin
          dcache_r = 1'b0;
          dcache_w = fill_buffer_write;
          next_state = waiting_on_fill;
          //stall = fill_stall;
          stall = 1'b1;
        end
      end
      
      flushing_line : begin
//	   $display("Controller - flushing line");
           dcache_w = 1'b0;
           stall = 1'b1;
           if((&evict_line) & (~|packet_type_req_in)) begin // when all writing is done must wait for ack from mem controller
             dcache_flushtype = 2'b01;
             next_state = flush_line_ack_wait;
             ctr_en = 1'b1;
             overwrite = 1'b1;
           end else begin
             ctr_en = ~&evict_line;
             next_state = flushing_line;
             dcache_r = 1'b1;
             r_line = (ctr_en) ? {evict_line + 1, 4'b0000} : {evict_line, 4'b0000};
             r_index = evict_addr_reg[35:28];
             r_tag = evict_addr_reg[27:6];
           end
      end

      // wait on ack stall and disable reading and writing
      flush_line_ack_wait: begin
//	   $display("Controller - flushing line ack wait");
        if((packet_type_req_in==3'b101) & (id_req_in==id_req_out)) begin
          next_state = idle;
          overwrite = 1'b1;
          packet_type_req_out = 3'b000;              // release circ mem slot
        end else begin
          stall = 1'b1;
          dcache_r = 1'b0;
          dcache_w = 1'b0;
          next_state = flush_line_ack_wait;
        end
      end

      flushing_dirty : begin
//	   $display("Controller - flushing dirty");
//         flush_ctr_en_4 = ~dirty_array[flush_ctr[3:2]];
           flush_ctr_en_4 = 1'b0;
           dcache_w = 1'b0;
           dcache_r = 1'b1;
           no_tagcheck_read = 1'b1;
           stall = 1'b1;
           if((&flush_ctr[1:0]) & (~|packet_type_req_in)) begin // when all writing is done must wait for ack from mem controller
             flush_ctr_en = 1'b1;
             dcache_flushtype = 2'b10;
             mem_addr_out = {tag_out[21:0], flush_ctr[11:4], flush_ctr[1:0], 4'h0};
             if(dirty_array[flush_ctr[3:2]]) begin
               overwrite = 1'b1;
               next_state = flush_dirty_ack_wait;
             end else if(&flush_ctr) begin
               next_state = idle;
             end else begin
               next_state = flushing_dirty;
             end
  //       end else if ((&flush_ctr[11:2]) & flush_ctr_en_4) begin
  //         no_tagcheck_read = 1'b1;
 //          stall = 1'b1;
 //          next_state = idle;
  //       end
           end else begin
//           flush_ctr_en = dirty_array[flush_ctr[3:2]] & (~&flush_ctr[1:0]);
             flush_ctr_en = ~&flush_ctr[1:0];
             next_state = flushing_dirty;
             r_line = {flush_ctr[1:0], 4'h0};
             r_index = flush_ctr[11:4];
           end
      end

      // wait on ack stall and disable reading and writing
      flush_dirty_ack_wait: begin
//	   $display("Controller - flushing dirty ack wait : flush_ctr:%h", flush_ctr);
        if((packet_type_req_in==3'b101) & (id_req_in==id_req_out) & ~|flush_ctr) begin
          next_state = idle;
          stall = 1'b1;
          overwrite = 1'b1;
          packet_type_req_out = 3'b000;              // release circ mem slot
        end else if((packet_type_req_in==3'b101) & (id_req_in==id_req_out)) begin
          stall = 1'b1;
          no_tagcheck_read = 1'b1;
          next_state = flushing_dirty;
          mem_addr_out = {tag_out[21:0], flush_ctr[11:4], flush_ctr[1:0], 4'h0};
          overwrite = 1'b1;
          packet_type_req_out = 3'b000;              // release circ mem slot
        end else begin
          stall = 1'b1;
          dcache_r = 1'b0;
          dcache_w = 1'b0;
          next_state = flush_dirty_ack_wait;
        end
      end

      flushing_clean : begin
//	   $display("Controller - flushing clean");
           flush_ctr_en_16 = 1'b1;
           dcache_w = 1'b0;
           dcache_r = 1'b1;
           stall = 1'b1;
           dcache_flushtype = 2'b11;
           r_index = flush_ctr[11:4];
           if(&flush_ctr[11:4]) begin // when all writing is done must wait for ack from mem controller
             next_state = idle;
           end else begin
             next_state = flushing_clean;
           end
      end
     
      // wait on ack stall and disable reading and writing
      fetch_and_add_send: begin
//	   $display("Controller - fetch and add sending");
        stall = 1'b1;
        dcache_r = 1'b0;
        dcache_w = 1'b0;
        mem_data_out = {{48{8'h00}}, w_data};
        if(~|packet_type_req_in) begin
          next_state = fetch_and_add_receive;
          overwrite = 1'b1;
          packet_type_req_out = 3'b111;              
        end else begin
          next_state = fetch_and_add_send;
        end
      end

      // wait on ack stall and disable reading and writing
      fetch_and_add_receive: begin
//	   $display("Controller - fetch and add receiving");
        dcache_r = 1'b0;
        dcache_w = 1'b0;
        if((packet_type_req_in==3'b110) & (id_req_in==id_req_out)) begin
          next_state = idle;
          data_out = mem_data_out;
          overwrite = 1'b1;
          packet_type_req_out = 3'b000;    // release circ mem unit            
        end else begin
          stall = 1'b1;
          dcache_r = 1'b0;
          dcache_w = 1'b0;
          next_state = fetch_and_add_send;
        end
      end

      // wait on ack stall and disable reading and writing
      synch_write: begin
//	   $display("Controller - synch write");
        mem_data_out = {{48{8'h00}}, w_data};
        stall = 1'b1;
        dcache_r = 1'b0;
        dcache_w = 1'b0;
        if(~|packet_type_req_in) begin
          next_state = synch_write_ack_wait;
          overwrite = 1'b1;
          packet_type_req_out = 3'b010;              
        end else begin
          next_state = synch_write;
        end
      end

      // wait on ack stall and disable reading and writing
      synch_write_ack_wait: begin
//	   $display("Controller - synch write ack wait");
        dcache_r = 1'b0;
        dcache_w = 1'b0;
        if((packet_type_req_in==3'b101) & (id_req_in==id_req_out)) begin
          next_state = idle;
          overwrite = 1'b1;
          packet_type_req_out = 3'b000;    // release circ mem unit            
        end else begin
          stall = 1'b1;
          dcache_r = 1'b0;
          dcache_w = 1'b0;
          next_state = synch_write_ack_wait;
        end
      end

      // wait on ack stall and disable reading and writing
      synch_read_send: begin
//	   $display("Controller - synch read send");
        stall = 1'b1;
        dcache_r = 1'b0;
        dcache_w = 1'b0;
        if(~|packet_type_req_in) begin
          next_state = synch_read_receive;
          overwrite = 1'b1;
          packet_type_req_out = 3'b100;              
        end else begin
          next_state = synch_read_send;
        end
      end

      // wait on ack stall and disable reading and writing
      synch_read_receive: begin
//	   $display("Controller - synch read receive");
        dcache_r = 1'b0;
        dcache_w = 1'b0;
        if((packet_type_req_in==3'b110) & (id_req_in==id_req_out)) begin
          next_state = idle;
          data_out = mem_data_out;
          overwrite = 1'b1;
          packet_type_req_out = 3'b000;    // release circ mem unit            
        end else begin
          stall = 1'b1;
          dcache_r = 1'b0;
          dcache_w = 1'b0;
          next_state = synch_read_receive;
        end
      end
  endcase
end


// state flop
always_ff @(posedge clk, posedge rst) begin
  if(rst)
    state <= idle;
  else
    state <= next_state;
end

// these flops hold write data from previous cycle
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    flushtype_reg <= 0;
    addr_reg <= 0;
    r_reg <= 0;
    w_type_reg <= 0;
    store_buffer <= 0;
    fwd_reg <= 0;
    fwd_data_reg <= 0;
  end else begin
    flushtype_reg <= flushtype;
    fwd_data_reg <= store_buffer;
    fwd_reg <= fwd;
    r_reg <= r;
    addr_reg <= addr; 
    w_type_reg <= w_type;
    store_buffer <= w_data;
  end
end

// evict info enable register
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    evict_way_reg <= 0;
    evict_addr_reg <= 0;
  end else if(evict_way_capture) begin
    evict_way_reg <= way;
    evict_addr_reg <= {tag_out, addr[13:0]};
  end
end

// fill buffer
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    fill_buffer[0] <= 0;
    fill_buffer[1] <= 0;
    fill_buffer[2] <= 0;
    fill_buffer[3] <= 0;
    fill_buffer_valids <= 0;
  end else if(synch_buffer_rst) begin
    fill_buffer[0] <= 0;
    fill_buffer[1] <= 0;
    fill_buffer[2] <= 0;
    fill_buffer[3] <= 0;
    fill_buffer_valids <= 0;
  end else if(fill_buffer_en) begin
    fill_buffer[0] <= mem_data_in[127:0];
    fill_buffer[1] <= mem_data_in[255:128];
    fill_buffer[2] <= mem_data_in[383:256];
    fill_buffer[3] <= mem_data_in[511:384];
    fill_buffer_valids = 4'b1111;
  end
end

// written metadata for fill buffer
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    fill_buffer_writtens <= 0;
  end else if (synch_buffer_rst) begin
    fill_buffer_writtens <= 0;
  end else begin
    fill_buffer_writtens <= fill_buffer_writtens_next;
  end
end

always_comb begin
  fill_buffer_writtens_next = fill_buffer_writtens;
  if(fill_buffer_write) begin
    fill_buffer_writtens_next[fill_buffer_write_line[5:4]] = 1'b1;
  end
end

// line counter
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    evict_line <= 0;
  end else if(ctr_en) begin
    evict_line <= evict_line + 1;
  end
end

always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    write_back_buffer <= 0;
  end else if(ctr_en | flush_ctr_en) begin
    write_back_buffer[0] <= (evict_line==2'b00 | flush_ctr[1:0]==2'b00) ? dcache_data_out : write_back_buffer[0];
    write_back_buffer[1] <= (evict_line==2'b01 | flush_ctr[1:0]==2'b01) ? dcache_data_out : write_back_buffer[1];
    write_back_buffer[2] <= (evict_line==2'b10 | flush_ctr[1:0]==2'b10) ? dcache_data_out : write_back_buffer[2];
    write_back_buffer[3] <= (evict_line==2'b11 | flush_ctr[1:0]==2'b11) ? dcache_data_out : write_back_buffer[3];
  end
end

// flush index/line counter
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    flush_ctr <= 0;
  end else if (flush_ctr_en_16) begin
     flush_ctr <= flush_ctr + 16;
  end else if (flush_ctr_en_4) begin
     flush_ctr <= flush_ctr + 4;
  end else if (flush_ctr_en) begin
     flush_ctr <= flush_ctr + 1;
  end
end
 
// bit 0 is forward from store buffer, bit 1 is forward from fill buffer
//assign fwd[0] = (addr_reg==addr) & |w_type_reg & hit & r;
//assign fwd[1] = (evict_addr_reg==addr) & (state != idle) & r;

// determines which line the fill buffer will write too
assign fill_buffer_write_line[5] = (~fill_buffer_writtens[3] & fill_buffer_valids[3]) | (~fill_buffer_writtens[2] & fill_buffer_valids[2]);
assign fill_buffer_write_line[4] = (~fill_buffer_writtens[3] & fill_buffer_valids[3]) | 
                                   ((~fill_buffer_writtens[1] & fill_buffer_valids[1]) & ~(~fill_buffer_writtens[2] & fill_buffer_valids[2]));
assign fill_buffer_write_line[3:0] = 4'b0000;

// 1 if the fill buffer will insert a write this cycle
assign fill_buffer_write = |(~fill_buffer_writtens & fill_buffer_valids);

// fill_stall is a special stall signal that is used while the state machine is filling
// some read and write requests can be processed while the cache is performing a fill
// stalls should only occur when this is not the case
//assign fill_stall = (r_reg | (|w_type_reg)) & ((~hit & ~|fwd_reg) | (fwd_reg[1] & ~fill_buffer_valids[addr[5:4]]) |
//                     ((evict_addr_reg==addr_reg) & (|w_type_reg)));

// following combinational logic creates the read modify write data input to the cache
// which is necessary due to the need to tagcheck before writing, as well
// as the logic for forwarding the data output of the module
always_comb begin
  case(w_line[3:2])
    2'b00: read_mod_write_data_32 = {dcache_data_out[127:32], store_buffer[31:0]};
    2'b01: read_mod_write_data_32 = {dcache_data_out[127:64], store_buffer[31:0], dcache_data_out[31:0]};
    2'b10: read_mod_write_data_32 = {dcache_data_out[127:96], store_buffer[31:0], dcache_data_out[63:0]};
    2'b11: read_mod_write_data_32 = {store_buffer[31:0], dcache_data_out[95:0]};
  endcase
  case(w_line[3])
    1'b0: read_mod_write_data_36 = {dcache_data_out[127:64], 28'h0000000, store_buffer[35:0]};
    1'b1: read_mod_write_data_36 = {28'h0000000, store_buffer[35:0], dcache_data_out[63:0]};
  endcase
  case(w_type_reg)
    2'b00: read_mod_write_data = store_buffer;
    2'b01: read_mod_write_data = read_mod_write_data_32;
    2'b10: read_mod_write_data = read_mod_write_data_36;
    2'b11: read_mod_write_data = store_buffer;
  endcase
//  case(fwd_reg)
//    2'b00: read_data_out <= dcache_data_out;
//    2'b01: read_data_out <= fwd_data_reg;
//    2'b10: read_data_out <= fill_buffer[addr_reg[5:4]];
//    2'b11: read_data_out <= fwd_data_reg;
//  endcase
end
  assign read_data_out = dcache_data_out;

endmodule
