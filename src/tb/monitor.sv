`include "transaction.sv"

class monitor;
        mailbox #(transaction) mbx_mon_sco;
        virtual dut_vif.MON vif;
        transaction t1;

        function new(mailbox #(transaction) mbx_mon_sco, virtual dut_vif.MON vif);
                this.vif=vif;
                this.mbx_mon_sco=mbx_mon_sco;
        endfunction

        task mon_run;
             @(vif.mon_cb);
                repeat(`TESTCASES) begin
                        @(vif.mon_cb);
                        t1=new();
                        t1.data_out=vif.mon_cb.data_out;
                        t1.rst=vif.mon_cb.rst;
                        t1.transaction_count=vif.mon_cb.transaction_count;
                        t1.addr=vif.mon_cb.addr;
                        t1.data_in=vif.mon_cb.data_in;
                        t1.read_en=vif.mon_cb.read_en;
                        t1.write_en=vif.mon_cb.write_en;
                        $display("[MON got:%0d] @%0t rst=%0d read=%0d write=%0d addr=%0d data_in=%0d data_out=%0h",t1.transaction_count,$time,t1.rst,t1.read_en,t1.write_en,t1.addr,t1.data_in,t1.data_out);
                        mbx_mon_sco.put(t1);
                end
        endtask
endclass

