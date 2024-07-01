
module tb;
  reg clk = 0;
  reg wr = 0;
  reg rd = 0;
  reg rst = 0;
  reg [7:0] din = 0;
  wire [7:0] dout;
  wire empty, full;
  
 fifo dut (clk,rst,wr,rd,din,dout,empty,full);
  
  always #5 clk = ~clk;
  
  
  
  covergroup c @(posedge clk);
   
  option.per_instance = 1;
    
   coverpoint empty {
     bins empty_l = {0};
     bins empty_h = {1};
   }
   
      coverpoint full {
     bins full_l = {0};
     bins full_h = {1};
   }
  
     coverpoint rst {
     bins rst_l = {0};
     bins rst_h = {1};
   }
  
      coverpoint wr {
     bins wr_l = {0};
     bins wr_h = {1};
   }
  
  
     coverpoint rd {
     bins rd_l = {0};
     bins rd_h = {1};
   }
  
    coverpoint din
   {
     bins lower = {[0:84]};
     bins mid = {[85:169]};
     bins high = {[170:255]};
   }
   
     coverpoint dout
   {
     bins lower = {[0:84]};
     bins mid = {[85:169]};
     bins high = {[170:255]};
   }
  
  cross_Wr_din: cross wr,din 
   {
     ignore_bins unused_wr = binsof(wr) intersect {0};
   }
  
   cross_rd_dout: cross rd,dout
   {
     ignore_bins unused_rd = binsof(rd) intersect {0};
   }
  
 endgroup
  
  c ci;
  
  integer i = 0;
  
  task write();
    for(i = 0; i < 20; i++) begin
    @(posedge clk);   
    wr = 1'b1;
    rd = 1'b0;
    din = $urandom();
   end  
  endtask
  
    task read();
      for(i = 0; i < 20; i++) begin
    @(posedge clk);   
    wr = 1'b0;
    rd = 1'b1;
    din = 0;
   end  
  endtask
  
  
  
  
  initial begin
  rst = 1'b1;
    #50;
  rst = 0;
  wr = 0;
  rd = 0;
  #20;
    write(); 
   #30;
    read(); 
   #30; 
  end
  
  
  
  initial begin
    ci = new();
    $dumpfile("dump.vcd");
    $dumpvars;
    #600;
    $finish();
  end
  
  
  
  
endmodule
