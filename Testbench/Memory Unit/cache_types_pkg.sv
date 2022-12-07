/**
* This holds the types used in the caches
*/
package cache_types_pkg;
	// Important constants
	// localparam DATA_CACHE_MEM_SIZE = 4096;		// 4096 bits
	// localparam DATA_CACHE_TAG_MEM_SIZE = 2048;	// 2048 bits
	// localparam WORD_SIZE = 128;					// 128 bits
	// localparam TAG_ */SIZE = 18; 					// 18 bits
	
	// Important constants (similar to cache_types_pkg.sv)
	localparam DATA_CACHE_MEM_SIZE = 4096;		// 4096 bits
	localparam DATA_CACHE_TAG_MEM_SIZE = 2048;	// 2048 bits
	localparam WORD_SIZE = 128;					// 128 bits
	localparam TAG_SIZE = 18; 					// 18 bits
	localparam WAY_PER_SET = 4; 				// 4 ways in a set
	localparam NUM_OF_SETS = 256;				// 256 sets per cache
	localparam RAM_READ_SIZE = 512; 			// 512 bits per read
	localparam NUM_OF_FLUSH_TYPES = 4;			
	
	typedef logic [WORD_SIZE - 1:0] data_memory_type [DATA_CACHE_MEM_SIZE - 1:0];		// Data array
	typedef logic [TAG_SIZE - 1:0] tag_memory_type [DATA_CACHE_TAG_MEM_SIZE - 1:0]; 	// Tag array
	
	// Structs 
	typedef struct{
		// Story ft. plru: [2:0] way 
		// bit 2 tells the whether 11/10 or 01/00 was recently accessed (way[1])
		// bit 1 tells what way[0] on the 11/10 side is currently or most recently accessed
		// bit 0 tells what way[0] on the 01/00 side is currently or most recently accessed
		logic [$clog2(WAY_PER_SET) : 0] plru; 					// 3 bits
		logic last_accessed_first_bit;							// Indicate whether 11/10 or 01/00 was accessed last (represents the higher bit (way[1]))
		logic last_accessed_top_half_way_last_bit; 				// Indicate whether 11 or 10 was last accessed (represents the lower bit)
		logic last_accessed_bottom_half_way_last_bit; 			// Indicate whether 01 or 00 was last accessed (represents the lower bit)
		logic [WAY_PER_SET - 1:0] valid;						// Valid bits (one per way/tag)
		logic [WAY_PER_SET - 1:0] dirty;						// Dirty bits (one per way)

	}set_metadata;

	typedef struct{
		set_metadata data [NUM_OF_SETS - 1: 0];
	} metadata_memory;
	
	
endpackage