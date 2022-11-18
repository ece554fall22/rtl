module control_unit(inst, control_bus control);
input [31:0] inst;

enum {halt, nop, jmp, jal, jmpr, jalr, bi, br, lih, lil, ld32, ld36, st32, st36, vldi, vsti, vldr, vstr, Addi, Subi, Andi, Ori, xori, shli, shri, cmpi, alu, Not, Falu, cmp, Vadd, Vsub,
Vmult, Vdiv, Vdot, Vdota, Vindx, Vreduce, Vsplat, Vswizzle, Vsadd, Vsmult, Vssub, Vsdiv, vsma, writeA, writeB, writeC, matmul, readC,
systolicstep, Vmax, Vmin, Vcomp, ftoi, itof, wcsr, rcsr, fa, cmpx, flushdirty, flushclean, flushicache, flushline, cmpdec, cmpinc}

logic [6:0] op_code;

assign op_code = inst[31:25];

always_comb begin
    control.halt = 0;
    control.flushicache = 0;
    control.data_cache_flush = '0;
    control.matrix_mutplier_en = 0;
    control.vector_wr_en = 0;
    control.register_wr_en = 0;
    control.mem_read = 0;
    control.mem_write = 0;
    control.vector_read_register1 = inst[14:10];
    control.vector_read_register2 = inst[19:15];
    control.scalar_read_register1 = inst[19:15];
    control.scalar_read_register2 = inst[14:10];
    control.write_register = inst[24:20];
    control.vector_alu_op = '0;
    control.op_type = '0;
    control.w_type = '0;
    control.r_type = '0;
    control.scalar_op_sel = '0;
    control.synch_op = '0;
    control.branch_control = '0;
    control.matmul_idx = '0;
    control.matmul_opcode = '0;
    control.matmul_high_low = 0;
    control.synch_req = 0;
    control.branch_jump = '0;
    control.branch_register = 0;
    control.store_pc = 0;
    control.alu_operands = 0;
    case (op_code)
        halt: begin
            halt = 1;
        end
        nop: begin
        end
        jmp: begin
            control.branch_jump = 2'b01;
        end
        jal: begin
            control.branch_jump = 2'b01;
            control.register_wr_en = 1;
            control.write_register = 32'hFFFF;
            store_pc = 1;
        end
        jmpr: begin
            control.branch_jump = 2'b01;
            control.branch_register = 1;
        end
        jalr: begin
            control.branch_jump = 2'b01;
            control.branch_register = 1;
            control.register_wr_en = 1;
            control.write_register = 32'hFFFF;
            store_pc = 1;
        end
        bi: begin
            control.branch_jump = 2'b10;
        end
        br: begin
            control.branch_jump = 2'b10;
            control.branch_register = 1;
        end
        lih: begin
            control.register_wr_en = 1;
        end
        lil: begin
            control.register_wr_en = 1;
        end
        ld32: begin
            control.register_wr_en = 1;
            control.mem_read = 1;
            control.r_type = 2'b01;
            control.scalar_alu_op = 4'b0000;
            control.alu_operands = 1;
        end
        ld36: begin
            control.register_wr_en = 1;
            control.mem_read = 1;
            control.r_type = 2'b10;
            control.scalar_alu_op = 4'b0000;
            control.alu_operands = 1;
        end
        st32: begin
            control.mem_write = 1;
            control.w_type = 2'b01;
            control.scalar_alu_op = 4'b0000;
            control.alu_operands = 1;
        end
        st36: begin
            control.mem_write = 1;
            control.w_type = 2'b10;
            control.scalar_alu_op = 4'b0000;
            control.alu_operands = 1;
        end
        vldi: begin
            control.mem_read = 1;
            control.r_type = 2'b11;
            control.
        end
        vsti: begin
        end
        vldr: begin
        end
        vstr: begin
        end
        Addi: begin
        end
        Subi: begin
        end
        Andi: begin
        end
        Ori: begin
        end
        xori: begin
        end
        shli: begin
        end
        shri: begin
        end
        cmpi: begin
        end
        alu: begin
        end
        Not: begin
        end
        Falu: begin
        end
        cmp: begin
        end
        Vadd: begin
        end
        Vsub: begin
        end
        Vmult: begin
        end
        Vdiv: begin
        end
        Vdot: begin
        end
        Vdota: begin
        end
        Vindx: begin
        end
        Vreduce: begin
        end
        Vsplat: begin
        end
        Vswizzle: begin
        end
        Vsadd: begin
        end
        Vsmult: begin
        end
        Vssub: begin
        end
        vsma: begin
        end
        writeA: begin
        end
        writeB: begin
        end
        writeC: begin
        end
        matmul: begin
        end
        readC: begin
        end
        systolicstep: begin
        end
        Vmax: begin
        end
        Vmin: begin
        end
        Vcompsel: begin
        end
        ftoi: begin
        end
        itof: begin
        end
        wcsr: begin
        end
        rcsr: begin
        end
        fa: begin
        end
        cmpx: begin
        end
        flushdirty: begin
        end
        flushclean: begin
        end
        flushicache: begin
        end
        flushline: begin
        end
        cmpdec: begin
        end
        cmpinc: begin
        end
    endcase
end