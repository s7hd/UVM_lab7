class yapp_tx_env extends uvm_env;
  
  // Component instances
  yapp_tx_agent agent;
  
  // Register with factory
  `uvm_component_utils(yapp_tx_env)
  
  // Component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // Build phase - construct agent
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = yapp_tx_agent::type_id::create("agent", this);
  endfunction
  
  // Start of simulation phase
  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "start_of_simulation phase", UVM_HIGH)
  endfunction
  
endclass