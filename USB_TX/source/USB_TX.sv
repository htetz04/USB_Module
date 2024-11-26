`timescale 1ns / 10ps

module USB_TX(
    input logic [3:0] TX_Packet,
    input logic [6:0] Buffer_Occupancy,
    input logic [7:0] TX_Packet_Data,
    output logic TX_Transfer_Active, TX_Error,
    output logic DP_OUT, DM_OUT
);

    logic packet_load_complete_TX, complete_TX;
    logic [2:0] out_state_TX;
    logic [3:0] pID;

    logic Get_TX_Packet_Data;
    logic [9:0] packet_counter_TX;
    logic [543:0] packet_TX;

    logic bit_en_TX;

USB_TX_States STATES(
    .clk(clk), .n_rst(n_rst),
    .packet_load_complete_TX(packet_load_complete_TX),
    .complete_TX(complete_TX),
    .TX_Packet(TX_Packet), .TX_Transfer_Active(TX_Transfer_Active), .TX_Error(TX_Error),
    .out_state_TX(out_state_TX), .pID(pID)
);

USB_TX_Packet_Compiler COMPILE(
    .clk(clk), .n_rst(n_rst),
    .c_state_TX(out_state_TX), .pID(pID),
    .Buffer_Occupancy(Buffer_Occupancy), .TX_Packet_Data(TX_Packet_Data),
    .Get_TX_Packet_Data(Get_TX_Packet_Data), .packet_load_complete_TX(packet_load_complete_TX),
    .packet_counter_TX(packet_counter_TX), .packet_TX(packet_TX)
);

USB_TX_Output_Clock OUT_CLK(
    .clk(clk), .n_rst(n_rst),
    .packet_load_complete_TX(packet_load_complete_TX),
    .bit_en_TX(bit_en_TX)
);

USB_TX_Packet_Loader LOAD(
    .clk(clk), .n_rst(n_rst),
    .bit_en_TX(bit_en_TX),
    .packet_load_complete_TX(packet_load_complete_TX),
    .packet_TX(packet_TX),
    .packet_counter(packet_counter),
    .complete_TX(complete_TX),
    .DP_OUT(DP_OUT), .DM_OUT(DM_OUT)
);


endmodule