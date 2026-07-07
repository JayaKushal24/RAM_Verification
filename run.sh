
echo "start of simulation"

vlog ./tb/testbench.sv
vsim -c tb -do " run -all">final_log.txt


echo "end of simulation"

vim final_log.txt
