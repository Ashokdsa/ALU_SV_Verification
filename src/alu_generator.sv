typedef enum{ADD,SUB,ADD_CIN,SUB_CIN,INC_A,DEC_A,INC_B,DEC_B,CMP,ADD_MUL,SH_MUL}arith;
typedef enum{AND,NAND,OR,NOR,XOR,XNOR,NOT_A,NOT_B,SHR1_A,SHL1_A,SHR1_B,SHL1_B,ROL_A_B,ROR_A_B}logical;
class alu_generator;
  base_transaction trans;
  mailbox #(base_transaction) mbx_gen_drv;
  int i;

  function new(mailbox #(base_transaction) mbx_gen_drv);
    this.mbx_gen_drv = mbx_gen_drv;
    trans = new();
  endfunction

  task start(int no);
    $display("GEN:");
    repeat(no) begin
      assert(trans.randomize())begin
        if(trans.mode)
          $display("------------------------%0d--------------------------\nRST = %0b\tCE = %1b\nINP_VALID = %2b\tMODE = %1b\tCMD = %0s\nOPA = %0d OPB = %0d CIN = %0b",i,trans.rst,trans.ce,trans.inp_valid,trans.mode,arith'(trans.cmd),trans.opa,trans.opb,trans.cin);
        else
          $display("------------------------%0d--------------------------\nRST = %0b\tCE = %1b\nINP_VALID = %2b\tMODE = %1b\tCMD = %0s\nOPA = %0d OPB = %0d CIN = %0b",i,trans.rst,trans.ce,trans.inp_valid,trans.mode,logical'(trans.cmd),trans.opa,trans.opb,trans.cin);
        i++; 
      end
      else $error("RANDOMIZATION FAILED");
      mbx_gen_drv.put(trans.copy);
    end
    $display("GEN: SENT %0d items",i);
  endtask
endclass
