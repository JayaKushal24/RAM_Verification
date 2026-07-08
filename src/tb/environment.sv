`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "reference_model.sv"

class environment;
        mailbox #(transaction) gen_drv=new();
        mailbox #(transaction) mbx_mon_sco=new();
        mailbox #(transaction) drv_ref=new();
        mailbox #(transaction) ref_sco=new();

        virtual dut_vif vif;

        generator gen;
        driver drv;
        monitor mon;
        scoreboard sco;
        reference_model ref_model;

        task report;
                $display("Total cases=%d \npass count= %d \nfail count= %d", (sco.pass_count+sco.fail_count), sco.pass_count, sco.fail_count);
                $display("Valid reads=%d \nvalid write=%d \n ", drv.valid_read_count, drv.valid_write_count);
        endtask


        function new(virtual dut_vif vif);
                this.vif=vif;
                gen=new(gen_drv);
                drv=new(gen_drv,drv_ref,vif);
                ref_model=new(drv_ref,ref_sco);
                mon=new(mbx_mon_sco,vif);
                sco=new(mbx_mon_sco,ref_sco);
        endfunction

        task test();
                fork
                        gen.gen_run();
                        drv.drv_run();
                        ref_model.ref_model_run();
                        mon.mon_run();
                        sco.sco_run();
                join
        endtask
endclass

