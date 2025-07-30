class alu_driver;

  int count3;
  int count;
  bit flag;
  int i;
  bit[`CWIDTH:0] previ;
  bit valid_a,valid_b;
  int unsigned total = {`WIDTH{1'b1}};
  int unsigned total_high = {`WIDTH + 1{1'b1}};

  base_transaction trans;
  
  mailbox #(base_transaction) mbx_gen_drv;
  mailbox #(base_transaction) mbx_drv_ref;

  virtual alu_intf.DRV vif;

  covergroup alu_input_cg @(vif.drv_cb);
    RST_cp: coverpoint trans.rst;
    CE_cp: coverpoint trans.ce;
    MODE_cp: coverpoint trans.mode iff(!trans.rst && trans.ce);
    CIN_cp: coverpoint trans.cin iff(!trans.rst && trans.ce && (trans.mode && (trans.cmd == 2 || trans.cmd == 3)));
    INP_VALID_cp: coverpoint trans.inp_valid iff(!trans.rst || trans.ce)
                  {
                    bins valid_3 = {3};
                    bins valid_2 = {2};
                    bins valid_1 = {1};
                    bins failed = {0};
                  }
    CMD_cp: coverpoint trans.cmd iff(!trans.rst || trans.ce)
            {
              bins arith[] = {[0:10]} iff (trans.mode == 1'b1);
              bins logical[] = {[0:13]} iff (trans.mode == 1'b0);
              bins out_of_range_arith = {[11:15]} iff (trans.mode == 1'b1);
              bins out_of_range_logical = {14,15} iff (trans.mode == 1'b0);
            }
    ADD_cp: coverpoint (int'(trans.opa) + int'(trans.opb)) iff(!trans.rst && trans.ce && (trans.mode && (trans.cmd == 0)))
             {
               bins in_range = {[0:total]};
               bins cout_trig = {[total + 1: total_high]};
             }
    ADD_CIN_cp: coverpoint (int'(trans.opa) + int'(trans.opb) + trans.cin) iff(!trans.rst && trans.ce && (trans.mode && (trans.cmd == 2)))
             {
               bins in_range = {[0:total]};
               bins cout_trig = {[total + 1 : total_high]};
             }
    SUB_cp: coverpoint trans.opa < trans.opb iff(!trans.rst && trans.ce && (trans.mode && (trans.cmd == 1 || trans.cmd == 3)))
             {
               bins normal = {0};
               bins oflow_trig = {1};
             }
    DECA_cp: coverpoint trans.opa == 0 iff(!trans.rst && trans.ce && (trans.mode && trans.cmd == 5))
             {
               bins normal = {0};
               bins corner = {1};
             }
    DECB_cp: coverpoint trans.opb == 0 iff(!trans.rst && trans.ce && (trans.mode && trans.cmd == 7))
             {
               bins normal = {0};
               bins corner = {1};
             }
    INCA_cp: coverpoint trans.opa == total iff(!trans.rst && trans.ce && (trans.mode && trans.cmd == 4))
             {
               bins normal = {0};
               bins corner = {1};
             }
    INCB_cp: coverpoint trans.opb == total iff(!trans.rst && trans.ce && (trans.mode && trans.cmd == 6))
             {
               bins normal = {0};
               bins corner = {1};
             }
    CMP_cp: coverpoint trans.opa iff(!trans.rst && trans.ce && (trans.mode && trans.cmd == 8))
             {
               bins greater = {[0:total]} iff (trans.opa > trans.opb);
               bins lesser = {[0:total]}  iff (trans.opa < trans.opb);
               bins equal = {[0:total]} iff (trans.opa == trans.opb);
             }
    SHA_cp: coverpoint (int'(trans.opa) << 1) iff(!trans.rst && trans.ce && (!trans.mode && trans.cmd == 9))
             {
               wildcard bins normal = {8'b0xxxxxxx};
               wildcard bins corner = {8'b1xxxxxxx};
             }
    SHB_cp: coverpoint (int'(trans.opb) << 1) iff(!trans.rst && trans.ce && (!trans.mode && trans.cmd == 11))
             {
               wildcard bins normal = {8'b0xxxxxxx};
               wildcard bins corner = {8'b1xxxxxxx};
             }
    MULT_cp: coverpoint trans.opa iff(!trans.rst && trans.ce && (trans.mode && trans.cmd == 10))
             {
               bins normal = {[0:127],[129:255]};
               bins corner = {255};
             }
    RO_cp: coverpoint trans.opb iff(!trans.rst && trans.ce && (!trans.mode && (trans.cmd == 12 || trans.cmd == 13)))
             {
               wildcard bins normal = {8'b0000xxxx};
               wildcard bins err_trig = {[4'b1000:$]};
             }
    OPA: coverpoint trans.opa
             {
               ignore_bins ign[] = {[0:total]};
             }
    OPB: coverpoint trans.opb
             {
               ignore_bins ign[] = {[0:total]};
             }
    ADD_MULT_cross: cross OPA,OPB iff(!trans.rst && trans.ce && (trans.mode && trans.cmd == 9))
             {
               bins all_val = binsof(OPA) || binsof(OPB);
               bins corner = binsof(OPA) intersect {total} || binsof(OPB) intersect {total};
             }
    mode_0_cp: coverpoint trans.inp_valid iff(!trans.rst && trans.ce && !(trans.mode))
             {
               bins valid_logical_3 = {2'b11} iff (trans.cmd inside {[0:5],12,13});
               bins valid_logical_2 = {2'b10} iff (trans.cmd inside {7,10,11});
               bins valid_logical_1 = {2'b01} iff (trans.cmd inside {6,8,9});
               bins invalid_logical_2 = {2'b10} iff (trans.cmd inside {[0:5],6,8,9,12,13});
               bins invalid_logical_1 = {2'b01} iff (trans.cmd inside {[0:5],7,10,11,12,13});
             }
    mode_1_cp: coverpoint trans.inp_valid iff(!trans.rst && trans.ce && (trans.mode))
             {
               bins valid_arith_3 = {2'b11} iff (trans.cmd inside {[0:3],[8:10]});
               bins valid_arith_2 = {2'b10} iff (trans.cmd inside {6,7});
               bins valid_arith_1 = {2'b01} iff (trans.cmd inside {4,5});
               bins invalid_arith_2 = {2'b10} iff (trans.cmd inside {[0:5],8,9,10});
               bins invalid_arith_1 = {2'b01} iff (trans.cmd inside {[0:3],[6:10]});
             }
  endgroup

  function new(mailbox #(base_transaction) mbx_gen_drv,mailbox #(base_transaction) mbx_drv_ref,virtual alu_intf.DRV vif);
    this.mbx_gen_drv = mbx_gen_drv;
    this.mbx_drv_ref = mbx_drv_ref;
    this.vif = vif;
    alu_input_cg = new();
    flag = 0;
  endfunction

  task start(int no);
    alu_input_cg.start;
    repeat(no)
    begin
      trans = new();
      mbx_gen_drv.get(trans);
      @(vif.drv_cb);
      i = i + 1;
      if(trans.rst == 1)
      begin
        vif.drv_cb.rst <= 1;
        vif.drv_cb.inp_valid<= 2'b00;
        vif.drv_cb.mode<= 0;
        vif.drv_cb.cmd<= 0;
        vif.drv_cb.ce<= 1;
        vif.drv_cb.opa<= 0;
        vif.drv_cb.opb<= 0;
        vif.drv_cb.cin<= 0;
        repeat(2)@(vif.drv_cb);
      end
      else
      begin
        vif.drv_cb.rst <= 0;
        vif.drv_cb.inp_valid<= trans.inp_valid;
        vif.drv_cb.mode<= trans.mode;
        vif.drv_cb.cmd<= trans.cmd;
        vif.drv_cb.ce <= trans.ce;
        vif.drv_cb.opa <= trans.opa;
        vif.drv_cb.opb <= trans.opb;
        vif.drv_cb.cin <= trans.cin;
        if(trans.ce) begin
          flag = (trans.mode && (trans.cmd == ADD || trans.cmd == SUB || trans.cmd == ADD_CIN || trans.cmd == SUB_CIN || trans.cmd == CMP || trans.cmd == ADD_MUL || trans.cmd == SH_MUL)) || (!trans.mode && (trans.cmd == AND ||  trans.cmd == NAND ||  trans.cmd == OR ||  trans.cmd == NOR ||  trans.cmd == XOR ||  trans.cmd == XNOR ||  trans.cmd == ROL_A_B ||  trans.cmd == ROR_A_B));
          valid_a = flag && trans.inp_valid[0] ? 1'b1 : valid_a;
          valid_b = flag && trans.inp_valid[1] ? 1'b1 : valid_b;
          count3 = (previ == {trans.mode,trans.cmd}) ? count3 : 0;
        $display("\n%0t | DRV: FLAG = %0b VALID_A = %0b VALID_B = %0b",$time/10 - 1,flag,valid_a,valid_b);
        if(flag && count3 > 0) begin
          count3++;
          if(count3 >= 4)
            count3 = 0;
          repeat(2)@(vif.drv_cb);
          $display(" %0t | DRV: ENTERED MULTIPLICATION COUNT = %0d",$time/10 - 1,count3);
        end
        else if(flag == 0)
        begin
          $display("%0t | DRV: FLAG ZERO GAVE ONE DELAY",$time/10 - 1);
          count = 0;
          repeat(1)@(vif.drv_cb);
        end
        else if (flag && (valid_a && valid_b))begin
          flag = 0;
          valid_a = 0;
          valid_b = 0;
          if(trans.mode && (trans.cmd == ADD_MUL|| trans.cmd == SH_MUL))
          begin
            count3 = 1;
            repeat(1)@(vif.drv_cb);
          end
          repeat(1)@(vif.drv_cb);
          count = 0;
          $display("%0t | DRV: BOTH VALID FLAG",$time/10 - 1);
        end
        else if(count < 16 && flag)
        begin
          count++;
          if(count == 0)
            repeat(1)@(vif.drv_cb);
          $display("%0t | DRV: COUNTING = %0d",$time/10 - 1,count);
        end
        else if(count >= 16) begin
          valid_a = 0;
          valid_b = 0;
          count = 0;
          flag = 0;
          $display("%0t | DRV: COUNT EXCEEDED",$time/10 - 1);
        end
        previ = {trans.mode,trans.cmd};
        end
        else
          repeat(1)@(posedge vif.drv_cb);
      end
      mbx_drv_ref.put(trans);
      if(trans.rst || !trans.ce)
        flag = 0;
      count = trans.rst ? 0 : count;
      $display("----------------------%0d---------------------",i);
      $display("%0t | DRV: DRIVEN THE VALUES TO DUT",$time/10 - 1);
      if(trans.mode)
        $display("RST = %0b CE = %1b\nINP_VALID = %2b MODE = %1b CMD = %0s\nOPA = %0d OPB = %0d CIN = %0b",trans.rst,trans.ce,trans.inp_valid,trans.mode,arith'(trans.cmd),trans.opa,trans.opb,trans.cin);
      else
      $display("RST = %0b CE = %1b\nINP_VALID = %2b MODE = %1b CMD = %0s\nOPA = %b\nOPB = %b",trans.rst,trans.ce,trans.inp_valid,trans.mode,logical'(trans.cmd),trans.opa,trans.opb);
    $display("DRV: COMPLETED %0d ITERATIONS",i);
    end
    alu_input_cg.stop;
  endtask
endclass

class driv_same extends alu_driver;
  function new(mailbox #(base_transaction) mbx_gen_drv,mailbox #(base_transaction) mbx_drv_ref,virtual alu_intf.DRV vif);
    super.new(mbx_gen_drv,mbx_drv_ref,vif);
  endfunction
  task start(int no);
    repeat(1)@(vif.drv_cb);
    repeat(no)
    begin
      trans = new();
      @(vif.drv_cb);
      mbx_gen_drv.get(trans);
      if(trans.rst == 1)
      begin
        vif.drv_cb.rst <= 1;
        vif.drv_cb.inp_valid<= 2'b00;
        vif.drv_cb.mode<= 0;
        vif.drv_cb.cmd<= 0;
        vif.drv_cb.ce<= 1;
        vif.drv_cb.opa<= 0;
        vif.drv_cb.opb<= 0;
        vif.drv_cb.cin<= 0;
      end
      else
      begin
        vif.drv_cb.rst <= 0;
        vif.drv_cb.inp_valid<= trans.inp_valid;
        vif.drv_cb.mode<= trans.mode;
        vif.drv_cb.cmd<= trans.cmd;
        vif.drv_cb.ce <= trans.ce;
        vif.drv_cb.opa <= trans.opa;
        vif.drv_cb.opb <= trans.opb;
        vif.drv_cb.cin <= trans.cin;
      end
      repeat(1)@(vif.drv_cb);
      if(i == 0)
        repeat(1)@(vif.drv_cb);
      mbx_drv_ref.put(trans);
      i = i + 1;
      $display("----------------------%0d---------------------\nDRV: DRIVEN THE VALUES TO DUT",i);
      if(trans.mode)
        $display("RST = %0b CE = %1b\nINP_VALID = %2b MODE = %1b CMD = %0s\nOPA = %0d OPB = %0d CIN = %0b",trans.rst,trans.ce,trans.inp_valid,trans.mode,arith'(trans.cmd),trans.opa,trans.opb,trans.cin);
      else
      $display("RST = %0b CE = %1b\nINP_VALID = %2b MODE = %1b CMD = %0s\nOPA = %b\nOPB = %b",trans.rst,trans.ce,trans.inp_valid,trans.mode,logical'(trans.cmd),trans.opa,trans.opb);
    repeat(3)@(vif.drv_cb);
    mbx_drv_ref.put(trans);
    $display("RAN IT FOR ONE MORE CYCLE");
    end
    $display("DRV: COMPLETED %0d ITERATIONS",i);
  endtask
endclass
