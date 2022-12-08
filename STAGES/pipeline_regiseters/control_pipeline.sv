module control_q_pipeline(input clk, rst_n, control_bus control_q, control_bus control_d);
    always_ff @ (posedge clk, negedge rst_n) begin
        if(!rst_n) begin
        control_q.halt  <= '0;
        control_q.flushicache <= '0;
        control_q.data_cache_flush <= '0';
        control_q.dirty <= '0;
        control_q.clean <= '0';
        control_q.matrix_mutplier_en <= '0';
        control_q.vector_wr_en <= '0';
        control_q.register_wr_en <= '0;
        control_q.mem_read <='0;
        control_q.mem_write <= '0;
        control_q.vector_read_register1 <= '0;
        control_q.vector_read_register2 <= '0;
        control_q.scalar_read_register1 <= '0;
        control_q.scalar_read_register2 <= '0;
        control_q.vector_write_register  <= '0;
        control_q.scalar_write_register <= '0' 
        control_q.vector_alu_op  <= '0;
        control_q.op_type <= '0;
        control_q.w_type <= '0; 
        control_q.r_type <= '0;
        control_q.scalar_op_sel <= '0;
        control_q.synch_op <= '0;
        control_q.branch_control_q <= '0;
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
        end 
        else begin
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
        control_q.synch_op <= control_d.synch_op ;
        control_q.branch_control_q <= control_d.branch_control_q;
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
        end
    end
endmodule