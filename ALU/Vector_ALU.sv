module vector_alu(v1, v2, r1, r2, op, imm, clk, rst_n, en);
input [31:0] v1 [3:0];
input [31:0] v2 [3:0];
input [31:0] r1, r2;
input [4:0] op;
input [7:0] imm;
output logic [31:0] vout [3:0];
output logic [31:0] rout;

logic [31:0] a1, a2, b1, b2, b3, b4, out5_d, out6_d, out5_q, out6_q, out7;

logic [31:0] v10 [2:0];
logic [31:0] v11 [2:0];
logic [31:0] v12 [2:0];
logic [31:0] v13 [2:0];
logic [31:0] r1pip[2:0];
logic [31:0] r2pip[2:0];
logic [31:0] out1 [2:0]; 
logic [31:0] out2 [2:0]; 
logic [31:0] out3 [2:0]; 
logic [31:0] out4 [2:0];
logic [3:0] gts [2:0];
logic [4:0] oppip [2:0];

//pipeline for alu signals
assign v10[0] =  v1[0];
assign v11[0] =  v1[1];
assign v12[0] =  v1[2];
assign v13[0] =  v1[3];
assign r1pip[0] =  r1;
assign r2pip[0] =  r2;
assign oppip[0] = op;

genvar i;
    generate;
        for (i=1; i<3; ++i) begin
            always_ff@( posedge clk, negedge rst_n ) begin
                if (rst_n) begin 
                    out1[i] <= '0;
                    out2[i] <= '0;
                    out3[i] <= '0;
                    out4[i] <= '0;
                    v10[i] <= '0;
                    v11[i] <= '0;
                    v12[i] <= '0;
                    v13[i] <= '0;
                    r1pip[i] <= '0;
                    r2pip[i] <= '0;
                    gts[i] <= '0;
                    oppip[i] <= '0;
                end
                else if(en) begin
                    out1[i] <= out1[i-1];
                    out2[i] <= out2[i-1];
                    out3[i] <= out3[i-1];
                    out4[i] <= out4[i-1];
                    v10[i] <= v10[i-1];
                    v11[i] <= v11[i-1];
                    v12[i] <= v12[i-1];
                    v13[i] <= v13[i-1];
                    r1pip[i] <= r1pip[i-1];
                    r2pip[i] <= r2pip[i-1];
                    gts[i] <= gts[i -1]; 
                    oppip [i] <= oppip[i-1];
                end

            end
        end
    endgenerate

always_ff@( posedge clk, negedge rst_n ) begin
    if (rst_n) begin 
        out5_q <= '0;
        out6_q <= '0;
    end
    else if(en) begin
        out5_q <= out5_d;
        out6_q <= out6_d;
    end
end

logic [1:0] op1, op2, op3, op4;

logic [1:0] Sel_1, Sel_2;

logic Sel_34;

