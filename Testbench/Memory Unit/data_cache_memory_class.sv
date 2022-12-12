// Red productions

/** Used in testing */

`ifndef CACHE_TYPES_PKG
	`define CACHE_TYPES_PKG 1
	`include "cache_types_pkg.sv"
`endif

import cache_types_pkg::*; // for structs

/** 
* Useful for randomizing the memory instances
*/
class data_cache_memory_class;
	logic [WORD_SIZE - 1:0] data_memory [DATA_CACHE_MEM_SIZE - 1:0];		// Data array
	logic [TAG_SIZE - 1:0] tag_memory [DATA_CACHE_TAG_MEM_SIZE - 1:0]; 		// Tag array
	
	logic [$clog2(NUM_OF_SETS) - 1: 0] most_recent_r_index;					// for updating metadata
	metadata_memory metadata;												// Hold metadata
	set_metadata next_set_metadata;											// next metadata that would be used for updating that of the specified set 
	logic [$clog2(WAY_PER_SET) - 1:0] victimway_sig; 						// Signal for victimway
	
	// Initialize the data to zeros. (not the tag and memory banks)
	function new();
		integer i;
		data_memory = '{default:'0};
		tag_memory = '{default:'0};
		most_recent_r_index = '{default:'0};
		next_set_metadata = '{default:'0};
		next_set_metadata.valid = '{default:'0};
		next_set_metadata.dirty = '{default:'0};
		next_set_metadata = '{default:'0};
		metadata = '{default:'0};
		
		for(i = 0; i < NUM_OF_SETS; i = i + 1) begin
			metadata.data[0] = '{default:'0};
		end
	endfunction
	
	/**
	* This returns the data of a way across all the ways in a set e.g 
	* (way0 -> 00,  way1 -> 00,  way2 -> 00,  way3 -> 00) WORD_SIZE * 4
	* 
	* Sidenote: way0 data ends at bit0 and way3 data starts at bit (RAM_READ_SIZE - 1)
	*/
	task automatic get_data(
		// Inputs 
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,
		const ref logic [5:0] r_line,							// the line index that would be read
		
		// Outputs 
		ref logic [RAM_READ_SIZE - 1: 0] read_data		 		// The return value of the read	
	);
	
		// Helper signals and values
		logic [$clog2(WAY_PER_SET) - 1: 0] way_index;	// 2 bits to index ways


		integer i;
		// Initialize return data
		for (i = 0; i < WAY_PER_SET; i = i + 1) begin // i = way index (i = 0 for way -> 00)
			way_index = 2'(i);	 
			
			 read_data[(WORD_SIZE * i) +: WORD_SIZE] = data_memory[{r_index, r_line[5:4], way_index}];
		end
		
	endtask
	
	/**
	* This returns the data of a way across all the ways in a set e.g 
	* (way0 -> 00,  way1 -> 00,  way2 -> 00,  way3 -> 00) WORD_SIZE * 4
	* 
	* Sidenote: way0 data ends at bit0 and way3 data starts at bit (RAM_READ_SIZE - 1)
	*/
	task automatic get_tag(
		// Inputs
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,
		
		// Outputs 
		ref logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] read_data 		// The return value of the read	
		
	);
		
		// Helper signals and values
		logic [$clog2(WAY_PER_SET) - 1: 0] way_index;	// 2 bits to index ways

		// Initialize return data
		for (int i = 0; i < WAY_PER_SET; i = i + 1) begin // i = word index (i = 0 for word -> 00)
			way_index = 2'(i);	 
			
			read_data[(TAG_SIZE * i) +: TAG_SIZE] = tag_memory[{r_index, way_index}];
		end
	endtask
	
	
	/**
	* Returns the metadata value at the specified read index
	*/
	task automatic get_current_metadata(
		// Inputs
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,
		
		// Outputs 
		ref set_metadata read_data
	);
	
		read_data = metadata.data[r_index];
	endtask
	
	/**
	* Call to fill passed parameters with the current values of the data, tag and metadata
	* 	at the specified index.
	*/
	task automatic read_data_tag_and_metadata_blocks(
		// Inputs 
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,
		const ref logic [5:0] r_line,
		
		// Outputs 
		ref logic [RAM_READ_SIZE - 1: 0] out_data,		
		ref logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] out_tag,		
		ref set_metadata out_metadata
	);
		
		// Fill data
		get_data(
					.r_index(r_index),
					.r_line(r_line),
					.read_data(out_data)
				);
				
				
		// Fill tags
		get_tag(
					.r_index(r_index),
					.read_data(out_tag)
				);
				
		
		// Fill metadata
		get_current_metadata(
								.r_index(r_index),
								.read_data(out_metadata)
							);
							
		// Update last accessed cache index
		most_recent_r_index = r_index;
	endtask
	
	/**
	 * Call to get the way where the data is present if the data is present.
	 * Returns a hit which should be used as a reference on whether the data in the way should be 
	 * 	regarded
	 */
	task automatic get_hit_dirty_victimway_and_way(
		// Inputs 
		const ref logic [TAG_SIZE - 1: 0] tag_in,						// tag to be searched for in block
		const ref set_metadata metadata_block,							// metadata per way		
		const ref logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] tag_block,	// all tags in a set 18 * 4 bits
		
		// For metadata computation
		const ref bit update_metadata,									// assert to indicate whether the metadata should be updated
																		// in the case where the test has to shadow the DUT
																		
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,			// Index of set whose metadata would possibly be updated
		const ref logic read_access_type,									// 1 indicates a read with a followup write and otherwise 0
		const ref logic no_tagcheck_read,								// Used to determine if the data is used for a write back to memory on a miss
		const ref logic [$clog2(NUM_OF_FLUSH_TYPES) - 1: 0] flushtype,	// 11 = flushclean, 10 = flushdirty, 01 = flushline, 00 = noflush
		
		// Output 
		ref logic hit,													// Indicate whether the data was found
		ref logic dirty,												// Indicate whether the data present is dirty
		ref logic [$clog2(WAY_PER_SET) - 1: 0] way						// Way where data is present
	);		
									
		// Helper signals 
		logic [WAY_PER_SET - 1: 0] data_found; 							// indicate the index where the data was found
		logic [TAG_SIZE - 1: 0] tag_at_index;							// variable in for loop for each way
		logic [$clog2(WAY_PER_SET) - 1: 0] victimway;

		// data found 
		for(int i = 0; i < WAY_PER_SET; i = i + 1) begin
			tag_at_index = tag_block[(TAG_SIZE * i) +: TAG_SIZE];
			data_found[i] = (tag_at_index === tag_in) ? 1'b1 : 1'b0;
			
			// check if data on way is valid array 
			data_found[i] &= metadata_block.valid[i];
			
			if(data_found[i]) begin
				way = i[1:0];
				
				// invalid data should not be dirty
				dirty = metadata_block.dirty[i] & metadata_block.valid[i];
			end
		end
		
		/*********** Outputs **************/
		// if data was found anywhere
		hit = |data_found;
		
		/********** Update Metadata ********/
		
		// Do not update metadata on a when writing back to memory 
		
		// Update metadata on every read
		if (update_metadata) begin // & ~no_tagcheck_read) begin 
			compute_next_metadata(
									.hit(hit),
									.way(way),
									.read_access_type(read_access_type),
									.r_index(r_index),
									.meta_data(metadata_block),
									.flushtype(flushtype),
									.victimway(victimway)
									); // saves to next_set_metadata class variable
				
		end
		
		// For viewing victimway signal on waveform
		victimway_sig = victimway;
		
		// Render victim way instead
		if(~hit) begin
			way = victimway;
		end
