// Created by: Leo Garcia Calderon & Mark Xia
// TODO: add other functional tests after passed the ADD function test
module tb_vector_ALU();

// Input signals
logic clk, rst_n, en;
logic [31:0] v1 [3:0];
logic [31:0] v2 [3:0];
logic [31:0] r1, r2;
logic [4:0] op;
logic [7:0] imm;

// Output signals
logic [31:0] vout [3:0];
logic [31:0] rout;
logic [31:0] correct_vout [3:0];
logic [31:0] correct_rout [3:0];
int fail_count;
logic fail;

vector_alu vec_alu1(.v1(v1), .v2(v2), .r1(r1), .r2(r2), .op(op), .imm(imm), .clk(clk), .rst_n(rst_n), .en(en), .vout(vout), .rout(rout));

// Initialize signals, reset and provide final test bench result
initial begin
    fail_count = 0;
    // Initialize clock signal
    clk = 0;
    // Initialize input values
    for (int i = 0; i < 4; i++) begin
        v1[i] = '0;
        v2[i] = '0;
    end
    r1 = '0;
    r2 = '0;
    op = '0;
    imm = '0;
    en = '1;
    // reset
    @(posedge clk);
    rst_n = 0'b0; // active low reset
    @(posedge clk);
    rst_n = 1'b1; // reset finished
    @(posedge clk);
    #20000;
    if (fail) begin
        $display("Total errors: %d", fail_count);
        $display("ARRRR! Ya code be blast!!! Aye, there might be errors, get debugging!");
        $stop();
    end
    else begin
        $display("YAHOO! TEST PASSED!");
        $stop;
    end
end

// Create clock signal
always begin
    #5 clk = ~clk;
end

// Testing based on randomized inputs
always @(posedge clk) begin
    for (int i = 0; i < 4; i++) begin
        v1[i] = $random;
        v2[i] = $random;
    end
    r1 = $random;
    r2 = $random;
    op = $random;
    imm = $random;
    case (op)
        5'h03: begin
            for(int i = 0; i < 4; i++) begin
                correct_vout[i] = v1[i] + v2[i];
                if (vout[i] !== correct_vout[i]) begin
                    fail = 1;
                    fail_count++;
                    $display("Error check: v1[%d] = %h , v2[%d] = %h, op = %d, vout[%d] = %h, Expected vout[%d]: %h",i,v1[i],i,v2[i],op,i,vout[i],i,correct_vout[i]);
                end
            end
        end
    endcase
end

endmodule