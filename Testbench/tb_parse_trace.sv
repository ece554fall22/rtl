// Created by: Leo Garcia Calderon & Mark Xia

module tb_parse_trace;
    logic vector;

    // first line
    bit [35:0] PC;
    bit [31:0] inst;

    // second line
    bit [4:0] rD;
    bit [35:0] rD_value;
    bit [24:0] imm;
    bit [4:0] rA;
    bit [35:0] rA_value;
    bit [4:0] rB;
    bit [35:0] rB_value;
    logic imm_used;

    bit [4:0] vD;

    bit [31:0] vD0;
    bit [31:0] vD1;
    bit [31:0] vD2;
    bit [31:0] vD3;

    bit [4:0] vA;

    bit [31:0] vA0;
    bit [31:0] vA1;
    bit [31:0] vA2;
    bit [31:0] vA3;

    bit [4:0] vB;

    bit [31:0] vB0;
    bit [31:0] vB1;
    bit [31:0] vB2;
    bit [31:0] vB3;

    bit [3:0] vMask;

    // third line
    bit [4:0] wb_reg;
    bit [35:0] wb_reg_value;

    // fourth line
    bit [3:0] wb_v;
    bit [31:0] wb_v0;
    bit [31:0] wb_v1;
    bit [31:0] wb_v2;
    bit [31:0] wb_v3;


    logic clk, rst;

    proc proc1(.clk(clk), .rst(rst), .err());

    // Create clock signal
    always begin
    #5 clk = ~clk;
    end

initial begin
    // Integer variable to hold file descriptor
    int fd;
    // String variable to hold the line of the file
    string line;

    // Open the tracer file in the current folder with "read" permission
    // fd = 0 if file doesn't exist
    fd = $fopen ("I:\\ece554\\rtl\\Testbench\\scalar.trace", "r"); // will need to change based on user
    if (fd) $display("Trace file opened successfully : %0d", fd);
    else begin
        $display("File not opened successfully : %0d", fd);
        $fclose(fd);
        $stop;
    end

    clk = 0;
    rst = 1;
    @(posedge clk);
    rst = 0; // reset finished
    @(posedge clk);

    $display("0");

    vector = 0;

    while (!$feof(fd)) begin
    // for(int i = 0; i < 4; i++) begin
        $fgets(line, fd);


////////// first line //////////
        if (line.substr(0,2) == "***") begin
            $display("1");

            $sscanf(line, "*** %x: %x ***", PC, inst);
        end


////////// second line //////////
        else if(line.substr(0,9) == "    inputs") begin
            $display("2");
            // rD with imm
            if ($sscanf(line, "    inputs: rD=r%d=%x imm=%d", rD, rD_value, imm) == 3) begin
                imm_used = 1;
            end

            // rD with rA and rB
            else if ($sscanf(line, "    inputs: rD=r%d=%x rA=r%x=%x rB=r%x=%x", rD, rD_value, rA, rA_value, rB, rB_value) == 6) begin
                imm_used = 0;
            end

            // vD with rA
            else if ($sscanf(line, "    inputs: vD=v%x=(%x,%x,%x,%x) rA=r%x=%x", vD, vD0, vD1, vD2, vD3, rA, rA_value) == 7) begin
                vector = 1;
            end

            // vD with vA, vB
            else if ($sscanf(line, "    inputs: vD=v%x=(%x, %x, %x, %x) vA=v%x=(%x, %x, %x, %x) vB=v%x=(%x, %x, %x, %x)", vD, vD0, vD1, vD2, vD3, vA, vA0, vA1, vA2, vA3, vB, vB0, vB1, vB2, vB3) == 15) begin
                vector = 1;
            end
            

        end
        

////////// third line //////////
        else if(line.substr(0,19) == "    scalar_writeback") begin
            $sscanf(line, "    scalar_writeback: rD=r%d=%x", wb_reg, wb_reg_value);
            $display("3");
        end

        else if(line.substr(0,14) == "    vector_mask") begin
            $sscanf(line, "    vector_mask: %b", vMask);
            $display("3");
        end        

        else if(line.substr(0,10) == "scalar_load") begin
            // TODO: memory instructions not ready yet
            $display("3");
        end

        else if(line.substr(0,11) == "scalar_store") begin
            // TODO: memory instructions not ready yet
            $display("3");
        end

        else if(line.substr(0,10) == "vector_load") begin
            // TODO: memory instructions not ready yet
            $display("3");
        end

        else if(line.substr(0,11) == "vector_store") begin
            // TODO: memory instructions not ready yet
            $display("3");
            
        end


////////// fourth line //////////
        else if(line.substr(0,19) == "    vector_writeback") begin
            $sscanf(line, "vector_writeback: vD=v%x=(%x, %x, %x, %x)", wb_v, wb_v0, wb_v1, wb_v2, wb_v3);
            $display("3");
        end

        else if(line.substr(0,6) == "    asm") begin

            $display("4");
            assign proc1.inst_f = inst;
            @(posedge clk);
            assign proc1.inst_f = 32'h02000000;
            repeat (4) @(posedge clk);

            if((wb_reg !== proc1.s_writeback_control.scalar_write_register || wb_reg_value !== proc1.register_write_data) & !vector) begin

                if (line.substr(9,11) == "lil") begin
                    if(wb_reg_value[17:0] === proc1.register_write_data[17:0]) begin
                        continue;
                    end
                end


                $display("%x", rA_value ^ rB_value);

                $display("Test Failed!");
                $display("PC: %x", PC);
                if(imm_used) begin
                    $display("expected rD: r%xd: %x", rD, rD_value);
                end
                else begin
                    $display("expected rA: r%x: %x", rA, rA_value);
                    $display("expected rB: r%x: %x", rB, rB_value);
                end
                $display("expected rW: r%x: %x", wb_reg, wb_reg_value);
                $display("actual WB Reg: r%x", proc1.s_writeback_control.scalar_write_register);
                $display("actual WB Reg Value: %x", proc1.register_write_data);
                $display("Decode Read1: %x", proc1.inst_f[19:15]);
                $display("Decode Read2: %x", proc1.inst_f[14:10]);
                $display("Decode Data1: %x", proc1.sdata1_d);
                $display("Decode Data2: %x", proc1.sdata2_d);            
                $display("Scalar Execute Data1: %x", proc1.sdata1_e);
                $display("Scalar Execute Data2: %x", proc1.sdata2_e);
                $display("Scalar Execute opcode: %x", proc1.sexecut.ALU.op);
                $display("Scalar Execute Data Out: %x", proc1.sdata_out_e);
                $stop();
            end

            else if((wb_v !== proc1.v_writeback_control.vector_write_register || wb_v0 !== proc1.vector_write_data[0] || wb_v1 !== proc1.vector_write_data[1] || wb_v2 !== proc1.vector_write_data[2] || wb_v3 !== proc1.vector_write_data[3]) & vector) begin
                // todo: waiting for toolchain to verify trace file
                $display("Vector Test failed!");
            end
        end

        // debugging
        // $display("Line: %s", line);
    end
    
    $fclose(fd);

    $display("All Tests Passed!");

    $stop();
end


endmodule