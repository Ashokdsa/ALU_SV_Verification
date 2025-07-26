`include "defines.svh"
typedef enum{ADD,SUB,ADD_CIN,SUB_CIN,INC_A,DEC_A,INC_B,DEC_B,CMP,ADD_MUL,SH_MUL}arith;
typedef enum{AND,NAND,OR,NOR,XOR,XNOR,NOT_A,NOT_B,SHR1_A,SHL1_A,SHR1_B,SHL1_B,ROL_A_B,ROR_A_B}logical;
module alu_assertion_cvg(clk,rst,ce,opa,opb,mode,inp_valid,cmd,cin,res);
  input clk;
  input rst;
  input ce;
  input [`WIDTH - 1 : 0] opa;
  input [`WIDTH - 1 : 0]opb;
  input mode;
  input [1:0] inp_valid;
  input [`CWIDTH - 1 : 0]cmd;
  input cin;
  input [`WIDTH : 0]res;
  int unsigned total = {`WIDTH{1'b1}};
  int unsigned total_high = {`WIDTH + 1{1'b1}};

  property ALU_Unknown;
    @(posedge clk)
    !($isunknown({rst,ce,opa,opb,mode,inp_valid,cmd,cin}));
  endproperty
  ALU_UNKNOWN: assert property(ALU_Unknown) else $error("INPUTS ARE UNKNOWN");

  ALU_RESET: assert property(@(posedge clk) !rst) else $info("RESET IS TRIGGERED");

  property ALU_State;
    @(posedge clk)
    !ce |=> res == $past(res);
  endproperty
  ALU_SAME_STATE: assert property(ALU_State) else $error("OUTPUT CHANGED");

  sequence delay_16;
    inp_valid == 2'b11 or (inp_valid[0] ##[0:16] inp_valid[1]) or (inp_valid[1] ##[0:16] inp_valid[0]);
  endsequence

  property ALU_clk_delay;
    @(posedge clk)
    if(mode)
      (cmd inside {ADD,SUB,ADD_CIN,SUB_CIN}) throughout delay_16 
    else
      (cmd inside {AND,NAND,OR,NOR,XOR,XNOR,ROL_A_B,ROR_A_B}) throughout delay_16;
  endproperty

  ALU_CLK: assert property(ALU_clk_delay) else $error("INPUTS HAVEN'T BEEN RECIEVED ON TIME");

  property ALU_clk_mult;
    @(posedge clk)
    (cmd == SH_MUL throughout (delay_16 ##3 1)) or (cmd == ADD_MUL throughout (delay_16 ##3 1));
  endproperty
  ALU_CLK_MULT: assert property(ALU_clk_mult) else $error("MULTIPLICATION FAILED");

  covergroup alu_cg @(posedge clk);
    RST_cp: coverpoint rst;
    CE_cp: coverpoint ce;
    MODE_cp: coverpoint mode iff(!rst || ce);
    CIN_cp: coverpoint cin iff(!rst || ce || (mode && (cmd == 2 || cmd == 3)));
    INP_VALID_cp: coverpoint inp_valid iff(!rst || ce)
                  {
                    bins valid_3 = {3};
                    bins valid_2 = {2};
                    bins valid_1 = {1};
                    bins failed = {0};
                  }
    CMD_cp: coverpoint cmd iff(!rst || ce)
            {
              bins arith[] = {[0:10]} with (mode == 1'b1);
              bins logical[] = {[0:13]} with (mode == 1'b0);
              bins out_of_range_arith = {[11:15]} with (mode == 1'b1);
              bins out_of_range_logical = {14,15} with (mode == 1'b0);
            }
    ADD_cp: coverpoint (int'(opa) + int'(opb)) iff(!rst || ce || (mode && (cmd == 0)))
             {
               bins in_range = {[0:total]};
               bins cout_trig = {[total + 1: total_high]};
             }
    ADD_CIN_cp: coverpoint (int'(opa) + int'(opb) + cin) iff(!rst || ce || (mode && (cmd == 2)))
             {
               bins in_range = {[0:total]};
               bins cout_trig = {[total + 1 : total_high]};
             }
    SUB_cp: coverpoint opa < opb iff(!rst || ce || (mode && (cmd == 1 || cmd == 3)))
             {
               bins normal = {0};
               bins oflow_trig = {1};
             }
    DECA_cp: coverpoint opa == 0 iff(!rst || ce || (mode && cmd == 5))
             {
               bins normal = {0};
               bins corner = {1};
             }
    DECB_cp: coverpoint opb == 0 iff(!rst || ce || (mode && cmd == 7))
             {
               bins normal = {0};
               bins corner = {1};
             }
    INCA_cp: coverpoint opa == total iff(!rst || ce || (mode && cmd == 4))
             {
               bins normal = {0};
               bins corner = {1};
             }
    INCB_cp: coverpoint opb == total iff(!rst || ce || (mode && cmd == 6))
             {
               bins normal = {0};
               bins corner = {1};
             }
    CMP_cp: coverpoint opa iff(!rst || ce || (mode && cmd == 8))
             {
               bins greater = {[0:total]} with (opa > opb);
               bins lesser = {[0:total]}  with (opa < opb);
               bins equal = {[0:total]} with (opa == opb);
             }
    SHA_cp: coverpoint (int'(opa) << 1) iff(!rst || ce || (!mode && cmd == 9))
             {
               wildcard bins normal = {8'b0xxxxxxx};
               wildcard bins corner = {8'b1xxxxxxx};
             }
    SHB_cp: coverpoint (int'(opb) << 1) iff(!rst || ce || (!mode && cmd == 11))
             {
               wildcard bins normal = {8'b0xxxxxxx};
               wildcard bins corner = {8'b1xxxxxxx};
             }
    MULT_cp: coverpoint opa iff(!rst || ce || (mode && cmd == 10))
             {
               bins normal = {[0:127],[129:255]};
               bins corner = {255};
             }
    RO_cp: coverpoint opb iff(!rst || ce || (!mode && (cmd == 12 || cmd == 13)))
             {
               wildcard bins normal = {8'b0000xxxx};
               wildcard bins err_trig = {8'b11111111};
             }
    ADD_MULT_cross: cross opa,opb iff(!rst || ce || (mode && cmd == 9))
             {
               bins normal = binsof(opa) || binsof(opb);
               bins corner = binsof(opa) intersect {total} || binsof(opb) intersect {total};
             }
    mode_0_cp: coverpoint inp_valid iff(!rst || ce || !(mode))
             {
               bins valid_logical_3 = {2'b11} with (cmd inside {[0:5],12,13});
               bins valid_logical_2 = {2'b10} with (cmd inside {7,10,11});
               bins valid_logical_1 = {2'b01} with (cmd inside {6,8,9});
               bins invalid_logical_2 = {2'b10} with (cmd inside {[0:5],6,8,9,12,13});
               bins invalid_logical_1 = {2'b01} with (cmd inside {[0:5],7,10,11,12,13});
             }
    mode_1_cp: coverpoint inp_valid iff(!rst || ce || (mode))
             {
               bins valid_arith_3 = {2'b11} with (cmd inside {[0:3],[8:10]});
               bins valid_arith_2 = {2'b10} with (cmd inside {6,7});
               bins valid_arith_1 = {2'b01} with (cmd inside {4,5});
               bins invalid_arith_2 = {2'b10} with (cmd inside {[0:5],8,9,10});
               bins invalid_arith_1 = {2'b01} with (cmd inside {[0:3],[6:10]});
             }
  endgroup

  INP_VALID_trans: cover property(ALU_clk_delay);
  alu_cg cg = new();

endmodule
