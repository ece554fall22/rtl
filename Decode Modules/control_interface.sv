interface control_bus;
    logic vector_wr_en, register_wr_en;
    logic [4:0] vector_read_register1, vector_read_register2, scalar_read_register1, scalar_read_register2, write_register, vector_alu_op;
    logic [1:0] op_type, w_type, r_type, scalar_op_sel, synch_op;
    logic [3:0] branch_control, matmul_idx;
    logic [2:0] matmul_opcode;
    logic matmul_high_low, synch_req;
endinterface