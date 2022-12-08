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
`ifndef READ_PROCEDURE_IF
	`define READ_PROCEDURE_IF 1
	`include "read_procedure_if.sv"
`endif
module data_cache_tb_sub(interface inf, ref data_cache_memory_class d_cache, ref logic clk, ref logic rst);
	// Import necessary packages
	import cache_types_pkg::*; // for functions
	
		
	// Instantiate data cache
	data_cache CACHE0(
						.w_index(inf.w_index), 
						.r_index(inf.r_index), 
						.w_tag(inf.w_tag), 
						.r_tag(inf.r_tag), 
						.w_line(inf.w_line),
						.r_line(inf.r_line), 
						.w_data(inf.w_data), 
						.flushtype(inf.flushtype), 
						.w_way(inf.w_way),
						.no_tagcheck_way(inf.no_tagcheck_way),
						.w_tagcheck(inf.w_tagcheck), 
						.rst(rst), 
						.clk(clk), 
						.w(inf.w), 
						.r(inf.r), 
						.no_tagcheck_read(inf.no_tagcheck_read),
						.last_write_from_mem(inf.last_write_from_mem),
						.tag_out(inf.dut_tag_out), 
						.data_out(inf.dut_data_out), 
						.way(inf.dut_way), 
						.hit(inf.dut_hit),
						.dirty(inf.dut_dirty),
						.dirty_array(inf.dut_dirty_array)
					);
						
	// Create interface object
	read_procedure_if read_intf();
						
	/** Used for checking internal signals */
	always @(CACHE0.valid_array, CACHE0.plru) begin
		inf.dut_valid_array = CACHE0.valid_array;	// to check the validity of arrays
		inf.dut_plru = CACHE0.plru;					// for the victim way logic 
	end
					
	/** Used for performing reads */
	task automatic read_main();
	
		// Read the data and tag blocks
		d_cache.read_data_tag_and_metadata_blocks(
			// Inputs 
			.r_index(inf.r_index),
			.r_line(inf.r_line),
			// Outputs 
			.out_data(inf.data_block),		
			.out_tag(inf.tag_block),		
			.out_metadata(inf.metadata_block)
		);
		
		// Get the hit, victimway and way
		d_cache.get_hit_dirty_victimway_and_way(
			// Inputs 
			.tag_in(inf.r_tag),						// tag to be searched for in block
			.metadata_block(inf.metadata_block),		// metadata per way		
			.tag_block(inf.tag_block),					// all tags in a set 18 * 4 bits
			.update_metadata(inf.update_metadata),		// assert to indicate whether the metadata should be updated to shadow the DUT											
			.r_index(inf.r_index),						// Index of set whose metadata would possibly be updated
			.read_access_type(inf.w_tagcheck),	// 1 indicates a read with a followup write and otherwise 0
			.no_tagcheck_read(inf.no_tagcheck_read),	// Used to determine if the data is used for a write back to memory on a miss
			.flushtype(inf.flushtype),		// The write way to writ+++e data back to memory
			
			// Output 
			.hit(inf.perf_hit),								// Indicate whether the data was found
			.dirty(inf.perf_dirty),							// Indicate whether the data present is dirty
			.way(inf.perf_way)								// Way where data is present
		);		
		
		// Used in viewing exact data fetched (For comparisons)
		d_cache.get_data_and_tag(
			// Inputs 
			.data_block(inf.data_block),			// Data across ways (all data in a line)
			.tag_block(inf.tag_block),				// all tags in a set 18 * 4 bits
			.way(inf.perf_way),							// Way where data is present
			// Output
			.data_out(inf.perf_data_out),
			.tag_out(inf.perf_tag_out)
		);
	
	endtask
	
	/**
	 * Call on a read or on a write (behavior would vary based on the signals asserted
	 */
	task automatic read_procedure();
	
		// If tag check done in last cycle
		if(inf.pre_write_procedure_done) begin
			inf.w = 1'b1; // write on next clock cycle
			
			// update meta data from previous read
			d_cache.delay_update_metadata();
			
			// Write to previous position 
			d_cache.write_data_tag_and_metadata(
													// Inputs 
													.w_line(inf.w_line),						
													.w_way(inf.w_way),							
													.w_data(inf.w_data),						
													.w_tag(inf.w_tag),							
													.w_index(inf.w_index),
													.last_write_from_mem(inf.last_write_from_mem)
												);		
		end
		
		
		inf.pre_write_procedure_done = 1'b0;
		inf.r = 1'b1;
		inf.no_tagcheck_read = 1'b0; // reading for tags initially
		inf.last_write_from_mem = 1'b0;
		
		// Perform read
		read_main();
		
		// Evaluate read
		if(inf.perf_hit) begin
			// Compare with DUT
			@(posedge clk) begin
				d_cache.compare_results(
											.dut_tag_out(inf.dut_tag_out),
											.dut_data_out(inf.dut_data_out),
											.dut_way(inf.dut_way),
											.dut_hit(inf.dut_hit),
											.dut_dirty(inf.dut_dirty),
											.dut_dirty_array(inf.dut_dirty_array),
											.dut_valid_array(inf.dut_valid_array),
											.dut_plru(inf.dut_plru),
											.perf_tag_out(inf.perf_tag_out),
											.perf_data_out(inf.dut_data_out),
											.perf_way(inf.perf_way),
											.perf_hit(inf.perf_hit),
											.perf_dirty(inf.perf_dirty),
											.perf_dirty_array(inf.metadata_block.dirty),
											.perf_valid_array(inf.metadata_block.valid),	// to check the validity of arrays
											.perf_plru(inf.metadata_block.plru)					// for the victim way logic 
										);
			end
		end
		else begin
			inf.no_tagcheck_read = ~inf.perf_hit; // On a miss assert to prevent modification of metadata
			// Write back to memory starting from the way where the missed data was found 
			inf.no_tagcheck_way = inf.perf_way;					
			
			if(inf.dut_way != inf.perf_way) begin
				$display("FAILED: The DUT eviction way is different from the perf test");
			end
			
			// Read out all four times for all the words on a way
			for(int i = 0; i < RAM_READ_SIZE / WORD_SIZE; i++) begin
				// Perform a read for write back to memory
				inf.r = 1'b1;
				read_main();
				
				// Read is ready now so compare data
				@(posedge clk);
				
				// Evaluate the DUT
				d_cache.compare_results(
											.dut_tag_out(inf.dut_tag_out),
											.dut_data_out(inf.dut_data_out),
											.dut_way(inf.dut_way),
											.dut_hit(inf.dut_hit),
											.dut_dirty(inf.dut_dirty),
											.dut_dirty_array(inf.dut_dirty_array),
											.dut_valid_array(inf.dut_valid_array),
											.dut_plru(inf.dut_plru),
											.perf_tag_out(inf.perf_tag_out),
											.perf_data_out(inf.dut_data_out),
											.perf_way(inf.perf_way),
											.perf_hit(inf.perf_hit),
											.perf_dirty(inf.perf_dirty),
											.perf_dirty_array(inf.metadata_block.dirty),
											.perf_valid_array(inf.metadata_block.valid),	// to check the validity of arrays
											.perf_plru(inf.metadata_block.plru)					// for the victim way logic 
										);
				
				
				if(inf.r_line[5:4] == 2'b11) begin
					inf.r_line[5:4] = 2'b00;
				end 
				else begin
					inf.r_line[5:4] += 1; // loop round
				end
			end
			
			
			
			// Write all 4 words on way // TO DO: Writing tags more than once
			for(int i = 0; i < RAM_READ_SIZE / WORD_SIZE; i++) begin
				@(negedge clk) begin
					if(i == 0) begin // initialize on first write
						inf.r = 1'b0;
						inf.w = 1'b1;	
						// Writing in same order data was read
						inf.w_way = inf.no_tagcheck_way;
						inf.w_tag = inf.r_tag;
						inf.w_index = inf.r_index;
						inf.w_data = WORD_SIZE'(0);
						inf.w_line[5:4] = inf.r_line[5:4];
						inf.last_write_from_mem = 1'b0;
					end
					
					if(i == (RAM_READ_SIZE / WORD_SIZE) - 1) begin
						inf.last_write_from_mem = 1'b1;
					end
				end
				
				@(posedge clk) begin
				
					d_cache.write_data_tag_and_metadata(
						.w_index(inf.w_index),					
						.w_line(inf.w_line),				
						.w_way(inf.w_way),				
						.w_data(inf.w_data),	// data to be fetched from memory. Should always be zero
						.w_tag(inf.w_tag),		// write to particular tag which is needed to be read 
						.last_write_from_mem(inf.last_write_from_mem) // update the valid array at that location
					);		
				end
				
				// Write every word
				if(inf.w_line[5:4] == 2'b11) begin
					inf.w_line[5:4] = 2'b00;
				end 
				else begin
					inf.w_line[5:4] += 1; // loop round
				end 
			end
			
			@(negedge clk) begin
				inf.r = 1'b1;
				inf.w = 1'b0;
				inf.last_write_from_mem = 1'b0;
			end
			
			// Attempt to read tag again 
			@(posedge clk) begin
				inf.no_tagcheck_read = 1'b0;
				read_main();

				d_cache.compare_results(
											.dut_tag_out(inf.dut_tag_out),
											.dut_data_out(inf.dut_data_out),
											.dut_way(inf.dut_way),
											.dut_hit(inf.dut_hit),
											.dut_dirty(inf.dut_dirty),
											.dut_dirty_array(inf.dut_dirty_array),
											.dut_valid_array(inf.dut_valid_array),
											.dut_plru(inf.dut_plru),
											.perf_tag_out(inf.perf_tag_out),
											.perf_data_out(inf.dut_data_out),
											.perf_way(inf.perf_way),
											.perf_hit(inf.perf_hit),
											.perf_dirty(inf.perf_dirty),
											.perf_dirty_array(inf.metadata_block.dirty),
											.perf_valid_array(inf.metadata_block.valid),	// to check the validity of arrays
											.perf_plru(inf.metadata_block.plru)					// for the victim way logic 
										);
			end
		end
		
		@(negedge clk) begin
			// on a write, save the addresses for next cycle
			if(inf.w_tagcheck) begin
				inf.w_index = inf.r_index;
				inf.w_line = inf.r_line;						
				inf.w_way = inf.dut_way;		
				inf.w_tag = inf.r_tag;			
				inf.w_data = get_next_data(inf.r_line, inf.perf_way); // data to be written on previous write request											
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
		
		return inf.DATA_ARRAY[index];
	endfunction
	
	/**************	TEST THE DUT LOGIC  *****************/
	
	initial begin
		repeat(5) @(negedge clk);
		rst = 1'b0; // deassert reset
		
		inf.flushtype = 2'b00; // no flushes
		
		// Change data for next access
		@(negedge clk) begin
			inf.w_tagcheck = 1'b1; // same thing but for DUT
			inf.r_tag = $random;
			inf.r_index = 100;
			inf.r_line = 6'b000000; // only top 2 bits change from 00 -> 11
		end
		
		// Initialize data array
		inf.pre_write_procedure_done = 1'b0;
		
		read_procedure();
		
		inf.pre_write_procedure_done = 1'b1;
		
		// Change data for next read access
		// Sidenote: Already on negedge from previous function
		inf.w_tagcheck = 1'b0; // same thing but for DUT
		@(negedge clk) begin
			
		end
		
		// follow up read
		read_procedure();
		
		
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
	
endmodule