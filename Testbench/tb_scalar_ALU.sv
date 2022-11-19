// Created by: Leo Garcia Calderon & Mark Xia
module tb_scalar_ALU();

    // inputs
    logic [35:0] A, B;
    logic [3:0] op;
    logic clk, rst_n;

    logic [35:0] out;
    logic [35:0] correct_out;
    logic error;
    logic nz, ez, lz, gz, le, ge;
    logic correct_nz, correct_ez, correct_lz, correct_gz, correct_le, correct_ge;
    logic fail;

    alu a1 ( // inputs 
        .clk(clk), .rst_n(rst_n), .A(A), .B(B), .op(op),
          // outputs
        .out(out), .nz(nz), .ez(ez), .lz(lz), .gz(gz), .le(le), .ge(ge)
    );


    initial begin
        clk = 0;
        A = '0;
        B = '0;
        fail = 0;
        // reset
        @(posedge clk);
        rst_n = 0'b0; // active low reset
        @(posedge clk);
        rst_n = 1'b1; // reset finished
        @(posedge clk);
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
    end

    always @(negedge clk) begin
        error = 1'b0;

        case(op)
            4'b0000 : begin //add
                correct_out = A + B;
                if (correct_out !== out) // TODO: put all if statements with no begin/end on the same line
                    error = 1'b1;
            end
            4'b0001 : begin //subtract
                correct_out = A - B;
                if (correct_out !== out)
                    error = 1'b1;
            end
            4'b0010 : begin //multiply
                correct_out = A * B;
                if (correct_out !== out)
                    error = 1'b1;
            end
            4'b0011 : begin //and
                correct_out = A & B;
                if (correct_out !== out)
                    error = 1'b1;
            end
            4'b0100 : begin //or
                correct_out = A | B;
                if (correct_out !== out)
                    error = 1'b1;
            end
            4'b0101 : begin //xor
                correct_out = A ^ B;
                if (correct_out !== out)
                    error = 1'b1;
            end
            4'b0110 : begin //shift <<
                correct_out = A << B[3:0];
                if (correct_out !== out)
                    error = 1'b1;
            end
            4'b0111 : begin //shift >>
                correct_out = A >> B[3:0];
                if (correct_out !== out)
                    error = 1'b1;
            end
            4'b1000 : begin //subtract
                correct_out = A - B;
                correct_nz = correct_out != 36'b0;
                correct_ez = ~correct_nz;
                correct_lz = correct_out[35];
                correct_gz = ~correct_lz;
                correct_le = correct_lz | correct_ez;
                correct_ge = correct_gz | correct_ez;
                if ((correct_out !== out) && (correct_nz !== nz) && (correct_ez !== ez) && (correct_lz !== lz) && (correct_gz !== gz) && (correct_le !== le) && (correct_ge !== ge))
                    error = 1'b1; // TODO: if statement is too long
            end
        endcase

        if (error == 1'b1) begin
            $display("Error check: A = %h , B = %h, op = %b, Out = %h, Expected Output: %h", A, B, op, out, correct_out);
            fail = 1'b1;
        end
    end

endmodule
