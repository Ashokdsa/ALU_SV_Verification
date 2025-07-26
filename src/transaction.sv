//dont forget to consider the multiplication in the base transaction
//remember the initial reset will be waited in the test, run by the top.
//can write featurer id using integer in test
`include "defines.svh"
class base_transaction; //proper working without multiplication
  rand logic rst;
  rand logic[1:0] inp_valid;
  randc logic mode;
  randc logic [`CWIDTH - 1:0] cmd;
  rand logic ce;
  rand logic [(`WIDTH-1):0]opa,opb;
  rand logic cin;
  logic err;
  logic [`WIDTH : 0] res;
  logic cout;
  logic g,l,e;
  logic oflow;
  constraint rst_val{rst == 0;ce == 1;}
  constraint inp_val
  {
    if(mode)
    {
      if(cmd == 4 || cmd == 5)
        inp_valid == 2'b01;
      else if(cmd == 6 || cmd == 7)
        inp_valid == 2'b10;
      else
        inp_valid == 2'b11;
    }
    else
    {
      if(cmd == 6 || cmd == 8 || cmd == 9)
        inp_valid == 2'b01;
      else if(cmd == 7 || cmd == 10 || cmd == 11)
        inp_valid == 2'b10;
      else
        inp_valid == 2'b11;
    }
  }
  constraint cmd_val
  {
    if(mode) 
      cmd inside {[0:8]}; 
    else 
      cmd inside {[0:13]};
  }

  virtual function base_transaction copy();
    copy = new();
    copy.rst = rst;
    copy.inp_valid = inp_valid;
    copy.mode = mode;
    copy.cmd = cmd;
    copy.ce = ce;
    copy.opa = opa;
    copy.opb = opb;
    copy.cin = cin;
    return copy;
  endfunction
endclass

class glo_transaction extends base_transaction; //allows reset and clock enable to be random

  constraint rst_val{rst inside {0,1};ce inside {0,1};}
  
  virtual function base_transaction copy();
    glo_transaction copy1;
    copy1 = new();
    copy1.rst = rst;
    copy1.inp_valid = inp_valid;
    copy1.mode = mode;
    copy1.cmd = cmd;
    copy1.ce = ce;
    copy1.opa = opa;
    copy1.opb = opb;
    copy1.cin = cin;
    return copy1;
  endfunction
endclass

class crn_transaction extends base_transaction; //most erroneous transaction related to out of range and wrong inp_valid
  constraint cmd_val
  {
    if(mode) 
      cmd inside {[0:15]}; 
    else 
      cmd inside {[0:15]};
  }
  constraint inp_val
  {
    if(mode)
    {
      if(cmd == 4 || cmd == 5)
        inp_valid != 2'b01;
      else if(cmd == 6 || cmd == 7)
        inp_valid != 2'b10;
      else
        inp_valid == 2'b00;
    }
    else
    {
      if(cmd == 6 || cmd == 8 || cmd == 9)
        inp_valid != 2'b01;
      else if(cmd == 7 || cmd == 10 || cmd == 11)
        inp_valid != 2'b10;
      else
        inp_valid == 2'b00;
    }
  }
  virtual function base_transaction copy();
    crn_transaction copy2;
    copy2 = new();
    copy2.rst = rst;
    copy2.inp_valid = inp_valid;
    copy2.mode = mode;
    copy2.cmd = cmd;
    copy2.ce = ce;
    copy2.opa = opa;
    copy2.opb = opb;
    copy2.cin = cin;
    return copy2;
  endfunction
endclass

class time_transaction extends base_transaction;
  rand int count;
  int count3;
  int i;
  bit valid_a,valid_b;

  constraint count_val{count inside {[11:16]};}
  constraint inp_val{inp_valid inside {[2'b01:2'b11]};}
  constraint cmd_val{
    if(mode)
      cmd inside {[0:3],[8:10]};
    else
      cmd inside {[0:5],12,13};
  }

  function void post_randomize();
    valid_a = inp_valid[0] ? 1'b1 : valid_a;
    valid_b = inp_valid[1] ? 1'b1 : valid_b;

    if({valid_a,valid_b} == 2'b00)
    begin
      i = 0;
      count.rand_mode(1);
      cmd.rand_mode(1);
      mode.rand_mode(1);
    end
    else if({valid_a,valid_b} == 2'b11)
    begin
      i = 0;
      if(mode && (cmd == 9 || cmd == 10))
      begin
        count.rand_mode(0);
        cmd.rand_mode(0);
        mode.rand_mode(0);
        if(count3 >= 3)begin
          count3 = 0;
          count.rand_mode(1);
          cmd.rand_mode(1);
          mode.rand_mode(1);
          valid_a = 1'b0;
          valid_b = 1'b0;
        end
        else
          count3++;
      end
      else begin
        count.rand_mode(1);
        cmd.rand_mode(1);
        mode.rand_mode(1);
        valid_a = 1'b0;
        valid_b = 1'b0;
      end
    end
    else if(i == 0) begin
      $display("DELAY = %0d",count);
      count.rand_mode(0);
      cmd.rand_mode(0);
      mode.rand_mode(0);
      i++;
    end
    else if(i < count) 
    begin
      count.rand_mode(0);
      cmd.rand_mode(0);
      mode.rand_mode(0);
      i++;
    end
    else if(i >= count)
    begin
      i = 0;
      count.rand_mode(1);
      cmd.rand_mode(1);
      mode.rand_mode(1);
      valid_a = 1'b0;
      valid_b = 1'b0;
    end
  endfunction

  virtual function base_transaction copy();
    time_transaction copy3;
    copy3 = new();
    copy3.rst = rst;
    copy3.inp_valid = inp_valid;
    copy3.mode = mode;
    copy3.cmd = cmd;
    copy3.cin = cin;
    copy3.ce = ce;
    copy3.opa = opa;
    copy3.opb = opb;
    return copy3;
  endfunction
endclass

class flag_transaction extends base_transaction; //Trigger COUT and OFLOW
  bit a;
  constraint mode_val{mode dist {0:=1,1:=9};}
  constraint cmd_val
  {
    if(mode) 
      cmd inside {[0:3],8}; 
    else 
      cmd inside {12,13};
  }
  constraint oper
    {
      if(mode)
      {
        if(cmd == 0 || cmd == 2)
          opa + opb >= 9'b100000000;
        else if(cmd == 1 || cmd == 3)
          opa < opb;
      }
      else
        opb > 3'b111;
    }
  virtual function base_transaction copy();
    flag_transaction copy4;
    copy4 = new();
    copy4.rst = rst;
    copy4.inp_valid = inp_valid;
    copy4.mode = mode;
    copy4.cmd = cmd;
    copy4.ce = ce;
    copy4.opa = opa;
    copy4.opb = opb;
    copy4.cin = cin;
    return copy4;
  endfunction
endclass

//FOR MULTIPLICATION TRANSACTION REMAINING
class mult_transaction extends base_transaction;
  int count3;

  constraint cmd_val{cmd inside {9,10};}
  constraint mode_val{mode == 1;}

  function void post_randomize();
    if(count3 >= 0 && count3 < 3)
    begin
      count3++;
      cmd.rand_mode(0);
    end
    else begin
      count3 = 0;
      cmd.rand_mode(1);
    end
  endfunction

  virtual function base_transaction copy();
    mult_transaction copy5;
    copy5 = new();
    copy5.rst = rst;
    copy5.inp_valid = inp_valid;
    copy5.mode = mode;
    copy5.cmd = cmd;
    copy5.ce = ce;
    copy5.opa = opa;
    copy5.opb = opb;
    copy5.cin = cin;
    return copy5;
  endfunction
endclass
