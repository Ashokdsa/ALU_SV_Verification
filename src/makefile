.IGNORE:
	make clean
	make new_funct

all:
	make clean
	make new_funct
	make compile
	make clear
	make simulate

main:
	make clean
	vlog -sv +acc +cover +fcover -l alu.log top.sv
	make clear
	vsim -vopt work.top -voptargs=+acc=npr -assertdebug -l simulation.log -coverage -c -do "coverage save -onexit -assert -directive -cvg -codeAll alu_coverage.ucdb; run -all; exit"
	vcover report -html alu_coverage.ucdb -htmldir covReport -details

compile:
	vlog -sv top.sv

simulate:
	vsim -c top -do "run -all;exit"

clean:
	rm -rf work/ transcript 
	
new_funct:
	rm alu_funct_coverage.ucdb

read_cov:
	vcover report -details alu_funct_coverage.ucdb

clear:
	clear 
	clear
