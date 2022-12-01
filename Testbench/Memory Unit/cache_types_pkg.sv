/**
* This holds the types used in the caches
*/
package cache_types_pkg;
	// Important constants
	localparam DATA_CACHE_MEM_SIZE = 4096;		// 4096 bits
	localparam DATA_CACHE_TAG_MEM_SIZE = 2048;	// 2048 bits
	localparam WORD_SIZE = 128;					// 128 bits
	localparam TAG_SIZE = 18; 					// 18 bits
	
	typedef logic [WORD_SIZE - 1:0] data_memory_type [DATA_CACHE_MEM_SIZE - 1:0];		// Data array
	typedef logic [TAG_SIZE - 1:0] tag_memory_type [DATA_CACHE_TAG_MEM_SIZE - 1:0]; 	// Tag array
	
	
	
endpackage