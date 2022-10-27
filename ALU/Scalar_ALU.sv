
module alu (A, B, op, out, zf, sf, of, clk, rst_n);

input [35:0] A, B;

input [3:0] op

output logic [35:0] out;

output logic nz, ez, lz, gz, le, ge;

logic nz_next, ez_next, lz_next, gz_next, le_next, ge_next;

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

assign nz_next = out != 36'b0;

assign ez_next = ~nz_next;

assign lz_next = out[35];

assign gz_next = ~lz_next;

assign le_next = lz_next | ez_next;

assign ge_next = gz_next | ez_next;

always_ff@(posedge clk, negedge !rst_n) begin
    if(!rst_n) begin
       nz <= 0;
       ez <= 0;
       lz <= 0;
       gz <= 0;
       le <= 0;
       ge <= 0;
    end
    else if(op[3] == 1'b1) begin
        nz <= nz_next;
        ez <= ez_next;
        lz <= lz_next;
        gz <= gz_next;
        le <= le_next;
        ge <= ge_next;
    end

end


endmodule