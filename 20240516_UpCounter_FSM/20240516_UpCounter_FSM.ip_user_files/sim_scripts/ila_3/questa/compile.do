vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -sv "+incdir+../../../../20240516_UpCounter_FSM.gen/sources_1/ip/ila_3/hdl/verilog" \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93 \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  "+incdir+../../../../20240516_UpCounter_FSM.gen/sources_1/ip/ila_3/hdl/verilog" \
"../../../../20240516_UpCounter_FSM.gen/sources_1/ip/ila_3/sim/ila_3.v" \

vlog -work xil_defaultlib \
"glbl.v"

