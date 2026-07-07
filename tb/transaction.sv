`include "defines.svh"
`ifndef TRANSACTION_SV
`define TRANSACTION_SV
	class transaction;
			rand logic[`ADDR_WIDTH-1:0]addr;
			rand logic read_en,write_en;
			rand logic[`DATA_WIDTH-1:0]data_in;
			logic [`DATA_WIDTH-1:0]data_out;
			bit[$clog2(`TESTCASES)-1:0] transaction_count;
			bit rst;
			constraint address{
				addr inside{[0:25]};//[26:32] reserved
			}
			constraint read_write{
					read_en!=write_en;
			}
	endclass
`endif

