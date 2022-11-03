/**
* Package which holds all the tasks used for the Instructions
* 	--RedNdu
*/
`ifndef ALUOPS_FUNCTIONS_PKG
	`define ALUOPS_FUNCTIONS_PKG 1
	`include "aluOps_functions_pkg.sv"
`endif
`ifndef INCLUDES_PKG 
	`define INCLUDES_PKG 1
	`include "includes_pkg.sv"
`endif
package aluOps_Tasks_pkg;
	/** Include all definition files through packages */
	import includes_pkg::*;
	import aluOps_functions_pkg::*; // for functions
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 					BIT ENCODING: 0011 011D DDDD SSSS STTT TTZZ ZZZZ ZXXX 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* Computes the solution for the ADD instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic ADD_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event ADD_done;
		
		fork 
			begin
				/** Compute ADD operation */
				compute_ADD(
							.rs(rs), 
							.rt(rt), 
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(ADD_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_ADD) @(posedge clk);
				
				// Trigger event
				->ADD_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying ADD instruction functionality", $time);
			verify_scalar_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:ADD_task
	
	/**
	* Computes the solution for the SUB instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic SUB_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event SUB_done;
		
		fork 
			begin
				/** Compute SUB operation */
				compute_SUB(
							.rs(rs), 
							.rt(rt), 
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(SUB_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_SUB) @(posedge clk);
				
				// Trigger event
				->SUB_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying SUB instruction functionality", $time);
			verify_scalar_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:SUB_task
	
	/**
	* Computes the solution for the MULT instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic MULT_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event MULT_done;
		
		fork 
			begin
				/** Compute MULT operation */
				compute_MULT(
							.rs(rs), 
							.rt(rt), 
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(MULT_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_MULT) @(posedge clk);
				
				// Trigger event
				->MULT_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying MULT instruction functionality", $time);
			verify_scalar_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:MULT_task
	
	/**
	* Computes the solution for the AND instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic AND_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event AND_done;
		
		fork 
			begin
				/** Compute AND operation */
				compute_AND(
							.rs(rs), 
							.rt(rt), 
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(AND_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_AND) @(posedge clk);
				
				// Trigger event
				->AND_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying AND instruction functionality", $time);
			verify_scalar_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:AND_task
	
	/**
	* Computes the solution for the OR instruction OR waits for 
	* the value to be ready before checking
	*/
	task automatic OR_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event OR_done;
		
		fork 
			begin
				/** Compute OR operation */
				compute_OR(
							.rs(rs), 
							.rt(rt), 
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(OR_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_OR) @(posedge clk);
				
				// Trigger event
				->OR_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying OR instruction functionality", $time);
			verify_scalar_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:OR_task
	
	/**
	* Computes the solution for the XOR instruction XOR waits for 
	* the value to be ready before checking
	*/
	task automatic XOR_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event XOR_done;
		
		fork 
			begin
				/** Compute XOR operation */
				compute_XOR(
							.rs(rs), 
							.rt(rt), 
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(XOR_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_XOR) @(posedge clk);
				
				// Trigger event
				->XOR_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying XOR instruction functionality", $time);
			verify_scalar_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:XOR_task
	
	/**
	* Computes the solution for the SHR instruction SHR waits for 
	* the value to be ready before checking
	*/
	task automatic SHR_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event SHR_done;
		
		fork 
			begin
				/** Compute SHR operation */
				compute_SHR(
							.rs(rs), 
							.rt(rt), 
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(SHR_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_SHR) @(posedge clk);
				
				// Trigger event
				->SHR_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying SHR instruction functionality", $time);
			verify_scalar_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:SHR_task
	
	/**
	* Computes the solution for the SHL instruction SHL waits for 
	* the value to be ready before checking
	*/
	task automatic SHL_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event SHL_done;
		
		fork 
			begin
				/** Compute SHL operation */
				compute_SHL(
							.rs(rs), 
							.rt(rt), 
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(SHL_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_SHL) @(posedge clk);
				
				// Trigger event
				->SHL_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying SHL instruction functionality", $time);
			verify_scalar_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:SHL_task
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 					BIT ENCODING: 001X XXXD DDDD SSSS Siii iiii iiii iiii 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* Computes the solution for the ADDI instruction ADD waits for 
	* the value to be ready before checking
	*/
	task automatic ADDI_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size sext_Imm,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		// ADD operation 
		ADD_task(
				.clk(clk),
				.rs(rs), 
				.rt(sext_Imm),
				.computed_rd(computed_rd),
				.expected_rd(expected_rd)
				);
	
	
	endtask:ADDI_task
	
	/**
	* Computes the solution for the SUBI instruction SUB waits for 
	* the value to be ready before checking
	*/
	task automatic SUBI_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size sext_Imm,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		// ADD operation 
		SUB_task(
				.clk(clk),
				.rs(rs), 
				.rt(sext_Imm),
				.computed_rd(computed_rd),
				.expected_rd(expected_rd)
				);
	
	
	endtask:SUBI_task
	
	/**
	* Computes the solution for the ANDI instruction AND waits for 
	* the value to be ready before checking
	*/
	task automatic ANDI_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size sext_Imm,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		// ADD operation 
		AND_task(
				.clk(clk),
				.rs(rs), 
				.rt(sext_Imm),
				.computed_rd(computed_rd),
				.expected_rd(expected_rd)
				);
	
	
	endtask:ANDI_task
	
	/**
	* Computes the solution for the ORI instruction OR waits for 
	* the value to be ready before checking
	*/
	task automatic ORI_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size sext_Imm,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		// ADD operation 
		OR_task(
				.clk(clk),
				.rs(rs), 
				.rt(sext_Imm),
				.computed_rd(computed_rd),
				.expected_rd(expected_rd)
				);
	
	
	endtask:ORI_task
	
	/**
	* Computes the solution for the XORI instruction XOR waits for 
	* the value to be ready before checking
	*/
	task automatic XORI_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size sext_Imm,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		// ADD operation 
		XOR_task(
				.clk(clk),
				.rs(rs), 
				.rt(sext_Imm),
				.computed_rd(computed_rd),
				.expected_rd(expected_rd)
				);
	
	
	endtask:XORI_task
	
	/**
	* Computes the solution for the SHRI instruction SHR waits for 
	* the value to be ready before checking
	*/
	task automatic SHRI_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size sext_Imm,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		// ADD operation 
		SHR_task(
				.clk(clk),
				.rs(rs), 
				.rt(sext_Imm),
				.computed_rd(computed_rd),
				.expected_rd(expected_rd)
				);
	
	
	endtask:SHRI_task
	
	/**
	* Computes the solution for the SHLI instruction SHL waits for 
	* the value to be ready before checking
	*/
	task automatic SHLI_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size sext_Imm,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		// ADD operation 
		SHL_task(
				.clk(clk),
				.rs(rs), 
				.rt(sext_Imm),
				.computed_rd(computed_rd),
				.expected_rd(expected_rd)
				);
	
	
	endtask:SHLI_task
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 					BIT ENCODING: 001X XXXD DDDD SSSS Siii iiii iiii iiii 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* Computes the solution for the FADD instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic FADD_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event ADD_done;
		
		fork 
			begin
				/** Compute ADD operation */
				compute_FADD(
							.rs(rs), 
							.rt(rt), 
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(ADD_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_FADD) @(posedge clk);
				
				// Trigger event
				->ADD_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying ADD instruction functionality", $time);
			verify_floating_point_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:FADD_task
	
	/**
	* Computes the solution for the FSUB instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic FSUB_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event SUB_done;
		
		fork 
			begin
				/** Compute SUB operation */
				compute_FSUB(
							.rs(rs), 
							.rt(rt), 
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(SUB_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_FSUB) @(posedge clk);
				
				// Trigger event
				->SUB_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying SUB instruction functionality", $time);
			verify_floating_point_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:FSUB_task
	
	/**
	* Computes the solution for the FMULT instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic FMULT_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event MULT_done;
		
		fork 
			begin
				/** Compute MULT operation */
				compute_FMULT(
							.rs(rs), 
							.rt(rt), 
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(MULT_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_FMULT) @(posedge clk);
				
				// Trigger event
				->MULT_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying MULT instruction functionality", $time);
			verify_floating_point_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:FMULT_task
	
	/**
	* Computes the solution for the FDIV instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic FDIV_task(
		const ref logic clk,
		const ref scalar_reg_size rs, 
		const ref scalar_reg_size rt,
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event DIV_done;
		
		fork 
			begin
				/** Compute DIV operation */
				compute_FDIV(
							.rs(rs), 
							.rt(rt), 
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(DIV_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_FDIV) @(posedge clk);
				
				// Trigger event
				->DIV_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying DIV instruction functionality", $time);
			verify_floating_point_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:FDIV_task
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 					BIT ENCODING: 0001 00XD DDDD ZZii iiii iiii iiii iiii 				*/
	/********************************************************************************************/
	/********************************************************************************************/

	/**
	* Computes the solution for the LIH instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic LIH_task(
		const ref logic clk,
		const ref scalar_reg_size_half Imm,
		const ref scalar_reg_size prev_rd, 	// previous value of rd (to ensure bottom half is unchanged)
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event LIH_done;
		
		fork 
			begin
				/** Compute LIH operation */
				compute_LIH(
							.Imm(Imm),
							.prev_rd(prev_rd),
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(LIH_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_LIH) @(posedge clk);
				
				// Trigger event
				->LIH_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying LIH instruction functionality", $time);
			verify_scalar_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:LIH_task

	/**
	* Computes the solution for the LIL instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic LIL_task(
		const ref logic clk,
		const ref scalar_reg_size_half Imm,
		const ref scalar_reg_size prev_rd, 	// previous value of rd (to ensure top half is unchanged)
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event LIL_done;
		
		fork 
			begin
				/** Compute LIL operation */
				compute_LIL(
							.Imm(Imm),
							.prev_rd(prev_rd),
							.rd(expected_rd)
							);
							
				// Wait until operation done
				wait(LIL_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_LIL) @(posedge clk);
				
				// Trigger event
				->LIL_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying LIL instruction functionality", $time);
			verify_scalar_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:LIL_task
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 					BIT ENCODING: 0XXX XXXD DDDD SSSS STTT TTZZ ZZZZ EEEE 				*/
	/********************************************************************************************/
	/********************************************************************************************/

	/**
	* Computes the solution for the VADD instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VADD_task(
		const ref logic clk,
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		const ref vector_reg_size computed_vd [VECTOR_LANES],
		ref vector_reg_size expected_vd [VECTOR_LANES]
	);
		/** Define variables */
		event VADD_done;
		
		fork 
			begin
				/** Compute VADD operation */
				compute_VADD(
							.vs(vs),
							.vt(vt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.vd(expected_vd)
				);
							
				// Wait until operation done
				wait(VADD_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VADD) @(posedge clk);
				
				// Trigger event
				->VADD_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VADD instruction functionality", $time);
			verify_vector_vd_float(.computed_vd(computed_vd), .expected_vd(expected_vd));
		end
	endtask:VADD_task
	
	/**
	* Computes the solution for the VSUB instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VSUB_task(
		const ref logic clk,
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		const ref vector_reg_size computed_vd [VECTOR_LANES],
		ref vector_reg_size expected_vd [VECTOR_LANES]
	);
		/** Define variables */
		event VSUB_done;
		
		fork 
			begin
				/** Compute VSUB operation */
				compute_VSUB(
							.vs(vs),
							.vt(vt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.vd(expected_vd)
				);
							
				// Wait until operation done
				wait(VSUB_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VSUB) @(posedge clk);
				
				// Trigger event
				->VSUB_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VSUB instruction functionality", $time);
			verify_vector_vd_float(.computed_vd(computed_vd), .expected_vd(expected_vd));
		end
	endtask:VSUB_task
	
	/**
	* Computes the solution for the VMULT instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VMULT_task(
		const ref logic clk,
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		const ref vector_reg_size computed_vd [VECTOR_LANES],
		ref vector_reg_size expected_vd [VECTOR_LANES]
	);
		/** Define variables */
		event VMULT_done;
		
		fork 
			begin
				/** Compute VMULT operation */
				compute_VMULT(
							.vs(vs),
							.vt(vt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.vd(expected_vd)
				);
							
				// Wait until operation done
				wait(VMULT_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VMULT) @(posedge clk);
				
				// Trigger event
				->VMULT_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VMULT instruction functionality", $time);
			verify_vector_vd_float(.computed_vd(computed_vd), .expected_vd(expected_vd));
		end
	endtask:VMULT_task
	
	/**
	* Computes the solution for the VDIV instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VDIV_task(
		const ref logic clk,
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		const ref vector_reg_size computed_vd [VECTOR_LANES],
		ref vector_reg_size expected_vd [VECTOR_LANES]
	);
		/** Define variables */
		event VDIV_done;
		
		fork 
			begin
				/** Compute VDIV operation */
				compute_VDIV(
							.vs(vs),
							.vt(vt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.vd(expected_vd)
				);
							
				// Wait until operation done
				wait(VDIV_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VDIV) @(posedge clk);
				
				// Trigger event
				->VDIV_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VDIV instruction functionality", $time);
			verify_vector_vd_float(.computed_vd(computed_vd), .expected_vd(expected_vd));
		end
	endtask:VDIV_task
	
	/**
	* Computes the solution for the VDOT instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VDOT_task(
		const ref logic clk,
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,	// 4 bits EEEE (idx: 3210)
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event VDOT_done;
		
		fork 
			begin
				/** Compute VDOT operation */
				compute_VDOT(
							.vs(vs),
							.vt(vt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.rd(expected_rd)
				);
							
				// Wait until operation done
				wait(VDOT_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VDOT) @(posedge clk);
				
				// Trigger event
				->VDOT_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VDOT instruction functionality", $time);
			verify_floating_point_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:VDOT_task
	
	/**
	* Computes the solution for the VDOTA instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VDOTA_task(
		const ref logic clk,
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,			// 4 bits EEEE (idx: 3210)
		const ref scalar_reg_size prev_rd,				// previous value of Rd
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event VDOTA_done;
		
		fork 
			begin
				/** Compute VDOTA operation */
				compute_VDOTA(
							.vs(vs),
							.vt(vt),
							.bitMaskImm(bitMaskImm),	// 4 bits EEEE (idx: 3210)
							.prev_rd(prev_rd),
							.rd(expected_rd)
				);
							
				// Wait until operation done
				wait(VDOTA_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VDOTA) @(posedge clk);
				
				// Trigger event
				->VDOTA_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VDOTA instruction functionality", $time);
			verify_floating_point_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:VDOTA_task
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 					BIT ENCODING: 0100 101D DDDD TTTT TZZZ ZZZi iZZZ ZZZZ 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* Computes the solution for the VINDX instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VINDX_task(
		const ref logic clk,
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_index_size index,		// 2 bits to select 4 lanes
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event VINDX_done;
		
		fork 
			begin
				/** Compute VINDX operation */
				compute_VINDX(
							.vt(vt),
							.index(index),	// 2 bits to select 4 lanes
							.rd(expected_rd)
				);
							
				// Wait until operation done
				wait(VINDX_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VINDX) @(posedge clk);
				
				// Trigger event
				->VINDX_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VINDX instruction functionality", $time);
			verify_scalar_rd(.computed_rd(computed_rd), .expected_rd(expected_rd)); // func used since operation is simply copy
		end
	endtask:VINDX_task
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 					BIT ENCODING: 0100 11XD DDDD TTTT TZZZ ZZZZ ZZZZ EEEE 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* Computes the solution for the VREDUCE instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VREDUCE_task(
		const ref logic clk,
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref vector_bit_mask bitMaskImm,			// 4 bits EEEE (idx: 3210)
		const ref scalar_reg_size computed_rd,
		ref scalar_reg_size expected_rd
	);
		/** Define variables */
		event VREDUCE_done;
		
		fork 
			begin
				/** Compute VREDUCE operation */
				compute_VREDUCE(
							.vt(vt),
							.bitMaskImm(bitMaskImm),
							.rd(expected_rd)
				);
							
				// Wait until operation done
				wait(VREDUCE_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VREDUCE) @(posedge clk);
				
				// Trigger event
				->VREDUCE_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VREDUCE instruction functionality", $time);
			verify_floating_point_rd(.computed_rd(computed_rd), .expected_rd(expected_rd));
		end
	endtask:VREDUCE_task
	
	/**
	* Computes the solution for the VSPLAT instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VSPLAT_task(
		const ref logic clk,
		const ref scalar_reg_size rt,
		const ref vector_bit_mask bitMaskImm,			// 4 bits EEEE (idx: 3210)
		const ref vector_reg_size computed_vd [VECTOR_LANES],
		ref vector_reg_size expected_vd [VECTOR_LANES]
	);
		/** Define variables */
		event VSPLAT_done;
		
		fork 
			begin
				/** Compute VSPLAT operation */
				compute_VSPLAT(
							.rt(rt),
							.bitMaskImm(bitMaskImm),
							.vd(expected_vd)
				);
							
				// Wait until operation done
				wait(VSPLAT_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VSPLAT) @(posedge clk);
				
				// Trigger event
				->VSPLAT_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VSPLAT instruction functionality", $time);
			verify_vector_vd_exact(.computed_vd(computed_vd), .expected_vd(expected_vd));
		end
	endtask:VSPLAT_task
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 					BIT ENCODING: 0101 000D DDDD SSSS S112 2334 4ZZZ EEEE 				*/
	/********************************************************************************************/
	/********************************************************************************************/

	/**
	* Computes the solution for the VSWIZZLE instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VSWIZZLE_task(
		const ref logic clk,
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_index_size index1,				// 2 bits to select 4 lanes
		const ref vector_index_size index2,		
		const ref vector_index_size index3,		
		const ref vector_index_size index4,		
		const ref vector_bit_mask bitMaskImm,			// 4 bits EEEE (idx: 3210)
		const ref vector_reg_size computed_vd [VECTOR_LANES],
		ref vector_reg_size expected_vd [VECTOR_LANES]
	);
		/** Define variables */
		event VSWIZZLE_done;
		
		fork 
			begin
				/** Compute VSWIZZLE operation */
				compute_VSWIZZLE(
							.vs(vs),
							.index1(index1),
							.index2(index2),
							.index3(index3),
							.index4(index4),
							.bitMaskImm(bitMaskImm),
							.vd(expected_vd)
				);
							
				// Wait until operation done
				wait(VSWIZZLE_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VSWIZZLE) @(posedge clk);
				
				// Trigger event
				->VSWIZZLE_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VSWIZZLE instruction functionality", $time);
			verify_vector_vd_exact(.computed_vd(computed_vd), .expected_vd(expected_vd));
		end
	endtask:VSWIZZLE_task
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 					BIT ENCODING: 0101 XXXD DDDD SSSS STTT TTZZ ZZZZ EEEE 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* Computes the solution for the VSADD instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VSADD_task(
		const ref logic clk,
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref scalar_reg_size rt,
		const ref vector_bit_mask bitMaskImm,					// 4 bits EEEE (idx: 3210)	
		const ref vector_reg_size computed_vd [VECTOR_LANES],
		ref vector_reg_size expected_vd [VECTOR_LANES]
	);
		/** Define variables */
		event VSADD_done;
		
		fork 
			begin
				/** Compute VSADD operation */
				compute_VSADD(
							.vs(vs),
							.rt(rt),
							.bitMaskImm(bitMaskImm),
							.vd(expected_vd)
				);
							
				// Wait until operation done
				wait(VSADD_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VSADD) @(posedge clk);
				
				// Trigger event
				->VSADD_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VSADD instruction functionality", $time);
			verify_vector_vd_float(.computed_vd(computed_vd), .expected_vd(expected_vd));
		end
	endtask:VSADD_task
	
	/**
	* Computes the solution for the VSMULT instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VSMULT_task(
		const ref logic clk,
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref scalar_reg_size rt,
		const ref vector_bit_mask bitMaskImm,					// 4 bits EEEE (idx: 3210)	
		const ref vector_reg_size computed_vd [VECTOR_LANES],
		ref vector_reg_size expected_vd [VECTOR_LANES]
	);
		/** Define variables */
		event VSMULT_done;
		
		fork 
			begin
				/** Compute VSMULT operation */
				compute_VSMULT(
							.vs(vs),
							.rt(rt),
							.bitMaskImm(bitMaskImm),
							.vd(expected_vd)
				);
							
				// Wait until operation done
				wait(VSMULT_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VSMULT) @(posedge clk);
				
				// Trigger event
				->VSMULT_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VSMULT instruction functionality", $time);
			verify_vector_vd_float(.computed_vd(computed_vd), .expected_vd(expected_vd));
		end
	endtask:VSMULT_task
	
	/**
	* Computes the solution for the VSSUB instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VSSUB_task(
		const ref logic clk,
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref scalar_reg_size rt,
		const ref vector_bit_mask bitMaskImm,					// 4 bits EEEE (idx: 3210)	
		const ref vector_reg_size computed_vd [VECTOR_LANES],
		ref vector_reg_size expected_vd [VECTOR_LANES]
	);
		/** Define variables */
		event VSSUB_done;
		
		fork 
			begin
				/** Compute VSSUB operation */
				compute_VSSUB(
							.vs(vs),
							.rt(rt),
							.bitMaskImm(bitMaskImm),
							.vd(expected_vd)
				);
							
				// Wait until operation done
				wait(VSSUB_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VSSUB) @(posedge clk);
				
				// Trigger event
				->VSSUB_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VSSUB instruction functionality", $time);
			verify_vector_vd_float(.computed_vd(computed_vd), .expected_vd(expected_vd));
		end
	endtask:VSSUB_task
	
	/**
	* Computes the solution for the VSDIV instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VSDIV_task(
		const ref logic clk,
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref scalar_reg_size rt,
		const ref vector_bit_mask bitMaskImm,					// 4 bits EEEE (idx: 3210)	
		const ref vector_reg_size computed_vd [VECTOR_LANES],
		ref vector_reg_size expected_vd [VECTOR_LANES]
	);
		/** Define variables */
		event VSDIV_done;
		
		fork 
			begin
				/** Compute VSDIV operation */
				compute_VSDIV(
							.vs(vs),
							.rt(rt),
							.bitMaskImm(bitMaskImm),
							.vd(expected_vd)
				);
							
				// Wait until operation done
				wait(VSDIV_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VSDIV) @(posedge clk);
				
				// Trigger event
				->VSDIV_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VSDIV instruction functionality", $time);
			verify_vector_vd_float(.computed_vd(computed_vd), .expected_vd(expected_vd));
		end
	endtask:VSDIV_task
	
	/********************************************************************************************/
	/********************************************************************************************/
	/** 					BIT ENCODING: 0101 101D DDDD SSSS STTT TTCC CCCZ EEEE 				*/
	/********************************************************************************************/
	/********************************************************************************************/
	
	/**
	* Computes the solution for the VSMA instruction and waits for 
	* the value to be ready before checking
	*/
	task automatic VSMA_task(
		const ref logic clk,
		const ref vector_reg_size vs [VECTOR_LANES],
		const ref vector_reg_size vt [VECTOR_LANES],
		const ref scalar_reg_size rt,
		const ref vector_bit_mask bitMaskImm,					// 4 bits EEEE (idx: 3210)	
		const ref vector_reg_size computed_vd [VECTOR_LANES],
		ref vector_reg_size expected_vd [VECTOR_LANES]
	);
		/** Define variables */
		event VSMA_done;
		
		fork 
			begin
				/** Compute VSMA operation */
				compute_VSMA(
							.vs(vs),
							.vt(vt),
							.rt(rt),
							.bitMaskImm(bitMaskImm),
							.vd(expected_vd)
				);
							
				// Wait until operation done
				wait(VSMA_done.triggered);
			end
			
			begin
				// Wait cerain number of cycles
				repeat(`CYCLES_VSMA) @(posedge clk);
				
				// Trigger event
				->VSMA_done;
			end
		join
		
		// Verify module functionality  
		@(negedge clk) begin
			$display("Verification @ %t: Verifying VSMA instruction functionality", $time);
			verify_vector_vd_float(.computed_vd(computed_vd), .expected_vd(expected_vd));
		end
	endtask:VSMA_task
	
endpackage