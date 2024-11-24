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
    logic packet_cnt_inc;
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

    assign packet_cnt_inc = byte_ready || Get_TX_Packet_Data; // For byte load from states or byte load from buffer

    PACKET_COUNTER (.INC_SIZE(8)) ( // Will increment by 8 for every byte added
        .clk(clk), .n_rst(n_rst), .clear(1'b0), 
        .count_enable(packet_cnt_inc), .rollover_val(10'd544),
        .count_out(packet_counter_TX) // , .rollover_flag(XXXX)
    );

    DATA_COUNTER (
        .clk(clk), .n_rst(n_rst), .clear(1'b0), 
        .count_enable(data_cnt_inc), .rollover_val(10'd544),
        .count_out(data_counter_TX) // , .rollover_flag(XXXX)
    );

    always_comb begin
        n_packet_TX = packet_TX;
        Get_TX_Packet_Data = 1'b0;
        packet_load_complete_TX = 1'b0;
        if(byte_ready_TX) begin
            n_packet_TX [(packet_counter_TX + 7) : (packet_counter_TX) ] = byte_TX;
        end

        if(c_state_TX == DATA_TX) begin
            if(data_counter_TX < Buffer_Occupancy) begin
                Get_TX_Packet_Data = 1'b1;
                if(data_counter_TX) begin
                    n_packet_TX [(packet_counter_TX + 7) : (packet_counter_TX) ] = TX_Packet_Data;
                end
            end

            else begin
                packet_load_complete_TX = 1'b1;
            end
        end
    end


endmodule