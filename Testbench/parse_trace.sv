module parse_trace;

initial begin
    // Integer variable to hold file descriptor
    int fd;
    // String variable to hold the line of the file
    string line;

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

    // Open the tracer file in the current folder with "read" permission
    // fd = 0 if file doesn't exist
    fd = $fopen ("I:\\ece554\\rtl\\Testbench\\scalar_pipeline_test.trace", "r");
    if (fd) $display("Trace file opened successfully : %0d", fd);
    else begin
        $display("File not opened successfully : %0d", fd);
        $fclose(fd);
        $stop;
    end
    // while (!$feof(fd)) begin
    for(int i = 0; i < 4; i++) begin
        $fgets(line, fd);


////////// first line //////////
        if (line.substr(0,2) == "***") begin

            $sscanf(line, "*** %x: %x ***", PC, inst);
        end


////////// second line //////////
        else if(line.substr(0,9) == "    inputs") begin
            // rD with imm
            if ($sscanf(line, "    inputs: rD=r%x=%x imm=%d", rD, rD_value, imm) == 3) begin
            end

            // rD with rA and rB
            else if (line, $sscanf("    inputs: rD=r%x=%x rA=r%x=%x rB=r%x=%x", rD, rD_value, rA, rA_value, rB, rB_value) == 6) begin
            end

            // TODO: vector inputs
        end
        

////////// third line //////////
        else if(line.substr(0,19) == "    scalar_writeback") begin
            $sscanf(line, "    scalar_writeback: rD=r%x=%x", wb_reg, wb_reg_value);
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
        else if(line.substr(0,2) == "asm") begin
            // TODO: do something
        end

        // debugging
        // $display("Line: %s", line);
    end
    
    $fclose(fd);
end


endmodule