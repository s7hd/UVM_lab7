class yapp_tx_agent extends uvm_agent;
  
  // Component instances
  yapp_tx_monitor   monitor;
  yapp_tx_driver    driver;
  yapp_tx_sequencer sequencer;
  
  // Register with factory
  `uvm_component_utils_begin(yapp_tx_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end
  
  // Component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // Build phase - construct all components
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Always create the monitor
    monitor = yapp_tx_monitor::type_id::create("monitor", this);
    
    // Create driver and sequencer only for active agents
    if(is_active == UVM_ACTIVE) begin
      driver = yapp_tx_driver::type_id::create("driver", this);
      sequencer = yapp_tx_sequencer::type_id::create("sequencer", this);
    end
  endfunction
  
  // Connect phase - connect components
  function void connect_phase(uvm_phase phase);
    if(is_active == UVM_ACTIVE) begin
      // Connect sequencer to driver
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction
  
  // Start of simulation phase
  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "start_of_simulation phase", UVM_HIGH)
  endfunction
  
endclass