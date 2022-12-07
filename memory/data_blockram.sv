module data_blockram(clk1, rst, rd_addr, wr_data, wr_addr, wr_en, data_out);

output[511:0] data_out;		// Cache lines are 512 bits, this output is the same fourth of the Cacheline in the 4 different ways
input [127:0] wr_data;		// wr_data is the fourth of the cacheline to be written
input [9:0] rd_addr;		// rd_addr is smaller than wr_addr since reads need to read from all 4 ways but writes only write to 1
input [11:0] wr_addr;           
input clk1, wr_en, rst;	// two input clocks justs because this is supported for blockram on fpga, should be the same clock since
				// we only need 1R 1W support for the blockram to work.
reg [511:0] data_out;		// same as output data_out written like this because that's how it's done in the intel example
reg [127:0] mem [4095:0];	// memory array that holds data

assign data_out = {mem[{rd_addr, 2'b11}],
				   mem[{rd_addr, 2'b10}],
				   mem[{rd_addr, 2'b01}],
				   mem[{rd_addr, 2'b00}]};

always @(posedge clk1, posedge rst) begin	// blockram
	if(rst) begin
		for(int i = 0; i < 4096; i++) begin	// zeros array on reset
			mem[i] <= 0;
	    end
	end
	else if(wr_en) begin
		mem[wr_addr] <= wr_data;			// wr
	end
end
endmodule
