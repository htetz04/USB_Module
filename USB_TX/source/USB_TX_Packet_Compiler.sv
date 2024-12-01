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
                    8'd6: begin
                        n_packet_TX[63:56] = TX_Packet_Data_Buffer;
                    end
                    8'd7: begin
                        n_packet_TX[71:64] = TX_Packet_Data_Buffer;
                    end
                    8'd8: begin
                        n_packet_TX[79:72] = TX_Packet_Data_Buffer;
                    end
                    8'd9: begin
                        n_packet_TX[87:80] = TX_Packet_Data_Buffer;
                    end
                    8'd10: begin
                        n_packet_TX[95:88] = TX_Packet_Data_Buffer;
                    end
                    8'd11: begin
                        n_packet_TX[103:96] = TX_Packet_Data_Buffer;
                    end
                    8'd12: begin
                        n_packet_TX[111:104] = TX_Packet_Data_Buffer;
                    end
                    8'd13: begin
                        n_packet_TX[119:112] = TX_Packet_Data_Buffer;
                    end
                    8'd14: begin
                        n_packet_TX[127:120] = TX_Packet_Data_Buffer;
                    end
                    8'd15: begin
                        n_packet_TX[135:128] = TX_Packet_Data_Buffer;
                    end
                    8'd16: begin
                        n_packet_TX[143:136] = TX_Packet_Data_Buffer;
                    end
                    8'd17: begin
                        n_packet_TX[151:144] = TX_Packet_Data_Buffer;
                    end
                    8'd18: begin
                        n_packet_TX[159:152] = TX_Packet_Data_Buffer;
                    end
                    8'd19: begin
                        n_packet_TX[167:160] = TX_Packet_Data_Buffer;
                    end
                    8'd20: begin
                        n_packet_TX[175:168] = TX_Packet_Data_Buffer;
                    end
                    8'd21: begin
                        n_packet_TX[183:176] = TX_Packet_Data_Buffer;
                    end
                    8'd22: begin
                        n_packet_TX[191:184] = TX_Packet_Data_Buffer;
                    end
                    8'd23: begin
                        n_packet_TX[199:192] = TX_Packet_Data_Buffer;
                    end
                    8'd24: begin
                        n_packet_TX[207:200] = TX_Packet_Data_Buffer;
                    end
                    8'd25: begin
                        n_packet_TX[215:208] = TX_Packet_Data_Buffer;
                    end
                    8'd26: begin
                        n_packet_TX[223:216] = TX_Packet_Data_Buffer;
                    end
                    8'd27: begin
                        n_packet_TX[231:224] = TX_Packet_Data_Buffer;
                    end
                    8'd28: begin
                        n_packet_TX[239:232] = TX_Packet_Data_Buffer;
                    end
                    8'd29: begin
                        n_packet_TX[247:240] = TX_Packet_Data_Buffer;
                    end
                    8'd30: begin
                        n_packet_TX[255:248] = TX_Packet_Data_Buffer;
                    end
                    8'd31: begin
                        n_packet_TX[263:256] = TX_Packet_Data_Buffer;
                    end
                    8'd32: begin
                        n_packet_TX[271:264] = TX_Packet_Data_Buffer;
                    end
                    8'd33: begin
                        n_packet_TX[279:272] = TX_Packet_Data_Buffer;
                    end
                    8'd34: begin
                        n_packet_TX[287:280] = TX_Packet_Data_Buffer;
                    end
                    8'd35: begin
                        n_packet_TX[295:288] = TX_Packet_Data_Buffer;
                    end
                    8'd36: begin
                        n_packet_TX[303:296] = TX_Packet_Data_Buffer;
                    end
                    8'd37: begin
                        n_packet_TX[311:304] = TX_Packet_Data_Buffer;
                    end
                    8'd38: begin
                        n_packet_TX[319:312] = TX_Packet_Data_Buffer;
                    end
                    8'd39: begin
                        n_packet_TX[327:320] = TX_Packet_Data_Buffer;
                    end
                    8'd40: begin
                        n_packet_TX[335:328] = TX_Packet_Data_Buffer;
                    end
                    8'd41: begin
                        n_packet_TX[343:336] = TX_Packet_Data_Buffer;
                    end
                    8'd42: begin
                        n_packet_TX[351:344] = TX_Packet_Data_Buffer;
                    end
                    8'd43: begin
                        n_packet_TX[359:352] = TX_Packet_Data_Buffer;
                    end
                    8'd44: begin
                        n_packet_TX[367:360] = TX_Packet_Data_Buffer;
                    end
                    8'd45: begin
                        n_packet_TX[375:368] = TX_Packet_Data_Buffer;
                    end
                    8'd46: begin
                        n_packet_TX[383:376] = TX_Packet_Data_Buffer;
                    end
                    8'd47: begin
                        n_packet_TX[391:384] = TX_Packet_Data_Buffer;
                    end
                    8'd48: begin
                        n_packet_TX[399:392] = TX_Packet_Data_Buffer;
                    end
                    8'd49: begin
                        n_packet_TX[407:400] = TX_Packet_Data_Buffer;
                    end
                    8'd50: begin
                        n_packet_TX[415:408] = TX_Packet_Data_Buffer;
                    end
                    8'd51: begin
                        n_packet_TX[423:416] = TX_Packet_Data_Buffer;
                    end
                    8'd52: begin
                        n_packet_TX[431:424] = TX_Packet_Data_Buffer;
                    end
                    8'd53: begin
                        n_packet_TX[439:432] = TX_Packet_Data_Buffer;
                    end
                    8'd54: begin
                        n_packet_TX[447:440] = TX_Packet_Data_Buffer;
                    end
                    8'd55: begin
                        n_packet_TX[455:448] = TX_Packet_Data_Buffer;
                    end
                    8'd56: begin
                        n_packet_TX[463:456] = TX_Packet_Data_Buffer;
                    end
                    8'd57: begin
                        n_packet_TX[471:464] = TX_Packet_Data_Buffer;
                    end
                    8'd58: begin
                        n_packet_TX[479:472] = TX_Packet_Data_Buffer;
                    end
                    8'd59: begin
                        n_packet_TX[487:480] = TX_Packet_Data_Buffer;
                    end
                    8'd60: begin
                        n_packet_TX[495:488] = TX_Packet_Data_Buffer;
                    end
                    8'd61: begin
                        n_packet_TX[503:496] = TX_Packet_Data_Buffer;
                    end
                    8'd62: begin
                        n_packet_TX[511:504] = TX_Packet_Data_Buffer;
                    end
                    8'd63: begin
                        n_packet_TX[519:512] = TX_Packet_Data_Buffer;
                    end
                    8'd64: begin
                        n_packet_TX[527:520] = TX_Packet_Data_Buffer;
                    end
                    8'd65: begin
                        n_packet_TX[535:528] = TX_Packet_Data_Buffer;
                    end
                    8'd66: begin
                        n_packet_TX[543:536] = TX_Packet_Data_Buffer;
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

