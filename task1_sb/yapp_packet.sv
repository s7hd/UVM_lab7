// Enum type for parity control
typedef enum bit {GOOD_PARITY, BAD_PARITY} parity_type_e;

class yapp_packet extends uvm_sequence_item;
  // Packet fields based on YAPP specification
  rand bit [1:0]  addr;     // 2-bit address specifier for the channel
  rand bit [5:0]  length;   // 6-bit length specifier for payload size
  rand bit [7:0]  payload[];// Variable payload array
  bit [7:0]       parity;   // Parity byte
  
  // Control knobs
  rand parity_type_e parity_type;
  rand int packet_delay;
  
  // UVM automation macros
  `uvm_object_utils_begin(yapp_packet)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(length, UVM_ALL_ON)
    `uvm_field_array_int(payload, UVM_ALL_ON)
    `uvm_field_int(parity, UVM_ALL_ON)
    `uvm_field_enum(parity_type_e, parity_type, UVM_ALL_ON)
    `uvm_field_int(packet_delay, UVM_ALL_ON)
  `uvm_object_utils_end
  
  // Constructor
  function new(string name = "yapp_packet");
    super.new(name);
  endfunction
  
  // Calculate correct parity (XOR of header and payload)
  function bit [7:0] calc_parity();
    bit [7:0] header;
    header = {addr, length};
    calc_parity = header;
    for (int i = 0; i < payload.size(); i++)
      calc_parity ^= payload[i];
    return calc_parity;
  endfunction
  
  // Set parity based on parity_type
  function void set_parity();
    if (parity_type == GOOD_PARITY)
      parity = calc_parity();
    else
      parity = ~calc_parity(); // Inverted (incorrect) parity
  endfunction
  
  // Automatically set parity after randomization
  function void post_randomize();
    set_parity();
  endfunction
  
  // Constraints
  // Valid address constraint (address 3 is illegal)
  constraint addr_valid_c {
    addr != 2'b11; // Address 3 is illegal
  }
  
  // Length and payload constraint
  constraint length_c {
    length inside {[1:63]}; // Length is 1 to 63 bytes
    payload.size() == length; // Payload size equals length
  }
  
  // Parity type constraint with 5:1 distribution favoring good parity
  constraint parity_dist_c {
    parity_type dist {GOOD_PARITY := 5, BAD_PARITY := 1};
  }
  
  // Packet delay constraint (1 to 20 cycles)
  constraint delay_c {
    packet_delay inside {[1:20]};
  }
endclass

// Short YAPP packet - Task 2 requirement
class short_yapp_packet extends yapp_packet;
  // Constructor
  function new(string name = "short_yapp_packet");
    super.new(name);
  endfunction

  // Register with factory
  `uvm_object_utils(short_yapp_packet)
  
  // Additional constraints for short packets
  constraint short_length_c {
    length < 15; // Limit packet length to less than 15
  }
  
  constraint addr_exclude_c {
    addr != 2; // Exclude address value of 2
  }
endclass