/**
 * 
 */
interface read_procedure_if();
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

endinterface