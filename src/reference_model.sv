`include "defines.svh"
class alu_reference;
  int iter;
  int count;
  bit[2:0] count3;
  bit valid_a,valid_b;
  semaphore correct = new(1);

  base_transaction trans;

  mailbox #(base_transaction) mbx_drv_ref;
  mailbox #(base_transaction) mbx_ref_scr;

  virtual alu_intf.REF vif;

  base_transaction temp;
  logic[`LOG2 - 1 : 0] shft;

  function new(mailbox #(base_transaction) mbx_drv_ref, mailbox #(base_transaction) mbx_ref_scr,virtual alu_intf.REF vif);
    this.mbx_drv_ref = mbx_drv_ref;
    this.mbx_ref_scr = mbx_ref_scr;
    this.vif = vif;
    temp = new();
    temp.res = 'bz;
    temp.err = 1'bz;
    temp.cout = 1'bz;
    temp.g = 1'bz;
    temp.l = 1'bz;
    temp.e = 1'bz;
    temp.oflow = 1'bz;
  endfunction

  task start(int no);
    repeat(no)
    begin
      trans = new();
      trans = new();
      mbx_drv_ref.get(trans);
      void'(correct.try_get(1));
      if(trans.rst)
      begin
        @(vif.ref_cb);
        count = 0;
        count3 = 0;
        trans.res = 'bz;
        trans.err = 1'bz;
        trans.cout = 1'bz;
        trans.g = 1'bz;
        trans.l = 1'bz;
        trans.e = 1'bz;
        trans.oflow = 1'bz;
        correct.put(1);
      end
      else begin
        if(trans.ce) begin
          count = (temp.cmd == trans.cmd) || (temp.mode == trans.mode) ? count : 0;
          count3 = (temp.cmd == trans.cmd) || (temp.mode == trans.mode) ? count3 : 0;
          temp.cmd = trans.cmd;
          temp.mode = trans.mode;
          trans.res = valid_a && valid_b ? temp.res : 'bz;
          trans.err = 1'bz;
          trans.cout = 1'bz;
          trans.g = 1'bz;
          trans.l = 1'bz;
          trans.e = 1'bz;
          trans.oflow = 1'bz;
          temp.opa = trans.inp_valid[0] ? trans.opa : temp.opa;
          temp.opb = trans.inp_valid[1] ? trans.opb : temp.opb;
          if(trans.mode) begin
            case(trans.cmd)
              4'd0: //ADD
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                  valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                end
                if(delay() == 2)
                begin
                  trans.res = temp.opa + temp.opb;
                  trans.err = 1'bz;
                  trans.cout = trans.res[`WIDTH];
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  trans.cout = 1'bz;
                  correct.put(1);
                end
              end
              4'd1: //SUB
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                  valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                end
                if(delay() == 2)
                begin
                  trans.res = temp.opa - temp.opb;
                  trans.err = 1'bz;
                  trans.oflow = trans.res[`WIDTH];
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  trans.oflow = 1'bz;
                  correct.put(1);
                end
              end
              4'd2: //ADD_CIN
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                  valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                end
                if(delay() == 2)
                begin
                  trans.res = temp.opa + temp.opb + trans.cin;
                  trans.err = 1'bz;
                  trans.cout = trans.res[`WIDTH];
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  trans.cout = 1'bz;
                  correct.put(1);
                end
              end
              4'd3: //SUB_CIN
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                  valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                end
                if(delay() == 2)
                begin
                  trans.res = temp.opa - temp.opb - trans.cin;
                  trans.err = 1'bz;
                  trans.oflow = trans.res[`WIDTH];
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  trans.oflow = 1'bz;
                  correct.put(1);
                end
              end
              4'd4: //INC A
              begin
                trans.res = trans.inp_valid[0] == 1'b1 ? (temp.opa + 1) : 'bz;
                trans.err = trans.inp_valid[0] == 1'b1 ? 1'bz :1'b1;
                correct.put(1);
              end
              4'd5: //DEC A
              begin
                trans.res = trans.inp_valid[0] == 1'b1 ? (temp.opa - 1) : 'bz;
                trans.err = trans.inp_valid[0] == 1'b1 ? 1'bz :1'b1;
                correct.put(1);
              end
              4'd6: //INC B
              begin
                trans.res = trans.inp_valid[1] == 1'b1 ? (temp.opb + 1) : 'bz;
                trans.err = trans.inp_valid[1] == 1'b1 ? 1'bz :1'b1;
                correct.put(1);
              end
              4'd7: //DEC B
              begin
                trans.res = trans.inp_valid[1] == 1'b1 ? (temp.opb - 1) : 'bz;
                trans.err = trans.inp_valid[1] == 1'b1 ? 1'bz :1'b1;
                correct.put(1);
              end
              4'd8: //CMP
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                  valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                end
                if(delay() == 2)
                begin
                  trans.res = 'bz;
                  trans.err = 1'bz;
                  trans.g = temp.opa > temp.opb;
                  trans.l = temp.opa < temp.opb;
                  trans.e = temp.opa == temp.opb;
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  trans.cout = 1'bz;
                  trans.g = 1'bz;
                  trans.l = 1'bz;
                  trans.e = 1'bz;
                  correct.put(1);
                end
              end
              4'd9: //INC_MUL
              begin
                if(count3 > 0 &&  count3 < 3)
                begin
                  count3++;
                  $display("COUNT = %0d",count3);
                end
                else if(count3 >= 3)
                begin
                  count3 = 0;
                  count = 0;
                  trans.res = ((temp.opa + 1) & {`WIDTH{1'b1}}) * ((temp.opb + 1) & {`WIDTH{1'b1}});
                  correct.put(1);
                end
                else
                begin
                  if(count == 0)
                    {valid_b,valid_a} = trans.inp_valid;
                  else begin
                    valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                    valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                  end
                  if(delay() == 2)
                  begin
                    trans.res = ((temp.opa + 1) & {`WIDTH{1'b1}}) * ((temp.opb + 1) & {`WIDTH{1'b1}});
                    trans.err = 1'bz;
                    count3++;
                    count = 0;
                  end
                  else if(delay() == 0)
                  begin
                    trans.res = 'bz;
                    trans.err = 1'b1;
                    count3 = 0;
                    count = 0;
                    correct.put(1);
                  end
                end
              end
              4'd10: //SH_MUL
              begin
                if(count3 > 0 && count3 < 3)
                begin
                  count3++;
                  $display("COUNT = %0d",count3);
                end
                else if(count3 >= 3)
                begin
                  correct.put(1);
                  count3 = 0;
                  count = 0;
                  trans.res = ((temp.opa << 1) & {`WIDTH{1'b1}}) * (temp.opb);
                end
                else
                begin
                  if(count == 0)
                  begin
                    {valid_b,valid_a} = trans.inp_valid;
                  end
                  else begin
                    valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                    valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                  end
                  if(delay() == 2)
                  begin
                    trans.res = ((temp.opa << 1) & {`WIDTH{1'b1}}) * (temp.opb);
                    trans.err = 1'bz;
                    count3++;
                    count = 0;
                  end
                  else if(delay() == 0)
                  begin
                    trans.res = 'bz;
                    trans.err = 1'b1;
                    count3 = 0;
                    count = 0;
                    correct.put(1);
                  end
                end
              end
              default:
              begin
                trans.res = 'bz;
                trans.err = 1'b1;
                trans.cout = 1'bz;
                trans.g = 1'bz;
                trans.l = 1'bz;
                trans.e = 1'bz;
                trans.oflow = 1'bz;
                correct.put(1);
              end
            endcase
          end
          else begin
            case(trans.cmd)
              4'd0: //AND
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] ? 1'b1 : valid_a;
                  valid_b = trans.inp_valid[1] ? 1'b1 : valid_b;
                end
                if(delay() == 2)
                begin
                  trans.res = (temp.opa & temp.opb) & ({`WIDTH{1'b1}});
                  trans.err = 1'bz;
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  correct.put(1);
                end
              end
              4'd1: //NAND
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                  valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                end
                if(delay() == 2)
                begin
                  trans.res = (~(temp.opa & temp.opb)) & ({`WIDTH{1'b1}});
                  trans.err = 1'bz;
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  correct.put(1);
                end
              end
              4'd2: //OR 
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                  valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                end
                if(delay() == 2)
                begin
                  trans.res = (temp.opa | temp.opb) & ({`WIDTH{1'b1}});
                  trans.err = 1'bz;
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  correct.put(1);
                end
              end
              4'd3://NOR
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                  valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                end
                if(delay() == 2)
                begin
                  trans.res = ~(temp.opa | temp.opb) & ({`WIDTH{1'b1}});
                  trans.err = 1'bz;
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  correct.put(1);
                end
              end
              4'd4: //XOR
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                  valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                end
                if(delay() == 2)
                begin
                  trans.res = (temp.opa ^ temp.opb) & ({`WIDTH{1'b1}});
                  trans.err = 1'bz;
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  correct.put(1);
                end
              end
              4'd5: //XNOR
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                  valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                end
                if(delay() == 2)
                begin
                  trans.res = ~(temp.opa ^ temp.opb) & ({`WIDTH{1'b1}});
                  trans.err = 1'bz;
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  correct.put(1);
                end
              end
              4'd6: //NOT_A
              begin
                trans.res = trans.inp_valid[0] == 1'b1 ? ~(trans.opa) & ({`WIDTH{1'b1}}) : 'bz;
                trans.err = trans.inp_valid[0] == 1'b1 ? 1'bz : 1'b1;
                correct.put(1);
              end
              4'd7: //NOT_B
              begin
                trans.res = trans.inp_valid[1] == 1'b1 ? ~(trans.opb) & ({`WIDTH{1'b1}}) : 'bz;
                trans.err = trans.inp_valid[1] == 1'b1 ? 1'bz : 1'b1;
                correct.put(1);
              end
              4'd8: //SHR1_A
              begin
                trans.res = trans.inp_valid[0] == 1'b1 ? (trans.opa >> 1) : 'bz;
                trans.err = trans.inp_valid[0] == 1'b1 ? 1'bz : 1'b1;
                correct.put(1);
              end
              4'd9: // SHL1_A
              begin
                trans.res = trans.inp_valid[0] == 1'b1 ? (trans.opa << 1) : 'bz;
                trans.err = trans.inp_valid[0] == 1'b1 ? 1'bz : 1'b1;
                correct.put(1);
              end
              4'd10: // SHR1_B
              begin
                trans.res = trans.inp_valid[1] == 1'b1 ? (trans.opb >> 1) : 'bz;
                trans.err = trans.inp_valid[1] == 1'b1 ? 1'bz : 1'b1;
                correct.put(1);
              end
              4'd11: // SHL1_B
              begin
                trans.res = trans.inp_valid[1] == 1'b1 ? (trans.opb << 1) : 'bz;
                trans.err = trans.inp_valid[1] == 1'b1 ? 1'bz : 1'b1;
                correct.put(1);
              end
              4'd12: // ROL_A_B
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                  valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                end
                shft = valid_b ? temp.opb[`LOG2 - 1 : 0] : 'bz;
                if(delay() == 2)
                begin
                  trans.res = {1'b0,temp.opa << shft | temp.opa >> (`WIDTH - shft)};
                  trans.err = temp.opb[`WIDTH - 1 : `LOG2 + 1] != 0 ? 1'b1 : 1'bz;
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  correct.put(1);
                end
              end
              4'd13: // ROR_A_B
              begin
                if(count == 0)
                  {valid_b,valid_a} = trans.inp_valid;
                else begin
                  valid_a = trans.inp_valid[0] == 1'b1 ? 1 : valid_a;
                  valid_b = trans.inp_valid[1] == 1'b1 ? 1 : valid_b;
                end
                shft = valid_b ? temp.opb[`LOG2 - 1 : 0] : 'bz;
                if(delay() == 2)
                begin
                  trans.res = {1'b0,(temp.opa >> shft | temp.opa << (`WIDTH - shft))};
                  trans.err = temp.opb[`WIDTH - 1 : `LOG2 + 1] != 0 ? 1'b1 : 1'bz;
                  correct.put(1);
                end
                else if(delay() == 0)
                begin
                  trans.res = 'bz;
                  trans.err = 1'b1;
                  correct.put(1);
                end
              end
              default:
              begin
                trans.res = 'bz;
                trans.err = 1'b1;
                trans.cout = 1'bz;
                trans.g = 1'bz;
                trans.l = 1'bz;
                trans.e = 1'bz;
                trans.oflow = 1'bz;
                correct.put(1);
              end
            endcase
          end
        end
        else begin
          trans.res = temp.res;
          trans.err = temp.err;
          trans.cout = temp.cout;
          trans.g = temp.g;
          trans.l = temp.l;
          trans.e = temp.e;
          trans.oflow = temp.oflow;
          correct.put(1);
        end
      end
      if(correct.try_get(1))
      begin
        mbx_ref_scr.put(trans);
        iter++;
        $display("%0t | REF: ITERATION: %0d",($time/10)-2,iter);
        if(trans.mode)
          $display("CMD = %0s OPA = %0d OPB = %0d CIN = %0b\nRES = %0d ERR = %0b COUT = %0b OFLOW = %0b G,L,E = %3b",arith'(trans.cmd),temp.opa,temp.opb,trans.cin,trans.res,trans.err,trans.cout,trans.oflow,{trans.g,trans.l,trans.e});
        else
          $display("CMD = %0s\nOPA = %b\nOPB = %0b\nOUTPUT:\nRES = %b ERR = %0b COUT = %0b OFLOW = %0b G,L,E = %3b",logical'(trans.cmd),trans.opa,trans.opb,trans.res,trans.err,trans.cout,trans.oflow,{trans.g,trans.l,trans.e});
      end
      temp.res = trans.res;
      temp.err = trans.err;
      temp.cout = trans.cout;
      temp.g = trans.g;
      temp.l = trans.l;
      temp.e = trans.e;
      temp.oflow = trans.oflow;
      @(vif.ref_cb);
    end
  endtask

  function int delay();
    if({valid_a,valid_b} == 2'b00)
    begin
      count = 0;
      return 0;
    end
    if(count >= 14)
    begin
      count = 0;
      if(valid_a && valid_b)
        return 2;
      else
        return 0;//time passed trigger err
    end
    else if(count < 15)
    begin
      if(valid_a && valid_b)
      begin
        count = 0;
        return 2;//value is true return key
      end
      else
      begin
        count++;
        return 1;//time is calculated
      end
    end
  endfunction
endclass
