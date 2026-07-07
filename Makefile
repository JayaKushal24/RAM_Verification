

TOP=tb

compile:
		vlib work
		vlog rtl/*.v
		vlog tb/*.sv

run:
		vsim  -c $(TOP) -do "run -all; quit"

clean:
		rm -rf work transcript

clean_cover:
		rm -rf covReport
		rm -rf verif_log.log	
		rm -rf verif_ucdb.ucdb

all: clean compile run
