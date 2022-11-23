module de_ex
(
input logic clk, rst, stall,
input logic [35:0] pc,
output logic [35:0] pc_reg,
input logic [3:0] mask,
output logic [3:0] mask_reg,
input logic we, r, w,
output logic we_reg, r_reg, w_reg,
input logic vector_wr_en, register_wr_en, matmul_high_low, synch_req, branch_register,
output logic vector_wr_en_reg, register_wr_en_reg, matmul_high_low_reg, synch_req_reg, branch_register_reg,
input logic mem_read, mem_write, matrix_multiplier_en, flushicache, store_pc, alu_operands,
output logic mem_read_reg, mem_write_reg, matrix_multiplier_en_reg, flushicache_reg, store_pc_reg, alu_operands_reg,
input logic [4:0] vector_read_register1, vector_read_register2, scalar_read_register1,
output logic [4:0] vector_read_register1_reg, vector_read_register2_reg, scalar_read_register1_reg,
input logic [4:0] scalar_read_register2, scalar_write_register, vector_write_register, vector_alu_op,
output logic [4:0] scalar_read_register2_reg, scalar_write_register_reg, vector_write_register_reg, vector_alu_op_reg,
input logic [1:0] op_type, w_type, r_type, scalar_op_sel, synch_op, data_cache_flush, branch_jump,
output logic [1:0] op_type_reg, w_type_reg, r_type_reg, scalar_op_sel_reg, synch_op_reg, data_cache_flush_reg, branch_jump_reg,
input logic [3:0] scalar_alu_op, imm_type,
output logic [3:0] scalar_alu_op_reg, imm_type_reg,
input logic [2:0] matmul_opcode, branch_control, matmul_idx,
output logic [2:0] matmul_opcode_reg, branch_control_reg, matmul_idx_reg
);

// it's a pipeline register
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    pc_reg <= 0;
    mask_reg <= 0;
    we_reg <= 0;
    r_reg <= 0;
    w_reg <= 0;
    vector_wr_en_reg <= 0;
    register_wr_en_reg <= 0;
    matmul_high_low_reg <= 0;
    synch_req_reg <= 0;
    branch_register_reg <= 0;
    mem_read_reg <= 0;
    mem_write_reg <= 0;
    matrix_multiplier_en_reg <= 0;
    flushicache_reg <= 0;
    store_pc_reg <= 0;
    alu_operands_reg <= 0;
    vector_read_register1_reg <= 0;
    vector_read_register2_reg <= 0;
    scalar_read_register1_reg <= 0;
    scalar_read_register2_reg <= 0;
    scalar_write_register_reg <= 0;
    vector_write_register_reg <= 0;
    vector_alu_op_reg <= 0;
    op_type_reg <= 0;
    w_type_reg <= 0;
    r_type_reg <= 0;
    scalar_op_sel_reg <= 0;
    synch_op_reg <= 0;
    data_cache_flush_reg <= 0;
    branch_jump_reg <= 0;
    scalar_alu_op_reg <= 0;
    imm_type_reg <= 0;
    matmul_opcode_reg <= 0;
    branch_control_reg <= 0;
    matmul_idx_reg <= 0;
  end else if (~stall) begin
    pc_reg <= pc;
    mask_reg <= mask;
    we_reg <= we;
    r_reg <= r;
    w_reg <= w;
    vector_wr_en_reg <= vector_wr_en;
    register_wr_en_reg <= register_wr_en;
    matmul_high_low_reg <= matmul_high_low;
    synch_req_reg <= synch_req;
    branch_register_reg <= branch_register;
    mem_read_reg <= mem_read;
    mem_write_reg <= mem_write;
    matrix_multiplier_en_reg <= matrix_multiplier_en;
    flushicache_reg <= flushicache;
    store_pc_reg <= store_pc;
    alu_operands_reg <= alu_operands;
    vector_read_register1_reg <= vector_read_register1;
    vector_read_register2_reg <= vector_read_register2;
    scalar_read_register1_reg <= scalar_read_register1;
    scalar_read_register2_reg <= scalar_read_register2;
    scalar_write_register_reg <= scalar_write_register;
    vector_write_register_reg <= vector_write_register;
    vector_alu_op_reg <= vector_alu_op;
    op_type_reg <= op_type;
    w_type_reg <= w_type;
    r_type_reg <= r_type;
    scalar_op_sel_reg <= scalar_op_sel;
    synch_op_reg <= synch_op;
    data_cache_flush_reg <= data_cache_flush;
    branch_jump_reg <= branch_jump;
    scalar_alu_op_reg <= scalar_alu_op;
    imm_type_reg <= imm_type;
    matmul_opcode_reg <= matmul_opcode;
    branch_control_reg <= branch_control;
    matmul_idx_reg <= matmul_idx;
  end
end

endmodule
