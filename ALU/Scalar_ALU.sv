
module alu (A, B, op, out, nz, ez, lz, gz, le, ge, clk, rst_n);
input clk, rst_n;
input [35:0] A, B;

input [3:0] op;  // TODO: Micro Doc says [2:0]?

output logic [35:0] out;

output logic nz, ez, lz, gz, le, ge;  // TODO: ALU Flags?

logic nz_next, ez_next, lz_next, gz_next, le_next, ge_next;

always@(op) begin //TODO: if two instructions that are the same come back to back, the output wont't change
    case(op) 
        4'b0000: out = A + B;
        4'b0001: out = A - B;
        4'b0010: out = A * B;
        4'b0011: out = A & B;
        4'b0100: out = A | B;
        4'b0101: out = A ^ B;
        4'b0110: out = A << B[3:0];
        4'b0111: out = A >> B[3:0];
        4'b1000: out = A - B;  // TODO: What is this?
        default: out = 32'b0;
    endcase
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