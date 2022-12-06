module tb_hazard_detection_unit();
//
// This module essentially creates a very simplified version of our processor
// designed to test the hazard detection unit. The only function of this dummy
// processor is to add values stored in registers together, or to random immediates, or load random immediates.
// It uses both the vector and scalar pipelines with delays and stalling similarly to our design.
// There is also a single cycle version modeled. The test is run
// by assigning random input registers to the simple addition, then running the processor for a few
// thousand cycles, then inserting a bunch of nops, then testing the register file state of the single cycle
// version against that of the multi cycle version. Additionally, all stores are checked to have the right value,
// which is always a result of the same addition from different registers.
//

// following are inputs to hazard detection unit
logic vector_wr_en, register_wr_en, mem_stall_in, clk, rst;
logic [5:0] vector_read_register_one, vector_read_register_two;
logic [5:0] scalar_read_register_one, scalar_read_register_two;
logic [4:0] write_register;
logic [1:0] op_type;


logic stall_fetch, stall_decode, stall_execute, stall_mem;
logic vector_wb_sel, register_wb_sel, vector_wb_sel_reg, register_wb_sel_reg;
logic [1:0] ex_to_ex, mem_to_mem, mem_to_ex;
logic buffer_register_sel, buffer_vector_sel, buffer_register, buffer_vector;
logic buffer_register_sel_reg, buffer_vector_sel_reg, buffer_register_reg, buffer_vector_reg;

// following are outputs of the wb stage.
logic [4:0] vector_wbr_out, register_wbr_out;
logic [3:0] vector_we;
logic register_we;
logic [127:0] vector_data;
logic [35:0] register_data;

// sc stands for single cycle
// vp stands for vector pipeline
// sp stands for scalar pipeline

// these model the vector register file for both the single cycle an dpipelined design
logic [31:0] [127:0] vector_register_model_sc;
logic [31:0] [127:0] vector_register_model;

// vector data is the wb value of a given instruction
logic [9:0] [127:0] vector_data_vp;
logic [2:0] [127:0] vector_data_sp;

// vector_data_func is an addition of all used registers in an instruction
logic [127:0] vector_data_func;
logic [127:0] vector_data_func_sc;

// random vector data is used as an immediate if vector read register 2 is not used
logic [127:0] random_vector_data;

// models the 36 bit register files for single cycle and pipelined case
logic [31:0] [35:0] register_model_sc;
logic [31:0] [35:0] register_model;

// writeback data of a given pipeline
logic [9:0] [35:0] register_data_vp;
logic [1:0] [35:0] register_data_sp;

// register data func is addition of ued registers and sometimes an immediate
logic [35:0] register_data_func;
logic [35:0] register_data_func_sc;

// immediate that is used if vector_read_register two is unused
logic [35:0] random_register_data;

// stores the last three scalar and vector store values
// for purposes of this simulation all stores store both vector and scalar values
logic [2:0] [127:0] vector_store_sc;
logic [2:0] [35:0] scalar_store_sc;

// holds important metadata about pipelined instructions
logic [9:0] [1:0] op_types_vp;
logic [1:0] [1:0] op_types_sp;
logic [9:0] [1:0] wr_ens_vp;
logic [2:0] [1:0] wr_ens_sp;
logic [9:0] [4:0] wr_regs_vp;
logic [2:0] [4:0] wr_regs_sp;
logic [1:0] [35:0] scalar_op1;
logic [1:0] [35:0] scalar_op2;

// pipelined forward values
logic [1:0] ex_to_ex_sp;
logic [1:0] mem_to_ex_sp;
logic [1:0] [1:0] mem_to_mem_sp;

// stall rand is used to randomize the mem_stall output
logic [2:0] stall_rand;

// rand selector is used to randomly select which read/write register should be used in high_dependency mode
// stall_freq = 2'b00 - no mem_stalls will ever occur
// stall_freq = 2'b01 - mem_stall will be asserted 12.5% of the time if the current instruction in mem stage
// is a memory instruction
// stall_freq = 2'b10 - mem_stall will be asserted 50% of the time if the current instruction in mem stage
// is a memory instruction
// stall_freq = 2'b11 - mem_stall will be asserted 87.5% of the time if the current instruction in mem stage
// is a memory instruction
logic [1:0] stall_freq, rand_selector;

