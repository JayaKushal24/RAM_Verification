`include "environment.sv"

program test(dut_vif vif);
	environment env;

	initial begin
		env = new(vif);
//     		env.gen.test_cases = 1000;
		env.test();
//     		#11000;
//     		repeat(env.gen.test_cases+2)@(posedge vif.clk);
		repeat(`TESTCASES+2)@(posedge vif.clk);

		env.report();
		$finish;
	end
endprogram

