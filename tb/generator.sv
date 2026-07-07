`include "transaction.sv"

class generator;
        transaction t1;
//      int test_cases;
        int txn_count;
        mailbox #(transaction)gen_drv;
//      event drv_done;
        function new(mailbox #(transaction)gen_drv);
			this.gen_drv=gen_drv;
//          this.drv_done=drv_done;
        endfunction
        task gen_run;
            repeat(`TESTCASES) begin
                t1=new();
                txn_count++;
                t1.transaction_count=txn_count;
                if(`EQUAL_READ_WRITE)   t1.read_write.constraint_mode(0);
                assert(t1.randomize());
                gen_drv.put(t1);
                $display("[GEN sent:%d]   @%0t read=%d write=%d addr=%d data_in=%d",t1.transaction_count,$time,t1.read_en,t1.write_en,t1.addr,t1.data_in);
//              @(drv_done);
            end
        endtask
endclass

