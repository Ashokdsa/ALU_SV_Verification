int i;
class test;
  alu_environment env;
  virtual alu_intf vif;
  function new(virtual alu_intf vif);
    this.vif = vif;
  endfunction

  task start();
    env = new(vif);
    env.build();
    $display("---------------------------------------------NORMAL TEST START------------------------------------------------");
    begin
      env.start(32);
    end
    $display("---------------------------------------------NORMAL TEST DONE-------------------------------------------------");
    i = i + env.scr.i;
  endtask
endclass

class global_test extends test;
  glo_transaction trans;
  
  function new(virtual alu_intf vif);
    super.new(vif);
    trans = new();
  endfunction

  task start();

    env = new(vif);
    env.build();
    env.gen.trans = trans;
    $display("---------------------------------------------GLOBAL TEST START------------------------------------------------");
    begin
      env.start(15);
    end
    $display("---------------------------------------------GLOBAL TEST DONE-------------------------------------------------");
    i = i + env.scr.i;
  endtask
endclass

class corner_test extends test;
  crn_transaction trans;
  
  function new(virtual alu_intf vif);
    super.new(vif);
    trans = new();
  endfunction

  task start();
    env = new(vif);
    env.build();
    env.gen.trans = trans;
    $display("---------------------------------------------CORNER TEST START------------------------------------------------");
    begin
      env.start(32);
    end
    $display("---------------------------------------------CORNER TEST DONE-------------------------------------------------");
    i = i + env.scr.i;
  endtask
endclass

class delay_test extends test;
  time_transaction trans;
  
  function new(virtual alu_intf vif);
    super.new(vif);
    trans = new();
  endfunction

  task start();
    env = new(vif);
    env.build();
    env.gen.trans = trans;
    $display("---------------------------------------------DELAY TEST START------------------------------------------------");
    begin
      env.start(15);
    end
    $display("---------------------------------------------DELAY TEST DONE-------------------------------------------------");
    i = i + env.scr.i;
  endtask
endclass

class flag_test extends test;
  flag_transaction trans;
  
  function new(virtual alu_intf vif);
    super.new(vif);
    trans = new();
  endfunction

  task start();
    env = new(vif);
    env.build();
    env.gen.trans = trans;
    $display("---------------------------------------------FLAG TEST START------------------------------------------------");
    begin
      env.start(20);
    end
    $display("---------------------------------------------FLAG TEST DONE-------------------------------------------------");
    i = i + env.scr.i;
  endtask
endclass

class mult_test extends test;
  mult_transaction trans;
  
  function new(virtual alu_intf vif);
    super.new(vif);
    trans = new();
  endfunction

  task start();
    env = new(vif);
    env.build();
    env.gen.trans = trans;
    $display("---------------------------------------------MULTIPLICATION TEST START------------------------------------------------");
    begin
      env.start(30);
    end
    $display("---------------------------------------------MULTIPLICATION TEST DONE-------------------------------------------------");
    i = i + env.scr.i;
  endtask
endclass

class mult_crn_test extends mult_test;
  mult_crn_transaction trans;

  function new(virtual alu_intf vif);
    super.new(vif);
    trans = new();
  endfunction

  task start();
    env = new(vif);
    env.build();
    env.gen.trans = trans;
    $display("---------------------------------------------MULTIPLICATION CORNER TEST START------------------------------------------------");
    begin
      env.start(9);
    end
    $display("---------------------------------------------MULTIPLICATION CORNER TEST DONE-------------------------------------------------");
    i = i + env.scr.i;
  endtask
endclass

class corner2_test extends test;
  crn_transaction2 trans;

  function new(virtual alu_intf vif);
    super.new(vif);
    trans = new();
  endfunction

  task start();
    env = new(vif);
    env.build();
    env.gen.trans = trans;
    $display("---------------------------------------------CORNER TEST 2 START------------------------------------------------");
    begin
      env.start(30);
    end
    $display("---------------------------------------------CORNER TEST 2 DONE-------------------------------------------------");
    i = i + env.scr.i;
  endtask
endclass

class reg_test extends test;

glo_transaction globe; //allows reset and clock enable to be random
crn_transaction corner; //most erroneous transaction related to out of range and wrong inp_valid
time_transaction tim;
flag_transaction flag; //Trigger COUT and OFLOW
mult_transaction mult; //Only Multiplication
crn_transaction2 crn2;
mult_crn_transaction mult_crn; //Only Multiplication

  function new(virtual alu_intf vif);
    super.new(vif);
    globe = new(); //allows reset and clock enable to be random
    corner = new(); //most erroneous transaction related to out of range and wrong inp_valid
    tim = new();
    flag = new(); //Trigger COUT and OFLOW
    mult = new(); //Only Multiplication
    crn2 = new(); //checks for max and min values
    mult_crn = new();
  endfunction

  task start();
    env=new(vif);
    env.build();

    $display("---------------------------------------------NORMAL TEST START------------------------------------------------");
    begin
      env.start(32);
    end
    $display("---------------------------------------------NORMAL TEST DONE-------------------------------------------------");
    $display("---------------------------------------------GLOBAL TEST START------------------------------------------------");
    begin
      env.gen.trans = globe;
      env.start(15);
    end
    $display("---------------------------------------------GLOAL TEST DONE-------------------------------------------------");
    $display("---------------------------------------------CORNER TEST START------------------------------------------------");
    begin
      env.gen.trans = corner;
      env.start(32);
    end
    $display("---------------------------------------------CORNER TEST DONE-------------------------------------------------");
    $display("---------------------------------------------DELAY TEST START------------------------------------------------");
    begin
      env.gen.trans = tim;
      env.start(60);
    end
    $display("---------------------------------------------DELAY TEST DONE-------------------------------------------------");
    $display("---------------------------------------------FLAG TEST START------------------------------------------------");
    begin
      env.gen.trans = flag;
      env.start(20);
    end
    $display("---------------------------------------------FLAG TEST DONE-------------------------------------------------");
    $display("---------------------------------------------MULTIPLICATION TEST START------------------------------------------------");
    begin
      env.gen.trans = mult;
      env.start(30);
    end
    $display("---------------------------------------------MULTIPLICATION TEST DONE-------------------------------------------------");
    $display("---------------------------------------------CORNER TEST 2 START------------------------------------------------");
    begin
      env.gen.trans = crn2;
      env.start(30);
    end
    $display("---------------------------------------------CORNER TEST 2 DONE-------------------------------------------------");
    $display("---------------------------------------------MUTLIPLICATION CORNER TEST START------------------------------------------------");
    begin
      env.gen.trans = mult_crn;
      env.start(9);
    end
    $display("---------------------------------------------MULTIPLICATION CORNER TEST DONE-------------------------------------------------");
    i = i + env.scr.i;
  endtask
endclass

class same_test extends test;
  same_environment env_same;
  function new(virtual alu_intf vif);
    super.new(vif);
  endfunction

  task start();
    env_same = new(vif);
    env_same.build();
    $display("--------------------------------------------SAME TEST START------------------------------------------------");
    begin
      env_same.start(4);
    end
    $display("---------------------------------------------SAME TEST DONE-------------------------------------------------");
    i = i + env_same.scr.i;
  endtask
endclass
