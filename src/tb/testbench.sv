`include "interface.sv"
`include "test.sv"
`include "defines.svh"
 `include "../rtl/dut_ram.v"

module tb;

        logic clk,rst;

// 		read_test t;
// 		write_test t;
//		simultaneous_test t;
 		test_regression t;
//        test t;

        always #5 clk=~clk;

        dut_vif vif(clk,rst);

        dut_ram dut(.clk(vif.clk), .rst(vif.rst), .read_en(vif.read_en), .write_en(vif.write_en), .addr(vif.addr), .data_in(vif.data_in), .data_out(vif.data_out));

        initial begin
                clk=0;
                rst=1;
                repeat(10) @(posedge clk);
                rst=0;
        end

        initial begin
                t=new(vif);
                t.start();
        end

endmodule

