/*-----------------------------------------------------------------
File name     : hw_top_dut.sv
Developers    : Kathleen Meade, Brian Dickinson
Created       : 01/04/11
Description   : lab06_vif hardware top module for acceleration
              : Instantiates clock generator, interfaces, and DUT
Notes         : From the Cadence "SystemVerilog Accelerated Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

module hw_top;

  logic [31:0]  clock_period;
  logic         run_clock;
  logic         clock;
  logic         reset;

  // Instantiate Clock and Reset interface
  clock_and_reset_if clk_rst_if(
    .clock(clock),
    .reset(reset),
    .run_clock(run_clock), 
    .clock_period(clock_period));


  // Instantiate YAPP interface for DUT input
  yapp_if in0(clk_rst_if.clock, clk_rst_if.reset);

  // Instantiate three Channel interfaces for router outputs
  channel_if chan0_if(clk_rst_if.clock, clk_rst_if.reset);
  channel_if chan1_if(clk_rst_if.clock, clk_rst_if.reset);
  channel_if chan2_if(clk_rst_if.clock, clk_rst_if.reset);

  // Instantiate HBUS interface for host communication
  hbus_if hbus_if(clk_rst_if.clock, clk_rst_if.reset);

 
  clkgen clkgen (
      .clock(clock ),
      .run_clock(run_clock),
      .clock_period(clock_period)
    );

  // Instantiate the DUT (Router)
  yapp_router dut(
    .reset(reset),
    .clock(clock),
    .error(),
    // Connect YAPP interface signals
    .in_data(in0.in_data),
    .in_data_vld(in0.in_data_vld),
    .in_suspend(in0.in_suspend),

    // Connect output Channel interfaces
    .data_0(chan0_if.data),
    .data_vld_0(chan0_if.data_vld),
    .suspend_0(chan0_if.suspend),

    .data_1(chan1_if.data),
    .data_vld_1(chan1_if.data_vld),
    .suspend_1(chan1_if.suspend),

    .data_2(chan2_if.data),  
    .data_vld_2(chan2_if.data_vld),
    .suspend_2(chan2_if.suspend),

    // Connect HBUS interface signals
    .haddr(hbus_if.haddr),
    .hdata(hbus_if.hdata_w),
    .hen(hbus_if.hen),
    .hwr_rd(hbus_if.hwr_rd)
  );

endmodule