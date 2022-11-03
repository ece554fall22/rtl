/**
* Package includes all extra files used across packages 
*	--RedNdu
*/ 
package includes_pkg;
	/** Define all MACROS */
	`include "define_macros.sv"
	
	/** Used in instruction_tb */
	localparam ALU_OP_SIZE = 4; 						// Number of bits
	localparam SCALAR_REGISTER_SIZE = 36; 				// Size of scalar registers
	localparam SCALAR_REGISTER_SIZE_HALF = 18; 			// Size of half of scalar registers
	localparam FLOATING_POINT_REGISTER_SIZE = 32;		// Size of floating point registers
	localparam VECTOR_REGISTER_SIZE = 32; 				// Size of vector registers
	localparam VECTOR_LANES = 4;						// 4 lanes per vector register
	
	/** Define types */
	typedef logic [SCALAR_REGISTER_SIZE - 1: 0] scalar_reg_size;
	typedef logic [SCALAR_REGISTER_SIZE_HALF - 1: 0] scalar_reg_size_half;
	typedef logic [FLOATING_POINT_REGISTER_SIZE - 1: 0] floating_point_reg_size;
	typedef logic [VECTOR_REGISTER_SIZE - 1: 0] vector_reg_size;
	typedef logic [VECTOR_LANES - 1: 0] vector_bit_mask;
	typedef logic [$clog2(VECTOR_LANES) - 1: 0] vector_index_size;
	
	
	/** Storing basic ALU operations and Operation Name mappings */
	logic [ALU_OP_SIZE - 1: 0] alu_oper [string];
	
	/** Storing floating point ALU operations and Name mappings */
	logic [ALU_OP_SIZE - 1: 0] fa_oper [string];
	
	/** Used in Floating point arithmetic */
	localparam FP_TOLERANCE_EPS = 0.0001; 						// Maximum error of expected from real floating point
	
	
endpackage