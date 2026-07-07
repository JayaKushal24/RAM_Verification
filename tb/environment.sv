`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "reference_model.sv"

class environment;
        mailbox #(transaction) gen_drv=new();
        mailbox #(transaction) mbx_mon_sco=new();
        mailbox #(transaction)drv_ref=new();
        mailbox #(transaction)ref_sco=new();
//      event drv_done;
        event mon_done;
		
//      logic clk,rst;

        generator gen;
        driver drv;
        monitor mon;
        scoreboard sco;
        reference_model ref_model;

        task report;
            $display("Total cases=%d \npass count= %d \nfail count= %d",(sco.pass_count+sco.fail_count),sco.pass_count,sco.fail_count);
            $display("Valid reads=%d \nvalid write=%d \n ",drv.valid_read_count,drv.valid_write_count);
        endtask

        virtual dut_vif vif;
//      dut_vif vif(clk,rst);
//      dut_ram dut(.clk(vif.clk),.rst(vif.rst),.read_en(vif.read_en),.write_en(vif.write_en),.addr(vif.addr),.data_in(vif.data_in),.data_out(vif.data_out));

        function new(virtual dut_vif vif);
            this.vif=vif;
            gen=new(gen_drv);
            drv=new(gen_drv,drv_ref,vif);
            ref_model=new(drv_ref,ref_sco);
            mon=new(mbx_mon_sco,vif,mon_done);
            sco=new(mbx_mon_sco,ref_sco,mon_done);
        endfunction

        task test();
            fork
                gen.gen_run();
                drv.drv_run();
                ref_model.ref_model_run();
                mon.mon_run();
                sco.sco_run();
            join_none
        endtask
endclass

