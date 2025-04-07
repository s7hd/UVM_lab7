class router_tb extends uvm_env;

  // UVC handles
  yapp_tx_env yapp;
  channel_env chan0, chan1, chan2;
  hbus_env hbus;
  clock_and_reset_env clk_rst;

  // Multichannel sequencer
  router_mcsequencer mcseqr;

  `uvm_component_utils(router_tb)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("BUILD", "Router testbench build phase executing", UVM_HIGH)

    yapp = yapp_tx_env::type_id::create("yapp", this);

    chan0 = channel_env::type_id::create("chan0", this);
    chan1 = channel_env::type_id::create("chan1", this);
    chan2 = channel_env::type_id::create("chan2", this);

    uvm_config_int::set(this, "chan0", "channel_id", 0);
    uvm_config_int::set(this, "chan1", "channel_id", 1);
    uvm_config_int::set(this, "chan2", "channel_id", 2);

    hbus = hbus_env::type_id::create("hbus", this);
    uvm_config_int::set(this, "hbus", "num_masters", 1);
    uvm_config_int::set(this, "hbus", "num_slaves", 0);

    clk_rst = clock_and_reset_env::type_id::create("clk_rst", this);

    //create the multichannel sequencer
    mcseqr = router_mcsequencer::type_id::create("mcseqr", this);
  endfunction
  
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("CONNECT", "Router testbench connect phase executing", UVM_HIGH)

 mc_seqr.yapp_seqr = uvc0.agt.seqr;
 mc_seqr.hbus_seqr = hbus.masters[0].sequencer;
  
 endfunction
  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "start_of_simulation phase", UVM_HIGH)
  endfunction

endclass

