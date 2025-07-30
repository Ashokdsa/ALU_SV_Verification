class alu_monitor;

  int count;
  bit flag;
  bit valid_a,valid_b;
  int i;
  bit[`CWIDTH:0] previ;
  int count3;
  int unsigned total = {`WIDTH{1'b1}};
  int unsigned total_high = {`WIDTH + 1{1'b1}};

  base_transaction trans;
  
  mailbox #(base_transaction) mbx_mon_scr;

  virtual alu_intf.MON vif;

  covergroup alu_output_cg @(vif.mon_cb);
    RES: coverpoint vif.mon_cb.res iff(!vif.mon_cb.rst && vif.mon_cb.ce)
         {
           bins normal = {[0:total]};
           bins out_of_bounds = {[total+1:$]};
         }
    OFLOW: coverpoint vif.mon_cb.oflow iff(!vif.mon_cb.rst && vif.mon_cb.ce)
         {
           bins zero = {0};
           bins trigger = {1};
         }
    COUT: coverpoint vif.mon_cb.cout iff(!vif.mon_cb.rst && vif.mon_cb.ce)
         {
           bins zero = {0};
           bins trigger = {1};
         }
    G: coverpoint vif.mon_cb.g iff(!vif.mon_cb.rst && vif.mon_cb.ce)
         {
           bins zero = {0};
           bins trigger = {1};
         }
    L: coverpoint vif.mon_cb.l iff(!vif.mon_cb.rst && vif.mon_cb.ce)
         {
           bins zero = {0};
           bins trigger = {1};
         }
    E: coverpoint vif.mon_cb.e iff(!vif.mon_cb.rst && vif.mon_cb.ce)
         {
           bins zero = {0};
           bins trigger = {1};
         }
    ERR: coverpoint vif.mon_cb.err iff(!vif.mon_cb.rst && vif.mon_cb.ce)
         {
           bins zero = {0};
           bins trigger = {1};
         }
  endgroup

  function new(mailbox #(base_transaction) mbx_mon_scr,virtual alu_intf.MON vif);
  this.mbx_mon_scr = mbx_mon_scr;
  this.vif = vif;
  alu_output_cg = new();
  flag = 0;
  endfunction

  task start(int no);
    alu_output_cg.start;
    repeat(1)@(vif.mon_cb);
    repeat(no)
    begin
      trans = new();
      repeat(1)@(vif.mon_cb);
      flag = 0;
      if(vif.mon_cb.ce) begin
      flag = (vif.mon_cb.mode && (vif.mon_cb.cmd == ADD || vif.mon_cb.cmd == SUB || vif.mon_cb.cmd == ADD_CIN || vif.mon_cb.cmd == SUB_CIN || vif.mon_cb.cmd == CMP || vif.mon_cb.cmd == ADD_MUL || vif.mon_cb.cmd == SH_MUL)) || (!vif.mon_cb.mode && (vif.mon_cb.cmd == AND || vif.mon_cb.cmd == NAND || vif.mon_cb.cmd == OR || vif.mon_cb.cmd == NOR || vif.mon_cb.cmd == XOR || vif.mon_cb.cmd == XNOR || vif.mon_cb.cmd == ROL_A_B || vif.mon_cb.cmd == ROR_A_B));
      trans.mode = vif.mon_cb.mode;
      valid_a = flag && vif.mon_cb.inp_valid[0] ? 1'b1 : valid_a;
      valid_b = flag && vif.mon_cb.inp_valid[1] ? 1'b1 : valid_b;
      //flag = valid_a && valid_b ? 1'b0 : 1'b1; 
      count3 = (previ == {vif.mon_cb.mode,vif.mon_cb.cmd}) ? count3 : 0;
      previ = {vif.mon_cb.mode,vif.mon_cb.cmd};
      end
      $display("%0t | MON: FLAG = %0b VALID_A = %0b VALID_B = %0b",$time/10 - 1,flag,valid_a,valid_b);
      count = vif.mon_cb.rst ? 0 : count;
      if(vif.mon_cb.rst)begin
        repeat(2)@(vif.mon_cb);
        $display("ENTERS RESET");
      end
      else if(flag && (count3 > 0)) begin
        repeat(2)@(vif.mon_cb);
        count3++;
        if(count3 >= 4)
          count3 = 0;
        $display("%0t | MON: ENTERED MULTIPLICATION COUNT = %0d",$time/10 - 1,count3);
      end
      else if(flag == 0)
      begin
        $display("%0t | MON: FLAG ZERO GAVE ONE DELAY",$time/10 - 1);
        count = 0;
        repeat(1)@(vif.mon_cb);
      end
      else if (flag && valid_a && valid_b)begin
        flag = 0;
        valid_a = 0;
        valid_b = 0;
        $display("%0t | MON: BOTH VALID COUNT = %0d",$time/10 - 1,count);
        repeat(1)@(vif.mon_cb);
        if(vif.mon_cb.mode && (vif.mon_cb.cmd == ADD_MUL|| vif.mon_cb.cmd == SH_MUL))
        begin
          count3 = 1;
          repeat(1)@(vif.mon_cb);
        end
        count = 0;
      end
      else if(count < 16 && flag)
      begin
        count++;
        $display("%0t | MON: COUNTING = %0d",$time/10 - 1,count);
      end
      else if(count >= 16) begin
        valid_a = 0;
        valid_b = 0;
        count = 0;
        flag = 0;
        $display("%0t | MON: COUNT EXCEEDED",$time/10 - 1);
      end
      trans.err = vif.mon_cb.err;
      trans.res = vif.mon_cb.res;
      trans.oflow = vif.mon_cb.oflow;
      trans.cout = vif.mon_cb.cout;
      trans.g = vif.mon_cb.g;
      trans.l = vif.mon_cb.l;
      trans.e = vif.mon_cb.e;
      mbx_mon_scr.put(trans);
      /*if(vif.mon_cb.rst)
        repeat(1)@(vif.mon_cb);*/
      i = i + 1;
      $display("%0t | MON: RECIEVED %0d ITEM",$time/10 - 1,i);
      $display("RESULT = %0d\nOFLOW = %1b COUT = %1b G = %1b L = %1b E = %1b",trans.res,trans.oflow,trans.cout,trans.g,trans.l,trans.e);
      //if(flag == 0)
        //repeat(1)@(posedge vif.mon_cb);
    end
    alu_output_cg.stop;
  endtask
endclass
