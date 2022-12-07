// Created by: Leo Garcia Calderon and Mark Xia

module tb_mat_mul();

    // inputs
    logic clk, rst_n, hl;
    logic [31:0] v_high [3:0];
    logic [31:0] v_low [3:0];
    logic [3:0] idx;
    logic [2:0] opcode;

    // outputs
    logic [31:0] data_out [3:0];

    // golden outputs
    logic [31:0] A [7:0][7:0];
    logic [31:0] B [7:0][7:0];
    logic [31:0] C [7:0][7:0];
    shortreal C_shortreal [7:0][7:0];

    // errors
    int errors;

    tpuv1 iDUT1 (
        // inputs 
        .clk(clk), .rst_n(rst_n), .hl(hl), .v_high(v_high),
        .v_low(v_low), .idx(idx), .opcode(opcode),
        // outputs
        .data_out(data_out));

    // create clock signal
    always #5 clk = ~clk;

    enum {nop, writeA, writeB, writeC, matmul, readC, systolic_step} opcodes;

    initial begin
        clk = 1'b0;
	    rst_n = 1'b1;

        // fill in golden A and B
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                A[i][j] = $random;
                B[i][j] = $random;
            end
        end

        // calculate golden output
        for (int i = 0; i < 8; i++) begin // iterate through rows of A
            for (int j = 0; j < 8; j++) begin // iterate through cols of B
                for (int k = 0; k < 8; k++) begin // iterate through rows of B
                    C_shortreal[i][j] += $bitstoshortreal(A[i][k]) * $bitstoshortreal(B[k][j]);
                    C[i][j] = $shortrealtobits(C_shortreal[i][j]);
                end
            end
        end

        @(posedge clk);
        rst_n = 0'b0; // active low reset
        @(posedge clk);
        rst_n = 1'b1; // reset finished
        @(posedge clk);

        idx = '0;

        // writing to memA
        opcode = writeA;
        for(int i = 0; i < 8; i++) begin
            v_high = A[i][7:4];
            v_low = A[i][3:0];
            @(posedge clk);
            ++idx;
        end

        // writing to memB
        opcode = writeB;
        for(int i = 0; i < 8; i++) begin
            v_high = B[i][7:4];
            v_low = B[i][3:0];
            @(posedge clk);
        end

        // multiply
        opcode = systolic_step;
        repeat (22) @(posedge clk);

        // check if calculate C equals golden C
        hl = 1;
        opcode = readC;
        for(int i = 0; i < 8; i++) begin

            idx = i;

            @(posedge clk);

            // check first half of row
            if(C[i][7:4] !== data_out) ++errors;
            hl = 0;

            @(posedge clk);

            // check second half of row
            if(C[i][3:0] !== data_out) ++errors;
            hl = 1;

            @(posedge clk);

        end

        if(errors > 0) begin
            $display("Test failed! You have %d errors!", errors);
        end
        else begin
            $display("YAHOO! Test passed!");
        end



    end // initial begin

endmodule // tb_mat_mul