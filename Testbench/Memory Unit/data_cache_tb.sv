/**
* This module would test the functionality of the data cache 
*/

`ifndef DATA_CACHE_MEMORY_CLASS
	`define DATA_CACHE_MEMORY_CLASS 1
	`include "data_cache_memory_class.sv"
`endif
`ifndef CACHE_TYPES_PKG
	`define CACHE_TYPES_PKG 1
	`include "cache_types_pkg.sv"
`endif
module data_cache_tb();
	// Import necessary packages
	import cache_types_pkg::*; // for functions
	
	// Main Signals
	logic [7:0] w_index; 			// Index where the cache would be written
	logic [7:0] r_index;			// Index of cache where data is to be read 
	logic [17:0] w_tag; 			// The tag of data to write to the cache 
	logic [17:0] r_tag;				// The tag to be compared for read or follow up write
	logic [5:0] w_line;				// desired line for write, uses the first two bits of these
	logic [5:0] r_line;				// desired line for write and read, uses the first two bits of these
	logic [127:0] w_data;			// data to be written in write operation
	logic [1:0] flushtype; 			// type of flush 11 = flushclean 10 = flushdirty 01 = flushline 00 = noflush
	logic [1:0] w_way;				// w_way is the 128bit chuck of a line in a set		
	logic [1:0] no_tagcheck_way;	// The way which would be used to write data from the cache to memory 
	logic w_tagcheck;				// signifies to the cache that this is a read being done for tagcheck purposes
	logic rst; 						// Reset signals 
	logic clk;						// Clock signals 
	logic w;						// incoming write signal
	logic r; 						// incoming read signal
	logic no_tagcheck_read;			// Used when data is being read back to and from memory rather than just from the cache
	logic last_write_from_mem;		// assert on last write from memory to cache to make way valid
	logic [17:0] dut_tag_out;    	// it is used to write tag back to main memory
	logic [127:0] dut_data_out;  	// data to be written back to main memory
	logic [1:0] dut_way;         	// can be the way where a hit occurred or the victim way
	logic dut_hit;					// assert on hit
	logic dut_dirty;				// indicates whether a given line is dirty
	logic [3:0] dut_dirty_array;	// Holds the dirty ways on the selected index

	// Helper signals 
	bit access_type; 				// determine if a write or a read is to be perfomed 
	
	// DUT internal signals
	logic [3:0] dut_valid_array;
	logic [2:0] dut_plru;
	
	// Used in perfect test bench
	logic [RAM_READ_SIZE - 1: 0] data_block;				// Data across ways (all data in a line)
	logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] tag_block;		// all tags in a set 18 * 4 bits
	set_metadata metadata_block;							// metadata per way
	bit update_metadata;									// assert to indicate whether the metadata should be updated to shadow the DUT						
	logic [WORD_SIZE - 1: 0] perf_data_out;
	logic [TAG_SIZE - 1: 0] perf_tag_out;	
	logic perf_hit;												// Indicate whether the data was found
	logic perf_dirty;											// Indicate whether the data present is dirty
	logic [$clog2(WAY_PER_SET) - 1: 0] perf_way;					// Way where data is present

	// Helper for main testbench
	logic pre_write_procedure_done;							// Used to prevent further read data for comparison
	
	// used for caches 
	// data_cache_memory_class data_cache;
	
	// Date bank
	logic [WORD_SIZE - 1:0] DATA_ARRAY [4];					// Hold data used in testing
		
	// Instantiate data cache
	data_cache CACHE0(
						.w_index(w_index), 
						.r_index(r_index), 
						.w_tag(w_tag), 
						.r_tag(r_tag), 
						.w_line(w_line),
						.r_line(r_line), 
						.w_data(w_data), 
						.flushtype(flushtype), 
						.w_way(w_way),
						.no_tagcheck_way(no_tagcheck_way),
						.w_tagcheck(w_tagcheck), 
						.rst(rst), 
						.clk(clk), 
						.w(w), 
						.r(r), 
						.no_tagcheck_read(no_tagcheck_read),
						.last_write_from_mem(last_write_from_mem),
						.tag_out(dut_tag_out), 
						.data_out(dut_data_out), 
						.way(dut_way), 
						.hit(dut_hit),
						.dirty(dut_dirty),
						.dirty_array(dut_dirty_array));
						
	// Create interface object
	// read_procedure_if read_intf();
						
	/** Used for checking internal signals */
	always @(CACHE0.valid_array, CACHE0.plru) begin
		dut_valid_array = CACHE0.valid_array;	// to check the validity of arrays
		dut_plru = CACHE0.plru;					// for the victim way logic 
	end
					
	/** Used for performing reads */
	task automatic read_main(
		const ref data_cache_memory_class data_cache,
		// Inputs 
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,
		const ref logic [5:0] r_line,		
		const ref logic [$clog2(NUM_OF_FLUSH_TYPES) - 1: 0] flushtype,
		const ref logic [TAG_SIZE - 1: 0] r_tag,
		const ref bit update_metadata,											
		const ref logic w_tagcheck,								
		const ref logic no_tagcheck_read,
		// Inputs and Outputs
		ref logic [RAM_READ_SIZE - 1: 0] data_block,				
		ref logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] tag_block,	
		ref logic [$clog2(WAY_PER_SET) - 1: 0] perf_way,				
		ref set_metadata metadata_block,															
		// Output
		ref logic perf_hit,
		ref logic perf_dirty,		
		ref logic [WORD_SIZE - 1: 0] perf_data_out,
		ref logic [TAG_SIZE - 1: 0] perf_tag_out
	);
	
		// Read the data and tag blocks
		data_cache.read_data_tag_and_metadata_blocks(
			// Inputs 
			.r_index(r_index),
			.r_line(r_line),
			// Outputs 
			.out_data(data_block),		
			.out_tag(tag_block),		
			.out_metadata(metadata_block)
		);
		
		// Get the hit, victimway and way
		data_cache.get_hit_dirty_victimway_and_way(
			// Inputs 
			.tag_in(r_tag),						// tag to be searched for in block
			.metadata_block(metadata_block),		// metadata per way		
			.tag_block(tag_block),					// all tags in a set 18 * 4 bits
			.update_metadata(update_metadata),		// assert to indicate whether the metadata should be updated to shadow the DUT											
			.r_index(r_index),						// Index of set whose metadata would possibly be updated
			.read_access_type(w_tagcheck),	// 1 indicates a read with a followup write and otherwise 0
			.no_tagcheck_read(no_tagcheck_read),	// Used to determine if the data is used for a write back to memory on a miss
			.flushtype(flushtype),		// The write way to writ+++e data back to memory
			
			// Output 
			.hit(perf_hit),								// Indicate whether the data was found
			.dirty(perf_dirty),							// Indicate whether the data present is dirty
			.way(perf_way)								// Way where data is present
		);		
		
		// Used in viewing exact data fetched (For comparisons)
		data_cache.get_data_and_tag(
			// Inputs 
			.data_block(data_block),			// Data across ways (all data in a line)
			.tag_block(tag_block),				// all tags in a set 18 * 4 bits
			.way(perf_way),							// Way where data is present
			// Output
			.data_out(perf_data_out),
			.tag_out(perf_tag_out)
		);
	
	endtask
	
	/**
	 * Call on a read or on a write (behavior would vary based on the signals asserted
	 */
	task automatic read_procedure(
		const ref data_cache_memory_class data_cache,
		const ref logic clk,
		// Inputs 
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,
			
		const ref logic [$clog2(NUM_OF_FLUSH_TYPES) - 1: 0] flushtype,
		const ref logic [TAG_SIZE - 1: 0] r_tag,
		const ref bit update_metadata,											
		const ref logic w_tagcheck,	
		// Inputs: DUT outputs
		const ref logic [TAG_SIZE - 1: 0] dut_tag_out,
		const ref logic [WORD_SIZE - 1: 0] dut_data_out,
		const ref logic [1:0] dut_way,
		const ref logic dut_hit,
		const ref logic dut_dirty,
		const ref logic [WAY_PER_SET - 1 : 0] dut_dirty_array,
		const ref logic [WAY_PER_SET - 1 : 0] dut_valid_array,
		const ref logic [$clog2(WAY_PER_SET) : 0] dut_plru,
		// Inputs and Outputs
		ref logic [5:0] r_line,
		ref logic last_write_from_mem,
		ref logic [RAM_READ_SIZE - 1: 0] data_block,				
		ref logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] tag_block,	
		ref logic [$clog2(WAY_PER_SET) - 1: 0] perf_way,				
		ref set_metadata metadata_block,	
		ref logic pre_write_procedure_done,		
		// Output
		ref logic no_tagcheck_read,
		ref logic perf_hit,
		ref logic perf_dirty,		
		ref logic [WORD_SIZE - 1: 0] perf_data_out,
		ref logic [TAG_SIZE - 1: 0] perf_tag_out,
		ref logic r,
		ref logic w,
		ref logic [$clog2(NUM_OF_SETS) - 1: 0] w_index,		
		ref logic [5:0] w_line,								
		ref logic [$clog2(WAY_PER_SET) - 1:0] w_way,			
		ref logic [WORD_SIZE - 1:0] w_data,					
		ref logic [TAG_SIZE - 1:0] w_tag,
		ref logic [$clog2(WAY_PER_SET) - 1:0] no_tagcheck_way
	);
	
		// If tag check done in last cycle
		if(pre_write_procedure_done) begin
			w = 1'b1; // write on next clock cycle
			
			// update meta data from previous read
			data_cache.delay_update_metadata();
			
			// Write to previous position 
			data_cache.write_data_tag_and_metadata(
													// Inputs 
													.w_line(w_line),						
													.w_way(w_way),							
													.w_data(w_data),						
													.w_tag(w_tag),							
													.w_index(w_index),
													.last_write_from_mem(last_write_from_mem)
												);		
		end
		
		
		pre_write_procedure_done = 1'b0;
		r = 1'b1;
		no_tagcheck_read = 1'b0; // reading for tags initially
		last_write_from_mem = 1'b0;
		
		// Perform read
		read_main(
					.data_cache(data_cache),
					// Inputs
					.r_index(r_index),
					.r_line(r_line),	
					.flushtype(flushtype),
					.r_tag(r_tag),
					.update_metadata(update_metadata),											
					.w_tagcheck(w_tagcheck),								
					.no_tagcheck_read(no_tagcheck_read),
					// Inputs and Outputs
					.data_block(data_block),				
					.tag_block(tag_block),	
					.perf_way(perf_way),				
					.metadata_block(metadata_block),															
					// Output
					.perf_hit(perf_hit),
					.perf_dirty(perf_dirty),		
					.perf_data_out(perf_data_out),
					.perf_tag_out(perf_tag_out)
		);
		
		// Evaluate read
		if(perf_hit) begin
			// Compare with DUT
			@(posedge clk) begin
				data_cache.compare_results(
											.dut_tag_out(dut_tag_out),
											.dut_data_out(dut_data_out),
											.dut_way(dut_way),
											.dut_hit(dut_hit),
											.dut_dirty(dut_dirty),
											.dut_dirty_array(dut_dirty_array),
											.dut_valid_array(dut_valid_array),
											.dut_plru(dut_plru),
											.perf_tag_out(perf_tag_out),
											.perf_data_out(dut_data_out),
											.perf_way(perf_way),
											.perf_hit(perf_hit),
											.perf_dirty(perf_dirty),
											.perf_dirty_array(metadata_block.dirty),
											.perf_valid_array(metadata_block.valid),	// to check the validity of arrays
											.perf_plru(metadata_block.plru)					// for the victim way logic 
										);
			end
		end
		else begin
			no_tagcheck_read = ~perf_hit; // On a miss assert to prevent modification of metadata
			// Write back to memory starting from the way where the missed data was found 
			no_tagcheck_way = perf_way;					
			
			if(dut_way != perf_way) begin
				$display("FAILED: The DUT eviction way is different from the perf test");
			end
			
			
			
			// Read out all four times for all the words on a way
			for(int i = 0; i < RAM_READ_SIZE / WORD_SIZE; i++) begin
				// Perform a read for write back to memory
				r = 1'b1;
				read_main(
							.data_cache(data_cache),
							// Inputs
							.r_index(r_index),
							.r_line(r_line),	
							.flushtype(flushtype),
							.r_tag(r_tag),
							.update_metadata(update_metadata),											
							.w_tagcheck(w_tagcheck),								
							.no_tagcheck_read(no_tagcheck_read),
							// Inputs and Outputs
							.data_block(data_block),				
							.tag_block(tag_block),	
							.perf_way(perf_way),				
							.metadata_block(metadata_block),															
							// Output
							.perf_hit(perf_hit),
							.perf_dirty(perf_dirty),		
							.perf_data_out(perf_data_out),
							.perf_tag_out(perf_tag_out)
				);
				
				// Read is ready now so compare data
				@(posedge clk);
				
				// Evaluate the DUT
				data_cache.compare_results(
											.dut_tag_out(dut_tag_out),
											.dut_data_out(dut_data_out),
											.dut_way(dut_way),
											.dut_hit(dut_hit),
											.dut_dirty(dut_dirty),
											.dut_dirty_array(dut_dirty_array),
											.dut_valid_array(dut_valid_array),
											.dut_plru(dut_plru),
											.perf_tag_out(perf_tag_out),
											.perf_data_out(dut_data_out),
											.perf_way(perf_way),
											.perf_hit(perf_hit),
											.perf_dirty(perf_dirty),
											.perf_dirty_array(metadata_block.dirty),
											.perf_valid_array(metadata_block.valid),	// to check the validity of arrays
											.perf_plru(metadata_block.plru)					// for the victim way logic 
										);
				
				
				if(r_line[5:4] == 2'b11) begin
					r_line[5:4] = 2'b00;
				end 
				else begin
					r_line[5:4] += 1; // loop round
				end
			end
			
			
			
			// Write all 4 words on way // TO DO: Writing tags more than once
			for(int i = 0; i < RAM_READ_SIZE / WORD_SIZE; i++) begin
				@(negedge clk) begin
					if(i == 0) begin // initialize on first write
						r = 1'b0;
						w = 1'b1;	
						// Writing in same order data was read
						w_way = no_tagcheck_way;
						w_tag = r_tag;
						w_index = r_index;
						w_data = WORD_SIZE'(0);
						w_line[5:4] = r_line[5:4];
						last_write_from_mem = 1'b0;
					end
					
					if(i == (RAM_READ_SIZE / WORD_SIZE) - 1) begin
						last_write_from_mem = 1'b1;
					end
				end
				
				@(posedge clk) begin
				
					data_cache.write_data_tag_and_metadata(
						.w_index(w_index),					
						.w_line(w_line),				
						.w_way(w_way),				
						.w_data(w_data),	// data to be fetched from memory. Should always be zero
						.w_tag(w_tag),		// write to particular tag which is needed to be read 
						.last_write_from_mem(last_write_from_mem) // update the valid array at that location
					);		
				end
				
				// Write every word
				if(w_line[5:4] == 2'b11) begin
					w_line[5:4] = 2'b00;
				end 
				else begin
					w_line[5:4] += 1; // loop round
				end 
			end
			
			@(negedge clk) begin
				r = 1'b1;
				w = 1'b0;
				last_write_from_mem = 1'b0;
			end
			
			// Attempt to read tag again 
			@(posedge clk) begin
				no_tagcheck_read = 1'b0;
				read_main(
							.data_cache(data_cache),
							// Inputs
							.r_index(r_index),
							.r_line(r_line),	
							.flushtype(flushtype),
							.r_tag(r_tag),
							.update_metadata(update_metadata),											
							.w_tagcheck(w_tagcheck),								
							.no_tagcheck_read(no_tagcheck_read),
							// Inputs and Outputs
							.data_block(data_block),				
							.tag_block(tag_block),	
							.perf_way(perf_way),				
							.metadata_block(metadata_block),															
							// Output
							.perf_hit(perf_hit),
							.perf_dirty(perf_dirty),		
							.perf_data_out(perf_data_out),
							.perf_tag_out(perf_tag_out)
				);

				data_cache.compare_results(
											.dut_tag_out(dut_tag_out),
											.dut_data_out(dut_data_out),
											.dut_way(dut_way),
											.dut_hit(dut_hit),
											.dut_dirty(dut_dirty),
											.dut_dirty_array(dut_dirty_array),
											.dut_valid_array(dut_valid_array),
											.dut_plru(dut_plru),
											.perf_tag_out(perf_tag_out),
											.perf_data_out(dut_data_out),
											.perf_way(perf_way),
											.perf_hit(perf_hit),
											.perf_dirty(perf_dirty),
											.perf_dirty_array(metadata_block.dirty),
											.perf_valid_array(metadata_block.valid),	// to check the validity of arrays
											.perf_plru(metadata_block.plru)					// for the victim way logic 
										);
			end
		end
		
		@(negedge clk) begin
			// on a write, save the addresses for next cycle
			if(w_tagcheck) begin
				w_index = r_index;
				w_line = r_line;						
				w_way = dut_way;		
				w_tag = r_tag;			
				w_data = get_next_data(r_line, perf_way); // data to be written on previous write request											
			end
		end
	endtask
	
	
	function logic [WORD_SIZE - 1:0] get_next_data(
		logic [5:0] r_line,
		logic [$clog2(WAY_PER_SET) - 1: 0] way	
		);
		
		int index; 
		index = r_line[5:4] + way;
		if(index > WAY_PER_SET) begin
			index -= WAY_PER_SET;
		end
		
		return DATA_ARRAY[index];
	endfunction
	
	/**************	TEST THE DUT LOGIC  *****************/
	
	initial begin
		// Cache and the rest
		data_cache_memory_class d_cache;
		d_cache = new();	
		
		// Declare and Initialize 
		DATA_ARRAY = '{128'hAAAA, 128'hBBBB, 128'hCCCC, 128'hDDDD};
		pre_write_procedure_done = 1'b0;
		update_metadata = 1'b1;
		flushtype = 2'b00; // no flushes
		w_tagcheck = 1'b1; // same thing but for DUT
		r_tag = 18'h0;
		r_index = 8'd100;
		r_line = 6'b000000; 
		r = 1'b0;
		w = 1'b0;
		no_tagcheck_read = 1'b0;
		last_write_from_mem = 1'b0;
		perf_hit = 1'b0;
		perf_dirty = 1'b0;
		// perf_way = 1'b0;
		perf_data_out = {WORD_SIZE{1'b0}};
		perf_tag_out = {TAG_SIZE{1'b0}};
		w_index = 2'b00;	
		w_line = 6'b000000;								
		w_way = 2'b00;		
		w_data = {WORD_SIZE{1'b0}};					
		w_tag = {TAG_SIZE{1'b0}};
		no_tagcheck_way = 2'b00;
		metadata_block = '{default:'0};
		data_block = {RAM_READ_SIZE{1'b0}};			
		tag_block = {(TAG_SIZE * WAY_PER_SET){1'b0}};	
		
		
		// Init global signals
		clk = 1'b0;
		rst = 1'b1;
		
		repeat(5) @(negedge clk);
		rst = 1'b0; // deassert reset
		
		flushtype = 2'b00; // no flushes

		// Change data for next access
		@(negedge clk) begin
			w_tagcheck = 1'b1; // same thing but for DUT
			r_tag = $random;
			r_index = 100;
			r_line = 6'b000000; // only top 2 bits change from 00 -> 11
		end
		
		// Initialize data array
		pre_write_procedure_done = 1'b0;
		
		read_procedure(
						.data_cache(d_cache),
						.clk(clk),
						// Inputs
						.r_index(r_index),	
						.flushtype(flushtype),
						.r_tag(r_tag),
						.update_metadata(update_metadata),											
						.w_tagcheck(w_tagcheck),
						// Inputs: DUT outputs						
						.dut_tag_out(dut_tag_out),
						.dut_data_out(dut_data_out),
						.dut_way(dut_way),
						.dut_hit(dut_hit),
						.dut_dirty(dut_dirty),
						.dut_dirty_array(dut_dirty_array),
						.dut_valid_array(dut_valid_array),
						.dut_plru(dut_plru),
						// Outputs and Inputs 
						.r_line(r_line),
						.last_write_from_mem(last_write_from_mem),
						.data_block(data_block),				
						.tag_block(tag_block),	
						.perf_way(perf_way),				
						.metadata_block(metadata_block),	
						.pre_write_procedure_done(pre_write_procedure_done),
						// Outputs
						.no_tagcheck_read(no_tagcheck_read),
						.perf_hit(perf_hit),
						.perf_dirty(perf_dirty),		
						.perf_data_out(perf_data_out),
						.perf_tag_out(perf_tag_out),
						.r(r),
						.w(w),
						.w_index(w_index),		
						.w_line(w_line),								
						.w_way(w_way),			
						.w_data(w_data),					
						.w_tag(w_tag),
						.no_tagcheck_way(no_tagcheck_way)
		);
		
		pre_write_procedure_done = 1'b1;
		
		// Change data for next read access
		// Sidenote: Already on negedge from previous function
		w_tagcheck = 1'b0; // same thing but for DUT
		@(negedge clk) begin
			
		end
		
		// follow up read
		read_procedure(
						.data_cache(d_cache),
						.clk(clk),
						// Inputs
						.r_index(r_index),	
						.flushtype(flushtype),
						.r_tag(r_tag),
						.update_metadata(update_metadata),											
						.w_tagcheck(w_tagcheck),
						// Inputs: DUT outputs						
						.dut_tag_out(dut_tag_out),
						.dut_data_out(dut_data_out),
						.dut_way(dut_way),
						.dut_hit(dut_hit),
						.dut_dirty(dut_dirty),
						.dut_dirty_array(dut_dirty_array),
						.dut_valid_array(dut_valid_array),
						.dut_plru(dut_plru),
						// Outputs and Inputs 
						.r_line(r_line),
						.last_write_from_mem(last_write_from_mem),
						.data_block(data_block),				
						.tag_block(tag_block),	
						.perf_way(perf_way),				
						.metadata_block(metadata_block),	
						.pre_write_procedure_done(pre_write_procedure_done),
						// Outputs
						.no_tagcheck_read(no_tagcheck_read),
						.perf_hit(perf_hit),
						.perf_dirty(perf_dirty),		
						.perf_data_out(perf_data_out),
						.perf_tag_out(perf_tag_out),
						.r(r),
						.w(w),
						.w_index(w_index),		
						.w_line(w_line),								
						.w_way(w_way),			
						.w_data(w_data),					
						.w_tag(w_tag),
						.no_tagcheck_way(no_tagcheck_way)
		);
		
		
		
		$stop();
		
		// Read main
		
		
		
		// Objectives:
	
		
		
		

		
		// 1. Check cache returns a miss when invalid data is present
		
		
		// 2. Check that a hit is asserted appropriately when data is present in the cache
		
		
		// 3. On sets with all invalid lines check that the plru performs as expected and fills up all lines in a set
		// 		in the order 11 -> 10 -> 01 -> 00
		
		
		// 4. Check the appropriate victim way is used by having multiple insertions and deletes on a single set
		
		
		// 5. Ensure that a miss when the data is writing back to and back from
		// 	memory does not update the metadata 
		
		
		// 6. Check that a write does not update the metadata 
		
		
		// 7. Ensure the first read does not update metadata if it happens to be a miss
		
		
		// 8. Write followed by read should be appropriately forwarded
		
		
		// Side note: 
		//	1. ensure that the "r" signal is asserted at the start of the last write on a read followed 
		//		by a write (when the w_tagcheck was asserted on the first read that resulted in the miss) 
		//		in order to update the metadata on the followup write from memory 
		
		//	3. we could use about 8 tags for all the lines in the cache to test swaps 
		//		since tags only have to be unique on a single set
		
		
	end
	
	// Generate clock
	always
		#5 clk = ~clk;

	

endmodule