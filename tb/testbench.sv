`include "interface.sv"
`include "test.sv"
`include "defines.svh"
 `include "../rtl/dut_ram.v"


module tb;
        logic clk,rst;
		
        always #5 clk= ~clk;
		
	dut_vif vif(clk,rst);
        test test(vif);
        dut_ram dut(.clk(vif.clk),.reset(vif.rst),.read_enb(vif.read_en),.write_enb(vif.write_en),.address(vif.addr),.data_in(vif.data_in),.data_out(vif.data_out));
			
	initial begin
    		clk=0;
    		rst=0;
    		repeat(10) @(posedge clk);
    		rst=1;
    		repeat(10) @(posedge clk);
    		rst=0;
	end		
endmodule


