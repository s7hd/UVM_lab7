class yapp_tx_monitor extends uvm_monitor;
  
  // Declare the virtual interface
  virtual interface yapp_if vif;

  // Declare analysis port
  uvm_analysis_port #(yapp_packet) item_collected_port;

  // Register the component with the UVM Factory
  `uvm_component_utils(yapp_tx_monitor)
  
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    // Create the analysis port
    item_collected_port = new("item_collected_port", this);
  endfunction

  // Build phase: Retrieve the virtual interface from the UVM configuration database
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual yapp_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MONITOR", "Failed to get vif from config_db")
    end
  endfunction

  // Run phase: Monitor the TX activity
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Monitor run phase executing", UVM_LOW)
    
    // Wait for reset signal
    @(posedge vif.reset);
    @(negedge vif.reset);
    `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)

    forever begin 
      // Create a new packet object to store received data
      yapp_packet pkt = yapp_packet::type_id::create("pkt", this);

      // Concurrently collect data and trigger transactions
      fork
        // Capture the packet from the DUT using `collect_packet()`
        vif.collect_packet(pkt.length, pkt.addr, pkt.payload, pkt.parity);
        
        // Trigger a transaction at the start of a packet
        @(posedge vif.monstart) void'(begin_tr(pkt, "Monitor_YAPP_Packet"));
      join

      // Check packet parity
      pkt.parity_type = (pkt.parity == pkt.calc_parity()) ? GOOD_PARITY : BAD_PARITY;

      // End transaction recording
      end_tr(pkt);

      // Send collected packet to scoreboard via TLM port
      item_collected_port.write(pkt);

      // Print collected packet details
      `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", pkt.sprint()), UVM_LOW)
    end
  endtask

  // Start of Simulation Phase: Log when the simulation starts
  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "start_of_simulation phase", UVM_HIGH)
  endfunction
  
endclass

