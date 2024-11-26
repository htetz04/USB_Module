`timescale 1ns / 10ps

module USB_TX_Packet_Loader (
    input logic clk, n_rst,
    input logic bit_en_TX, packet_load_complete_TX,
    input logic [543:0] packet_TX,
    input logic [9:0] packet_counter,
    output logic complete_TX,
    output logic DP_OUT, DM_OUT
);

always_comb begin
    complete_TX = 1'b0;
    DP_OUT = 1'b1;
    DM_OUT = 1'b0;
end



endmodule

