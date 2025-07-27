`include "package.sv"
`include "interface.sv"
`include "ALU_Design_16clock_cycles.v"
`include "assertion_cvg.sv"
module top;
  import alu_pkg::*;
  bit clk;

  alu_intf intf(clk);

  ALU_DESIGN #(`WIDTH,`CWIDTH) DUT (.INP_VALID(intf.inp_valid),.OPA(intf.opa),.OPB(intf.opb),.CIN(intf.cin),.CLK(intf.clk),.RST(intf.rst),.CMD(intf.cmd),.CE(intf.ce),.MODE(intf.mode),.COUT(intf.cout),.OFLOW(intf.oflow),.RES(intf.res),.G(intf.g),.E(intf.e),.L(intf.l),.ERR(intf.err));

  alu_assertion_cvg ASSERT(.clk(clk),.rst(intf.rst),.ce(intf.ce),.opa(intf.opa),.opb(intf.opb),.mode(intf.mode),.inp_valid(intf.inp_valid),.cmd(intf.cmd),.cin(intf.cin),.res(intf.res));

  always #5 clk = ~clk;

  //test tb = new(intf);
  //global_test tb = new(intf);
  //corner_test tb = new(intf);
  //delay_test tb = new(intf);
  //flag_test tb = new(intf);
  //mult_test tb = new(intf);
  //mult_crn_test tb = new(intf);
  //corner2_test tb = new(intf);
  //same_test tb = new(intf);
  reg_test reg_tb = new(intf);
  
  initial begin //initialize the reset
    ASSERT.cg.stop;
    @(negedge clk);
    intf.rst = 1;
    @(negedge clk);
    intf.rst = 0;
    repeat(2)@(posedge clk);
    ASSERT.cg.start;
    //tb.start();
    reg_tb.start();
    $finish;
  end

  initial begin //MAIN
  end
endmodule
