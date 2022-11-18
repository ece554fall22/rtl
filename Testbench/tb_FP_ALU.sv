// Created by: Leo Garcia Calderon & Mark Xia
module tb_FP_ALU();

logic [31:0] A, B;
logic [1:0] op;
logic [31:0] out, correct_out;
logic clk, gt, correct_gt;
logic error, fail;
shortreal operand1, operand2, flout_out;

fp_alu f1(// inputs
          .A(A), .B(B), .op(op),
          // outputs 
          .out(out), .gt(gt));

initial begin
    clk = 0;
    A = '0;
    B = '0;
    fail = 0;
    #20000;
    if (fail) begin
        $display("ARRRR! YA CODE BE BLAST!!! Aye, there might be errors, get debugging!");
        $stop;
    end
    else begin
        $display("YAHOO! TEST PASSED!");
        $stop;
    end
end

always begin
    #5 clk = ~clk;
end

always @(posedge clk) begin
    A = $random;
    B = $random;
    op = $random;
    operand1 = $bitstoshortreal(A);
    operand2 = $bitstoshortreal(B);
end

always @(negedge clk) begin
    error = 1'b0;
    correct_gt = '0;

    case(op)
        2'b00 : begin
            flout_out = operand1 + operand2;
            correct_out = flout_out;
            if (correct_out !== out)
                error = 1'b1;
        end
        2'b01 : begin
            flout_out = operand1 - operand2;
            correct_out = flout_out;
            if (correct_out !== out)
                error = 1'b1;
        end
        2'b10 : begin
            flout_out = operand1 * operand2;
            correct_out = flout_out;
            if (correct_out !== out)
                error = 1'b1;
        end
        2'b11 : begin
            correct_out = operand2;
            correct_gt = operand1 > operand2;
            if ((correct_out !== out) && (correct_gt !== gt))
                error = 1'b1;
        end
    endcase
    if (error) begin
        $display("Error check: A = %h , B = %h, op = %b, Out = %h, Expected Output: %h", A, B, op, out, correct_out);
        fail = 1'b1;
        $stop;
    end
end

endmodule