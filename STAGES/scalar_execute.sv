module scalar_execute(
    input clk, rst_n,
    input [35:0] data1, data2,
    control_bus control,
    input [24:0] immediate,
    output logic nz, ez, lz, gz, le, ge,
    output logic [35:0] data_out
);

logic [35:0] operand2;

assign operand2 = (control.alu_operands) ? {{11{immediate[24]}}, immediate}, data2;

alu (.A(data1), .B(operand2), .op(control.scalar_alu_op), .out(data_out), .nz(nz), .ez(ez), .lz(lz), .gz(gz), .le(le), .ge(ge), .clk(clk), .rst_n(rst_n));

