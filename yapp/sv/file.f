# Add include directories for all UVCs
+incdir+../sv
+incdir+../../task1_integ
+incdir+../../channel/sv
+incdir+../../hbus/sv
+incdir+../../clock_and_reset/sv

# YAPP UVC files
../../task1_integ/yapp_pkg.sv      # Correct path to yapp_pkg.sv
../../task1_integ/yapp_if.sv      # Correct path to yapp_if.sv

# Clock and Reset UVC files
../../clock_and_reset/sv/clock_and_reset_if.sv
../../clock_and_reset/sv/clock_and_reset_pkg.sv

# HBUS UVC files
../../hbus/sv/hbus_pkg.sv
../../hbus/sv/hbus_if.sv

# Channel UVC files
../../channel/sv/channel_if.sv
../../channel/sv/channel_pkg.sv

# Multichannel components
../../task1_integ/router_mcsequencer.sv
../../task1_integ/router_mcseqs_lib.sv
../../task1_integ/router_test_lib.sv

# Main testbench files
../../yapp/sv/clkgen.sv   # Added clkgen.sv
../../task1_integ/yapp_router.sv
../../yapp/sv/hw_top_dut.sv   # Added hw_top_dut.sv
../../yapp/sv/tb_top.sv   # Changed top.sv to tb_top.sv


# Timescale
+timescale+1ns/1ns
