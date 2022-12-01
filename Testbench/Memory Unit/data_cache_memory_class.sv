/** 
* Useful for randomizing the memory instances
*/
class data_cache_memory_class;
	// Important constants (similar to cache_types_pkg.sv)
	localparam DATA_CACHE_MEM_SIZE = 4096;		// 4096 bits
	localparam DATA_CACHE_TAG_MEM_SIZE = 2048;	// 2048 bits
	localparam WORD_SIZE = 128;					// 128 bits
	localparam TAG_SIZE = 18; 					// 18 bits
	localparam WAY_PER_SET = 4; 				// 4 ways in a set
	localparam NUM_OF_SETS = 256;				// 256 sets per cache
	localparam RAM_READ_SIZE = 512; 			// 512 bits per read
	localparam TAG_SIZE = 18;					// 18 bits
	
	// Structs 
	typedef struct{
		// Story ft. plru: [2:0] way 
		// bit 2 tells the whether 11/10 or 01/00 was recently accessed (way[1])
		// bit 1 tells what way[0] on the 11/10 side is currently or most recently accessed
		// bit 0 tells what way[0] on the 01/00 side is currently or most recently accessed
		logic [WAY_PER_SET : 0] plru; 							// 3 bits
		logic last_accessed_first_bit;							// Indicate whether 11/10 or 01/00 was accessed last (represents the higher bit (way[1]))
		logic last_accessed_top_half_way_last_bit; 				// Indicate whether 11 or 10 was last accessed (represents the lower bit)
		logic last_accessed_bottom_half_way_last_bit; 			// Indicate whether 01 or 00 was last accessed (represents the lower bit)
		logic valid [WAY_PER_SET - 1];							// Valid bits (one per way/tag)
		logic dirty [WAY_PER_SET - 1];							// Dirty bits (one per way)
	
	}set_metadata;
	
	typedef struct{
		set_metadata data [NUM_OF_SETS - 1: 0];
	} metadata_memory;
	
	
	logic [WORD_SIZE - 1:0] data_memory [DATA_CACHE_MEM_SIZE - 1:0];		// Data array
	logic [TAG_SIZE - 1:0] tag_memory [DATA_CACHE_TAG_MEM_SIZE - 1:0]; 		// Tag array
	metadata_memory metadata;												// Hold metadata
	
	
	// Initialize the data to zeros.
	function new();
		data_memory = '{default:'0};
		tag_memory = '{default:'0};
		valid = '{default:'0};
		dirty = '{default:'0};
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
		ref logic [RAM_READ_SIZE - 1: 0] read_data; 		// The return value of the read	
	);
	
		// Helper signals and values
		logic [$clog2(WAY_PER_SET) - 1: 0] way_index;	// 2 bits to index ways

		// Initialize return data
		for (int i = 0; i < WAY_PER_SET; i = i + 1) begin // i = way index (i = 0 for way -> 00)
			way_index = 2'(i);	 
			
			read_data[(WORD_SIZE * (i + 1)) - 1 : WORD_SIZE * i] = data_memory[{r_index, r_line[5:4], way_index}];
		end
		
		return read_data;
		
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
			
			read_data[(TAG_SIZE * (i + 1)) - 1 : TAG_SIZE * i] = tag_memory[{r_index, way_index}];
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
	task read_data_tag_and_metadata_blocks(
		// Inputs 
		automatic ref logic clk;
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,
		const ref logic [5:0] r_line	
		
		// Outputs 
		ref logic [RAM_READ_SIZE - 1: 0] out_data,		
		ref logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] out_tag,		
		ref set_metadata out_metadata
	);
		
		// Fill data
		get_data(
					.r_index(r_index),
					.r_line(r_line),
					.read_data(out_data),
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
	endtask
	
	/**
	 * Call to get the way where the data is present if the data is present.
	 * Returns a hit which should be used as a reference on whether the data in the way should be 
	 * 	regarded
	 */
	task get_hit_dirty_victimway_and_way(
		// Inputs 
		const ref logic [TAG_SIZE - 1: 0] tag_in,						// tag to be searched for in block
		const ref set_metadata metadata_block,							// metadata per way		
		const ref logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] tag_block,	// all tags in a set 18 * 4 bits
		
		// For metadata computation
		const ref bit update_metadata,									// assert to indicate whether the metadata should be updated
																		// in the case where the test has to shadow the DUT
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,			// Index of set whose metadata would possibly be updated
		const ref bit read_access_type									// 1 indicates a read with a followup write and otherwise 0
		
		// Output 
		ref logic hit,													// Indicate whether the data was found
		ref logic dirty,												// Indicate whether the data present is dirty
		ref logic [$clog2(WAY_PER_SET) - 1: 0] way						// Way where data is present
	);		
		// Helper signals 
		logic [WAY_PER_SET - 1: 0] data_found; 							// indicate the index where the data was found
		logic [TAG_SIZE - 1: 0] tag_at_index;							// variable in for loop for each way
	
		// data found 
		for(int i = 0; i < WAY_PER_SET; i++) begin
			tag_at_index = tag_block[(TAG_SIZE * (i + 1)) - 1: TAG_SIZE * i];
			data_found[i] = (tag_at_index === tag_in) ? 1'b1 : 1'b0;
			
			// check if data on way is valid array 
			data_found[i] &= metadata_block.valid[i];
			
			if(data_found[i]) begin
				way = 2'(i);
				
				// invalid data should not be dirty
				dirty = metadata_block.dirty[i] & metadata_block.valid[i];
			end
		end
		
		// if data was found anywhere
		hit = |data_found;
		
		// On flag: update the metadata after access
		if (update_metadata) begin 
			fork 
				begin
					compute_next_metadata(
											.hit(hit),
											.way(way),
											.read_access_type(read_access_type),
											.r_index(r_index),
											.meta_data(out_metadata)
											); // saves to next_set_metadata class variable
					
					// Update on next clock edge
					@(posedge clk) delay_update_metadata();
				end
			join_none
		end
		
	endtask
	
	/**
	* Based on parameters passed compute the next metadata for the indexed set
	*/
	task automatic compute_next_metadata(
		// Inputs 
		const ref logic hit,											// data present in cache
		const ref logic [$clog2(WAY_PER_SET) - 1: 0] way,				// way where data is present 
		const ref bit read_access_type,									// assert if read is done for the purpose of a follow up write
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,			// Index of set whose metadata would possibly be updated
		const ref set_metadata meta_data,								// Metadata of the set
		const ref logic [$clog2(NUM_OF_FLUSH_TYPES) - 1: 0] flushtype;	// 11 = flushclean, 10 = flushdirty, 01 = flushline, 00 = noflush
		
		// Outputs
		ref set_metadata next_set_metadata								// next metadata that would be used for updating that of the specified set 
		ref logic [$clog2(WAY_PER_SET) - 1: 0] victimway 				// the victimway in case of a miss
	);
		// Helper signals
		logic next_valid [WAY_PER_SET - 1];								// Valid bits (one per way/tag)
		logic next_dirty [WAY_PER_SET - 1];								// Dirty bits (one per way)
		logic next_last_accessed_first_bit;								// Indicate whether 11/10 or 01/00 was accessed last (represents the higher bit (way[1]))
		logic next_last_accessed_top_half_way_last_bit; 				// Indicate whether 11 or 10 was last accessed (represents the lower bit)
		logic next_last_accessed_bottom_half_way_last_bit; 				// Indicate whether 01 or 00 was last accessed (represents the lower bit)
		logic [$clog2(WAY_PER_SET) - 1: 0] way_accessed; 				// choose between victimway on a miss and the way selected on a hit

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
			else begin // read without followup write
				next_dirty = dirty;
		end						
		else begin
			// Compute the victimway 
			compute_victimway (
								.meta_data(meta_data),
								.victimway(victimway)
							);
			
			// TO DO: Add flushtype
			
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
		next_last_accessed_first_bit = last_accessed_first_bit ;							
		next_last_accessed_top_half_way_last_bit = last_accessed_top_half_way_last_bit ; 				
		next_last_accessed_bottom_half_way_last_bit = last_accessed_bottom_half_way_last_bit;
		
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
		next_set_metadata.valid;
		next_set_metadata.dirty;
		
		// Initialize plru breakdown
		next_set_metadata.last_accessed_first_bit = next_last_accessed_first_bit;
		next_set_metadata.last_accessed_top_half_way_last_bit = next_last_accessed_top_half_way_last_bit;
		next_set_metadata.last_accessed_bottom_hal = next_last_accessed_bottom_half_way_last_bit;
		
		// Initialize plru members 
		next_set_metadata.plru = {next_last_accessed_first_bit, 
								  next_last_accessed_top_half_way_last_bit,
								  next_last_accessed_bottom_half_way_last_bit};
	 
		
	endtask
	
	/**
	* Computes the victimway using the passed parameters 
	*/
	task compute_victimway (
		// Inputs
		const ref set_metadata meta_data,						// Metadata of the set
		
		// Output 
		ref logic [$clog2(WAY_PER_SET) - 1: 0] victimway		// the victim of the passed set
	);
		// Helper signals
		logic valid [WAY_PER_SET - 1];							// Valid bits (one per way/tag)
		bit any_invalid;										// indicate if there is an invalid line
		logic last_accessed_top_half_way_last_bit; 				// Indicate whether 11 or 10 was last accessed (represents the lower bit)
		logic last_accessed_bottom_half_way_last_bit; 			// Indicate whether 01 or 00 was last accessed (represents the lower bit)
		logic last_accessed_first_bit;							// Indicate whether 11/10 or 01/00 was accessed last (represents the higher bit (way[1]))
		
		// Initialize 
		last_accessed_top_half_way_last_bit    = meta_data.last_accessed_top_half_way_last_bit;	 	// 1 indicates 11 was accessed last and 0 -> 10
		last_accessed_bottom_half_way_last_bit = meta_data.last_accessed_bottom_half_way_last_bit; 	// 1 indicates 01 was accessed last and 0 -> 00
		last_accessed_first_bit = meta_data.last_accessed_first_bit;
		
		// Victim priority 11 -> 10 -> 01 -> 00
		for(int i = WAY_PER_SET - 1; i > 0; i++) begin
			if(valid[i]) begin
				any_invalid = 1'b1;
				victimway = WAY_PER_SET'(i); // 2 bits
				return;
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
	
	function delay_update_metadata(); 
		set = next_set_metadata
	endtask
	
	
	/**
	 *
	 */
	task get_data_and_tag(
		// Inputs 
		const ref logic [RAM_READ_SIZE - 1: 0] data_block,					// Data across ways (all data in a line)
		const ref logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] tag_block,	// all tags in a set 18 * 4 bits
		const ref set_metadata metadata_block,								// metadata per way
		const ref logic hit,													// Indicate whether the data was found
		const ref logic [$clog2(WAY_PER_SET) - 1: 0] way						// Way where data is present
		
		// Output
		ref logic [WORD_SIZE - 1: 0] data_out,
		ref logic [TAG_SIZE - 1: 0] tag_out,
		
	);
	
		// Internal signals
		logic [WORD_SIZE - 1: 0] way_data;						// 128 bits of data on a particular way
	
		if(hit) begin
			data_out = data_block[(WORD_SIZE * (way + 1)) - 1 : way * WORD_SIZE]; 
			tag_block = tag_block[(TAG_SIZE * (i + 1)) - 1: TAG_SIZE * i];
		end
		else begin
			$display("Function should not be called on a miss");
		end
	endtask

	/**
	* Call to fill passed parameters with the current values of the data, tag and metadata
	* 	at the specified index.
	*/
	task write_data_tag_and_metadata(
		// Inputs 
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,
		const ref logic [5:0] r_line	
		
		// Outputs 
		ref logic [RAM_READ_SIZE - 1: 0] out_data,		
		ref logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] out_tag,		
		ref set_metadata out_metadata
	);
	
	
	endtask
	

endclass 