module data_cache(w_index, r_index, w_tag, r_tag, w_line, r_line, w_data, flushtype, w_way,
                  w_tagcheck, rst, clk, w, r, last_write_from_mem, tag_out, data_out, way, hit, 
				  dirty, no_tagcheck_way, no_tagcheck_read, dirty_array);
input logic [7:0] w_index, r_index;		// indexes for write and read operation
input logic [17:0] w_tag, r_tag;		// the write tag and the tag to be compared for read
input logic [5:0] w_line, r_line;		// desired line for write and read, this module only uses the first two bits of these
input logic [127:0] w_data;				// data to be written in write operation
input logic [1:0] flushtype, w_way;		// type of flush 11 = flushclean 10 = flushdirty 01 = flushline 00 = noflush
										// w_way is the way to write
input logic [1:0] no_tagcheck_way;
input logic w_tagcheck, rst, clk, w, r; // w_tagcheck is a signal that signifies to the cache that this is a read being done for purposes of a tagcheck
input logic no_tagcheck_read;
input logic last_write_from_mem;		// assert on last write from memory to cache to make way valid
output logic [17:0] tag_out;            // this is important because it means next cycle there will be a write to this address, since metadata is read
output logic [127:0] data_out;          // once per cycle and needs to be used by the read that should be happenning simultaneously metadata needs to be updated
output logic [1:0] way;                 // on the cycle that w_tagcheck is asserted
output logic hit, dirty;
output logic [3:0] dirty_array;
	
logic r_reg, fwd_metadata, fwd_data, fwd_metadata_reg, fwd_data_reg, fwd_tag, fwd_tag_reg;
logic [9:0] rd_addr;
logic [7:0] r_index_reg;
logic [11:0] wr_index;
logic [127:0] data_reg;
logic [511:0] block_data_out, data_fwded;
logic [10:0] metadata_out, metadata_fwded, metadata_reg;
logic [10:0] metadata_in;
logic [71:0] block_tag_out, tag_fwded;
logic [17:0] tag_reg, wr_tag;
logic [17:0] tag_data [3:0];
logic [127:0] data [3:0];
logic [3:0] valid_array, fwd_way_reg_onehot;
logic [2:0] plru;
logic [3:0] match;
logic [1:0] victimway, fwd_way, fwd_way_reg;
logic [7:0] meta_wr_addr;
logic meta_wr_en;

data_blockram data_blockram(.clk1(clk), .rst(rst), .rd_addr(rd_addr), .wr_data(w_data), 
	.wr_addr(wr_index), .wr_en(w), .data_out(block_data_out));

metadata_registers metadata(.clk(clk), .rst(rst), .rd_addr(r_index),.data_in(metadata_in), 
			    .wr_addr(meta_wr_addr), .wr_en(r_reg & ~no_tagcheck_read), .data_out(metadata_out));

tag_blockram tags(.tag_out(block_tag_out), .r_index(r_index), .w_index({w_index, w_way}), .tag_in(w_tag), 
                 .wr_en(w), .rst(rst), .clk(clk));

