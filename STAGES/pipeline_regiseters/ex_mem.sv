module ex_mem
(
input logic clk, rst, stall,
input logic [35:0] alu_out, pc,
output logic [35:0] alu_out_reg, pc_reg,
input logic [3:0] mask,
output logic [3:0] mask_reg,
input logic pc_sel, we, r, w,
output logic pc_sel_reg, we_reg, r_reg, w_reg
);

// it's a pipeline register
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    alu_out_reg <= 0;
    pc_reg <= 0;
    mask_reg <= 0;
    pc_sel_reg <= 0;
    we_reg <= 0;
    r_reg <= 0;
    w_reg <= 0;
  end else if (~stall) begin
    alu_out_reg <= alu_out;
    pc_reg <= pc;
    mask_reg <= mask;
    pc_sel_reg <= pc_sel;
    we_reg <= we;
    r_reg <= r;
    w_reg <= w;
  end
end

endmodule
