/**
* Package which holds all the functions used for the Instructions
* 	--RedNdu
*/
`ifndef INCLUDES_PKG 
	`define INCLUDES_PKG 1
	`include "includes_pkg.sv"
`endif
package aluOps_functions_pkg;
	/** Include all definition files through packages */
	import includes_pkg::*;
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 										VERIFICATION					 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* Verification of a scalar computation that writes to register Rd
	*/
	function automatic void verify_scalar_rd(
		const ref scalar_reg_size computed_rd, 
		const ref scalar_reg_size expected_rd 
	);
		// Computation
		if(computed_rd !== expected_rd) begin
			$display("Error: The computed value: %X is not equal to the expected: %X", computed_rd, expected_rd);
		end
		else begin
			$display("Passed: Test Passed!");
		end
	
	endfunction: verify_scalar_rd
	
	/**
	* Verification of a floating point computation that writes to register Rd
	* 
	* Floating point computation might vary, hence there is a tolerance to the
	*	expected value
	*/
	function automatic void verify_floating_point_rd(
		const ref scalar_reg_size computed_rd, 
		const ref scalar_reg_size expected_rd 
	);
		// Two useful inbuilt funtions: $shortrealtobits and $bitstoshortreal
		
		floating_point_reg_size computed_32b, expected_32b;
		shortreal computed_real, expected_real;
		
		// convert to 32 bits
		computed_32b = floating_point_reg_size'(computed_rd); 
		expected_32b = floating_point_reg_size'(expected_rd);
		
		// convert to real
		computed_real = shortreal'(computed_32b);
		expected_real = shortreal'(expected_32b);
		
		// Computation
		if($abs(computed_real - expected_real) > shortreal'(FP_TOLERANCE_EPS)) begin
			$display("Error: The computed value: %X is not equal to the expected: %X", computed_rd, expected_rd);
		end
		else begin
			$display("Passed: Test Passed!");
		end

	endfunction: verify_floating_point_rd
	
	/**
	* Verification of a vector computation that writes to lanes in vector register Vd
	* 
	* Floating point computation might vary, hence there is a tolerance to the
	*	expected value
	*/
	function automatic void verify_vector_vd_float(
		const ref vector_reg_size computed_vd [VECTOR_LANES], 
		const ref vector_reg_size expected_vd [VECTOR_LANES]  
	);
		shortreal computed_real, expected_real;
		bit failed;
		failed = 0; // Not failed yet
		
		// Computation
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			// convert to real
			computed_real = shortreal'(computed_vd[i]);
			expected_real = shortreal'(expected_vd[i]);
			
			// Computation
			if($abs(computed_real - expected_real) > shortreal'(FP_TOLERANCE_EPS)) begin
				failed = 1;
				break;
			end
		end
		
		// Print Computed and Expected values on failure
		if(failed) begin
			$display("Error encountered in one or more vector register lanes");
			
			for(int i = 0; i < VECTOR_LANES; i += 1) begin
				$display("Error in lane %d: The computed value: %X is not equal to the expected: %X", i, computed_vd[i], expected_vd[i]);
			end
		end
		else begin
			$display("Passed: Test Passed!");
		end
	
	endfunction: verify_vector_vd_float
	
	/**
	* Verification of a vector computation that writes to lanes in vector register Vd
	* 
	* Since the operations that use it are assigning values directly from a register, this
	*	result should be exact.
	*/
	function automatic void verify_vector_vd_exact(
		const ref vector_reg_size computed_vd [VECTOR_LANES], 
		const ref vector_reg_size expected_vd [VECTOR_LANES]  
	);
		bit failed;
		failed = 0; // Not failed yet
		
		// Computation
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			// Computation
			if(computed_vd[i] !== expected_vd[i]) begin // Exact
				failed = 1;
				break;
			end
		end
		
		// Print Computed and Expected values on failure
		if(failed) begin
			$display("Error encountered in one or more vector register lanes");
			
			for(int i = 0; i < VECTOR_LANES; i += 1) begin
				$display("Error in lane %d: The computed value: %X is not equal to the expected: %X", i, computed_vd[i], expected_vd[i]);
			end
		end
		else begin
			$display("Passed: Test Passed!");
		end
	
	endfunction: verify_vector_vd_exact
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 									INPUT GENERATION					 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* Generate random values for each lane of a vector register and store in provided vector
	*	register.
	* 
	*/
	function automatic void rand_vector_register_gen(
		ref vector_reg_size vx [VECTOR_LANES]
	);
		// Gen random values
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			vx[i] = $random;
		end
		
	endfunction: rand_vector_register_gen
	
	/**
	* Generate random values and store in provided scalar register.
	* 
	*/
	function automatic void rand_scalar_register_gen(
		ref scalar_reg_size rx
	);
		// Gen random values
		rx = $random;
		
	endfunction: rand_scalar_register_gen
	
	
	/**
	* Generate random values for index 2 bits
	* 
	*/
	function automatic void rand_index_gen(
		ref vector_index_size index
	);
		// Gen random values
		index = $random;
		
	endfunction: rand_index_gen
	
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 										SCALAR ALU OPS					 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* High level computation of the ADD ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_ADD(
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt, 
		ref scalar_reg_size rd
	);
		// Computation
		rd = rs + rt;
	
	endfunction: compute_ADD
	
	/**
	* High level computation of the SUB ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_SUB(
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt, 
		ref scalar_reg_size rd
	);
		// Computation
		rd = rs - rt;
	
	endfunction: compute_SUB
	
	/**
	* High level computation of the MULT ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_MULT(
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt, 
		ref scalar_reg_size rd
	);
		// Computation
		rd = rs * rt;
	
	endfunction: compute_MULT
	
	/**
	* High level computation of the AND ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_AND(
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt, 
		ref scalar_reg_size rd
	);
		// Computation
		rd = rs & rt;
	
	endfunction: compute_AND

	
	/**
	* High level computation of the OR ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_OR(
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt, 
		ref scalar_reg_size rd
	);
		// Computation
		rd = rs | rt;
	
	endfunction: compute_OR
	
	/**
	* High level computation of the XOR ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_XOR(
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt, 
		ref scalar_reg_size rd
	);
		// Computation
		rd = rs ^ rt;
	
	endfunction: compute_XOR
	
	/**
	* High level computation of the SHR ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_SHR(
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt, 
		ref scalar_reg_size rd
	);
		// Computation
		rd = rs >> rt;
	
	endfunction: compute_SHR
	
	/**
	* High level computation of the SHL ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_SHL(
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt, 
		ref scalar_reg_size rd
	);
		// Computation
		rd = rs << rt;
	
	endfunction: compute_SHL


	/********************************************************************************************/
	/********************************************************************************************/
	/** 								FLOATING POINT ALU OPS					 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* High level computation of the FADD ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_FADD(
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt, 
		ref scalar_reg_size rd
	);
		floating_point_reg_size rs_32b, rt_32b;
		rs_32b = floating_point_reg_size'(rs);
		rt_32b = floating_point_reg_size'(rt);
		
		// Two useful inbuilt funtions: $shortrealtobits and $bitstoshortreal 
		
		// Computation
		rd = scalar_reg_size'( $shortrealtobits( shortreal'(rs_32b) + shortreal'(rt_32b) ) ); // unsigned sign extension
	
	endfunction: compute_FADD
	
	/**
	* High level computation of the FSUB ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_FSUB(
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt, 
		ref scalar_reg_size rd
	);
		floating_point_reg_size rs_32b, rt_32b;
		rs_32b = floating_point_reg_size'(rs);
		rt_32b = floating_point_reg_size'(rt);
		
		// Two useful inbuilt funtions: $shortrealtobits and $bitstoshortreal 
		// Computation
		rd = scalar_reg_size'( $shortrealtobits( shortreal'(rs_32b) - shortreal'(rt_32b) ) ); // unsigned sign extension
	
	endfunction: compute_FSUB
	
	/**
	* High level computation of the FMULT ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_FMULT(
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt, 
		ref scalar_reg_size rd
	);
		floating_point_reg_size rs_32b, rt_32b;
		rs_32b = floating_point_reg_size'(rs);
		rt_32b = floating_point_reg_size'(rt);
		
		// Two useful inbuilt funtions: $shortrealtobits and $bitstoshortreal 
		
		// Computation
		rd = scalar_reg_size'( $shortrealtobits( shortreal'(rs_32b) * shortreal'(rt_32b) ) ); // unsigned sign extension
	
	endfunction: compute_FMULT
	
	/**
	* High level computation of the FDIV ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_FDIV(
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt, 
		ref scalar_reg_size rd
	);
		floating_point_reg_size rs_32b, rt_32b;
		rs_32b = floating_point_reg_size'(rs);
		rt_32b = floating_point_reg_size'(rt);
		
		// Two useful inbuilt funtions: $shortrealtobits and $bitstoshortreal 
		
		// Computation
		rd = scalar_reg_size'( $shortrealtobits( shortreal'(rs_32b) / shortreal'(rt_32b) ) ); // unsigned sign extension
	
	endfunction: compute_FDIV
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 									REGISTER LOAD OPS					 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* High level computation of the LIH ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_LIH(
		const ref scalar_reg_size_half Imm,
		const ref scalar_reg_size prev_rd, 	// previous value of rd (to ensure one half is unchanged)
		ref scalar_reg_size rd
	);
		scalar_reg_size sext_Imm, lower_half;
		
		sext_Imm = scalar_reg_size'(Imm) << SCALAR_REGISTER_SIZE_HALF; // shift left by 18
		lower_half = prev_rd & scalar_reg_size'({SCALAR_REGISTER_SIZE_HALF{1'b1}});
		$display("lower half: %X", lower_half);
		$display("SEXT IMM: %X", sext_Imm);
		
		// Computation
		rd = sext_Imm | lower_half;
		$display("rd: %X", rd);
		
	endfunction: compute_LIH
	
	/**
	* High level computation of the LIL ALU operation
	* 
	* Reassigns register Rd a new value 
	*/
	function automatic void compute_LIL(
		const ref scalar_reg_size_half Imm,
		const ref scalar_reg_size prev_rd, 	// previous value of rd (to ensure one half is unchanged)
		ref scalar_reg_size rd
	);
		scalar_reg_size sext_Imm, higher_half;
		
		sext_Imm = scalar_reg_size'(Imm);
		higher_half = prev_rd & (scalar_reg_size'({SCALAR_REGISTER_SIZE_HALF{1'b1}}) << SCALAR_REGISTER_SIZE_HALF); // shift to top half
		
		// Computation
		rd = sext_Imm | higher_half;
	
	endfunction: compute_LIL
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 										VECTOR ALU OPS 1				 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* High level computation of the VADD ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VADD(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]
	);
		vector_reg_size inter_res; // intermediate result
		
		// Mask lane entries and add
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			inter_res = $shortrealtobits( shortreal'(vs[i]) + shortreal'(vt[i]) ); // 32 bits
			vd[i] = inter_res & {VECTOR_REGISTER_SIZE{bitMaskImm[i]}}; 
		end
		
	
	endfunction: compute_VADD
	
	/**
	* High level computation of the VSUB ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VSUB(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]
	);
		vector_reg_size inter_res; // intermediate result
		
		// Mask lane entries and subtract
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			inter_res = $shortrealtobits( shortreal'(vs[i]) - shortreal'(vt[i]) ); // 32 bits
			vd[i] = inter_res & {VECTOR_REGISTER_SIZE{bitMaskImm[i]}}; 		
		end
		
	
	endfunction: compute_VSUB
	
	/**
	* High level computation of the VMULT ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VMULT(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]
	);
		vector_reg_size inter_res; // intermediate result
		
		// Mask lane entries and multiply
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			inter_res = $shortrealtobits( shortreal'(vs[i]) * shortreal'(vt[i]) ); // 32 bits
			vd[i] = inter_res & {VECTOR_REGISTER_SIZE{bitMaskImm[i]}}; 	
		end
		
	
	endfunction: compute_VMULT
	
	/**
	* High level computation of the VDIV ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VDIV(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]
	);
		vector_reg_size inter_res; // intermediate result
		
		// Mask lane entries and divide
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			inter_res = $shortrealtobits( shortreal'(vs[i]) / shortreal'(vt[i]) ); // 32 bits
			vd[i] = inter_res & {VECTOR_REGISTER_SIZE{bitMaskImm[i]}};
		end
		
	
	endfunction: compute_VDIV
	
	/**
	* High level computation of the VDOT ALU operation
	* 
	* Reassigns register rd a new value based on mask
	*/
	function automatic void compute_VDOT(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		ref scalar_reg_size rd
	);
		vector_reg_size oper_res; // operation result (dot)
		vector_reg_size accum; 					// accumulation
		vector_reg_size masked_intermediate;   // holds masking result
		
		accum = 0;
		// Mask lane entries and DOT
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			oper_res = $shortrealtobits( shortreal'(vs[i]) * shortreal'(vt[i]) ); // 32 bits
			masked_intermediate = (oper_res & {VECTOR_REGISTER_SIZE{bitMaskImm[i]}}); 
			accum = $shortrealtobits( shortreal'(accum) + shortreal'(masked_intermediate) ); // 32 bits
		end
		
		// Assign sum to rd
		rd = scalar_reg_size'(accum);
	
	endfunction: compute_VDOT
	
	/**
	* High level computation of the VDOTA ALU operation
	* 
	* Reassigns register rd a new value based on mask
	*/
	function automatic void compute_VDOTA(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,			// 4 bits EEEE (idx: 3210)
		const ref scalar_reg_size prev_rd,				// previous value of Rd
		ref scalar_reg_size rd
	);
		// Compute VDOT
		compute_VDOT(
					.vs(vs),
					.vt(vt),
					.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
					.rd(rd)						// rd is updated with computed value
		);
	
		// Assign sum to rd
		compute_FADD(
					.rs(prev_rd), 
					.rt(rd), 					// Already holds VDOT result
					.rd(rd)
		);
	
	endfunction: compute_VDOTA
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 									VECTOR ALU OPS 2					 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* High level computation of the VINDX ALU operation
	* 
	* Reassigns register rd a new value
	*/
	function automatic void compute_VINDX(
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_index_size index,				// 2 bits to select 4 lanes
		ref scalar_reg_size rd
	);
	
		// Assign rd with value from vector lane
		rd = scalar_reg_size'(vt[index]);
	
	endfunction: compute_VINDX
	
	/**
	* High level computation of the VREDUCE ALU operation
	* 
	* Reassigns register rd a new value based on mask
	*/
	function automatic void compute_VREDUCE(
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		ref scalar_reg_size rd
	);
		vector_reg_size accum; 					// accumulation
		vector_reg_size masked_intermediate;   // holds masking result
		
		accum = 0;
		// Mask lane entries and ADD
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			masked_intermediate = vt[i] & {VECTOR_REGISTER_SIZE{bitMaskImm[i]}}; 
			accum = $shortrealtobits( shortreal'(accum) + shortreal'(masked_intermediate) ); // 32 bits
		end
		
		// Assign rd with value from vector lane
		rd = scalar_reg_size'(accum);
	
	endfunction: compute_VREDUCE
	
	/**
	* High level computation of the VSPLAT ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VSPLAT(
		const ref scalar_reg_size rt,
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]
	);
		
		// Assign only to masked lanes
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			if(bitMaskImm[i]) begin
				vd[i] = vector_reg_size'(rt);
			end
		end
	
	endfunction: compute_VSPLAT
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 									VECTOR ALU OPS 3					 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* High level computation of the VSWIZZLE ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VSWIZZLE(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_index_size index1,				// 2 bits to select 4 lanes
		const ref vector_index_size index2,		
		const ref vector_index_size index3,		
		const ref vector_index_size index4,		
		const ref vector_bit_mask bitMaskImm,			// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]
	);
		// Declare
		vector_index_size idx_arr [VECTOR_LANES - 1: 0];
		
		// Assign index to array for ease
		idx_arr[0] = index1;
		idx_arr[1] = index2;
		idx_arr[2] = index3;
		idx_arr[3] = index4;
		
		// Assign only to masked lanes
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			if(bitMaskImm[i]) begin
				vd[i] = vs[idx_arr[i]];
			end
		end
	
	endfunction: compute_VSWIZZLE

	/********************************************************************************************/
	/********************************************************************************************/
	/** 									VECTOR ALU OPS 4					 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* High level computation of the VSADD ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VSADD(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref scalar_reg_size rt,
		const ref vector_bit_mask bitMaskImm,					// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]	
	);
		vector_reg_size oper_res; // operation result (dot)
		vector_reg_size rt_32b;
		vector_index_size index1, index2, index3, index4;		// 2 bits to select 4 lanes
		
		// Assign index for Vswizzle computation
		index1 = 2'b00; 
		index2 = 2'b01;
		index3 = 2'b10;
		index4 = 2'b11;
		
		// Compute Vswizzle to load vd with "vt" 
		compute_VSWIZZLE(
					.vs(vs),
					.index1(index1),
					.index2(index2),
					.index3(index3),
					.index4(index4),
					.bitMaskImm(bitMaskImm),
					.vd(vd)
		);
		
		// Convert from 36 bits to 32 bits 
		rt_32b = vector_reg_size'(rt);
		
		// Mask lane entries and compute the addition of vd[lane] - rt
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			oper_res = $shortrealtobits( shortreal'(vd[i]) + shortreal'(rt_32b) ); // 32 bits
			if(bitMaskImm[i]) begin
				vd[i] = oper_res; 
			end
			
		end
	
	endfunction: compute_VSADD
	
	/**
	* High level computation of the VSMULT ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VSMULT(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref scalar_reg_size rt,
		const ref vector_bit_mask bitMaskImm,					// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]	
	);
		vector_reg_size oper_res; // operation result (dot)
		vector_reg_size rt_32b;
		vector_index_size index1, index2, index3, index4;		// 2 bits to select 4 lanes
		
		// Assign index for Vswizzle computation
		index1 = 2'b00; 
		index2 = 2'b01;
		index3 = 2'b10;
		index4 = 2'b11;
		
		// Compute Vswizzle to load vd with "vt" 
		compute_VSWIZZLE(
					.vs(vs),
					.index1(index1),
					.index2(index2),
					.index3(index3),
					.index4(index4),
					.bitMaskImm(bitMaskImm),
					.vd(vd)
		);
		
		// Convert from 36 bits to 32 bits 
		rt_32b = vector_reg_size'(rt);
		
		// Mask lane entries and compute the multiplicaition of vd[lane] - rt
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			oper_res = $shortrealtobits( shortreal'(vd[i]) * shortreal'(rt_32b) ); // 32 bits
			if(bitMaskImm[i]) begin
				vd[i] = oper_res; 
			end
			
		end
	
	endfunction: compute_VSMULT
	
	/**
	* High level computation of the VSSUB ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VSSUB(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref scalar_reg_size rt,
		const ref vector_bit_mask bitMaskImm,					// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]	
	);
		vector_reg_size oper_res; // operation result (dot)
		vector_reg_size rt_32b;
		vector_index_size index1, index2, index3, index4;		// 2 bits to select 4 lanes
		
		// Assign index for Vswizzle computation
		index1 = 2'b00; 
		index2 = 2'b01;
		index3 = 2'b10;
		index4 = 2'b11;
		
		// Compute Vswizzle to load vd with "vt" 
		compute_VSWIZZLE(
					.vs(vs),
					.index1(index1),
					.index2(index2),
					.index3(index3),
					.index4(index4),
					.bitMaskImm(bitMaskImm),
					.vd(vd)
		);
		
		// Convert from 36 bits to 32 bits 
		rt_32b = vector_reg_size'(rt);
		
		// Mask lane entries and compute the subtraction of vd[lane] - rt
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			oper_res = $shortrealtobits( shortreal'(vd[i]) - shortreal'(rt_32b) ); // 32 bits
			if(bitMaskImm[i]) begin
				vd[i] = oper_res; 
			end
			
		end
	
	endfunction: compute_VSSUB
	
	/**
	* High level computation of the VSDIV ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VSDIV(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref scalar_reg_size rt,
		const ref vector_bit_mask bitMaskImm,					// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]	
	);
		vector_reg_size oper_res; // operation result (dot)
		vector_reg_size rt_32b;
		vector_index_size index1, index2, index3, index4;		// 2 bits to select 4 lanes
		
		// Assign index for Vswizzle computation
		index1 = 2'b00; 
		index2 = 2'b01;
		index3 = 2'b10;
		index4 = 2'b11;
		
		// Compute Vswizzle to load vd with "vt" 
		compute_VSWIZZLE(
					.vs(vs),
					.index1(index1),
					.index2(index2),
					.index3(index3),
					.index4(index4),
					.bitMaskImm(bitMaskImm),
					.vd(vd)
		);
		
		// Convert from 36 bits to 32 bits 
		rt_32b = vector_reg_size'(rt);
		
		// Mask lane entries and compute the division of vd[lane] - rt
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			oper_res = $shortrealtobits( shortreal'(vd[i]) / shortreal'(rt_32b) ); // 32 bits
			if(bitMaskImm[i]) begin
				vd[i] = oper_res; 
			end
		end
	
	endfunction: compute_VSDIV
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 									VECTOR ALU OPS 5					 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* High level computation of the VSMA ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VSMA(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref scalar_reg_size rt,
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]	
	);
	
		/** Compute VSMULT operation of vt *rt */
		compute_VSMULT(
					.vs(vt),
					.rt(rt),
					.bitMaskImm(bitMaskImm),
					.vd(vd)						// (vt * rt)
		);
		
		/** Compute VADD operation */
		compute_VADD(
					.vs(vs),
					.vt(vd),
					.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
					.vd(vd) 					// vs + (vt * rt)
		);
		
	endfunction: compute_VSMA
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 									VECTOR ALU OPS 6					 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* High level computation of the VMAX ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VMAX(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,					// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]	
	);
		shortreal vs_real, vt_real;

		// Assign to only masked vector lanes
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			if(bitMaskImm[i]) begin
				// Convert to real
				vs_real = shortreal'(vs);
				vt_real = shortreal'(vt);
				
				// Assign Maximum
				vd[i] = (vt_real > vs_real) ? $shortrealtobits(vt_real) : $shortrealtobits(vs_real); 
			end
			
		end
		
	endfunction: compute_VMAX
	
	/**
	* High level computation of the VMIN ALU operation
	* 
	* Reassigns register Vd a new value per lane based on mask
	*/
	function automatic void compute_VMIN(
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,					// 4 bits EEEE (idx: 3210)
		ref vector_reg_size vd [VECTOR_LANES]	
	);
		shortreal vs_real, vt_real;

		// Assign to only masked vector lanes
		for(int i = 0; i < VECTOR_LANES; i += 1) begin
			if(bitMaskImm[i]) begin
				// Convert to real
				vs_real = shortreal'(vs);
				vt_real = shortreal'(vt);
				
				// Assign Minimum
				vd[i] = (vt_real < vs_real) ? $shortrealtobits(vt_real) : $shortrealtobits(vs_real); 
			end
		end
		
	endfunction: compute_VMIN
	
endpackage

