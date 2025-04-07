class yapp_tx_driver extends uvm_driver #(yapp_packet);
  
  // Declare the virtual interface
  virtual interface yapp_if vif;

  // Register with the factory for UVM automation
  `uvm_component_utils(yapp_tx_driver)
  
  int num_sent = 0;
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: Retrieve the virtual interface from the UVM configuration database
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual yapp_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("DRIVER", "Failed to get vif from config_db")
    end
  endfunction

  // UVM run phase: Manage transactions and reset behavior
  virtual task run_phase(uvm_phase phase);
    fork
      get_and_drive();   // Get packets and drive them to the DUT
      reset_signals();   // Handle reset behavior
    join
  endtask

  // Task to get packets from the sequencer and send them to the DUT
  task get_and_drive();
    // Wait for reset to complete before sending packets
    @(posedge vif.reset);
    @(negedge vif.reset);
    `uvm_info(get_type_name(), "Reset dropped - Ready to transmit packets", UVM_MEDIUM)

    forever begin
      // Get new transaction from the sequencer
      seq_item_port.get_next_item(req);
      `uvm_info(get_type_name(), $sformatf("Sending Packet :\n%s", req.sprint()), UVM_HIGH)
       
      // Concurrently drive the packet and record the transaction
      fork
        // Send packet to DUT
        begin
          // Copy payload data into the interface memory
          foreach (req.payload[i])
            vif.payload_mem[i] = req.payload[i];

          // Transmit packet data using the interface method
          vif.send_to_dut(req.length, req.addr, req.parity, req.packet_delay);
        end

        // Trigger transaction at start of packet (when drvstart is asserted)
        @(posedge vif.drvstart) void'(begin_tr(req, "Driver_YAPP_Packet"));
      join

      // End transaction recording
      end_tr(req);

      // Communicate that the transaction is done
      seq_item_port.item_done();
    end
  endtask

  // Task to reset all TX signals when reset is active
  task reset_signals();
    forever vif.yapp_reset();
  endtask

  // Report phase: Log the number of packets sent
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: YAPP TX driver sent %0d packets", num_sent), UVM_LOW)
  endfunction

  // Start of Simulation Phase: Log when the simulation starts
  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Start of simulation phase", UVM_HIGH)
  endfunction

endclass
