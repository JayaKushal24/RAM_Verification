`include "environment.sv"

class test;
        environment env;
        virtual dut_vif vif;
        function new(virtual dut_vif vif);
                this.vif=vif;
                env=new(vif);
        endfunction

        virtual task start();
                env.test();
                env.report();
                $finish;
        endtask
endclass

class read_test extends test;
        transaction1 tr;
        function new(virtual dut_vif vif);
                super.new(vif);
                tr=new();
                env.gen.t1=tr;
        endfunction
endclass

class write_test extends test;
        transaction2 tr;
        function new(virtual dut_vif vif);
                super.new(vif);
                tr=new();
                env.gen.t1=tr;
        endfunction
endclass

class simultaneous_test extends test;
        transaction3 tr;
        function new(virtual dut_vif vif);
                super.new(vif);
                tr=new();
                env.gen.t1=tr;
        endfunction
endclass

class test_regression extends test;
        transaction  tr0;
        transaction1 tr1;
        transaction2 tr2;
        transaction3 tr3;

        function new(virtual dut_vif vif);
                super.new(vif);
        endfunction

        task run_test(transaction tr);
//                env=new(vif);
                env.gen.t1=tr;
                env.test();
                env.report();
        endtask

        virtual task start();

                tr0=new();
                run_test(tr0);

                tr1=new();
                run_test(tr1);

                tr2=new();
                run_test(tr2);

                tr3=new();
                run_test(tr3);

                $finish;
        endtask

endclass

