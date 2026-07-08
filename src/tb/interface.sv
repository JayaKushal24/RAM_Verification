`include "defines.svh"

interface dut_vif(input clk, input rst);
        logic read_en, write_en;
        logic [`ADDR_WIDTH-1:0]addr;
        logic [`DATA_WIDTH-1:0]data_out;
        logic [`DATA_WIDTH-1:0]data_in;
        int transaction_count;
  
        clocking drv_cb @(posedge clk);
                default input #0 output #0;
                output addr,data_in,read_en,write_en,transaction_count;
        endclocking

        clocking mon_cb @(posedge clk);
                default input #0;
                input addr, data_in,read_en,write_en,data_out,rst,transaction_count;
        endclocking

        modport DRV (clocking drv_cb, input clk, rst);
        modport MON (clocking mon_cb, input clk, rst);
        modport DUT_MOD (input clk, rst, addr, data_in, read_en, write_en, output data_out);
endinterface

