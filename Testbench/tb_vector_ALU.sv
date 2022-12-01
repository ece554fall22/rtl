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
    repeat (12) @(posedge clk);
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

// Create clock signal
always begin
    #5 clk = ~clk;
end

// Correct computed values
logic [31:0] out1 [3:0];
logic [31:0] out2 [3:0];
logic [31:0] out3 [3:0];
logic [31:0] out4 [3:0];
logic [31:0] out5 [3:0];
logic [31:0] out6 [3:0];
logic [31:0] out7 [3:0];
logic [31:0] out8 [3:0];
logic [31:0] in [3:0];
logic [31:0] zero [3:0];
assign zero = {32'h0000,32'h0000,32'h0000,32'h0000};
// Generate a 4 * 4 entries' shortreal pipeline that stores computed correct values
genvar i;
generate;
    for(i = 0; i < 4; i++) begin
        always_ff@(posedge clk) begin
            if (!rst_n) begin
                for(int k = 0; k < 4; k++) begin
                    in[k] <= '0;
                    out1[k] <= '0;
                    out2[k] <= '0;
                    out3[k] <= '0;
                    out4[k] <= '0;
                    out5[k] <= '0;
                    out6[k] <= '0;
                    out7[k] <= '0;
                    out8[k] <= '0;
                end
            end
            else begin
                out1 <= in;
                out2 <= out1;
                out3 <= out2;
                out4 <= out3;
                out5 <= out4;
                out6 <= out5;
                out7 <= out6;
                out8 <= out7;
            end
        end
    end
endgenerate

// 2 entries each 32 bit; inst_out[5] = instruction; inst_out[4:1] = Vout[3:0]; inst_out[0] = rout;
// HW computed values
// ins_out
logic [31:0] inso1 [5:0];
logic [31:0] inso2 [5:0];
logic [31:0] inso3 [5:0];
logic [31:0] inso4 [5:0];
logic [31:0] inso5 [5:0];
logic [31:0] inso6 [5:0];
logic [31:0] inso7 [5:0];
logic [31:0] inso8 [5:0];
logic [31:0] in2 [5:0];
genvar j;
generate;
    for(j = 0; j < 3; j++) begin
        always_ff@(posedge clk) begin
            if (!rst_n) begin
                for(int k = 0; k < 6; k++) begin
                    inso1[k] <= '0;
                    inso2[k] <= '0;
                    inso3[k] <= '0;
                    inso4[k] <= '0;
                    inso5[k] <= '0;
                    inso6[k] <= '0;
                    inso7[k] <= '0;
                    inso8[k] <= '0;
                end
            end
            else begin
                inso1 <= in2;
                inso2 <= inso1;
                inso3 <= inso2;
                inso4 <= inso3;
                inso5 <= inso4;
                inso6 <= inso5;
                inso7 <= inso6;
                inso8 <= inso7;
            end
        end
    end
endgenerate

assign in2[5] = ~rst_n ? '0 : op;
assign in2[4:1] = ~rst_n ? {32'h0000,32'h0000,32'h0000,32'h0000} : vout[3:0];
assign in2[0] = ~rst_n ? '0 : rout;

// Testing based on randomized inputs
always @(posedge clk) begin
    for (int i = 0; i < 4; i++) begin
        v1[i] = $random;
        v2[i] = $random;
        // if (cycle_count > 3)begin
            $display("v1[%d]: %1.100f\n",i,$bitstoshortreal(v1[i]));
            $display("v2[%d]: %1.100f\n",i,$bitstoshortreal(v2[i]));
        // end
    end
    r1 = $random;
    r2 = $random;
    op = 5'h03;
    //imm = 1;

    case (op)
        5'h03: begin
            // Compute the correct output and put it in temporary location
            // shape(correct_vout) = 4*32
            for(int i = 0; i < 4; i++) begin
                // correct_vout[i] = ($bitstoshortreal(v1[i]) + $bitstoshortreal(v2[i]));
                correct_vout[i] = $bitstoshortreal(v1[i]) + $bitstoshortreal(v2[i]);
                // pipeline the output
                in[i] = $shortrealtobits(correct_vout[i]);
            end
            
            // if (vout[i] != correct_vout[i]) begin
            //     fail = 1;
            //     fail_count++;
            //     $display("Error check: v1[%d] = %h , v2[%d] = %h, op = %d, vout[%d] = %h, Expected vout[%d]: %h",i,v1[i],i,v2[i],op,i,vout[i],i,correct_vout[i]);
            // end
        end
    endcase
end

always @(posedge clk) begin
    if (cycle_count >= 8) begin
        case (inso7[5])
            5'h0003: begin
                if (inso7[4:1] == out7[3:0]) begin
                    $display("yes! a hit! at cycle%d",cycle_count);
                end
                else begin
                    for(int g = 0; g < 4; g++)begin
                        $display("op = %d, vout[%d] = %1.100f, Expected vout[%d]: %1.100f",op,g,$bitstoshortreal(inso2[g]),g,$bitstoshortreal(out2[g]));
                    end
                end
            end
            default:$display("shit, ran into default!");
        endcase
    end
    cycle_count++;
end


endmodule