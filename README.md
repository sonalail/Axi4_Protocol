# Axi4_Protocol
# Running the test
Using Questasim simulator
cd sim/questa_sim

# Compilation:  
make compile top_file=<top_file>

ex: make compile top_file=axi_top

# Simulation:
make run top_module=<module_name> arg="+UVM_TESTNAME= <testname>"

ex: make run top_module=axi_top arg="+UVM_TESTNAME=axi_write_read_test"

# Compilation with coverage:
make compile_with_cov top_file=<top_file>

ex: make compile_with_cov top_file=axi_top.sv

# Simulation with coverage:
make run_with_cov top_module=<module_name> arg="+UVM_TESTNAME= <testname>"

ex: make run_with_cov top_module=dma_top arg="+UVM_TESTNAME=axi_write_read_test"

# Wavefrom:  
make view &

# Clean:
make clean


