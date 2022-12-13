module control_pipeline(input clk, rst_n, stall, control_bus control_q, control_bus control_d);
    always_ff @ (posedge clk, negedge rst_n) begin
        if(!rst_n) begin
        control_q.halt  <= '0;
        control_q.flushicache <= '0;
        control_q.data_cache_flush <= '0;
        control_q.dirty <= '0;
        control_q.clean <= '0;
        control_q.matrix_mutplier_en <= '0;
        control_q.vector_wr_en <= '0;
        control_q.register_wr_en <= '0;
        control_q.mem_read <='0;
        control_q.mem_write <= '0;
        control_q.vector_read_register1 <= '0;
        control_q.vector_read_register2 <= '0;
        control_q.scalar_read_register1 <= '0;
        control_q.scalar_read_register2 <= '0;
        control_q.vector_write_register  <= '0;
        control_q.scalar_write_register <= '0; 
        control_q.vector_alu_op  <= '0;
        control_q.op_type <= '0;
        control_q.w_type <= '0; 
        control_q.r_type <= '0;
        control_q.scalar_op_sel <= '0;
        control_q.synch_op <= '0;
        control_q.matmul_idx <= '0;
        control_q.matmul_opcode <= '0;
        control_q.matmul_high_low <= '0; 
        control_q.synch_req <= '0;
        control_q.branch_jump <= '0; 
        control_q.branch_register <= '0; 
        control_q.store_pc <= '0;
        control_q.alu_operands <= '0;
        control_q.imm_type <= '0; 
        control_q.r_read1  <= '0;
        control_q.r_read2 <= '0;
        control_q.v_read1 <= '0;
        control_q.v_read2 <= '0;
        control_q.pc_select <= '0;
        control_q.store_immediate <= '0;
        control_q.mask <= '0;
        control_q.scalar_alu_op <= '0;
        control_q.imm_hl <= '0;
        control_q.invert <= '0;
        control_q.scalar_vector_wb <= '0;
        control_q.vector_scalar_wb <= '0;
        control_q.vecc_op <= '0;
        end 
        else if(!stall) begin
        control_q.halt  <= control_d.halt;
        control_q.flushicache <= control_d.flushicache;
        control_q.data_cache_flush <= control_d.data_cache_flush;
        control_q.dirty <= control_d.dirty;
        control_q.clean <= control_d.clean;
        control_q.matrix_mutplier_en <= control_d.matrix_mutplier_en;
        control_q.vector_wr_en <= control_d.vector_wr_en;
        control_q.register_wr_en <= control_d.register_wr_en;
        control_q.mem_read <= control_d.mem_read;
        control_q.mem_write <= control_d.mem_write;
        control_q.vector_read_register1 <= control_d.vector_read_register1;
        control_q.vector_read_register2 <= control_d.vector_read_register2;
        control_q.scalar_read_register1 <= control_d.scalar_read_register1;
        control_q.scalar_read_register2 <= control_d.scalar_read_register2 ;
        control_q.vector_write_register  <= control_d.vector_write_register;
        control_q.scalar_write_register <= control_d.scalar_write_register;
        control_q.vector_alu_op  <= control_d.vector_alu_op;
        control_q.op_type <= control_d.op_type;
        control_q.w_type <= control_d.w_type; 
        control_q.r_type <= control_d.r_type;
        control_q.scalar_op_sel <= control_d.scalar_op_sel;
        control_q.synch_op <= control_d.synch_op;
        control_q.matmul_idx <= control_d.matmul_idx;
        control_q.matmul_opcode <= control_d.matmul_opcode;
        control_q.matmul_high_low <= control_d.matmul_high_low; 
        control_q.synch_req <= control_d.synch_req ;
        control_q.branch_jump <= control_d.branch_jump; 
        control_q.branch_register <= control_d.branch_register; 
        control_q.store_pc <= control_d.store_pc;
        control_q.alu_operands <= control_d.alu_operands;
        control_q.imm_type <= control_d.imm_type; 
        control_q.r_read1  <= control_d.r_read1;
        control_q.r_read2 <= control_d.r_read2;
        control_q.v_read1 <= control_d.v_read1;
        control_q.v_read2 <= control_d.v_read2;
        control_q.pc_select <= control_d.pc_select;
        control_q.store_immediate <= control_d.store_immediate;
        control_q.mask <= control_d.mask;
        control_q.scalar_alu_op <= control_d.scalar_alu_op;
        control_q.imm_hl <= control_d.imm_hl;
        control_q.invert <= control_d.invert;
        control_q.scalar_vector_wb <= control_d.scalar_vector_wb;
        control_q.vector_scalar_wb <= control_d.vector_scalar_wb;
        control_q.vecc_op <= control_d.vecc_op;
        end
        else begin
        control_q.halt  <= '0;
        control_q.flushicache <= '0;
        control_q.data_cache_flush <= '0;
        control_q.dirty <= '0;
        control_q.clean <= '0;
        control_q.matrix_mutplier_en <= '0;
        control_q.vector_wr_en <= '0;
        control_q.register_wr_en <= '0;
        control_q.mem_read <='0;
        control_q.mem_write <= '0;
        control_q.vector_read_register1 <= '0;
        control_q.vector_read_register2 <= '0;
        control_q.scalar_read_register1 <= '0;
        control_q.scalar_read_register2 <= '0;
        control_q.vector_write_register  <= '0;
        control_q.scalar_write_register <= '0; 
        control_q.vector_alu_op  <= '0;
        control_q.op_type <= '0;
        control_q.w_type <= '0; 
        control_q.r_type <= '0;
        control_q.scalar_op_sel <= '0;
        control_q.synch_op <= '0;
        control_q.matmul_idx <= '0;
        control_q.matmul_opcode <= '0;
        control_q.matmul_high_low <= '0; 
        control_q.synch_req <= '0;
        control_q.branch_jump <= '0; 
        control_q.branch_register <= '0; 
        control_q.store_pc <= '0;
        control_q.alu_operands <= '0;
        control_q.imm_type <= '0; 
        control_q.r_read1  <= '0;
        control_q.r_read2 <= '0;
        control_q.v_read1 <= '0;
        control_q.v_read2 <= '0;
        control_q.pc_select <= '0;
        control_q.store_immediate <= '0;
        control_q.mask <= '0;
        control_q.scalar_alu_op <= '0;
        control_q.imm_hl <= '0;
        control_q.invert <= '0;
        control_q.scalar_vector_wb <= '0;
        control_q.vector_scalar_wb <= '0;
        control_q.vecc_op <= '0;
        end
    end
endmodule