class alu_scoreboard;
  bit cmp,dut;
  int i;
  int MATCH,MISMATCH;

  base_transaction dut_trans;
  base_transaction ref_trans;
  
  mailbox #(base_transaction) mbx_ref_scr;
  mailbox #(base_transaction) mbx_mon_scr;

  function new(mailbox #(base_transaction) mbx_ref_scr,mailbox #(base_transaction) mbx_mon_scr);
    this.mbx_ref_scr = mbx_ref_scr;
    this.mbx_mon_scr = mbx_mon_scr;
    dut_trans = new();
    ref_trans = new();
  endfunction

  task start(int no);
    repeat(no)
    begin
      fork
        begin:DUT_OUTPUT
          dut = 0;
          mbx_mon_scr.get(dut_trans);
          dut = 1;
          $display("%0t | SCO: RECIEVED DUT OUTPUT %0b",($time/10)-2,cmp);
        end:DUT_OUTPUT
        begin:REF_OUTPUT
          cmp = 0;
          mbx_ref_scr.get(ref_trans);
          cmp = 1;
          $display("%0t | SCO: RECIEVED REF OUTPUT,%0b",($time/10)-2,cmp);
        end:REF_OUTPUT
        
        //begin
          //wait(cmp);
          //i++;
          //compare();
        //end
      join_any
      if(cmp)
      begin
        wait(dut);
        i++;
        $display("SCO: COMPLETED %0d ITERATIONS OF OUTPUT",i);
        compare();
      end
      else if(dut)
      begin
        #2;
        if(cmp)
        begin
          i++;
          $display("SCO: COMPLETED %0d ITERATIONS OF OUTPUT",i);
          compare();
        end
      end
    end
  endtask

  task compare();
    if($isunknown(ref_trans.res))
    begin
      if(dut_trans.err === ref_trans.err && dut_trans.oflow === ref_trans.oflow && dut_trans.cout === ref_trans.cout && dut_trans.g === ref_trans.g && dut_trans.l === ref_trans.l && dut_trans.e === ref_trans.e) begin
        MATCH++;
        $display("%0t | CORRECT EXECUTION, OUTPUT MATCHES\n\t RECIEVED\tEXPECTED\nRES(d):  %0d\t\t%0d\nRES(b):  %b\t%b\nOFLOW:    %1b\t\t%1b\nCOUT:\t    %1b\t\t%1b\nG: \t    %1b\t\t%1b\nL: \t    %1b\t\t%1b\nE: %1b    \t\t%1b\nERR: \t    %0b\t\t%0b",($time/10)-2,dut_trans.res,ref_trans.res,dut_trans.res,ref_trans.res,dut_trans.oflow,ref_trans.oflow,dut_trans.cout,ref_trans.cout,dut_trans.g,ref_trans.g,dut_trans.l,ref_trans.l,dut_trans.e,ref_trans.e,dut_trans.err,ref_trans.err);
      end
      else begin
        MISMATCH++;
        $display("%0t | INCORRECT EXECUTION, OUTPUT DOES NOT MATCH\n\t\t\t\t\t\t\tRECIEVED\tEXPECTED\n\t\t\t\t\t\tRES(d): %0d\t\t%0d\n\t\t\t\t\t\tRES(b): %b\t%b\n\t\t\t\t\t\tOFLOW:\t%1b\t\t%1b\n\t\t\t\t\t\tCOUT: \t%1b\t\t%1b\n\t\t\t\t\t\tG: \t%1b\t\t%1b\n\t\t\t\t\t\tL:\t%1b\t\t%1b\n\t\t\t\t\t\tE: \t%1b\t\t%1b\t\n\t\t\t\t\t\tERR: \t%0b\t\t%0b",($time/10)-2,dut_trans.res,ref_trans.res,dut_trans.res,ref_trans.res,dut_trans.oflow,ref_trans.oflow,dut_trans.cout,ref_trans.cout,dut_trans.g,ref_trans.g,dut_trans.l,ref_trans.l,dut_trans.e,ref_trans.e,dut_trans.err,ref_trans.err);
      end
    end
    else
    if(dut_trans.err === ref_trans.err && dut_trans.res === ref_trans.res && dut_trans.oflow === ref_trans.oflow && dut_trans.cout === ref_trans.cout && dut_trans.g === ref_trans.g && dut_trans.l === ref_trans.l && dut_trans.e === ref_trans.e) begin
      MATCH++;
      $display("%0t | CORRECT EXECUTION, OUTPUT MATCHES\n\t RECIEVED\tEXPECTED\nRES(d):  %0d\t\t%0d\nRES(b):  %b\t%b\nOFLOW:    %1b\t\t%1b\nCOUT:\t    %1b\t\t%1b\nG: \t    %1b\t\t%1b\nL: \t    %1b\t\t%1b\nE: \t    %1b\t\t%1b\nERR: \t    %0b\t\t%0b",($time/10)-2,dut_trans.res,ref_trans.res,dut_trans.res,ref_trans.res,dut_trans.oflow,ref_trans.oflow,dut_trans.cout,ref_trans.cout,dut_trans.g,ref_trans.g,dut_trans.l,ref_trans.l,dut_trans.e,ref_trans.e,dut_trans.err,ref_trans.err);
    end
    else begin
      MISMATCH++;
      $display("%0t | INCORRECT EXECUTION, OUTPUT DOES NOT MATCH\n\t\t\t\t\t\t\tRECIEVED\tEXPECTED\n\t\t\t\t\t\tRES(d): %0d\t\t%0d\n\t\t\t\t\t\tRES(b):%b\t%b\n\t\t\t\t\t\tOFLOW: \t%1b\t\t%1b\n\t\t\t\t\t\tCOUT: \t%1b\t\t%1b\n\t\t\t\t\t\tG: \t%1b\t\t%1b\n\t\t\t\t\t\tL: \t%1b\t\t%1b\n\t\t\t\t\t\tE: \t%1b\t\t%1b\t\n\t\t\t\t\t\tERR: \t%0b\t\t%0b",($time/10)-2,dut_trans.res,ref_trans.res,dut_trans.res,ref_trans.res,dut_trans.oflow,ref_trans.oflow,dut_trans.cout,ref_trans.cout,dut_trans.g,ref_trans.g,dut_trans.l,ref_trans.l,dut_trans.e,ref_trans.e,dut_trans.err,ref_trans.err);
    end
    $display("---------------------------------------------------------------------------------------------------------------------------------------------------");
  endtask
endclass
