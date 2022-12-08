module parse_trace;

initial begin
    // Integer variable to hold file descriptor
    int fd;
    // String variable to hold the line of the file
    string line;

    // Open the tracer file in the current folder with "read" permission
    // fd = 0 if file doesn't exist
    fd = $fopen ("C:\\Users\\07yhx\\ece554\\rtl\\Testbench\\randscalar0.trace", "r");
    if (fd) $display("Trace file opened successfully : %0d", fd);
    else begin
        $display("File not opened successfully : %0d", fd);
        $fclose(fd);
        $stop;
    end
    while (!$feof(fd)) begin
        $fgets(line, fd);
        $display("Line: %s", line);
    end
    
    $fclose(fd);
end

endmodule