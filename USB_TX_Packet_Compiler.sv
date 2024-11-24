`timescale 1ns/10ps

module USB_TX_Packet_Compiler(
    input logic clk, n_rst,
    input logic byte_ready_TX,
    input logic [2:0] c_state_TX,
    input logic [6:0] Buffer_Occupancy,
    input logic [7:0] byte_TX, TX_Packet_Data,
    output logic Get_TX_Packet_Data, packet_load_complete_TX,
    output logic [9:0] packet_counter_TX,
    output logic [543:0] packet_TX
);

    logic [543:0] n_packet_TX;
    logic packet_cnt_inc, data_cnt_inc;
    loigc [7:0] TX_Packet_Data_Buffer;

    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            packet_TX <= 544'b0;
            TX_Packet_Data_Buffer <= 8'b0;
        end
        else begin
            packet_TX <= n_packet_TX;
            TX_Packet_Data_Buffer <= TX_Packet_Data;
        end
    end

     USB_TX_Counter #(.SIZE(4)) (
        .clk(clk), .n_rst(n_rst), .clear(clear), 
        .count_enable(count_enable), .rollover_val(XXXX),
        .count_out(XXXX), .rollover_flag(XXXX)
    );

endmodule