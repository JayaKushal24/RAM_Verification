`include "transaction.sv"
class monitor;
        mailbox #(transaction)mbx_mon_sco;
        virtual dut_vif vif;
        transaction t1;
        event mon_done;
		function new(mailbox #(transaction)mbx_mon_sco,virtual dut_vif vif,event mon_done);
            this.vif=vif;
            this.mon_done=mon_done;
            this.mbx_mon_sco=mbx_mon_sco;
        endfunction
        task mon_run;
            @(posedge vif.clk);
            forever begin
				@(posedge vif.clk);
                #1;
                t1=new();
		t1.data_out=vif.data_out;
	    	t1.rst=vif.rst;
                t1.transaction_count= vif.transaction_count;
                $display("[MON got:%0d] @%0t rst=%0d data_out=%0h",t1.transaction_count,$time,t1.rst,t1.data_out);
	    	mbx_mon_sco.put(t1);
		->mon_done;
            end
        endtask
endclass

