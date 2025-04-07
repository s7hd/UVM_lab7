class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  router_tb tb; //handle 

  // Constructor
  function new(string name = "base_test", uvm_component parent);
    super.new(name, parent);
    `uvm_info("Test : ","Constructor!",UVM_LOW);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("Test : ","Build Phase!",UVM_HIGH);
    tb = router_tb :: type_id :: create("tb", this);

    // Enable transaction recording
    uvm_config_int::set(this, "*", "recording_detail", 1);
  endfunction

  // End of elaboration phase
  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

  // Run phase - set drain time for objection mechanism
  virtual task run_phase(uvm_phase phase);
    uvm_objection obj = phase.get_objection();
    obj.set_drain_time(this, 200ns);
  endtask

  // Check phase - check config usage
  function void check_phase(uvm_phase phase);
    check_config_usage();
  endfunction
endclass

//------------------------------------------------------------------------------
// NEW TEST: yapp_012_test - Sets default sequence to yapp_012_seq
//------------------------------------------------------------------------------
// class yapp_012_test extends base_test;
//   `uvm_component_utils(yapp_012_test)

//   // Constructor
//   function new(string name = "yapp_012_test", uvm_component parent);
//     super.new(name, parent);
//     `uvm_info("yapp_012_test : ","Constructor!",UVM_LOW);
//   endfunction

//   // Build phase
//   function void build_phase(uvm_phase phase);
//     `uvm_info("yapp_012_test : ","Build Phase!",UVM_HIGH);
    
//     // Set the default sequence to yapp_012_seq
//     uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase", "default_sequence", yapp_012_seq::get_type());
    
//     // Call parent's build phase
//     super.build_phase(phase);
//   endfunction
// endclass

//////////////////////////


class simple_test extends base_test;
  `uvm_component_utils(simple_test)

  // Constructor
  function new(string name = "simple_test", uvm_component parent);
    super.new(name, parent);
    `uvm_info("simple_test : ","Constructor!",UVM_LOW);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info("simple_test : ","Build Phase!",UVM_HIGH);
    uvm_config_wrapper::set(this, "*uvc0.agt.seqr.run_phase",  "default_sequence", yapp_012_seq::get_type()); 
    uvm_config_wrapper::set(this, "*ch*",  "default_sequence", channel_rx_resp_seq::get_type()); 
    uvm_config_wrapper::set(this, "*clk_rst*",  "default_sequence", clk10_rst5_seq::get_type()); 
    uvm_config_int::set( this, "*", "recording_detail", 1); 
    `uvm_info(get_type_name(), "build_phase completed" , UVM_HIGH )

endfunction:build_phase


task run_phase(uvm_phase phase);
super.run_phase(phase);
endtask

endclass


class test_uvc_integration extends base_test;
  `uvm_component_utils(test_uvc_integration)

  function new(string name = "test_uvc_integration", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_wrapper::set(this, "*uvc0.agt.seqr.run_phase", "default_sequence", yapp_88_seq::get_type());
    uvm_config_wrapper::set(this, "*ch*", "default_sequence", channel_rx_resp_seq::get_type());
    uvm_config_wrapper::set(this, "*clk_rst*", "default_sequence", clk10_rst5_seq::get_type());
    uvm_config_wrapper::set(this, "*hbus*.m_sequencer.run_phase", "default_sequence", hbus_small_packet_seq::get_type());
    uvm_config_int::set(this, "*", "recording_detail", 1);

    `uvm_info(get_type_name(), "build_phase completed", UVM_HIGH)
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), "Starting run_phase for test_uvc_integration", UVM_MEDIUM)
  endtask : run_phase

endclass : test_uvc_integration


/////////////
class mc_simple_test extends base_test;
  `uvm_component_utils(mc_simple_test)

  function new(string name = "mc_simple_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_factory::get().set_type_override_by_type(
      yapp_packet_seq::get_type(), 
      yapp_short_packet_seq::get_type()
    );

    uvm_config_wrapper::set(this, "*ch*", "default_sequence", channel_rx_resp_seq::get_type());
    uvm_config_wrapper::set(this, "*clk_rst*", "default_sequence", clk10_rst5_seq::get_type());
    uvm_config_wrapper::set(this, "tb.mcseqr.run_phase", "default_sequence", router_simple_mcseq::get_type());


    super.build_phase(phase);
    `uvm_info(get_type_name(), "Starting run_phase for mc_simple_test", UVM_MEDIUM)
  endfunction
endclass

