`include "transaction.sv"

class generator;
        transaction t1;
        int txn_count;
        mailbox #(transaction) gen_drv;

        function new(mailbox #(transaction) gen_drv);
                this.gen_drv=gen_drv;
                t1=new();
        endfunction

        task gen_run;
                repeat(`TESTCASES) begin
                        txn_count++;
                        t1.transaction_count=txn_count;
                        assert(t1.randomize());
                        gen_drv.put(t1.copy);
                  $display("[GEN sent:%d]   @%0t read=%d write=%d addr=%d data_in=%d", t1.transaction_count,$time,t1.read_en,t1.write_en,t1.addr,t1.data_in);
                end
        endtask
endclass

