module cache_test_hierarchy(
input logic clk, rst,
input logic go,
output logic done,
input logic [35:0] wr_offset,
input logic [63:0] virt_addr_base,
input logic wr_done, rd_done,
input logic full, empty,
input logic [511:0] rd_data,
output logic [511:0] wr_data,
output logic [63:0] wr_addr, rd_addr,
output logic rd_go, wr_go, rd_en, wr_en
);
logic [1:0] [2:0] packet_type_req_in, packet_type_req_out, packet_type_circ_out;
logic [1:0] [3:0] id_req_in, id_req_out, id_circ_out;
logic [1:0] [511:0] data_req_in, data_req_out,  data_circ_out;
logic [1:0] [35:0] addr_req_in, addr_req_out, addr_circ_out;
logic r, mem_stall_in;
logic [1:0] w_type, overwrite, flushtype;
logic [35:0] addr;
logic [127:0] w_data;
logic [127:0] data_out;
logic [15:0] cache_lines, wr_size;

data_cache_controller CACHECONTROLLLER(.clk(clk), .rst(rst), .r(r), .faa(1'b0), .w_type(w_type), .addr(addr), 
                                       .mem_addr_in(addr_req_out[0]), .w_data(w_data), .mem_data_in(data_req_out[0]),
			               .id_req_in(id_req_out[0]), .packet_type_req_in(packet_type_req_out[0]),
			               .data_out(data_out), .mem_data_out(data_req_in[0]), .stall(mem_stall_in),
			               .overwrite(overwrite[0]), .mem_addr_out(addr_req_in[0]), .flushtype(flushtype),
			               .id_req_out(id_req_in[0]), .packet_type_req_out(packet_type_req_in[0]), .done(done));

circular_memory_unit CMU0(.clk(clk), .rst(rst), .addr_req_in(addr_req_in[0]), .addr_req_out(addr_req_out[0]),
                          .addr_circ_in(addr_circ_out[1]), .addr_circ_out(addr_circ_out[0]), .data_req_in(data_req_in[0]),
		          .data_req_out(data_req_out[0]), .data_circ_in(data_circ_out[1]), .data_circ_out(data_circ_out[0]),
		          .id_req_in(id_req_in[0]), .id_req_out(id_req_out[0]), .id_circ_in(id_circ_out[1]),
		          .id_circ_out(id_circ_out[0]), .packet_type_req_in(packet_type_req_in[0]),
		          .packet_type_req_out(packet_type_req_out[0]), .packet_type_circ_in(packet_type_circ_out[1]),
		          .packet_type_circ_out(packet_type_circ_out[0]), .overwrite(overwrite[0]));

circular_memory_unit CMU1(.clk(clk), .rst(rst), .addr_req_in(addr_req_in[1]), .addr_req_out(addr_req_out[1]),
                          .addr_circ_in(addr_circ_out[0]), .addr_circ_out(addr_circ_out[1]), .data_req_in(data_req_in[1]),
		          .data_req_out(data_req_out[1]), .data_circ_in(data_circ_out[0]), .data_circ_out(data_circ_out[1]),
		          .id_req_in(id_req_in[1]), .id_req_out(id_req_out[1]), .id_circ_in(id_circ_out[0]),
		          .id_circ_out(id_circ_out[1]), .packet_type_req_in(packet_type_req_in[1]),
		          .packet_type_req_out(packet_type_req_out[1]), .packet_type_circ_in(packet_type_circ_out[0]),
		          .packet_type_circ_out(packet_type_circ_out[1]), .overwrite(overwrite[1]));

cache_tester_sm CACHETESTSM(.wr_offset(wr_offset), .clk(clk), .rst(rst), 
                            .mem_stall_in(mem_stall_in), .cache_data(data_out), .wr_data(w_data), 
		            .addr(addr), .r(r), .flushtype(flushtype), .w_type(w_type), .go(go));

mem_controller MEM(.empty(empty), .rd_done(rd_done), .full(full), .wr_done(wr_done), .clk(clk), .rst(rst),
                   .rd_go(rd_go), .rd_en(rd_en), .wr_go(wr_go), .wr_en(wr_en),
	           .overwrite(overwrite[1]), .addr_in(addr_req_out[1]), .mmio_addr(virt_addr_base), .rd_addr(rd_addr), 
	           .wr_addr(wr_addr), .addr_out(addr_req_in[1]), .wr_size(wr_size), .cache_lines(cache_lines), .rd_data(rd_data),
	           .wr_data(wr_data), .data_in(data_req_out[1]), .data_out(data_req_in[1]), .id_req_in(id_req_out[1]), 
	           .id_req_out(id_req_in[1]), .packet_type_req_in(packet_type_req_out[1]),
	           .packet_type_req_out(packet_type_req_in[1]));

endmodule
