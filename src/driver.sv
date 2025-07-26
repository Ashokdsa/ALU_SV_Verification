class alu_driver;

  int count;
  int i;

  base_transaction trans;
  
  mailbox #(base_transaction) mbx_gen_drv;
  mailbox #(base_transaction) mbx_drv_ref;

  virtual alu_intf.DRV vif;

  function new(mailbox #(base_transaction) mbx_gen_drv,mailbox #(base_transaction) mbx_drv_ref,virtual alu_intf.DRV vif);
    this.mbx_gen_drv = mbx_gen_drv;
    this.mbx_drv_ref = mbx_drv_ref;
    this.vif = vif;
  endfunction

  task start(int no);
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
      repeat(2)@(vif.drv_cb);
      mbx_drv_ref.put(trans);
      i = i + 1;
      $display("----------------------%0d---------------------\nDRV: DRIVEN THE VALUES TO DUT",i);
      if(trans.mode)
        $display("RST = %0b CE = %1b\nINP_VALID = %2b MODE = %1b CMD = %0s\nOPA = %0d OPB = %0d CIN = %0b",trans.rst,trans.ce,trans.inp_valid,trans.mode,arith'(trans.cmd),trans.opa,trans.opb,trans.cin);
      else
      $display("RST = %0b CE = %1b\nINP_VALID = %2b MODE = %1b CMD = %0s\nOPA = %b\nOPB = %b",trans.rst,trans.ce,trans.inp_valid,trans.mode,logical'(trans.cmd),trans.opa,trans.opb);
    end
    $display("DRV: COMPLETED %0d ITERATIONS",i);
  endtask
endclass
