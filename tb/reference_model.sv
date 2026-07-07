`include "defines.svh"
`include "transaction.sv"

class reference_model;
        logic[`DATA_WIDTH-1:0]ref_mem[0:(2**(`ADDR_WIDTH)-1)];
        logic[`DATA_WIDTH-1:0]last_data_out;
        transaction t2;
        mailbox #(transaction)drv_ref;
        mailbox #(transaction)ref_sco;
        function new(mailbox #(transaction)drv_ref,mailbox #(transaction)ref_sco);
            this.drv_ref=drv_ref;
            this.ref_sco=ref_sco;
        endfunction


        task ref_model_run;
            forever begin
                drv_ref.get(t2);
//              @(posedge clk);
		if(t2.rst) begin
		      foreach(ref_mem[i])
			      ref_mem[i]=0;
		      last_data_out='bz;
		      t2.data_out='bz;
		end
		else if(t2.write_en && !t2.read_en)begin
                    ref_mem[t2.addr]=t2.data_in;
                    t2.data_out=last_data_out;
                end
		else if (t2.read_en && !t2.write_en)begin
                    t2.data_out=ref_mem[t2.addr];
                    last_data_out=t2.data_out;
                end
                else t2.data_out=last_data_out;
          	$display("[REF got %d] @%0t rst=%0d read=%0d write=%0d addr=%0d data_in=%0d data_out=%0d",t2.transaction_count,$time,t2.rst,t2.read_en,t2.write_en,t2.addr,t2.data_in,t2.data_out);	  
		ref_sco.put(t2);
            end
        endtask
endclass
