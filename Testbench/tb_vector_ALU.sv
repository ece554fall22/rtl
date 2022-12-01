// Created by: Leo Garcia Calderon & Mark Xia
// Modified by Brian Mhatre
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
// Current cycle's correct outputs
shortreal correct_vout [3:0];
shortreal correct_rout [3:0];
int fail_count;
logic fail;
int cycle_count;

vector_alu vec_alu1(.v1(v1), .v2(v2), .r1(r1), .r2(r2), .op(op), .imm(imm), .clk(clk), .rst_n(rst_n), .en(en), .vout(vout), .rout(rout));

// Initialize signals, reset and provide final test bench result
initial begin
    cycle_count = '0;
    fail_count = 0;
    // Initialize clock signal
    clk = 0;
    rst_n = 0; 
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
    rst_n = 1; // reset finished
    @(posedge clk);
    // Repeat x clock cycles to test
    // repeat (12) @(posedge clk);
    for(int tests = 0; tests<100; tests++) begin
        cycle_count=cycle_count+9;
        r1 = $random;
        r2 = $random;
        op = 5'h03;
        // imm = 1;
        for (int i = 0; i < 4; i++) begin
            v1[i] = $random;
            v2[i] = $random;
            // if (cycle_count > 3)begin
                $display("v1[%d]: %1.100f\n",i,$bitstoshortreal(v1[i]));
                $display("v2[%d]: %1.100f\n",i,$bitstoshortreal(v2[i]));
            // end
        end

        repeat (9) @(posedge clk);
        case (op)
        5'h03: begin
            // Compute the correct output and put it in temporary location
            // shape(correct_vout) = 4*32
            for(int i = 0; i < 4; i++) begin
                correct_vout[i] = $bitstoshortreal(v1[i]) + $bitstoshortreal(v2[i]);
            end
        end
        endcase
        if (vout === correct_vout) begin
            $display("yes! a hit! at cycle%d",cycle_count);
        end
        else begin
            for(int g = 0; g < 4; g++)begin
                $display("op = %d, vout[%d] = %1.100f, Expected vout[%d]: %1.100f",op,g,vout[g],g,correct_vout[g]);
            end
            fail = 1;
            fail_count++;
        end

        
        @(posedge clk);
        if (fail) begin
            $display("Total errors: %d", fail_count);
            $display("ARRRR! Ya code be blast!!! Aye, there might be errors, get debugging!");
            $stop;
        end
        else begin
            $display("YAHOO! TEST PASSED!");
            $stop;
        end
    end
end

// Create clock signal
always begin
    #5 clk = ~clk;
end

endmodule