module circular_memory_unit #(
parameter DEPTH = 512
)
(
input clk, rst, overwrite,
input [35:0] addr_circ_in, addr_req_in,
output [35:0] addr_circ_out, addr_req_out,
input [DEPTH-1:0] data_circ_in, data_req_in,
output [DEPTH-1:0] data_circ_out, data_req_out,
input [4:0] id_circ_in, id_req_in,
output [4:0] id_circ_out, id_req_out,
input [2:0] packet_type_circ_in, packet_type_req_in,
output [2:0] packet_type_circ_out, packet_type_req_out
);

// outputs to connected module are always circ inputs
assign addr_req_out = addr_circ_in;
assign data_req_out = data_circ_in;
assign id_req_out = id_circ_in;
assign packet_type_req_out = packet_type_circ_in;

// outputs to next circular unit can be overwritten by connected module
assign addr_circ_out = (overwrite) ? addr_req_in : addr_circ_in;
assign data_circ_out = (overwrite) ? data_req_in : data_circ_in;
assign id_circ_out = (overwrite) ? id_req_in : id_circ_in;
assign packet_type_circ_out = (overwrite) ? packet_type_req_in : packet_type_circ_in;

endmodule
