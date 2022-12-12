/**
 * Abstarcts the interface for connecting the DUT to the 
 * 	testbench through the signals below
 */
 `ifndef CACHE_TYPES_PKG
	`define CACHE_TYPES_PKG 1
	`include "cache_types_pkg.sv"
`endif
interface read_procedure_if();
	// Import necessary packages
	import cache_types_pkg::*; // for functions
	// Inputs 
	logic [$clog2(NUM_OF_SETS) - 1: 0] r_index;
	logic [$clog2(NUM_OF_FLUSH_TYPES) - 1: 0] flushtype;
	logic [TAG_SIZE - 1: 0] r_tag;
	bit update_metadata;										
	logic w_tagcheck;	
	// DUT outputs
	logic [TAG_SIZE - 1: 0] dut_tag_out;
	logic [WORD_SIZE - 1: 0] dut_data_out;
	logic [1:0] dut_way;
	logic dut_hit;
	logic dut_dirty;
	logic [WAY_PER_SET - 1 : 0] dut_dirty_array;
	logic [WAY_PER_SET - 1 : 0] dut_valid_array;
	logic [$clog2(WAY_PER_SET) : 0] dut_plru;
	// Inputs and Outputs
	logic [5:0] r_line;
	logic [RAM_READ_SIZE - 1: 0] data_block;				
	logic [(TAG_SIZE * WAY_PER_SET) - 1: 0] tag_block;	
	logic [$clog2(WAY_PER_SET) - 1: 0] perf_way;				
	set_metadata metadata_block;
	// Output
	logic no_tagcheck_read;
	logic perf_hit;
	logic perf_dirty;
	logic [WORD_SIZE - 1: 0] perf_data_out;
	logic [TAG_SIZE - 1: 0] perf_tag_out;
	logic r;
	logic w;
	logic [$clog2(NUM_OF_SETS) - 1: 0] w_index;	
	logic [5:0] w_line;						
	logic [$clog2(WAY_PER_SET) - 1:0] w_way;	
	logic [WORD_SIZE - 1:0] w_data;	
	logic [TAG_SIZE - 1:0] w_tag;
	logic [$clog2(WAY_PER_SET) - 1:0] no_tagcheck_way;	
	logic access_type; // 1 on a write, 0 on a read
	
	// Data bank
	logic [WORD_SIZE - 1:0] DATA_ARRAY [4];					// Hold data used in testing
	logic [TAG_SIZE -1 : 0] TAG_ARRAY [5];					// tags across same index
endinterface