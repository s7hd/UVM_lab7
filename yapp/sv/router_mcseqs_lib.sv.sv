class router_simple_mcseq extends uvm_sequence;
  `uvm_object_utils(router_simple_mcseq)
  `uvm_declare_p_sequencer(router_mcsequencer)

 
  function new(string name = "router_simple_mcseq");
    super.new(name);
  endfunction


  virtual task body();

    `uvm_info(get_type_name(), "Starting router_simple_mcseq", UVM_LOW)

    if (starting_phase != null)
      starting_phase.raise_objection(this, "Starting multichannel sequence");

    //set router to accept small packets (maxpktsize = 20) and enable
    hbus_small_packet_seq set_small_seq;
    `uvm_do_on(set_small_seq, p_sequencer.hbus_seqr)

    //read maxpktsize to verify it is 20
    hbus_read_max_pkt_seq read_pkt_small;
    `uvm_do_on(read_pkt_small, p_sequencer.hbus_seqr)

    //send 6 packets to addresses 0,1,2 using yapp_012_seq
    repeat (6) begin
      yapp_012_seq y012_seq;
      `uvm_do_on(y012_seq, p_sequencer.yapp_seqr)
    end

    //set router to accept large packets (maxpktsize = 63)
    hbus_set_default_regs_seq set_large_seq;
    `uvm_do_on(set_large_seq, p_sequencer.hbus_seqr)

    //read maxpktsize to verify it is 63
    hbus_read_max_pkt_seq read_pkt_large;
    `uvm_do_on(read_pkt_large, p_sequencer.hbus_seqr)

    //Send 6 random YAPP packets
    repeat (6) begin
      yapp_base_seq rand_seq;
      `uvm_do_on(rand_seq, p_sequencer.yapp_seqr)
    end

    if (starting_phase != null)
      starting_phase.drop_objection(this, "Completed multichannel sequence");

    `uvm_info(get_type_name(), "Completed router_simple_mcseq", UVM_LOW)

  endtask : body

endclass : router_simple_mcseq

