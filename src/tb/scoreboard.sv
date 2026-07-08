`include "transaction.sv"

class scoreboard;
        mailbox #(transaction) mbx_mon_sco;
        mailbox #(transaction) ref_sco;
        transaction t1, t2;
        int pass_count, fail_count;

        function new(mailbox #(transaction) mbx_mon_sco, mailbox #(transaction) ref_sco);
                this.mbx_mon_sco = mbx_mon_sco;
                this.ref_sco = ref_sco;
        endfunction

        task sco_run;
                repeat(`TESTCASES) begin
                        mbx_mon_sco.get(t1);
                        ref_sco.get(t2);
                        if(t1.transaction_count!=t2.transaction_count)          $error("Transaction mismatch: MON=%0d REF=%0d",t1.transaction_count,t2.transaction_count);
                        if(t1.data_out===t2.data_out) begin
                                $display("PASS @%0t transaction No:%d",$time,t2.transaction_count);
                                pass_count++;
                        end
                        else begin
                                $display("FAIL @%0t Transaction=%0d Expected=%0h Got=%0h",$time,t2.transaction_count,t2.data_out,t1.data_out);
                                fail_count++;
                        end
                        $display("****************************************************************");
                end
        endtask
endclass