assign a1 = (Sel_1 == 2'b00) ? r1 : v1[0];

assign b1 = (Sel_1 == 2'b00) ? r2 :
            (Sel_1 == 2'b01) ? v2[0] :
            (Sel_1 == 2'b10) ? v1[1] : r1;

assign a2 = (Sel_2 == 2'b00) ? v1[2] : v1[1];

assign b2 = (Sel_2 == 2'b00) ? v1[3] : 
            (Sel_2 == 2'b01) ? v2[1] : r1;

assign b3 = (Sel_34) ? r1 : v2[2];
assign b4 = (Sel_34) ? r1 : v2[3];

fp_alu alu1 (.A(a1), .B(b1), .op(op1), .out(out1[0]), .gt(gts[0]));

fp_alu alu2 (.A(a2), .B(b2), .op(op2), .out(out2[0]), .gt(gts[1]));

fp_alu alu3 (.A(v1[2]), .B(b3), .op(op3), .out(out3[0]), .gt(gts[2]));

fp_alu alu4 (.A(v1[3]), .B(b4), .op(op4), .out(out4[0]), .gt(gts[3]));

fp_alu alu5 (.A(out1[1]), .B(out2[1]), .op(2'b00), .out(out5_d), .gt());

fp_alu alu6 (.A(out3[1]), .B(out4[1]), .op(2'b00), .out(out6_d), .gt());

fp_alu alu7 (.A(out5_q), .B(out6_q), .op(2'b00), .out(out7), .gt());





enum {Fadd, Fsub, Fmult, Vadd, Vsub, Vmult, Vdot, Vdota, Vindx, Vreduce, Vsplat, Vswizzle, Vsadd, Vssub, Vsmult, Vsma, Vcompsel, Vmax, Vmin} operations;


always_comb begin
    op1 = 2'b0;
    op2 = 2'b0;
    op3 = 2'b0;
    op4 = 2'b0;
    Sel_1 = 2'b0;
    Sel_2 = 2'b0;
    Sel_34 = 0;
    case(op) 
        Fsub: begin
            op1 = 2'b01;
        end
        Fmult: begin
            op1 = 2'b10;
        end
        Vadd: begin
            Sel_1 = 2'b00;
            Sel_2 = 2'b01;
        end
        Vsub: begin
            op1 = 2'b01;
            Sel_1 = 2'b00;
            Sel_2 = 2'b01;
        end
        Vmult: begin
            op1 = 2'b10;
            Sel_1 = 2'b00;
            Sel_2 = 2'b01;
        end
        Vdot: begin
            op1 = 2'b10;
            Sel_1 = 2'b00;
            Sel_2 = 2'b01;
        end
        Vdota: begin
            op1 = 2'b10;
            Sel_1 = 2'b00;
            Sel_2 = 2'b01;
        end
        Vreduce: begin
            op1 = 2'b01;
            Sel_1 = 2'b00;
            Sel_2 = 2'b01;
        end
        Vsadd: begin
            op1 = 2'b00;
            Sel_1 = 2'b00;
            Sel_2 = 2'b11;
            Sel_34 = 1;
        end
        Vssub: begin
            op1 = 2'b01;
            Sel_1 = 2'b00;
            Sel_2 = 2'b11;
            Sel_34 = 1;
        end
        Vsmult: begin
            op1 = 2'b10;
            Sel_1 = 2'b00;
            Sel_2 = 2'b11;
            Sel_34 = 1;
        end
        Vsma: begin
            op1 = 2'b10;
            Sel_1 = 2'b00;
            Sel_2 = 2'b11;
            Sel_34 = 1;
        end
        Vcompsel: begin
            op1 = 2'b11;
            Sel_1 = 2'b00;
            Sel_2 = 2'b01;
        end
        Vmax: begin
            op1 = 2'b11;
            Sel_1 = 2'b00;
            Sel_2 = 2'b01;
        end
        Vmin: begin
            op1 = 2'b11;
            Sel_1 = 2'b00;
            Sel_2 = 2'b01;
        end
    endcase
end

//Fadd, Fsub, Fmult, Vadd, Vsub, Vmult, Vdot, Vdota, Vindx, Vreduce, Vsplat, Vswizzle, Vsadd, Vssub, Vsmult, Vsma, Vcompsel, Vmax, Vmin

always_comb begin
    rout = 32'b0;
    vout[0] = 32'b0;
    vout[1] = 32'b0;
    vout[2] = 32'b0;
    vout[3] = 32'b0;
    case(oppip[2])
        Fadd: begin
            rout = out1[2];
        end
        Fsub: begin
            rout = out1[2];
        end
        Fmult: begin
            rout = out1[2];
        end
        Vadd: begin
            vout[0] = out1[2];
            vout[1] = out2[2];
            vout[2] = out3[2];
            vout[3] = out4[2];
        end
        Vsub: begin
            vout[0] = out1[2];
            vout[1] = out2[2];
            vout[2] = out3[2];
            vout[3] = out4[2];
        end
        Vmult: begin
            vout[0] = out1[2];
            vout[1] = out2[2];
            vout[2] = out3[2];
            vout[3] = out4[2];
        end
        Vdot: begin
            rout = out7;
        end
        Vdota: begin
            rout = out7 + r1pip[2];
        end
        Vindx: begin
            rout = (imm[1:0] == 2'b00) ? v10[2] :
                    (imm[1:0] == 2'b01) ? v11[2] :
                    (imm[1:0] == 2'b10) ? v12[2] :
                    v13[0];
        end
        Vreduce: begin
            rout = out5_q;
        end
        Vsplat: begin
            vout[0] = r1pip[2];
            vout[1] = r1pip[2];
            vout[2] = r1pip[2];
            vout[3] = r1pip[2];
        end
        Vswizzle: begin
            vout[0] = (imm[1:0] == 2'b00) ? v10[2] :
                    (imm[1:0] == 2'b01) ? v11[2] :
                    (imm[1:0] == 2'b10) ? v12[2] :
                    v13[0];
            vout[1] = (imm[3:2] == 2'b00) ? v10[2] :
                    (imm[3:2] == 2'b01) ? v11[2] :
                    (imm[3:2] == 2'b10) ? v12[2] :
                    v13[0];
            vout[2] = (imm[5:4] == 2'b00) ? v10[2] :
                    (imm[5:4] == 2'b01) ? v11[2] :
                    (imm[5:4] == 2'b10) ? v12[2] :
                    v13[0];
            vout[3] = (imm[7:6] == 2'b00) ? v10[2] :
                    (imm[7:6] == 2'b01) ? v11[2] :
                    (imm[7:6] == 2'b10) ? v12[2] :
                    v13[0];
        end
        Vsadd: begin
            vout[0] = out1[2];
            vout[1] = out2[2];
            vout[2] = out3[2];
            vout[3] = out4[2];
        end
        Vssub: begin
            vout[0] = out1[2];
            vout[1] = out2[2];
            vout[2] = out3[2];
            vout[3] = out4[2];
        end
        Vsmult: begin
            vout[0] = out1[2];
            vout[1] = out2[2];
            vout[2] = out3[2];
            vout[3] = out4[2];
        end
        Vsma: begin
        end
        Vcompsel: begin
            vout[0] = (gts[2][0]) ? r1 : r2;
            vout[1] = (gts[2][1]) ? r1 : r2;
            vout[2] = (gts[2][2]) ? r1 : r2;
            vout[3] = (gts[2][3]) ? r1 : r2;            
        end
        Vmax: begin
            vout[0] = (gts[2][0]) ? v10[2] : out1[2];
            vout[1] = (gts[2][1]) ? v11[2] : out2[2];
            vout[2] = (gts[2][2]) ? v12[2] : out3[2];
            vout[3] = (gts[2][3]) ? v13[2] : out4[2];  
        end
        Vmin: begin
            vout[0] = (gts[2][0]) ? out1[2] : v10[2];
            vout[1] = (gts[2][1]) ? out2[2] : v11[2];
            vout[2] = (gts[2][2]) ? out3[2] : v12[2];
            vout[3] = (gts[2][3]) ? out4[2] : v13[2];
        end
    endcase
end

