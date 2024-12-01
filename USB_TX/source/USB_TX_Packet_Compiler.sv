`timescale 1ns / 10ps

module USB_TX_Packet_Compiler(
    input logic clk, n_rst,
    input logic [2:0] c_state_TX,
    input logic [3:0] pID,
    input logic [6:0] Buffer_Occupancy,
    input logic [7:0] TX_Packet_Data,
    output logic Get_TX_Packet_Data, packet_load_complete_TX,
    output logic copy_signal,
    output logic [9:0] packet_counter_TX,
    output logic [543:0] packet_TX
);

    logic [543:0] n_packet_TX;
    logic [7:0] TX_Packet_Data_Buffer;
    logic packet_cnt_inc, data_cnt_inc;
    logic flag_pack, flag_count;
    logic n_copy_signal, n_packet_load_complete_TX;

    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            packet_TX <= 544'b0;
            TX_Packet_Data_Buffer <= 8'b0;
            copy_signal <= 1'b0;
            packet_load_complete_TX <= 1'b0;
        end
        else begin
            packet_TX <= n_packet_TX;
            TX_Packet_Data_Buffer <= TX_Packet_Data;
            copy_signal <= n_copy_signal;
            packet_load_complete_TX <= n_packet_load_complete_TX;
        end
    end

    logic [7:0] data_counter_TX;

    USB_TX_Counter #(.SIZE(10), .INC_SIZE(8)
    )
    PACKET_COUNTER( // Will increment by 8 for every byte added
        .clk(clk), .n_rst(n_rst), .clear(1'b0), 
        .count_enable(packet_cnt_inc), .rollover_val(10'd544),
        .count_out(packet_counter_TX), .rollover_flag(flag_pack)
    );

    USB_TX_Counter #(.SIZE(8)
    )DATA_COUNTER(
        .clk(clk), .n_rst(n_rst), .clear(1'b0), 
        .count_enable(data_cnt_inc), .rollover_val(8'd64),
        .count_out(data_counter_TX), .rollover_flag(flag_count)
    );

    always_comb begin
        n_packet_TX = packet_TX;

        Get_TX_Packet_Data = 1'b0;
        n_packet_load_complete_TX = packet_load_complete_TX;

        packet_cnt_inc = 1'b0;
        data_cnt_inc = 1'b0;

        n_copy_signal = 1'b0;

        if(c_state_TX == 3'd1) begin
            n_packet_TX[7:0] = 8'b00000001;
            packet_cnt_inc = 1'b1;
        end
        else if(c_state_TX == 3'd2) begin
            n_packet_TX[15:8] = {4'b0, pID};
            packet_cnt_inc = 1'b1;
            if(
                pID == 4'b0010 || // ACK
                pID == 4'b1010 || // NAK
                pID == 4'b1110    // STALL
            ) begin
                n_copy_signal = 1'b1;
                n_packet_load_complete_TX = 1'b1;
            end
        end

        else if(c_state_TX == 3'd5) begin
            n_copy_signal = 1'b1;
            packet_cnt_inc = 1'b1;
            n_packet_load_complete_TX = 1'b1;
        end
        
        else if(c_state_TX == 3'd4) begin
            if(Buffer_Occupancy >= 0) begin
                case(data_counter_TX)
                    8'd1: begin
                        n_packet_TX[23:16] = TX_Packet_Data_Buffer;
                    end
                    8'd2: begin
                        n_packet_TX[31:24] = TX_Packet_Data_Buffer;
                    end
                    8'd3: begin
                        n_packet_TX[39:32] = TX_Packet_Data_Buffer;
                    end
                    8'd4: begin
                        n_packet_TX[47:40] = TX_Packet_Data_Buffer;
                    end
                    8'd5: begin
                        n_packet_TX[55:48] = TX_Packet_Data_Buffer;
                    end

                endcase

                if(Buffer_Occupancy != 0) begin
                    Get_TX_Packet_Data = 1'b1;
                    packet_cnt_inc = 1'b1;
                    data_cnt_inc = 1'b1;
                    n_packet_load_complete_TX = 1'b0;
                end

                else begin
                    
                    case(data_counter_TX)
                        8'd0: begin
                            n_packet_TX[23:16] = 8'b11111111;
                        end
                        8'd1: begin
                            n_packet_TX[31:24] = 8'b11111111;
                        end
                        8'd2: begin
                            n_packet_TX[39:32] = 8'b11111111;
                        end
                        8'd3: begin
                            n_packet_TX[47:40] = 8'b11111111;
                        end
                        8'd4: begin
                            n_packet_TX[55:48] = 8'b11111111;
                        end
                    endcase     
                end    
            end
        end 
    end

endmodule

