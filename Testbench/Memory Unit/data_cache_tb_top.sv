/**
 * Top level testbench for the caches
 */
`ifndef READ_PROCEDURE_IF
	`define READ_PROCEDURE_IF 1
	`include "read_procedure_if.sv"
`endif
`ifndef DATA_CACHE_TB_SUB
	`define DATA_CACHE_TB_SUB 1
	`include "data_cache_tb_sub.sv"
`endif
module data_cache_tb_top();
	logic clk;
	logic rst;
	read_procedure_if inf();
	// Cache and the rest
	data_cache_memory_class d_cache;
	
	// Sub testbench for evaluating dUT
	data_cache_tb_sub TB_SUB_INST(inf, d_cache, clk, rst);

	initial begin

		d_cache = new();
		
		// Initialize signal
		inf.pre_write_procedure_done = 1'b0;
		inf.update_metadata = 1'b1;
		inf.flushtype = 2'b00; // no flushes
		inf.w_tagcheck = 1'b1; // same thing but for DUT
		inf.r_tag = 18'h0;
		inf.r_index = 8'd100;
		inf.r_line = 6'b000000; 
		inf.r = 1'b0;
		inf.w = 1'b0;
		inf.no_tagcheck_read = 1'b0;
		inf.last_write_from_mem = 1'b0;
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
		inf.metadata_block = '{default:'0};
		inf.data_block = {RAM_READ_SIZE{1'b0}};			
		inf.tag_block = {(TAG_SIZE * WAY_PER_SET){1'b0}};
		
		// Declare and Initialize 
		inf.DATA_ARRAY = '{128'hAAAA, 128'hBBBB, 128'hCCCC, 128'hDDDD};
		// Init global signals
		clk = 1'b0;
		rst = 1'b1;
	end
	
	// Generate clock
	always
		#5 clk = ~clk;


endmodule