module fe_de
(
input logic clk, rst, stall,
input logic [31:0] inst,
output logic [31:0] inst_reg,
input logic [4:0] vread1, vread2,
output logic [4:0] vread1_reg, vread2_reg,
input logic [35:0] pc_plus_4, pc,
output logic [35:0] pc_plus_4_reg, pc_reg
);

// it's a pipeline register
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    inst_reg <= 0;
    vread1_reg <= 0;
    vread2_reg <= 0;
    pc_plus_4_reg <= 0;
    pc_reg <= 0;
  end else if (~stall) begin
    inst_reg <= inst;
    vread1_reg <= vread1;
    vread2_reg <= vread2;
    pc_plus_4_reg <= pc_plus_4;
    pc_reg <= pc;
  end
end

endmodule