// when high_dependencies = 1 50% of all read/write registers will be r0/v0 25% will be r1/v1 and 25% will be randomly
// selected randomly with equal probability among all possible values 0-31 
// this should allow test cases with large numbers of dependencies
logic high_dependencies;

// when disable_instructions is high nops are inserted into the dummy test processor
logic disable_instructions;

// failed = 1 if at least one test has been failed by the module
// if begin_store_checking is 0 stores will not be checked.
logic failed, begin_store_checking;

// store_count_sc counts single cycle stores so far, store_count counts pipelined stores so far
int store_count_sc;
int store_count;

// forwarded values for register model
logic [35:0] scalar_read_one_fwded, scalar_read_two_fwded;
logic [127:0] vector_read_one_fwded, vector_read_two_fwded;

hazard_detection_unit dut(.*);

// declare wb module, using its capability to buffer vector results
wb writeback(.scalar_pipeline_wb(register_data_sp[1]), .vector_pipeline_wb(register_data_vp[9]), .pc({36{1'b0}}), .scalar_pipeline_vwb(vector_data_sp[2]), .vector_pipeline_vwb(vector_data_vp[9]),
             .scalar_pipeline_we(wr_ens_sp[2][0]), .vector_pipeline_we(wr_ens_vp[9][0]), .pc_sel(1'b0), .scalar_pipeline_mask(4'hF), .vector_pipeline_mask(4'hF),
             .register_wb_sel(register_wb_sel_reg), .vector_wb_sel(vector_wb_sel_reg), .buffer_register_sel(buffer_register_sel_reg), .buffer_vector_sel(buffer_vector_sel_reg),
             .buffer_register(buffer_register_reg), .buffer_vector(buffer_vector_reg),
             .vector_we(vector_we), .register_we(register_we), .vector_data(vector_data), .register_data(register_data), .clk(clk), .rst(rst), .scalar_pipeline_wbr(wr_regs_sp[2]), 
             .vector_pipeline_wbr(wr_regs_vp[9]), .vector_wbr(vector_wbr_out), .register_wbr(register_wbr_out));


// forward reads from register file in pipelined model
assign scalar_read_one_fwded = (scalar_read_register_one[4:0]===register_wbr_out) ? register_data : register_model[scalar_read_register_one[4:0]];
assign scalar_read_two_fwded = (scalar_read_register_two[4:0]===register_wbr_out) ? register_data : register_model[scalar_read_register_two[4:0]];
assign vector_read_one_fwded = (vector_read_register_one[4:0]===vector_wbr_out) ? vector_data : vector_register_model[vector_read_register_one[4:0]];
assign vector_read_two_fwded = (vector_read_register_two[4:0]===vector_wbr_out) ? vector_data : vector_register_model[vector_read_register_two[4:0]];

// following 4 assign statements just add in use registers 
assign register_data_func = ((scalar_read_register_one[5]) ? scalar_read_one_fwded : 0) +
                            ((scalar_read_register_two[5]) ? scalar_read_two_fwded : random_register_data);

assign register_data_func_sc = ((scalar_read_register_one[5]) ? register_model_sc[scalar_read_register_one[4:0]] : 0) +
                            ((scalar_read_register_two[5]) ? register_model_sc[scalar_read_register_two[4:0]] : random_register_data); 

assign vector_data_func = ((vector_read_register_one[5]) ? vector_read_one_fwded : 0) +
                          ((vector_read_register_two[5]) ? vector_read_two_fwded : random_vector_data) +
                          ((scalar_read_register_one[5]) ? {{92{scalar_read_one_fwded[35]}}, scalar_read_one_fwded} : 0) +
                          ((scalar_read_register_two[5]) ? {{92{scalar_read_two_fwded[35]}}, scalar_read_two_fwded} : 
                          {{92{random_register_data[35]}}, random_register_data});

assign vector_data_func_sc = ((vector_read_register_one[5]) ? vector_register_model_sc[vector_read_register_one[4:0]] : 0) +
                          ((vector_read_register_two[5]) ? vector_register_model_sc[vector_read_register_two[4:0]] : random_vector_data) +
                          ((scalar_read_register_one[5]) ? {{92{register_model_sc[scalar_read_register_one[4:0]][35]}}, 
                          register_model_sc[scalar_read_register_one[4:0]]} : 0) +
                          ((scalar_read_register_two[5]) ? {{92{register_model_sc[scalar_read_register_two[4:0]][35]}}, 
                           register_model_sc[scalar_read_register_two[4:0]]} : 
                          {{92{random_register_data[35]}}, random_register_data});


initial begin
  
  // initial signal values
  for(int i = 0; i < 32; i++) begin
    register_model_sc[i] = 0;
    register_model[i] = 0;
    vector_register_model_sc[i] = 0;
    vector_register_model[i] = 0;
  end
  op_type = 0;
  vector_read_register_one = 0;
  vector_read_register_two = 0;
  scalar_read_register_one = 0;
  scalar_read_register_two = 0;
  write_register = 0;
  begin_store_checking = 0;
  failed = 0;
  mem_stall_in = 0;
  clk = 0;
  rst = 1;
  disable_instructions = 1;
  high_dependencies = 0;
  stall_freq = 0;
  @(posedge clk);
  rst = 0;
  @(posedge clk);
  @(posedge clk);
  for(int j = 0; j < 8; j++) begin
   // will run test 8 times one for each combonation of high_dependencies and stall_freq
    if(j==0) begin
      high_dependencies = 0;
      stall_freq = 2'b00;
    end else if(j==1) begin
      high_dependencies = 0;
      stall_freq = 2'b01;
    end else if(j==2) begin
      high_dependencies = 0;
      stall_freq = 2'b10;
    end else if(j==3) begin
      high_dependencies = 0;
      stall_freq = 2'b11;
    end else if(j==4) begin
      high_dependencies = 1;
      stall_freq = 2'b00;
    end else if(j==5) begin
      high_dependencies = 1;
      stall_freq = 2'b01;
    end else if(j==6) begin
      high_dependencies = 1;
      stall_freq = 2'b10;
    end else if(j==7) begin
      high_dependencies = 1;
      stall_freq = 2'b11;
    end
    
    // will run 100 times in each of the 8 combonations
    for(int i = 0; i < 100; i++) begin
      disable_instructions = 0;
      begin_store_checking = 0;
      
      // I know there is a way to do this wihtout the for loop but i forgot it
      for(int k = 0; k < 1000; k++)
        @(posedge clk);

      // stop the processor
      disable_instructions = 1;

      // allow remaining instructions to writeback
      for(int k = 0; k < 15; k++)
        @(posedge clk);
      
      // once we have waited for all instructions to writeback check state of pipelined model versus
      // single cycle model, if any registers are off a cascading error must have occurred at some point.
      for(int k = 0; k < 32; k++) begin
        if(!(vector_register_model_sc[k]===vector_register_model[k])) begin
          failed = 1;
          $display("error single cycle and simplified pipelined processor vector register files do not match!!");
        end else if (!(register_model_sc[k]===register_model[k])) begin
          failed = 1;
          $display("error single cycle and simplified pipelined processor register files do not match!!");
        end
      end
    end
  end

  // if failed == 0 all tests have passed
  if(failed === 0) begin
    $display("YAHOO! ALL TESTS PASSED!");
  end else begin
    $display("One or more errors in code, get debugging!");
  end
  $stop;
end

// vector pipeline simulation
// note since the vector pipeline does not forward or stall we can just calc based on current inputs
always @(posedge clk) begin
  for(int i = 1; i < 10; i++) begin
    vector_data_vp[i] <= vector_data_vp[i-1];
    register_data_vp[i] <= register_data_vp[i-1];
    wr_ens_vp[i] <= wr_ens_vp[i-1];
    op_types_vp[i] <= op_types_vp[i-1];
    wr_regs_vp[i] <= wr_regs_vp[i-1];
  end
  vector_data_vp[0] <= vector_data_func;
  register_data_vp[0] <= register_data_func;
  op_types_vp[0] <= op_type;
  wr_regs_vp[0] <= write_register;
  if(~stall_decode & op_type[1]) begin
     wr_ens_vp[0][0] <= register_wr_en;
     wr_ens_vp[0][1] <= vector_wr_en;
  end
end

// single cycle simplified registers model
always @(posedge clk) begin
  if(~stall_decode) begin
    if(register_wr_en) begin
      register_model_sc[write_register] <= register_data_func_sc;
    end else if (vector_wr_en) begin
      vector_register_model_sc[write_register] <= vector_data_func_sc;
    end
  end
end

// single cycle store modeling
always @(posedge clk) begin
  if(~stall_decode) begin
    if(~register_wr_en & ~vector_wr_en & op_type[0] & ~op_type[1]) begin
      vector_store_sc[store_count_sc % 3] <= vector_data_func_sc;
      scalar_store_sc[store_count_sc % 3] <= register_data_func_sc;
      store_count_sc += 1;
    end
  end
end

// simplified processor store checking
always @(posedge clk) begin
  if(~|wr_ens_sp[1] & op_types_sp[1][0] & ~op_types_sp[1][1]) begin
    if(!(vector_data_sp[1]===vector_store_sc[store_count % 3])) begin
      failed = 1;
      $display("vector data did not match expected during a store.");
    end
    if(!(register_data_sp[0]===scalar_store_sc[store_count % 3])) begin
      failed = 1;
      $display("register data did not match expected during a store.");
    end
    store_count += 1;
  end
end

// assign input values (mostly randomly)
always @(negedge clk) begin
  if(~stall_decode) begin
    if(~disable_instructions) begin
      random_vector_data = $random;
      random_register_data = $random;
      op_type = $random;
      if(~high_dependencies) begin
        vector_read_register_one = $random;
        vector_read_register_two = $random;
        scalar_read_register_one = $random;
        scalar_read_register_two = $random;
        write_register = $random;
      end else begin
        rand_selector = $random;
        if(rand_selector[1])
          vector_read_register_one[4:0] = 5'b00000;
        else if(rand_selector[0])
          vector_read_register_one[4:0] = 5'b00001;
        else
          vector_read_register_one[4:0] = $random;
        vector_read_register_one[5] = $random;

        rand_selector = $random;
        if(rand_selector[1])
          vector_read_register_two[4:0] = 5'b00000;
        else if(rand_selector[0])
          vector_read_register_two[4:0] = 5'b00001;
        else
          vector_read_register_two[4:0] = $random;
        vector_read_register_two[5] = $random;

        rand_selector = $random;
        if(rand_selector[1])
          scalar_read_register_one[4:0] = 5'b00000;
        else if(rand_selector[0])
          scalar_read_register_one[4:0] = 5'b00001;
        else
          scalar_read_register_one[4:0] = $random;
        scalar_read_register_one[5] = $random;

        rand_selector = $random;
        if(rand_selector[1])
          scalar_read_register_two[4:0] = 5'b00000;
        else if(rand_selector[0])
          scalar_read_register_two[4:0] = 5'b00001;
        else
          scalar_read_register_two[4:0] = $random;
        scalar_read_register_two[5] = $random;

        rand_selector = $random;
        if(rand_selector[1])
          write_register = 5'b00000;
        else if(rand_selector[0])
          write_register = 5'b00001;
        else
          write_register = $random;
      end
      if(op_type[0]) begin
        vector_wr_en = $random;
        register_wr_en = $random & ~vector_wr_en;
      end else begin
        vector_wr_en = $random;
        register_wr_en = ~vector_wr_en;
      end
    end else begin
      random_vector_data = 0;
      random_register_data = 0;
      op_type = 0;
      vector_wr_en = 0;
      register_wr_en = 0;
      mem_stall_in = 0;
      vector_read_register_one = 0;
      vector_read_register_two = 0;
      scalar_read_register_one = 0;
      scalar_read_register_two = 0;
      write_register = 0;
    end
  end
end

// model random mem_stall_ins
always @(negedge clk) begin
  if(~|stall_freq) begin
    mem_stall_in = 0; 
  end else if(stall_freq===2'b01) begin
    stall_rand = $random;
    mem_stall_in = (op_types_sp[1]===2'b01) & ~|stall_rand;
  end else if(stall_freq===2'b10) begin
    mem_stall_in = (op_types_sp[1]===2'b01) & $random;
  end else begin
    stall_rand = $random;
    mem_stall_in = (op_types_sp[1]===2'b01) & |stall_rand;
  end
end

// model simplified scalar pipeline
always @(posedge clk) begin
  if(~stall_execute) begin
    op_types_sp[0] <= op_type;
    wr_ens_sp[0] <= (op_type[1]) ? {vector_wr_en, register_wr_en} : 0;
    wr_regs_sp[0] <= write_register;
    scalar_op1[0] <= (scalar_read_register_one[5]) ? register_model[scalar_read_register_one[4:0]] : 0;
    scalar_op2[0] <= (scalar_read_register_two[5]) ? register_model[scalar_read_register_two[4:0]] : random_register_data;
    vector_data_sp[0] <= (vector_wr_en) ? vector_data_func : random_vector_data;
    ex_to_ex_sp[0] <= ex_to_ex;
    mem_to_ex_sp[0] <= mem_to_ex;
    mem_to_mem_sp[0] <= mem_to_mem;
  end
  if(~stall_mem) begin
    op_types_sp[1] <= op_types_sp[0];
    wr_ens_sp[1] <= wr_ens_sp[0];
    wr_regs_sp[1] <= wr_regs_sp[0];
    scalar_op1[1] <= scalar_op1[0];
    scalar_op2[1] <= scalar_op2[0];
    vector_data_sp[1] <= vector_data_sp[0];
    register_data_sp[0] <= ((mem_to_ex_sp[0]) ? register_data_sp[1] : ((ex_to_ex_sp[0]) ? register_data_sp[0] : scalar_op1[0]))
                         + ((mem_to_ex_sp[1]) ? register_data_sp[1] : ((ex_to_ex_sp[1]) ? register_data_sp[0] : scalar_op2[0]));
  end
    register_data_sp[1] <= (~op_types_sp[1][0]) ? register_data_sp[0] : (((mem_to_mem_sp[1][0]) ? register_data_sp[1] : scalar_op1[1]) +
                           ((mem_to_mem_sp[1][1]) ? register_data_sp[1] : scalar_op2[1]));
    vector_data_sp[2] <= vector_data_sp[1];
    wr_regs_sp[2] <= wr_regs_sp[1];
  if(stall_mem)
    wr_ens_sp[2] <= 0;
  else
    wr_ens_sp[2] <= wr_ens_sp[1];
end

// does writes to simulated pipeline vector and scalar register file models
always @(posedge clk) begin
  if(vector_we) begin
    vector_register_model[vector_wbr_out] <= vector_data;
  end
  if(register_we) begin
    register_model[register_wbr_out] <= register_data;
  end
end

// registered outputs of hazard detection unit
always_ff @(posedge clk) begin
  if(rst) begin
    vector_wb_sel_reg <= 0;
    register_wb_sel_reg <= 0;
    buffer_register_sel_reg <= 0;
    buffer_vector_sel_reg <= 0;
    buffer_register_reg <= 0;
    buffer_vector_reg <= 0;
  end else begin
    vector_wb_sel_reg <= vector_wb_sel;
    register_wb_sel_reg <= register_wb_sel;
    buffer_register_sel_reg <= buffer_register_sel;
    buffer_vector_sel_reg <= buffer_vector_sel;
    buffer_register_reg <= buffer_register;
    buffer_vector_reg <= buffer_vector;
  end
end

// clk
always begin
  #5 clk = ~clk;
end

endmodule
