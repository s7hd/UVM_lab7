class router_mcsequencer extends uvm_component;
  `uvm_component_utils(router_mcsequencer)

  
  function new(string name = "router_mcsequencer", uvm_component parent);
    super.new(name, parent);
  endfunction : new

 uvm_sequencer#(yapp_packet) yapp_seqr;
   hbus_master_sequencer   hbus_seqr;

endclass : router_mcsequencer

