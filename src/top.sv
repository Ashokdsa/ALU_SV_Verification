`include "package.sv"
`include "interface.sv"
`include "ALU_Design_16clock_cycles.v"
`include "assertion_cvg.sv"
module top;
  import alu_pkg::*;
  bit clk;

  alu_intf intf(clk);

  ALU_DESIGN #(`WIDTH,`CWIDTH) DUT (.INP_VALID(intf.inp_valid),.OPA(intf.opa),.OPB(intf.opb),.CIN(intf.cin),.CLK(intf.clk),.RST(intf.rst),.CMD(intf.cmd),.CE(intf.ce),.MODE(intf.mode),.COUT(intf.cout),.OFLOW(intf.oflow),.RES(intf.res),.G(intf.g),.E(intf.e),.L(intf.l),.ERR(intf.err));

  bind intf alu_assertion_cvg ASSERT(.clk(clk),.rst(intf.rst),.ce(intf.ce),.opa(intf.opa),.opb(intf.opb),.mode(intf.mode),.inp_valid(intf.inp_valid),.cmd(intf.cmd),.cin(intf.cin),.res(intf.res));

  always #5 clk = ~clk;

  //test tb = new(intf);          //Normal Test Cases to check the working of the DUT driven with proper input valid
  //global_test tb = new(intf);   //Tests the output when global signals reset and clock enable is randomized
  //corner_test tb = new(intf);   //Tests the output for corner cases, when the relevant inputs are not driven at the required time
  //delay_test tb = new(intf);      //Drives the needed inputs for 2 operand operations within 16 clock cycles
  //w_delay_test tb = new(intf);  //Doesn't drive the needed inputs for 2 operand operations within 16 clock cycles
  //flag_test tb = new(intf);     //Drives inputs to operations which trigger a flag (Ex: G,L,E,ERR,COUT,OFLOW)
  //mult_test tb = new(intf);     //Drives valid Multiplication inputs
  //mult_crn_test tb = new(intf); //Drives the inputs which are out of range after completing intermediate operations
  //corner2_test tb = new(intf);  //Drives inputs which give negative outputs in subtraction and out if bound outputs for shifting
  reg_test reg_tb = new(intf);  //Runs all the previous test cases under one execution
  
  initial begin //initialize the reset
    $assertoff(0,top);
    @(negedge clk);
    intf.rst = 1;
    @(negedge clk);
    intf.rst = 0;
    repeat(1)@(posedge clk);
    $asserton(0,top);
    //tb.start();
    reg_tb.start();
    $finish;
  end

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,top);
  end

  initial begin //MAIN
  end
endmodule
