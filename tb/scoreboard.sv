`include "transaction.sv"

class scoreboard;
        mailbox #(transaction)mbx_mon_sco;
        mailbox #(transaction)ref_sco;
        transaction t1,t2;
        event mon_done;
        int pass_count,fail_count;
        function new(mailbox #(transaction)mbx_mon_sco,mailbox #(transaction)ref_sco,event mon_done);
            this.mbx_mon_sco=mbx_mon_sco;
            this.ref_sco=ref_sco;
            this.mon_done=mon_done;
        endfunction
        task sco_run;
            forever begin
                @(mon_done);
                mbx_mon_sco.get(t1);
                ref_sco.get(t2);
                $display("[SCO_MON got:%d]@%0t data_out=%d",t1.transaction_count,$time,t1.data_out);
                $display("[SCO_REF got:%d]@%0t data_out=%d",t2.transaction_count,$time,t2.data_out);
                if(t1.data_out===t2.data_out)begin
                    $display("PASS@ time =%0t",$time);
                    pass_count++;
                end
                else begin
                    $display("FAIL @ time =%0t data_out(Expected:%d/got:%d)",$time,t1.data_out,t2.data_out);
                    fail_count++;
                end
                $display("************************************************************************************************8");

            end
        endtask
endclass

