class alu_monitor;

  int i;

  base_transaction trans;
  
  mailbox #(base_transaction) mbx_mon_scr;

  virtual alu_intf.MON vif;

  function new(mailbox #(base_transaction) mbx_mon_scr,virtual alu_intf.MON vif);
  this.mbx_mon_scr = mbx_mon_scr;
  this.vif = vif;
  endfunction

  task start(int no);
    repeat(2)@(vif.mon_cb);
    repeat(no)
    begin
      trans = new();
      repeat(2)@(vif.mon_cb);
      trans.err = vif.mon_cb.err;
      trans.res = vif.mon_cb.res;
      trans.oflow = vif.mon_cb.oflow;
      trans.cout = vif.mon_cb.cout;
      trans.g = vif.mon_cb.g;
      trans.l = vif.mon_cb.g;
      trans.e = vif.mon_cb.g;
      mbx_mon_scr.put(trans);
      i = i + 1;
      $display("MON: RECIEVED %0d ITEM",i);
      $display("RESULT = %0d\nOFLOW = %1b COUT = %1b G = %1b L = %1b E = %1b",trans.res,trans.oflow,trans.cout,trans.g,trans.l,trans.e);
      @(vif.mon_cb);
    end
  endtask
endclass
