module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import UVC packages
  import yapp_pkg::*;
  import clock_and_reset_pkg::*;
  import hbus_pkg::*;
  import channel_pkg::*;

  // Include testbench and test components
  `include "router_tb.sv"
  `include "router_test_lib.sv"
  `include "router_scoreboard.sv"
  `include "router_mcsequencer.sv"
  `include "router_mcseqs_lib.sv"


  // Set the virtual interfaces for UVCs
  initial begin
    yapp_vif_config::set(null , "*uvc0*" , "vif" , hw_top.in0);
    hbus_vif_config::set(null , "*hbus*" , "vif" , hw_top.hbus_if);
    clock_and_reset_vif_config::set(null , "*clk_rst*" , "vif" , hw_top.clk_rst_if);
    channel_vif_config::set(null , "*ch0*" , "vif" , hw_top.chan0_if);
    channel_vif_config::set(null , "*ch1*" , "vif" , hw_top.chan1_if);
    channel_vif_config::set(null , "*ch2*" , "vif" , hw_top.chan2_if);

    // Start UVM test
    run_test();
  end
endmodule : top
