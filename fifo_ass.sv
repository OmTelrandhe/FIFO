module fifo(
input clk,rst,wr,rd,
input [7:0] din,
output reg [7:0] dout,
output reg empty, full
    );
    
    reg [3:0] wptr=0,rptr=0,cnt=0;
    reg [7:0] mem [15:0];
    
    always @(posedge clk)
    begin 
    if (rst == 1'b1) begin
    cnt<=0;
    wptr<=0;
    rptr<=0;
    end
    else if (wr && !full) 
    begin
    if (cnt <15)
    begin 
    mem[wptr]<=din;
    wptr<=wptr+1;
    cnt<=cnt+1;
    end
    end
  else if (rd && !empty)
  begin
  if (cnt>0) begin
  dout <= mem[rptr];
  rptr<=rptr+1;
  cnt<=cnt-1;
  end
  end

if(wptr==15)
  wptr<=0;
if(wptr==0)
  rptr<=0;
  end
  
  assign full = (cnt==15) ?1'b1:1'b0;
  assign empty = (cnt==0) ?1'b1:1'b0;
  
endmodule



module tb;
reg wr=0,rd=0,clk=0,rst=0;
reg [7:0] din =0;
wire [7:0] dout;
wire empty, full;
integer i=0;
reg start=0;

always #5 clk=~clk;
initial begin
#2;
start = 1;
#10;
start=0;
end

reg temp=0;
initial begin 
#592;
temp=1;
#10;
temp=0;
end


fifo dut (clk,rst,wr,rd,din,dout,empty,full);


task write();
for(i=0;i<15;i++)
begin 
din= $random();
wr=1'b1;
rd=1'b0;
@(posedge clk);
end 
endtask

task read();
for(i=0;i<15;i++)
begin
wr=1'b0;
rd=1'b1;
@(posedge clk);
end 
endtask


//status of empty and full flag when reset assert

//A1: assert property (@(posedge clk) $rose(rst) |-> (empty && !full)) $info("suc at %0t",$time);

//A2: assert property (@(posedge clk) rst |-> (empty && !full)) $info("empty and fullwhen reset assrt suc at %0t",$time);

//A3 : assert property (@(posedge clk) $rose(rst) |-> (empty && !full) [*1:31] ##1 (!rst || temp)) $info("empty and fullwhen reset assrt suc at %0t",$time);


////reading empty fifo
//A4: assert property (@(posedge clk) disable iff(rst) empty |-> !rd) $info("read empty fifo suc at %0t",$time); 


////writing to full fifo
//A5: assert property (@(posedge clk) disable iff(rst) full |-> !wr);

////rear and write pointer during write operation
////wptr must increment till fifo get full 
////rptr must remain stable
//wptr_incr_write: assert property (@(posedge clk) ($rose(wr) && !rst) |=> (dut.wptr==$past(dut.wptr+1)) [*1:50] ##1 (!wr || full || rst || temp)) $info(" write ptr during writing operation sucat %0t",$time);
//rptr_stable_write: assert property (@(posedge clk) ($rose(wr) && !rst) |=> ($stable(dut.rptr)) [*1:50] ##1 (!wr || full || rst || temp)) $info("read ptr during writing operation sucat %0t",$time);

//read and write pointer during read operation
//wptr must stable 
//rptr must increment
wptr_stable_read: assert property (@(posedge clk) ($rose(rd) && !rst) |=> ($stable(dut.wptr)) [*1:50] ##1 (!rd || empty || rst || temp)) $info(" write ptr during reading operation sucat %0t",$time);
rptr_icnr_read: assert property (@(posedge clk) ($rose(rd) && !rst) |=> (dut.rptr==$past(dut.rptr+1)) [*1:50] ##1 (!rd || empty || rst || temp)) $info("read ptr during reading operation sucat %0t",$time);


//behaviour of full and empty flag with cnt
full_set_cnt: assert property (@(posedge clk) full |-> (dut.cnt==15))  $info(" full suc at %0t",$time);
empty_set_cnt: assert property (@(posedge clk) empty |-> (dut.cnt==0))  $info(" empty suc at %0t",$time);

initial begin
$display("-----starting testbench------");
$display("-----empty and full check when rst assert------");
@(posedge clk) {rst,wr,rd} = 3'b100;
@(posedge clk) {rst,wr,rd} = 3'b101;
@(posedge clk) {rst,wr,rd} = 3'b110;
@(posedge clk) {rst,wr,rd} = 3'b111;
@(posedge clk) {rst,wr,rd} = 3'b000;
@(posedge clk);
#20;
$display("-----reading empty fifo------");
@(posedge clk) {rst,wr,rd} = 3'b001;  //here we should get a failure because empty flag is set and we are trying to read the data
@(posedge clk) {rst,wr,rd} = 3'b000;
@(posedge clk);
#20;
$display("-----writing full fifo ------");
write();
@(posedge clk) {rst,wr,rd} = 3'b010;
@(posedge clk) {rst,wr,rd} = 3'b000;
#20;
$display("-----read and write ptr during reading operation ------");
read();

//$display("-----read and write ptr during writing operation ------");
//@(posedge clk) {rst,wr,rd} = 3'b100;
//@(posedge clk) {rst,wr,rd} = 3'b000;
//@(posedge clk);
//write();
end

initial begin
#610;
$finish();
end

endmodule
