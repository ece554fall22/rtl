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
	logic [$clog2(WAY_PER_SET) - 1:0]  w_way_save; // would be used to write to way later
	logic [$clog2(NUM_OF_SETS) - 1: 0] r_index_save;
	logic [TAG_SIZE - 1: 0] r_tag_save;
	logic [5:0] r_line_save;
	logic read_procedure_start;
	logic [$clog2(NUM_OF_SETS) - 1: 0] INDEX_ARRAY [3]; // used in holding index values for test 2
	int index_group; 		// For ACT 2					
	int way_index;   		// For ACT 2
	int loop_cnt1;   		// For ACT 2
	int loop_cnt2;   		// For ACT 2
	int line_index;  		// For ACT 2
		
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
	
	// Always write on posedge clk after line fetch
	always @(negedge clk) begin
		// At the next negative clock egde
		@(negedge clk) begin
			// to prevent confict in signal assertion
			if(~read_procedure_start) begin
				inf.w = 1'b0;
			end
		end
	end
	
	
	task prepare_next_cycle_write();
		// Already at negative edge here
		// If tag check done in last cycle
		inf.w = 1'b1; // write on next clock cycle
		
		// Write to previous position 
		d_cache.write_data_tag_and_metadata(
												// Inputs 
												.w_line(inf.w_line),						
												.w_way(inf.w_way),							
												.w_data(inf.w_data),						
												.w_tag(inf.w_tag),							
												.w_index(inf.w_index)
											);		
		
		d_cache.delay_update_metadata();
	endtask
	
	/**
	 * Call on a read or on a write (behavior would vary based on the signals asserted
	 */
	task automatic read_procedure();
		inf.r = 1'b1;
		inf.no_tagcheck_read = 1'b0; // reading for tags initially
		
		// Indicate the function has been been started
		read_procedure_start = 1;
		
		if(inf.access_type) begin
			inf.w_tagcheck = 1'b1;
		end
		else begin
			inf.w_tagcheck = 1'b0;
		end
		
		// save index for later memory write
		r_index_save = inf.r_index;
		r_tag_save = inf.r_tag;
		r_line_save = inf.r_line;
		
		// Index has been latched
		@(posedge clk);
		
		// Perform read
		read_main(); 
		
		// Wait for input to stabilize
		@(negedge clk);
		inf.w = 1'b0;
		
		// Evaluate read
		if(inf.perf_hit) begin			
			// Compare with DUT
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
		else begin
			// Write back to memory starting from the way where the missed data was found 
			inf.no_tagcheck_way = inf.perf_way;	
			w_way_save = inf.dut_way;
			
			if(inf.dut_way !== inf.perf_way) begin
				$display("FAILED: The DUT eviction way is different from the perf test");
			end
			
			// Read out all four times for all the words on a way
			for(int i = 0; i < RAM_READ_SIZE / WORD_SIZE; i++) begin
				// Perform a read for write back to memory
				inf.r = 1'b1;
				
				if(i !== 0) begin
					// Read is ready now so compare data
					@(posedge clk) begin
						// inf.no_tagcheck_read = ~inf.perf_hit; // On a miss assert to prevent modification of metadata
						
						// update meta data from previous read on the previous cycle
						d_cache.delay_update_metadata();
						
						read_main();
					end
					
					// Wait for input to stabilize
					@(negedge clk);
				end
				
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
										
				// Already on neg edge of clock
				if(i == 0) begin
					// if the line is not dirty, write immediately
					if(~inf.metadata_block.dirty) begin
						break;
					end
					
					inf.w_tagcheck = 1'b0;
					// Disable write from previous cycle
					inf.w = 1'b0;
					inf.w_index = 8'h0;
					inf.w_line = 6'h0;						
					inf.w_way = 2'h0;		
					inf.w_tag = 18'h0;	
				end
				
				// Already on neg edge of clock
				if(inf.r_line[5:4] == 2'b11) begin
					inf.r_line[5:4] = 2'b00;
				end 
				else begin
					inf.r_line[5:4] += 1; // loop round
				end
			end
			
			// Write all 4 words on way // TO DO: Writing tags more than once
			for(int i = 0; i < RAM_READ_SIZE / WORD_SIZE; i++) begin
				if(i == 0) begin // initialize on first write
					// Already on negative clk edge
					inf.w_tagcheck = 1'b0;
					inf.r = 1'b0;
					inf.w = 1'b1;	
					// Writing in same order data was read
					inf.w_way = w_way_save;
					inf.w_tag = inf.r_tag;
					inf.w_index = inf.r_index;
					inf.w_data = WORD_SIZE'(0);
					inf.w_line[5:4] = inf.r_line[5:4];
					inf.r_index = 8'h0;
					inf.r_tag = 18'h0;
					inf.r_line = 6'h0;
				end
				
				@(posedge clk) begin
					// Update for previous read
					if(i == 0) begin
						// update meta data from previous read
						d_cache.delay_update_metadata();
					end
			
				
					d_cache.write_data_tag_and_metadata(
						.w_index(inf.w_index),					
						.w_line(inf.w_line),				
						.w_way(inf.w_way),				
						.w_data(inf.w_data),	// data to be fetched from memory. Should always be zero
						.w_tag(inf.w_tag)		// write to particular tag which is needed to be read 
					);		
				end
				
				
				@(negedge clk) begin
					// Write every word
					if(inf.w_line[5:4] == 2'b11) begin
						inf.w_line[5:4] = 2'b00;
					end 
					else begin
						inf.w_line[5:4] += 1; // loop round
					end 
				end
			end
			
		
			// Perform a read because the data is now valid
			// 	or on a write, the block is now in the cache
			// Already on negative clock edge from loop

			inf.w = 1'b0;
			inf.r = 1'b1;
			inf.w_tagcheck = inf.access_type;	
			inf.r_index = r_index_save;
			inf.r_tag = r_tag_save;
			inf.r_line = r_line_save;
			inf.no_tagcheck_read = 1'b0;			
			
			// Attempt to read tag again 
			@(posedge clk) begin
				read_main();
			end
			
			// Compare on negative clock edge
			@(negedge clk) begin

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
		
		// on a write, save the addresses for next cycle
		if(inf.access_type) begin 
			inf.w_index = r_index_save;
			inf.w_line = r_line_save;						
			inf.w_way = w_way_save;		
			inf.w_tag = r_tag_save;			
			inf.w_data = get_next_data(inf.r_line, inf.perf_way); // data to be written on previous write request
			
			inf.w = 1'b1; // write data on next cycle
			inf.r = 1'b0;
			inf.r_index = 8'h0;
			inf.r_tag = 18'h0;
			inf.r_line = 6'h0;
		end
		
		// Exiting function
		read_procedure_start = 0;
	endtask
	
	
	function logic [WORD_SIZE - 1:0] get_next_data(
		logic [5:0] r_line,
		logic [$clog2(WAY_PER_SET) - 1: 0] way	
		);
		
		int index; 
		index = r_line[5:4] + way;
		if(index >= WAY_PER_SET) begin
			index -= WAY_PER_SET;
		end
		
		return inf.DATA_ARRAY[index];
	endfunction
	
	
	class rand_gen;
		randc int num;
		int max_val;
		
		function new(int max_val);
			this.max_val = max_val;
		endfunction
		constraint limit_c { num < max_val; num >= 0;}
	endclass
	
	/** Initialize tag and data blocks in DUT */
	initial begin
		CACHE0.tags.mem = '{default:'0};
		CACHE0.data_blockram.mem = '{default:'0};
	end
	
	
	/**************	TEST THE DUT LOGIC  *****************/
	
	initial begin
		// Declare
		rand_gen rand_gen_inst1 = new(16 * 3); // for writing to 3 indices
		rand_gen rand_gen_inst2 = new(16 * 3); // for reading from 3 indices
		// Initialize signal
		inf.update_metadata = 1'b1;
		inf.flushtype = 2'b00; // no flushes
		inf.w_tagcheck = 1'b0; // same thing but for DUT
		inf.r_tag = 18'h0;
		inf.r_index = 8'd100;
		inf.r_line = 6'b000000; 
		inf.r = 1'b0;
		inf.w = 1'b0;
		inf.no_tagcheck_read = 1'b0;
		inf.perf_hit = 1'b0;
		inf.perf_dirty = 1'b0;
		inf.perf_way = 1'b0;
		inf.perf_data_out = {WORD_SIZE{1'b0}};
		inf.perf_tag_out = {TAG_SIZE{1'b0}};
		inf.w_index = 2'b00;	
		inf.w_line = 6'b000000;								
		inf.w_way = 2'b00;		
		inf.w_data = {WORD_SIZE{1'b0}};					
		inf.w_tag = {TAG_SIZE{1'b0}};
		inf.no_tagcheck_way = 2'b00;
		inf.access_type = 1'b0;
		inf.metadata_block = '{default:'0};
		inf.data_block = {RAM_READ_SIZE{1'b0}};			
		inf.tag_block = {(TAG_SIZE * WAY_PER_SET){1'b0}};
		read_procedure_start = 0; // indicate if the function has been called
		INDEX_ARRAY = '{default:'0};
		
		// Declare and Initialize 
		inf.DATA_ARRAY = '{128'hAAAA, 128'hBBBB, 128'hCCCC, 128'hDDDD};
		inf.TAG_ARRAY = '{18'h01234, 18'h05678, 18'h09ABC, 18'h0DDEF, 18'h3FFFF};
		
		repeat(5) @(negedge clk);
		rst = 1'b0; // deassert reset
		
		inf.flushtype = 2'b00; // no flushes
		
		/*******************************ACT 1 ***************************/
		// Features: 
		// 1. Lots of Forwarding
		// 2. Requests to same line 
		// 3. Basic random writes and reads
		
		/******************************* WRITES ***************************/
		// Write to the remaining ways on the cache and validate

		for(int i = 0; i < 4; i += 1) begin
			// Change data for next read access
			// Sidenote: Already on negedge from previous function
			
			//TAGS
			inf.r_tag = inf.TAG_ARRAY[i];
			// Change data for next access
			inf.r_index = 100;	
			
			// Write remaining lines to cache (same tag as above)
			// Line -> 00
			inf.access_type = 1'b1;
			inf.r_line = 6'b000000; // only top 2 bits change from 00 -> 11
			read_procedure();
			prepare_next_cycle_write();
			
			//TAGS
			inf.r_tag = inf.TAG_ARRAY[i];
			// Change data for next access
			inf.r_index = 100;	
			
			// Write remaining lines to cache (same tag as above)
			// Line -> 01
			inf.access_type = 1'b1;
			inf.r_line = 6'b010000; // only top 2 bits change from 00 -> 11
			read_procedure();
			prepare_next_cycle_write();
			
			//TAGS
			inf.r_tag = inf.TAG_ARRAY[i];
			// Change data for next access
			inf.r_index = 100;	
			
			// Line -> 10
			inf.access_type = 1'b1;
			inf.r_line = 6'b100000; // only top 2 bits change from 00 -> 11
			read_procedure();
			prepare_next_cycle_write();
			
			//TAGS
			inf.r_tag = inf.TAG_ARRAY[i];
			// Change data for next access
			inf.r_index = 100;	
			
			// Line -> 11
			inf.access_type = 1'b1;
			inf.r_line = 6'b110000; // only top 2 bits change from 00 -> 11
			read_procedure();
			prepare_next_cycle_write();
		end

		/***********************SAME LINE READS ***************************/
		// Write to the remaining ways on the cache and validate
		for(int i = 3; i >= 0; i -= 1) begin
			//TAGS
			inf.r_tag = inf.TAG_ARRAY[i];
			// Change data for next access
			inf.r_index = 100;	
			
			// Perform reads to specific lines in random order
			// Line -> 01
			inf.access_type = 1'b0;
			inf.r_line = 6'b010000; // only top 2 bits change from 00 -> 11
			read_procedure();
			d_cache.delay_update_metadata();
			
			
			//TAGS
			inf.r_tag = inf.TAG_ARRAY[i];
			// Change data for next access
			inf.r_index = 100;	
			
			// Perform reads to specific lines in random order
			// Line -> 11
			inf.access_type = 1'b0;
			inf.r_line = 6'b110000; // only top 2 bits change from 00 -> 11
			read_procedure();
			d_cache.delay_update_metadata();
			
			//TAGS
			inf.r_tag = inf.TAG_ARRAY[i];
			// Change data for next access
			inf.r_index = 100;	
			
			// Line -> 00
			inf.access_type = 1'b0;
			inf.r_line = 6'b000000; // only top 2 bits change from 00 -> 11
			read_procedure();
			d_cache.delay_update_metadata();
			
			//TAGS
			inf.r_tag = inf.TAG_ARRAY[i];
			// Change data for next access
			inf.r_index = 100;	
			
			// Line -> 10
			inf.access_type = 1'b0;
			inf.r_line = 6'b100000; // only top 2 bits change from 00 -> 11
			read_procedure();
			d_cache.delay_update_metadata();
		end
		
		
		INDEX_ARRAY = '{8'd150, 8'd23, 8'd211};
		rand_gen_inst1 = new(16 * 3); // for writing to 3 indices
		rand_gen_inst2 = new(16 * 3); // for reading from 3 indices
		
		
		
		/*******************************ACT 2 ***************************/
		// Features:
		// 1.. Random Read and Write Accesses
		
		/******************************* WRITES ***************************/
		// Write to 3 different ways in cache and read in any order

		loop_cnt1 = 0;
		loop_cnt2 = 0;
		while(loop_cnt1 < (16 * 3)) begin
			rand_gen_inst1.randomize();
			loop_cnt1 += 1;
			
			// Change data for next read access
			// Sidenote: Already on negedge from previous function

			// Change data for next access
			index_group = rand_gen_inst1.num % 16;
			way_index = index_group / 4;
			line_index = index_group % 4;
			inf.r_index = INDEX_ARRAY[rand_gen_inst1.num / 16];
			inf.r_tag = inf.TAG_ARRAY[way_index]; //TAGS
			
			
			// Write remaining lines to cache (same tag as above)
			// Line -> 00
			inf.access_type = 1'b1;
			inf.r_line = {line_index[1:0], 4'h0}; // only top 2 bits change from 00 -> 11
			read_procedure();
			prepare_next_cycle_write();
			
			// Give some time for actual data to be present before reading
			if(loop_cnt1 >= 24) begin
				rand_gen_inst2.randomize();
				loop_cnt2 += 1;
				
				// Change data for next access
				index_group = rand_gen_inst2.num % 16;
				way_index = index_group / 4;
				line_index = index_group % 4;
				inf.r_index = INDEX_ARRAY[rand_gen_inst2.num / 16];
				inf.r_tag = inf.TAG_ARRAY[way_index]; //TAGS
					
				// Perform reads to specific lines in random order
				// Line -> 01
				inf.access_type = 1'b0;
				inf.r_line = {line_index[1:0], 4'h0};; // only top 2 bits change from 00 -> 11
				read_procedure();
				d_cache.delay_update_metadata();
			end
		end
		
		
		// Read the remaining positions
		while(loop_cnt2 < (16 * 3)) begin
			rand_gen_inst2.randomize();
			loop_cnt2 += 1;
				
			// Change data for next access
			index_group = rand_gen_inst2.num % 16;
			way_index = index_group / 4;
			line_index = index_group % 4;
			inf.r_index = INDEX_ARRAY[rand_gen_inst2.num / 16];
			inf.r_tag = inf.TAG_ARRAY[way_index]; //TAGS
			
			
			// Perform reads to specific lines in random order
			// Line -> 01
			inf.access_type = 1'b0;
			inf.r_line = {line_index[1:0], 4'h0}; // only top 2 bits change from 00 -> 11
			read_procedure();
			d_cache.delay_update_metadata();
		end
		
		@(negedge clk);
		
		
		
		$stop();		
		
	end
	
endmodule