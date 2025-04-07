`include "uvm_macros.svh"
import uvm_pkg::*;
`include "packet_compare.sv" // Contains comp_equal

// Definition of analysis ports
`uvm_analysis_imp_decl(_yapp)
`uvm_analysis_imp_decl(_chan0)
`uvm_analysis_imp_decl(_chan1)
`uvm_analysis_imp_decl(_chan2)

class router_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(router_scoreboard)

  // Creating the analysis ports
  uvm_analysis_imp_yapp #(yapp_packet, router_scoreboard) yapp_imp;
  uvm_analysis_imp_chan0 #(channel_packet, router_scoreboard) chan0_imp;
  uvm_analysis_imp_chan1 #(channel_packet, router_scoreboard) chan1_imp;
  uvm_analysis_imp_chan2 #(channel_packet, router_scoreboard) chan2_imp;

  // Queue for each address
  yapp_packet q0[$];
  yapp_packet q1[$];
  yapp_packet q2[$];

  // Counters for YAPP and channel packets
  int yapp_count = 0;
  int chan_count = 0;
  int err = 0;

  // Constructor
  function new(string name = "router_scoreboard", uvm_component parent);
    super.new(name, parent);
    yapp_imp   = new("yapp_imp", this);
    chan0_imp  = new("chan0_imp", this);
    chan1_imp  = new("chan1_imp", this);
    chan2_imp  = new("chan2_imp", this);
  endfunction

  // Write YAPP packet function
  function void write_yapp(yapp_packet pkt);
    // Early exit if parity is bad, address is 3, or length is 0
    if (pkt.parity_type == bad_parity || pkt.addr == 3 || pkt.length == 0)
      return;

    yapp_packet pkt_copy;
    $cast(pkt_copy, pkt.clone());

    // Store the packet in the corresponding queue based on address
    case (pkt.addr)
      0: begin
        q0.push_back(pkt_copy);
        `uvm_info(get_type_name(), "Packet stored in q0", UVM_MEDIUM)
      end
      1: begin
        q1.push_back(pkt_copy);
        `uvm_info(get_type_name(), "Packet stored in q1", UVM_MEDIUM)
      end
      2: begin
        q2.push_back(pkt_copy);
        `uvm_info(get_type_name(), "Packet stored in q2", UVM_MEDIUM)
      end
    endcase

    yapp_count++;
  endfunction

  // Channel 0 write function
  function void write_chan0(channel_packet pkt);
    if (q0.size() == 0) return;
    yapp_packet yp = q0.pop_front();
    if (!comp_equal(yp, pkt)) begin
      err++;
      `uvm_warning(get_type_name(), "Mismatch detected on chan0")
    end
    chan_count++;
  endfunction

  // Channel 1 write function
  function void write_chan1(channel_packet pkt);
    if (q1.size() == 0) return;
    yapp_packet yp = q1.pop_front();
    if (!comp_equal(yp, pkt)) begin
      err++;
      `uvm_warning(get_type_name(), "Mismatch detected on chan1")
    end
    chan_count++;
  endfunction

  // Channel 2 write function
  function void write_chan2(channel_packet pkt);
    if (q2.size() == 0) return;
    yapp_packet yp = q2.pop_front();
    if (!comp_equal(yp, pkt)) begin
      err++;
      `uvm_warning(get_type_name(), "Mismatch detected on chan2")
    end
    chan_count++;
  endfunction

  // Packet comparison function
  function bit comp_equal(yapp_packet yp, channel_packet cp);
    // Check for address mismatch
    if (yp.addr != cp.addr) begin
      `uvm_error("PKT_COMPARE", $sformatf("Address mismatch: YAPP %0d vs CHAN %0d", yp.addr, cp.addr))
      return 0;
    end
    // Check for length mismatch
    if (yp.length != cp.length) begin
      `uvm_error("PKT_COMPARE", $sformatf("Length mismatch: YAPP %0d vs CHAN %0d", yp.length, cp.length))
      return 0;
    end
    // Check for payload mismatch
    foreach (yp.payload[i])
      if (yp.payload[i] != cp.payload[i]) begin
        `uvm_error("PKT_COMPARE", $sformatf("Payload[%0d] mismatch: YAPP %0d vs CHAN %0d", i, yp.payload[i], cp.payload[i]))
        return 0;
      end
    return 1;
  endfunction

  // Report phase function
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    $display("\n========== TEST REPORT ==========\n");
    $display("YAPP Packets Received   : %0d", yapp_count);
    $display("Channel Packets Matched : %0d", chan_count);
    $display("Mismatched Packets      : %0d", err);
    $display("Queue status -> q0:%0d, q1:%0d, q2:%0d\n", q0.size(), q1.size(), q2.size());

    if (err || yapp_count != chan_count) begin
      $display("TEST FAILED\n");
    end else begin
      $display("TEST PASSED\n");
    end

    $display("=================================\n");
  endfunction

endclass : router_scoreboard