//		$display("Hit value: %b", hit);
//		$display("Victimway value: %b", victimway);
	endtask
	
	/**
	 * Updates the metadata after certain delay
	 */
	task delay_update_metadata(); 
		if(most_recent_r_index >= 0) begin
			metadata.data[most_recent_r_index] = next_set_metadata;
			most_recent_r_index = -1;
		end
	endtask
	
	/**
	* Based on parameters passed compute the next metadata for the indexed set
	*/
	task automatic compute_next_metadata(
		// Inputs 
		const ref logic hit,											// data present in cache
		const ref logic [$clog2(WAY_PER_SET) - 1: 0] way,				// way where data is present 
		const ref logic read_access_type,									// assert if read is done for the purpose of a follow up write
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,			// Index of set whose metadata would possibly be updated
		const ref set_metadata meta_data,								// Metadata of the set
		const ref logic [$clog2(NUM_OF_FLUSH_TYPES) - 1: 0] flushtype,	// 11 = flushclean, 10 = flushdirty, 01 = flushline, 00 = noflush
		
		// Outputs
		ref logic [$clog2(WAY_PER_SET) - 1: 0] victimway 				// the victimway in case of a miss
	);
		// Helper signals
		logic [WAY_PER_SET - 1 : 0] next_valid;								// Valid bits (one per way/tag)
		logic [WAY_PER_SET - 1 : 0] next_dirty;								// Dirty bits (one per way)
		logic next_last_accessed_first_bit;								// Indicate whether 11/10 or 01/00 was accessed last (represents the higher bit (way[1]))
		logic next_last_accessed_top_half_way_last_bit; 				// Indicate whether 11 or 10 was last accessed (represents the lower bit)
		logic next_last_accessed_bottom_half_way_last_bit; 				// Indicate whether 01 or 00 was last accessed (represents the lower bit)
		logic [$clog2(WAY_PER_SET) - 1: 0] way_accessed; 				// choose between victimway on a miss and the way selected on a hit
		logic [WAY_PER_SET - 1 : 0] valid;									// Valid bits (one per way/tag)
		logic [WAY_PER_SET - 1 : 0] dirty;

		// Initialize 
		valid = meta_data.valid;
		dirty = meta_data.dirty;
		
		// Update dirty
		// Rule 1: Don't update a the dirty flag if it was not done for follow up write purposes
	
		if(hit) begin
			if(read_access_type) begin // read with followup write
				next_dirty = dirty;
				next_dirty[way] = 1'b1; 
			end
			else if(flushtype != 2'b00) begin // cannot be asserted with a write
			
				if(flushtype == 2'b01) begin // flush line
					next_dirty = dirty;
					next_dirty[way] = 1'b0;
					
					// TO DO: Verify that this is for flushing ways
				end
				else if(flushtype == 2'b10) begin // flush dirty
					next_dirty = dirty;
					next_dirty[way] = 4'b0; // none dirty
				end
				else if(flushtype == 2'b11) begin // flushclean
					next_dirty = dirty;
				end
			end
			else begin // read without followup write
				next_dirty = dirty;
			end
		end						
		else begin
			// Compute the victimway 
			compute_victimway (
								.meta_data(meta_data),
								.victimway(victimway)
							);
					
			
			next_dirty = dirty;
			next_dirty[victimway] = 1'b0; // all write backs would be made first before new data comes in
			
			// TO DO: Confirm no changes are made to the dirty array on a miss with regards to flushtypes
			
		end
		
		/**************** Compute next valid bit ****************/
		
		if(flushtype === 2'b00) begin // no flush 
			if(hit) begin // data present in cache
				next_valid = valid;
			end
			else begin	// On a miss: make the victimway index valid since it would shortly be written to  (TO DO: Confirm) 
				next_valid = valid;
				next_valid[victimway] = 1'b1;
			end
		end
		else if(flushtype === 2'b01) begin // flushline (TO DO: Don't know what flushline is)
			next_valid = valid;
			
			// for all the indices where there is a hit invalidate
			if(hit) begin
				next_valid[way] = 1'b0;
			end
		end
		else if(flushtype === 2'b10) begin // flushdirty 
			// for all the indexes that are clean and valid -> keep valid (make position 1)
			next_valid = valid & ~dirty;
		end
		else if(flushtype === 2'b11) begin // flushclean
			// for all the indexes that are clean and valid -> invalidate (make position 0)
			next_valid = valid & dirty;
		end
		

		
		/**************** Compute access bits (plru) ****************/
		
		// Initialize w/ previous values
		next_last_accessed_first_bit = meta_data.last_accessed_first_bit ;							
		next_last_accessed_top_half_way_last_bit = meta_data.last_accessed_top_half_way_last_bit ; 				
		next_last_accessed_bottom_half_way_last_bit = meta_data.last_accessed_bottom_half_way_last_bit;
		
		// Initialize based on hit scenario
		way_accessed = hit ? way : victimway;
		
		next_last_accessed_first_bit = way_accessed[1];  					// indicate the half recently accessed	
		if(way_accessed[1]) begin // 11/10 was just accessed
			next_last_accessed_top_half_way_last_bit = way_accessed[0]; 	// indicate the most recently accessed index on the top half
		end
		else begin // 01/00 was just accessed
			next_last_accessed_bottom_half_way_last_bit = way_accessed[0]; 	// indicate the most recently accessed index on the bottom half
		end

		
		/**************** Initialize next metadata 	*******************/
		
		// Initialize next 
		next_set_metadata.valid = next_valid;
		next_set_metadata.dirty = next_dirty;
		
		// Initialize plru breakdown
		next_set_metadata.last_accessed_first_bit = next_last_accessed_first_bit;
		next_set_metadata.last_accessed_top_half_way_last_bit = next_last_accessed_top_half_way_last_bit;
		next_set_metadata.last_accessed_bottom_half_way_last_bit = next_last_accessed_bottom_half_way_last_bit;
		
		// Initialize plru members 
		next_set_metadata.plru = {next_last_accessed_first_bit, 
								  next_last_accessed_top_half_way_last_bit,
								  next_last_accessed_bottom_half_way_last_bit};
	 
		
	endtask
	
	/**
	* Computes the victimway using the passed parameters 
	*/
	task automatic compute_victimway (
		// Inputs
		const ref set_metadata meta_data,						// Metadata of the set
		
		// Output 
		ref logic [$clog2(WAY_PER_SET) - 1: 0] victimway		// the victim of the passed set
	);
		// Helper signals
		logic [WAY_PER_SET - 1:0]valid;							// Valid bits (one per way/tag)
		bit any_invalid;										// indicate if there is an invalid line
		logic last_accessed_top_half_way_last_bit; 				// Indicate whether 11 or 10 was last accessed (represents the lower bit)
		logic last_accessed_bottom_half_way_last_bit; 			// Indicate whether 01 or 00 was last accessed (represents the lower bit)
		logic last_accessed_first_bit;							// Indicate whether 11/10 or 01/00 was accessed last (represents the higher bit (way[1]))
		
		// Initialize 
		last_accessed_top_half_way_last_bit    = meta_data.last_accessed_top_half_way_last_bit;	 	// 1 indicates 11 was accessed last and 0 -> 10
		last_accessed_bottom_half_way_last_bit = meta_data.last_accessed_bottom_half_way_last_bit; 	// 1 indicates 01 was accessed last and 0 -> 00
		last_accessed_first_bit = meta_data.last_accessed_first_bit;
		valid = meta_data.valid;
		
		any_invalid = 1'b0;
		// Victim priority 11 -> 10 -> 01 -> 00
		for(int i = WAY_PER_SET - 1; i >= 0; i--) begin
			if(~valid[i]) begin
				any_invalid = 1'b1;
				victimway = WAY_PER_SET'(i); // 2 bits
				break;
			end
		end
	
		// When there all lines in the set are valid
		if(~any_invalid) begin
			if(last_accessed_first_bit) begin // 11/10 was last accessed
				if(last_accessed_bottom_half_way_last_bit) begin // 1 -> 01 was last accessed
					victimway = 2'b00;
				end
				else begin  // 0 -> 00 was last accessed
					victimway = 2'b01;
				end
				end
			else begin // 01/00 was last accessed 
				if(last_accessed_top_half_way_last_bit) begin // 1 -> 11 was last accessed
					victimway = 2'b10;
				end
				else begin  // 0 -> 10 was last accessed
					victimway = 2'b11;
				end
			end
		end

	endtask
	

	/**
	 * Returns the data out and the tag outputs of the selected line in the block
	 */
	task automatic get_data_and_tag(
		// Inputs 
		const ref logic [RAM_READ_SIZE - 1: 0] data_block,					// Data across ways (all data in a line
		const ref logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] tag_block,	// all tags in a set 18 * 4 bits
		const ref logic [$clog2(WAY_PER_SET) - 1: 0] way,						// Way where data is present
		
		// Output
		ref logic [WORD_SIZE - 1: 0] data_out,
		ref logic [TAG_SIZE - 1: 0] tag_out
		
	);
	
		data_out = data_block[(WORD_SIZE * way) +: WORD_SIZE]; 
		tag_out = tag_block[(TAG_SIZE * way) +: TAG_SIZE];
	endtask

	/**
	* Call to fill passed parameters with the current values of the data, tag and metadata
	* 	at the specified index.
	*/
	task automatic write_data_tag_and_metadata(
		// Inputs 
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] w_index,		// index that the tag was compared to
		const ref logic [5:0] w_line,								// line which was compared to on the previous cycle
		const ref logic [$clog2(WAY_PER_SET) - 1:0] w_way,			// Way in cache to be written to
		const ref logic [WORD_SIZE - 1:0] w_data,					// data to be written to memory index 
		const ref logic [TAG_SIZE - 1:0] w_tag						// tag to be written for the given way						// assert on last write from memory to cache to make way valid
	);
	
		// Write selected word on line to memory
		data_memory[{w_index, w_line[5:4], w_way}] = w_data;
		tag_memory[{w_index, w_way}] = w_tag;
	endtask
	
	
	task automatic compare_results(
		const ref logic [TAG_SIZE - 1: 0] dut_tag_out,
		const ref logic [WORD_SIZE - 1: 0] dut_data_out,
		const ref logic [1:0] dut_way,
		const ref logic dut_hit,
		const ref logic dut_dirty,
		const ref logic [WAY_PER_SET - 1 : 0] dut_dirty_array,
		const ref logic [WAY_PER_SET - 1 : 0] dut_valid_array,
		const ref logic [$clog2(WAY_PER_SET) : 0] dut_plru,
		const ref logic [TAG_SIZE - 1: 0] perf_tag_out,
		const ref logic [WORD_SIZE - 1: 0] perf_data_out,
		const ref logic [1:0] perf_way,
		const ref logic perf_hit,
		const ref logic perf_dirty,
		const ref logic [WAY_PER_SET - 1 : 0]  perf_dirty_array,
		const ref logic [WAY_PER_SET - 1 : 0] perf_valid_array,
		const ref logic [$clog2(WAY_PER_SET) : 0] perf_plru
	);


		if((|perf_valid_array[perf_way] | (|dut_valid_array[dut_way])) &&
			(dut_tag_out !== perf_tag_out)) begin
			$display("Time %t: TAG failed", $time);
		end
		
		
		if((|perf_valid_array[perf_way] | (|dut_valid_array[dut_way])) &&
			dut_data_out !== perf_data_out) begin
			$display("Time %t: Data out failed", $time);
		end
		
		
		if(dut_way !== perf_way) begin
			$display("Time %t: Way failed", $time);
		end
		
		if(dut_hit !== perf_hit) begin
			$display("Time %t: Hit failed", $time);
		end
		
		if((|perf_valid_array[perf_way] | (|dut_valid_array[dut_way])) && 
			(dut_hit | perf_hit) && dut_dirty !== perf_dirty) begin
			$display("Time %t: Dirty failed", $time);
		end
		
		if((|perf_valid_array | (|dut_valid_array)) && dut_dirty_array !== perf_dirty_array) begin
			$display("Time %t: Dirty array failed", $time);	
		end
		
		if(dut_valid_array !== perf_valid_array) begin
			$display("Time %t: Valid array failed", $time);
		end
		
		if(dut_plru !== perf_plru) begin
			$display("Time %t: Plru array failed", $time);
		end

	endtask
	

endclass 