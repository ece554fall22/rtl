/**
* Verifies the functionality of all the Instructions specified in the 
* 	ISA which is used in the project.
* 	--RedNdu
*/
`ifndef ALUOPS_FUNCTIONS_PKG
	`define ALUOPS_FUNCTIONS_PKG 1
	`include "aluOps_functions_pkg.sv"
`endif
`ifndef ALUOPS_TASKS_PKG
	`define ALUOPS_TASKS_PKG 1
	`include "aluOps_Tasks_pkg.sv"
`endif
`ifndef INCLUDES_PKG 
	`define INCLUDES_PKG 1
	`include "includes_pkg.sv"
`endif
module instructions_tb();
	/** Include all definition files through packages */
	import includes_pkg::*;
	import aluOps_Tasks_pkg::*;
	import aluOps_functions_pkg::*;
	
	logic clk, rst_n; 							// Global signals 
	
	
	scalar_reg_size in_A;						// First input: Would be a register
	scalar_reg_size in_B; 						// Second input: Can be a sign extended Immediate or a Register
	
	logic [ALU_OP_SIZE - 1: 0] op;				// ALU operation input
	logic nz, ez, lz, gz, le, ge;				// Zero comparison signals
	scalar_reg_size computed_rd;				// Computed version of the rd (from DUT)
	
	/** Passed to scalar tasks */
	scalar_reg_size expected_rd;				// Used for storing the expected value computed by internal functions
	scalar_reg_size_half Imm; 					// 18 bits used to specify load value for top/bottom half of scalar register
	scalar_reg_size prev_rd; 					// Used to determine previous value of register before top/bottom half of scalar register is loaded
	scalar_reg_size rt;							// Scalar register input
	scalar_reg_size sext_Imm;					// Scalar register input (Used in ADDI, SUBI, e.t.c)
		
	/** Passed to vector tasks */
	vector_reg_size vs [VECTOR_LANES];
	vector_reg_size vt [VECTOR_LANES];
	vector_bit_mask bitMaskImm;					// 4 bits EEEE (idx: 3210)
	vector_reg_size computed_vd [VECTOR_LANES];	
	vector_reg_size expected_vd [VECTOR_LANES];
	vector_index_size index;					// 2 bits to select 4 lanes (Used in VINDX_task)
	vector_index_size index1;					// 2 bits to select 4 lanes (Used in VSWIZZLE_task)
	vector_index_size index2;					// 2 bits to select 4 lanes (Used in VSWIZZLE_task)
	vector_index_size index3;					// 2 bits to select 4 lanes (Used in VSWIZZLE_task)
	vector_index_size index4;					// 2 bits to select 4 lanes (Used in VSWIZZLE_task)
	
	integer disable_flag;						// For checking, one test at a time

	/** Instantiate ALU block */
	alu ALU_BLK0(
				.clk(clk), 
				.rst_n(rst_n),
				.A(in_A),
				.B(in_B), 
				.op(op), 
				.out(computed_rd), 
				.nz(nz), 
				.ez(ez), 
				.lz(lz), 
				.gz(gz), 
				.le(le), 
				.ge(ge)
				);
	
	/** Initialize Operations */
	initial begin
		/** Basic ALU Operations */
		alu_oper["ADD"] = 4'b0000;
		alu_oper["SUB"] = 4'b0001;
		alu_oper["MUL"] = 4'b0010;
		alu_oper["AND"] = 4'b0011;
		alu_oper["OR"]  = 4'b0100;
		alu_oper["XOR"] = 4'b0101;
		alu_oper["SHR"] = 4'b0110;
		alu_oper["SHL"] = 4'b1000;
		
		/** Intermediate Operation */
		alu_oper["ADDI"] = 4'b0000;
		alu_oper["SUBI"] = 4'b0001;
		alu_oper["ANDI"] = 4'b0011;
		alu_oper["ORI"]  = 4'b0100;
		alu_oper["XORI"] = 4'b0101;
		alu_oper["SHRI"] = 4'b0110;
		alu_oper["SHLI"] = 4'b1000;
		
		/** Floating point Operations */
		fa_oper["FADD"]  = 2'b00;
		fa_oper["FSUB"]  = 2'b01;
		fa_oper["FMULT"] = 2'b10;
		fa_oper["FDIV"]  = 2'b11;
	end
	
	initial begin
		/** Initialize signals */
		clk = 1'b0;
		rst_n = 1'b0; 
		rand_scalar_register_gen(in_A);
		rand_scalar_register_gen(in_B);
		op = alu_oper["ADD"];
		disable_flag = 0; 	// just for testing 
		Imm = 0; 			// 18 bits
		prev_rd = 0; 		// 36 bits
		
		if(disable_flag) begin
		
			// Verify ADD Operation
			// Example 1:
			op = alu_oper["ADD"];
			ADD_task(
					.clk(clk),
					.rs(in_A), 
					.rt(in_B),
					.computed_rd(computed_rd),
					.expected_rd(expected_rd)
					);
					
			// Example 2:
			op = alu_oper["ADDI"];
			ADDI_task(
					.clk(clk),
					.rs(in_A), 
					.sext_Imm(in_B),
					.computed_rd(computed_rd),
					.expected_rd(expected_rd)
					);
					
			// Verify FADD Operation
			// Example 3:
			FADD_task(
					.clk(clk),
					.rs(in_A), 
					.rt(in_B),
					.computed_rd(computed_rd),
					.expected_rd(expected_rd)
					);
					
			// Example 4:
			Imm = 18'h3FF00; 				// 18 bits
			prev_rd = 36'h0000D5555; 		// 36 bits
			
			LIH_task(
				.clk(clk),
				.Imm(Imm),
				.prev_rd(prev_rd), 	// previous value of rd (to ensure one half is unchanged)
				.computed_rd(computed_rd),
				.expected_rd(expected_rd)
			);
			
			Imm = 18'h3FF00; 				// 18 bits
			prev_rd = 36'hD5555000; 		// 36 bits
			
			LIL_task(
				.clk(clk),
				.Imm(Imm),
				.prev_rd(prev_rd), 	// previous value of rd (to ensure one half is unchanged)
				.computed_rd(computed_rd),
				.expected_rd(expected_rd)
			);
					
		end
		else begin 
			// Check only one test 
			
			rand_vector_register_gen(vs); // generate random vs
			rand_vector_register_gen(vt); // generate random vt
			rand_scalar_register_gen(rs); // generate random rs
			rand_scalar_register_gen(rt); // generate random rt
			
			for(int i = 0; i < 2 ** VECTOR_LANES; i += 1) begin
				// Set bit mask
				bitMaskImm = vector_bit_mask'(i);
				
				// Set operation e.g op = vec_oper["VADD"];
				VADD_task(
					.clk(clk),
					.vs(vs),
					.vt(vt),
					.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
					.computed_vd(computed_vd),
					.expected_vd(expected_vd)
				);
				
				// Set operation e.g op = vec_oper["VSUB"];
				VSUB_task(
					.clk(clk),
					.vs(vs),
					.vt(vt),
					.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
					.computed_vd(computed_vd),
					.expected_vd(expected_vd)
				);
				
				// Set operation e.g op = vec_oper["VMULT"];
				VMULT_task(
					.clk(clk),
					.vs(vs),
					.vt(vt),
					.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
					.computed_vd(computed_vd),
					.expected_vd(expected_vd)
				);
				
				// Set operation e.g op = vec_oper["VDIV"];
				VDIV_task(
					.clk(clk),
					.vs(vs),
					.vt(vt),
					.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
					.computed_vd(computed_vd),
					.expected_vd(expected_vd)
				);
				
				// Set operation e.g op = vec_oper["VDOT"];
				VDOT_task(
					.clk(clk),
					.vs(vs),
					.vt(vt),
					.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
					.computed_vd(computed_vd),
					.expected_vd(expected_vd)
				);
				
				// Set operation e.g op = vec_oper["VDOTA"];
				rand_scalar_register_gen(prev_rd);  // Set previous rd value (prev_rd)
				
				VDOTA_task(
							.clk(clk),
							.vs(vs),
							.vt(vt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.prev_rd(prev_rd),				// previous value of Rd
							.computed_rd(computed_rd),
							.expected_rd(expected_rd)
				);
				
				// Set operation e.g op = vec_oper["VREDUCE"];
				VREDUCE_task(
							.clk(clk),
							.vt(vt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.computed_rd(computed_rd),
							.expected_rd(expected_rd)
				);
				
				// Set operation e.g op = vec_oper["VSPLAT"];
				VSPLAT_task(
							.clk(clk),
							.rt(rt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.computed_vd(computed_vd),
							.expected_vd(expected_vd)
				);
				
				// Set operation e.g op = vec_oper["VSADD"];
				VSADD_task(
							.clk(clk),
							.vs(vs),
							.rt(rt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.computed_vd(computed_vd),
							.expected_vd(expected_vd)
				);
				
				// Set operation e.g op = vec_oper["VSMULT"];
				VSMULT_task(
							.clk(clk),
							.vs(vs),
							.rt(rt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.computed_vd(computed_vd),
							.expected_vd(expected_vd)
				);
				
				// Set operation e.g op = vec_oper["VSSUB"];
				VSSUB_task(
							.clk(clk),
							.vs(vs),
							.rt(rt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.computed_vd(computed_vd),
							.expected_vd(expected_vd)
				);
				
				// Set operation e.g op = vec_oper["VSDIV"];
				VSDIV_task(
							.clk(clk),
							.vs(vs),
							.rt(rt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.computed_vd(computed_vd),
							.expected_vd(expected_vd)
				);
				
				// Set operation e.g op = vec_oper["VSMA"];
				VSMA_task(
							.clk(clk),
							.vs(vs),
							.vt(vt),
							.rt(rt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.computed_vd(computed_vd),
							.expected_vd(expected_vd)
				);

				
			end
			
			for(int i = 0; i < VECTOR_LANES; i += 1) begin
				// Set index e.g 00, 01, 10, 11
				index = vector_index_size'(i); 
				
				VINDX_task(
							.clk(clk),
							.vt(vt),
							.index(index),		// 2 bits to select 4 lanes
							.computed_rd(computed_rd),
							.expected_rd(expected_rd)
				);
			end

			
			for(int i = 0; i < VECTOR_LANES ** 3 ; i += 1) begin // Check random combinations of indexes (4^3 times)
				// Set index e.g 00, 01, 10, 11
				rand_index_gen(index1);
				rand_index_gen(index2);
				rand_index_gen(index3);
				rand_index_gen(index4);
				
				VSWIZZLE_task(
							.clk(clk),
							.vs(vs),
							.index1(index1),			// 2 bits to select 4 lanes
							.index2(index2),			// 2 bits to select 4 lanes
							.index3(index3),			// 2 bits to select 4 lanes
							.index4(index4),			// 2 bits to select 4 lanes	
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.computed_vd(computed_vd),
							.expected_vd(expected_vd)
				);
		end
		
				
		$stop();
	end
	
	/** Generate clock */
	always @(clk) begin
		clk <= #5 ~clk;
	end


endmodule
