class alu_environment;
  alu_generator gen;
  alu_driver drv;
  alu_monitor mon;
  alu_scoreboard scr;
  alu_reference refe;

  mailbox #(base_transaction) mbx_gen_drv;
  mailbox #(base_transaction) mbx_drv_ref;
  mailbox #(base_transaction) mbx_mon_scr;
  mailbox #(base_transaction) mbx_ref_scr;

  virtual alu_intf vif;

  function new(virtual alu_intf vif);
    this.vif = vif;
  endfunction

  task build();
    mbx_gen_drv = new();
    mbx_drv_ref = new();
    mbx_mon_scr = new();
    mbx_ref_scr = new();

    gen = new(mbx_gen_drv);
    drv = new(mbx_gen_drv,mbx_drv_ref,vif);
    mon = new(mbx_mon_scr,vif);  
    scr = new(mbx_ref_scr,mbx_mon_scr);
    refe = new(mbx_drv_ref,mbx_ref_scr,vif);
  endtask

  task start(int no);
    fork
      gen.start(no);
      drv.start(no);
      mon.start(no);
      scr.start(no);
      refe.start(no);
    join
    $display("%0d MATCHED OUT OF %0d THAT IS %0f PERCENTAGE",scr.MATCH,scr.MATCH + scr.MISMATCH,((real'(scr.MATCH)/real'(scr.MATCH + scr.MISMATCH)))*100);
  endtask
endclass

class same_environment extends alu_environment;
  driv_same drv_same;

  function new(virtual alu_intf vif);
    super.new(vif);
  endfunction

  task build();
    mbx_gen_drv = new();
    mbx_drv_ref = new();
    mbx_mon_scr = new();
    mbx_ref_scr = new();

    gen = new(mbx_gen_drv);
    drv_same = new(mbx_gen_drv,mbx_drv_ref,vif);
    mon = new(mbx_mon_scr,vif);  
    scr = new(mbx_ref_scr,mbx_mon_scr);
    refe = new(mbx_drv_ref,mbx_ref_scr,vif);
  endtask

  task start(int no);
    fork
      gen.start(no);
      drv_same.start(no);
      mon.start(no);
      scr.start(no);
      refe.start(no);
    join
    $display("%0d MATCHED OUT OF %0d THAT IS %0f PERCENTAGE",scr.MATCH,scr.MATCH + scr.MISMATCH,((real'(scr.MATCH)/real'(scr.MATCH + scr.MISMATCH)))*100);
  endtask
endclass
