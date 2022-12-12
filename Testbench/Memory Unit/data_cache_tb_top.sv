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
		// Init global signals
		
		clk = 1'b0;
		rst = 1'b1;
	end
	
	// Generate clock
	always
		#5 clk = ~clk;


endmodule