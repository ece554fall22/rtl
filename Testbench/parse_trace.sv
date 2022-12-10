module parse_trace;
    // first line
    bit [35:0] PC;
    bit [31:0] inst;

    // second line
    integer rD_int;
    bit [4:0] rD;
    bit [35:0] rD_value;
    integer imm_int;
    bit [24:0] imm;
    bit [4:0] rA;
    bit [35:0] rA_value;
    bit [4:0] rB;
    bit [35:0] rB_value;

    // third line
    bit [4:0] wb_reg;
    bit [35:0] wb_reg_value;

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
    fd = $fopen ("I:\\ece554\\rtl\\Testbench\\scalar_pipeline_test.trace", "r");
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



    // while (!$feof(fd)) begin
    for(int i = 0; i < 4; i++) begin
        $fgets(line, fd);


////////// first line //////////
        if (line.substr(0,2) == "***") begin
            $display("1");

            $sscanf(line, "*** %x: %x ***", PC, inst);
        end


////////// second line //////////
        else if(line.substr(0,9) == "    inputs") begin
            // rD with imm
            if ($sscanf(line, "    inputs: rD=r%x=%x imm=%d", rD, rD_value, imm) == 3) begin
            end

            // rD with rA and rB
            else if ($sscanf(line, "    inputs: rD=r%x=%x rA=r%x=%x rB=r%x=%x", rD, rD_value, rA, rA_value, rB, rB_value) == 6) begin
                $display("2");
            end

            // TODO: vector inputs
        end
        

////////// third line //////////
        else if(line.substr(0,19) == "    scalar_writeback") begin
            $sscanf(line, "    scalar_writeback: rD=r%x=%x", wb_reg, wb_reg_value);
            $display("3");
        end

        else if(line.substr(0,19) == "    vector_writeback") begin
            $sscanf(line, "    vector_writeback: v%x = %x", wb_reg, wb_reg_value);
        end

        else if(line.substr(0,10) == "scalar_load") begin
            // TODO: do something
        end

        else if(line.substr(0,11) == "scalar_store") begin
            // TODO: do something
        end

        else if(line.substr(0,10) == "vector_load") begin
            // TODO: do something
        end

        else if(line.substr(0,11) == "vector_store") begin
            // TODO: do something
        end


////////// fourth line //////////
        else if(line.substr(0,6) == "    asm") begin
            $display("4");
            assign proc1.inst_f = inst;
            assign proc1.sdata1_d = rA_value;
            assign proc1.sdata2_d = rB_value;
            repeat (20) @(posedge clk);
            $display("R%x: %x", rA, rA_value);
            $display("R%x: %x", rB, rB_value);
            $display("R%x: %x", wb_reg, wb_reg_value);
            $display("WB Reg: %x", proc1.s_writeback_control.scalar_write_register);
            $display("WB Reg Value: %x", proc1.register_write_data);
            $display("Decode Read1: %x", proc1.inst_f[19:15]);
            $display("Decode Read2: %x", proc1.inst_f[14:10]);
            $display("Decode Data1: %x", proc1.sdata1_d);
            $display("Decode Data2: %x", proc1.sdata2_d);            
            $display("Scalar Execute Data1: %x", proc1.sdata1_e);
            $display("Scalar Execute Data2: %x", proc1.sdata2_e);
            $display("Scalar Execute opcode: %x", proc1.sexecut.ALU.op);
            $display("Scalar Execute Data Out: %x", proc1.sdata_out_e);
        end

        // debugging
        // $display("Line: %s", line);
    end
    
    $fclose(fd);

    $stop();
end


endmodule