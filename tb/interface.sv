`include"defines.svh"

interface dut_vif(input clk,input rst);
        logic read_en,write_en;
        logic [`ADDR_WIDTH-1:0]addr;
        logic [`DATA_WIDTH-1:0]data_out;
        logic [`DATA_WIDTH-1:0]data_in;
	bit[$clog2(`TESTCASES)-1:0] transaction_count;
        /*
        clocking drv_dut@(posedge clk);
                default input #1 output #2;//check values here...
                input data_out,rst;
                output addr,data_in,read_en,write_en;
        endclocking
        */
        //modport drv_dut_mod(clocking drv_dut);
        modport drv_dut_mod(input clk,rst,addr,data_in,read_en,write_en,output data_out);
endinterface

