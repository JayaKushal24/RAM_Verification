
`include "defines.svh"
`ifndef TRANSACTION_SV
`define TRANSACTION_SV
        class transaction;
                rand logic[`ADDR_WIDTH-1:0]addr;
                rand logic read_en,write_en;
                rand logic[`DATA_WIDTH-1:0]data_in;
                logic [`DATA_WIDTH-1:0]data_out;
                int transaction_count;
                bit rst;
                constraint address{
                        addr inside{[0:25]};//[26:31] reserved
                }
                constraint read_write{
                        read_en!=write_en;
                }
                virtual function transaction copy();
                        copy=new();
                        copy.addr=this.addr;
                        copy.read_en=this.read_en;
                        copy.write_en=this.write_en;
                        copy.data_in=this.data_in;
                        copy.data_out=this.data_out;
                        copy.transaction_count=this.transaction_count;
                        copy.rst=this.rst;
                endfunction
        endclass

        class transaction1 extends transaction;
                constraint read_write{
                        read_en inside {1};
                        write_en inside {0};
                }
                virtual function transaction copy();
                        transaction1 tr;
                        tr=new();
                        tr.addr=this.addr;
                        tr.read_en=this.read_en;
                        tr.write_en=this.write_en;
                        tr.data_in=this.data_in;
                        tr.data_out=this.data_out;
                        tr.transaction_count=this.transaction_count;
                        tr.rst=this.rst;
                        copy=tr;
                endfunction
        endclass

        class transaction2 extends transaction;
                constraint read_write{
                        read_en inside {0};
                        write_en inside {1};
                }
                virtual function transaction copy();
                        transaction2 tr;
                        tr=new();
                        tr.addr=this.addr;
                        tr.read_en=this.read_en;
                        tr.write_en=this.write_en;
                        tr.data_in=this.data_in;
                        tr.data_out=this.data_out;
                        tr.transaction_count=this.transaction_count;
                        tr.rst=this.rst;
                        copy=tr;
                endfunction
        endclass


        class transaction3 extends transaction;
                constraint read_write{
                        read_en==1;
                        write_en==1;
                }
                virtual function transaction copy();
                        transaction3 tr;
                        tr=new();
                        tr.addr=this.addr;
                        tr.read_en=this.read_en;
                        tr.write_en=this.write_en;
                        tr.data_in=this.data_in;
                        tr.data_out=this.data_out;
                        tr.transaction_count=this.transaction_count;
                        tr.rst=this.rst;
                        copy=tr;
                endfunction
        endclass

`endif
