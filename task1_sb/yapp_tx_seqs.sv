class yapp_base_seq extends uvm_sequence #(yapp_packet);
  `uvm_object_utils(yapp_base_seq)

  function new(string name="yapp_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body
endclass : yapp_base_seq

class yapp_5_packets extends yapp_base_seq;
  `uvm_object_utils(yapp_5_packets)

  function new(string name="yapp_5_packets");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_5_packets sequence", UVM_LOW)
    repeat(5)
      `uvm_do(req)
  endtask
endclass : yapp_5_packets

class yapp_1_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_1_seq)

  function new(string name = "yapp_1_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_1_seq", UVM_LOW)
    `uvm_do_with(req, { req.addr == 1; })
  endtask
endclass

class yapp_012_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_012_seq)

  function new(string name = "yapp_012_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_012_seq", UVM_LOW)
    `uvm_do_with(req, { req.addr == 0; })
    `uvm_do_with(req, { req.addr == 1; })
    `uvm_do_with(req, { req.addr == 2; })
  endtask
endclass

class yapp_111_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_111_seq)

  function new(string name = "yapp_111_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_111_seq", UVM_LOW)
    repeat (3) begin
      yapp_1_seq y1_seq = yapp_1_seq::type_id::create("y1_seq");
      `uvm_do_with(y1_seq, { req.addr == 1; })
    end
  endtask
endclass

class yapp_repeat_addr_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_repeat_addr_seq)
  rand bit [7:0] sqaddr;
  constraint valid_addr { sqaddr != 3; }

  function new(string name = "yapp_repeat_addr_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_repeat_addr_seq", UVM_LOW)
    `uvm_do_with(req, { req.addr == sqaddr; })
    `uvm_do_with(req, { req.addr == sqaddr; })
  endtask
endclass

class yapp_incr_payload_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_incr_payload_seq)

  function new(string name = "yapp_incr_payload_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_incr_payload_seq", UVM_LOW)
    `uvm_create(req)
    if (!req.randomize())
      `uvm_error(get_type_name(), "Randomization failed")
    for (int i = 0; i < req.length; i++)
      req.payload[i] = i;
    req.set_parity();
    `uvm_send(req)
  endtask
endclass

class yapp_88_seq extends yapp_base_seq;
  uvm_object_utils(yapp_88_seq)

  function new(string name = "yapp_88_seq");
    super.new(name);
  endfunction : new
  
task body();
  int parity_error_count = 0;
  for (int addr = 0; addr <= 3; addr++) begin
    for (int len = 1; len <= 22; len++) begin
      yapp_packet req;
      uvm_create(req)

      req.addr = addr;
      req.length = len;
      req.payload = new[len];
      foreach (req.payload[i])
        req.payload[i] = $urandom_range(0, 255);

      if ((parity_error_count < 18) && ($urandom_range(0, 99) < 20)) begin
        req.has_parity_error = 1;
        parity_error_count++;
      end else begin
        req.has_parity_error = 0;
      end

      uvm_send(req)
    end
  end
endtask

endclass : yapp_88_seq
    