// Have to indicate that the data written from memory is valid
next_metadata_comb next_metadata(.way(way), .plru(plru), .valid_array(valid_array), .dirty_array(dirty_array), 
                         .w_tagcheck(w_tagcheck), .flushtype(flushtype), .hit(hit), .next_metadata(metadata_in),
						 .last_write_from_mem(last_write_from_mem));

  assign rd_addr = {r_index, r_line[5:4]};
  assign wr_index = {w_index, w_line[5:4], w_way};
  
  assign meta_wr_addr = last_write_from_mem ? w_index : r_index_reg;
  assign meta_wr_en = last_write_from_mem | (r_reg & ~no_tagcheck_read); // enable to write valid bit
  
  genvar i;
  generate
    for (i = 0; i < 4; i++) begin
      assign tag_data[3-i] = tag_fwded[(71-(i*18)):(54-(i*18))];      // splits up outputs of tag and data blockrams into their 4 individual values
      assign data[3-i] = data_fwded[(511-(i*128)):(384-(i*128))];
      assign match[i] = (r_tag==tag_data[i]) ? valid_array[i] : 1'b0; // compares the 4 tags from the tag_blockram to the r_tag input
    end
  endgenerate

  assign fwd_way_reg_onehot = {&fwd_way_reg, fwd_way_reg[1] & ~fwd_way_reg[0],  // one hot form of which way needs to be forwarded for a w/r bypass
                   ~fwd_way_reg[1] & fwd_way_reg[0], ~|fwd_way_reg};

  assign hit = |match;                                                            // hit is 1 if a tag  match is found
  assign way = (no_tagcheck_read) ? no_tagcheck_way : (hit) ? {(match[3] | match[2]), (match[1] | match[3])} : victimway;  // way, if a hit is the way of the hit on miss the way of victim
  assign plru = metadata_fwded[2:0];
  assign dirty_array = metadata_fwded[6:3];                                       // array of dirty values for 4 ways of cache
  assign valid_array = metadata_fwded[10:7];  									  // array of valid values for 4 ways of cache
  assign dirty = (way[1]) ? (way[0]) ? dirty_array[3] : dirty_array[2] :          // logic for dirty output
	         (way[0]) ? dirty_array[1] : dirty_array[0];

  assign data_out = (way[1]) ? (way[0]) ? data[3] : data[2] :                     // data out logic (needed for reads and memory write backs
	         (way[0]) ? data[1] : data[0];  

  assign tag_out = (way[1]) ? (way[0]) ? tag_data[3] : tag_data[2] :              // tag out logic (tagout is needed for cpu store instructions and memory write backs
	         (way[0]) ? tag_data[1] : tag_data[0];

  assign victimway[1] = (~plru[2] & (valid_array[1] & valid_array[0])) | ~(valid_array[3] & valid_array[2]);                            // caclulates way of victim
  assign victimway[0] = (((~plru[2]) ? ~plru[1] : ~plru[0]) & (valid_array[2] & valid_array[0])) | (~(valid_array[3] & valid_array[1]) & ~(valid_array[3] & ~valid_array[2]));

  assign fwd_metadata = (r_index==r_index_reg);                                 // finds when metadata needs to be forwarded
  assign metadata_fwded = (fwd_metadata_reg) ? metadata_reg : metadata_out;     // fwd logic for metadata
  assign fwd_data = (rd_addr=={w_index, w_line[5:4]});                          // finds when tag/data needs to be forwarded
 assign data_fwded = {(fwd_data_reg & fwd_way_reg_onehot[3]) ? data_reg : block_data_out[511:384]     // fwd logic for data
                       , (fwd_data_reg & fwd_way_reg_onehot[2]) ? data_reg : block_data_out[383:256]
                       , (fwd_data_reg & fwd_way_reg_onehot[1]) ? data_reg : block_data_out[255:128]
                       , (fwd_data_reg & fwd_way_reg_onehot[0]) ? data_reg : block_data_out[127:0]};
  assign tag_fwded = {(fwd_data_reg & fwd_way_reg_onehot[3]) ? tag_reg : block_tag_out[71:54]         // fwd logic for tag
                       , (fwd_data_reg & fwd_way_reg_onehot[2]) ? tag_reg : block_tag_out[53:36]
                       , (fwd_data_reg & fwd_way_reg_onehot[1]) ? tag_reg : block_tag_out[35:18]
                       , (fwd_data_reg & fwd_way_reg_onehot[0]) ? tag_reg : block_tag_out[17:0]};
 
  always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
      tag_reg <= 0;
      metadata_reg <= 0;
      data_reg <=0;
      fwd_metadata_reg <=0;                     // registers that hold fwding data, as well as read data, since metadata is updated
      fwd_data_reg <= 0;                        // one cycle after a read
      fwd_way <= 0;
      r_reg <= 0;
      r_index_reg  <= 0;
    end
    else begin
      tag_reg <= w_tag;
      metadata_reg <= metadata_in;
      data_reg <= w_data;
      fwd_metadata_reg <= fwd_metadata;
      fwd_data_reg <= fwd_data;
      fwd_way_reg <= w_way;
      r_reg <= r;
      r_index_reg <= r_index;
    end
  end

endmodule
