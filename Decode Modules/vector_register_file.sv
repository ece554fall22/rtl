module vector_register_file(read1, read2, write_addr, write_vector, mask, data1, data2, we, clk, rst_n);

parameter VECTOR_REG_SIZE = 32;
parameter VECTOR_REG_WIDTH = 4;

input clk, rst_n;
input [127:0] write_vector;
input[4:0] read1, read2, write_addr;
input [3:0] we;
output logic [127:0] data1, data2;

logic [32:0] reg_data1 [3:0];
logic [32:0] reg_data2 [3:0];

logic [32:0] out1 [3:0];
logic [32:0] out2 [3:0];

ram_single #(REG_SIZE = 32) r1 [3:0] (.q(write_vector), .a_in(read1), .a_out(write_addr), .d(reg_data1), .we(we), .clk(clk));
ram_single #(REG_SIZE = 32) r2 [3:0] (.q(write_vector), .a_in(read1), .a_out(write_addr), .d(reg_data2), .we(we), .clk(clk));

genvar i;
generate;
    for(i =0; i <4; i++) begin
        out1[i] = (we[i] & (read1 == write_addr)) ? write_vector[(i*VECTOR_REG_SIZE + VECTOR_REG_SIZE -1): VECTOR_REG_SIZE*i] : reg_data1[i];
        out1[2] = (we[i] & (read2 == write_addr)) ? write_vector[(i*VECTOR_REG_SIZE + VECTOR_REG_SIZE -1): VECTOR_REG_SIZE*i] : reg_data2[i];
    end
endgenerate


assign data1 = {out1[3], out1[2], out1[1], out1[0]};

assign data2 = {out2[3], out2[2], out2[1], out2[0]};

endmodule