`include"defines.svh"

interface alu_intf(input clk);
  logic rst;
  logic [1:0]inp_valid;
  logic mode;
  logic [`CWIDTH:0] cmd;
  logic ce;
  logic [(`WIDTH - 1) : 0]opa,opb;
  logic cin;
  logic err;
  logic [`WIDTH : 0]res;
  logic oflow,cout;
  logic g,l,e;

  clocking drv_cb @(posedge clk);
    default input #0 output #0;
    output rst;
    output inp_valid;
    output mode;
    output cmd;
    output ce;
    output opa;
    output opb;
    output cin;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #0 output #0;
    input err;
    input res;
    input oflow;
    input cout;
    input g,l,e;
  endclocking

  clocking ref_cb @(posedge clk);
  endclocking

  modport DRV (clocking drv_cb);
  modport MON (clocking mon_cb);
  modport REF (clocking ref_cb);
endinterface
