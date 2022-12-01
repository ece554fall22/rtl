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
	logic [7:0] w_index; 		// Index where the cache would be written
	logic [7:0] r_index;		// Index of cache where data is to be read 
	logic [17:0] w_tag; 		// The tag of data to write to the cache 
	logic [17:0] r_tag;			// The tag to be compared for read or follow up write
	logic [5:0] w_line;			// desired line for write, uses the first two bits of these
	logic [5:0] r_line;			// desired line for write and read, uses the first two bits of these
	logic [127:0] w_data;		// data to be written in write operation
	logic [1:0] flushtype; 		// type of flush 11 = flushclean 10 = flushdirty 01 = flushline 00 = noflush
	logic [1:0] w_way;			// w_way is the 128bit chuck of a line in a set		
	logic w_tagcheck;			// signifies to the cache that this is a read being done for tagcheck purposes
	logic rst; 					// Reset signals 
	logic clk;					// Clock signals 
	logic w;					// incoming write signal
	logic r; 					// incoming read signal
	logic [17:0] tag_out;    	// it is used to write tag back to main memory
	logic [127:0] data_out;  	// data to be written back to main memory
	logic [1:0] way;         	// on the cycle that w_tagcheck is asserted
	logic hit;					// assert on hit
	logic dirty;				// indicates whether a given line is dirty

	// Helper signals 
	data_memory_type data_memory;	// refers to the data memory portion of a data cache instance
	tag_memory_type tag_memory;		// refers to the tag cache memory of a data cache instance
	bit access_type; 				// determine if a write or a read is to be perfomed 

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
						.w_tagcheck(w_tagcheck), 
						.rst(rst), 
						.clk(clk), 
						.w(w), 
						.r(r), 
						.tag_out(tag_out), 
						.data_out(data_out), 
						.way(way), 
						.hit(hit),
						.dirty(dirty));
						
						
	

	initial begin
		// Declare and Initialize 
		data_cache_memory_class data_cache;
		data_cache = new();
		data_cache.randomize();					// initialize with random values
		
		// Determine random task to do with cache
		access_type = $random;
		
		// Writes have to have a read followed by the write if there is a hit
		
		
		
		// For ease
		data_memory = data_cache.data_memory;
		tag_memory = data_cache.tag_memory;
	  
		for(int i = 0; i < 10; i++) begin
			$write("%x", data_cache.data_memory[i]);
			$display("");
		end 
		
		// Objectives:
		
		// 1. Check cache returns a miss when invalid data is present
		
		
		// 2. Check that a hit is asserted appropriately when data is present in the cache
		
		
		// 3. On sets with all invalid lines check that the plru performs as expected and fills up all lines in a set
		
		
		// * 4. Check the appropriate victim way is used by having multiple insertions and deletes on a single set
		
		
		// 
		
		// we would be using 8 tags for all the lines in the cache
		
		
		
		read_data_tag_and_metadata_blocks(
		// Inputs 
		const ref logic [$clog2(NUM_OF_SETS) - 1: 0] r_index,
		const ref logic [5:0] r_line	
		
		// Outputs 
		ref logic [RAM_READ_SIZE - 1: 0] out_data,		
		ref logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] out_tag,		
		ref set_metadata out_metadata
		);
		
		
		get_hit_dirty_and_way(
		// Inputs 
		const ref logic [TAG_SIZE - 1: 0] tag_in,						// tag to be searched for in block
		const ref set_metadata metadata_block,							// metadata per way		
		const ref logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] tag_block,	// all tags in a set 18 * 4 bits
		
		// Output 
		ref logic hit,											// Indicate whether the data was found
		ref logic dirty,										// Indicate whether the data present is dirty
		ref logic [$clog2(WAY_PER_SET) - 1: 0] way				// Way where data is present
		);
		
		
		// Proceedure:  victimway override would be used to replace the exact way which the DUT is replacing
		
		
	end
	
	// Generate clock
	always @(clk)
		clk <= #2 ~clk;


endmodule