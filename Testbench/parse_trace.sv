module parse_trace;

initial begin
    // Integer variable to hold file descriptor
    int fd;
    // String variable to hold the line of the file
    string line;

    bit [10:0] current_PC;
    bit [31:0] inst;
    bit [4:0] curr_reg;
    bit [35:0] curr_reg_value;
    int imm;
    bit [35:0] wb_reg_value; 

    // Open the tracer file in the current folder with "read" permission
    // fd = 0 if file doesn't exist
    fd = $fopen ("I:\\ece554\\rtl\\Testbench\\randscalar0.trace", "r");
    if (fd) $display("Trace file opened successfully : %0d", fd);
    else begin
        $display("File not opened successfully : %0d", fd);
        $fclose(fd);
        $stop;
    end
    while (!$feof(fd)) begin
        $fgets(line, fd);

        // first line
        if ($sscanf(line, "*** %x: %x ***", current_PC, inst) == 2) {
            // TODO: do something
        }


        // second line
        else if(line.substr(0,5) == "inputs") {
            // TODO: do something
        }
        

        // third line
        else if(line.substr(0,15) == "scalar_writeback") {
            // TODO: do something
        }

        else if(line.substr(0,15) == "vector_writeback") {
            // TODO: do something
        }

        else if(line.substr(0,10) == "scalar_load") {
            // TODO: do something
        }

        else if(line.substr(0,11) == "scalar_store") {
            // TODO: do something
        }

        else if(line.substr(0,10) == "vector_load") {
            // TODO: do something
        }

        else if(line.substr(0,11) == "vector_store") {
            // TODO: do something
        }


        // fourth line
        else if(line.substr(0,2) == "asm") {
            // TODO: do something
        }

        // debugging
        $display("%x", inst);
        // $display("Line: %s", line);
    end
    
    $fclose(fd);
end


endmodule