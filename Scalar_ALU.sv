
module alu (A, B, op, out, zf, sf, of);

input [35:0] A, B;

input [3:0] op

output [35:0] out;

output zf, sf, of;


always@(op) begin
    case(op) begin
        4'b0000: out = A + B;
        4'b0001: out = A - B;
        4'b0010: out = A * B;
        4'b0011: out = A & B;
        4'b0100: out = A | B;
        4'b0101: out = A ^ B:
        4'b0110: out = A << B;
        4'b0111: out = A >> B;
        default: out = 32'b0;
    end
end




endmodule