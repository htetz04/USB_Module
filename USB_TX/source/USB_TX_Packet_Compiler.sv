`timescale 1ns / 10ps

module USB_TX_Packet_Compiler(
    input logic clk, n_rst,
    input logic [2:0] c_state_TX,
    input logic [3:0] pID,
    input logic [6:0] Buffer_Occupancy,
    input logic [7:0] TX_Packet_Data,
    output logic Get_TX_Packet_Data, packet_load_complete_TX,
    output logic [9:0] packet_counter_TX,
    output logic [543:0] packet_TX
);

    logic [543:0] n_packet_TX;
    logic packet_cnt_inc, data_cnt_inc;
    logic [7:0] TX_Packet_Data_Buffer;
    logic [7:0] data_counter_TX;


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

    
    USB_TX_Counter #(.SIZE(10), .INC_SIZE(8)
    )
    PACKET_COUNTER( // Will increment by 8 for every byte added
        .clk(clk), .n_rst(n_rst), .clear(1'b0), 
        .count_enable(packet_cnt_inc), .rollover_val(10'd544),
        .count_out(packet_counter_TX) // , .rollover_flag(XXXX)
    );

    USB_TX_Counter #(.SIZE(8)
    )DATA_COUNTER(
        .clk(clk), .n_rst(n_rst), .clear(1'b0), 
        .count_enable(data_cnt_inc), .rollover_val(8'd64),
        .count_out(data_counter_TX) // , .rollover_flag(XXXX)
    );

    always_comb begin
        n_packet_TX = packet_TX;
        Get_TX_Packet_Data = 1'b1;
        packet_load_complete_TX = 1'b0;
        packet_cnt_inc = 1'b0;
        
        if(c_state_TX == 3'd1) begin // SYNC_TX
            n_packet_TX [7:0] = 8'b00000001;
            packet_cnt_inc = 1'b1;
        end
        else if(c_state_TX == 3'd2) begin // PID_TX
            n_packet_TX [15:8] = {4'b0, pID};
            packet_cnt_inc = 1'b1;
        end
        
        // else if(c_state_TX == 3'd4) begin // If state is DATA
        //     if(data_counter_TX < Buffer_Occupancy) begin
        //         Get_TX_Packet_Data = 1'b1;
                
        //         if(data_counter_TX == 8'b0) begin
        //         end

        //         else if(data_counter_TX == 8'b1) begin
        //             n_packet_TX [21:15] = 8'b1111;
        //         end

        //         data_cnt_inc = 1'b1;
        //     end
        //     else begin
        //         packet_load_complete_TX = 1'b1;
        //     end
        // end

    end


endmodule
