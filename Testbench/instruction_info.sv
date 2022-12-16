

class instruction_info();
    logic [35:0] PC;
    logic [31:0] inst;
    logic [4:0] rD;
    logic [35:0] rD_value;
    logic [24:0] Imm;
    logic [4:0] rA;
    logic [35:0] rA_value;
    logic [4:0] rB;
    logic [35:0] rB_value;
    logic Imm_used;
    logic [4:0] wb_reg;
    logic [35:0] wb_reg_value;

    function new();
        PC = '{default: 0};
        inst  = '{default: 0};
        rD  = '{default: 0};
        rD_value = '{default: 0};
        Imm = '{default: 0};
        rA = '{default: 0};
        rA_value = '{default: 0};
        rB = '{default: 0};
        rB_value = '{default: 0};
        Imm_used = '{default: 0};
        wb_reg = '{default: 0};
        wb_reg_value = '{default: 0};
    endfunction

    task setPC(
        logic [35:0] PC
    );

        this.PC = PC;

    endtask

    task setInst(
        logic [31:0] inst
    );

        this.inst = inst;

    endtask

    task setRD(
        logic [4:0] rD
    );

        this.rD = rD;

    endtask

    task setRD_value(
        logic [35:0] rD_value
    );

        this.rD_value = rD_value;

    endtask

    task setImm(
        logic [24:0] Imm
    );

        this.Imm = Imm;

    endtask

    
    task setRA(
        logic [4:0] rA
    );

        this.rA = rA;
    endtask

    task setRB(
        logic [4:0] rB
    );

        this.rB = rB;
    endtask

    task setRA_value(
        logic [35:0] rA_value
    );

        this.rA_value = rA_value;

    endtask

     task setRB_value(
        logic [35:0] rB_value
    );

        this.rB_value = rB_value;

    endtask

    
    task setImm_used(
        logic [35:0] Imm_used
    );

        this.Imm_used = Imm_used;

    endtask

    
    task setWb_reg(
        logic [4:0] wb_reg
    );

        this.wb_reg = wb_reg;
    endtask

    task setWb_reg_value(
        logic [35:0] wb_reg_value
    );

        this.wb_reg_value = wb_reg_value;

    endtask

endclass