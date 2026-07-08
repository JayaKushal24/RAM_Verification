`include "transaction.sv"

class driver;
        virtual dut_vif vif;
        transaction t1;
        transaction t2;
        mailbox #(transaction) gen_drv;
        mailbox #(transaction) drv_ref;

        int valid_read_count, valid_write_count;

        task drv_run;
        repeat(`TESTCASES) begin
                gen_drv.get(t1);
                t2=new t1;
                @(vif.drv_cb);
                t2.rst=vif.rst;
                vif.drv_cb.addr<=t1.addr;
                vif.drv_cb.data_in<=t1.data_in;
                vif.drv_cb.read_en<=t1.read_en;
                vif.drv_cb.write_en<=t1.write_en;
                vif.drv_cb.transaction_count <= t1.transaction_count;
                if(!vif.rst) begin
                        cg.sample();
                        if(t1.write_en && !t1.read_en)          valid_write_count++;
                        else if(t1.read_en && !t1.write_en)     valid_read_count++;
                end
                $display("[DRV sent:%0d] @%0t rst=%0d read=%0d write=%0d addr=%0d data_in=%0d",t1.transaction_count,$time,t2.rst,t1.read_en,t1.write_en,t1.addr,t1.data_in);
                drv_ref.put(t2);
        end
endtask

        covergroup cg;
                address: coverpoint t1.addr {
                        bins addr_low[]={[0:9]};
                        bins addr_mid[]={[10:17]};
                        bins addr_high[]={[18:25]};
                        illegal_bins reserved={[26:31]};
                }

                data_in: coverpoint t1.data_in {
                        bins data_all[]={[0:(2**(`DATA_WIDTH)-1)]};
                }

                read: coverpoint t1.read_en {
                        bins read_high={1};
                        bins read_low={0};
                }

                write: coverpoint t1.write_en {
                        bins write_high={1};
                        bins write_low={0};
                }

                read_addr: cross address,read;
                write_addr: cross address,write;
        endgroup

        function new(mailbox #(transaction) gen_drv,mailbox #(transaction) drv_ref,virtual dut_vif vif);
                this.vif=vif;
                this.gen_drv=gen_drv;
                this.drv_ref=drv_ref;
                cg=new();
        endfunction
endclass

