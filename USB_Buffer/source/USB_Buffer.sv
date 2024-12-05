`timescale 1ns / 10ps

module USB_Buffer(
    input logic clk, n_rst,
    input logic Store_TX_Data, Store_RX_Packet_Data, 
    input logic Get_TX_Packet_Data, Get_RX_Data,
    input logic flush, clear,
    input logic [7:0] TX_Data, RX_Packet_Data,
    output logic [6:0] Buffer_Occupancy,
    output logic [7:0] TX_Packet_Data, RX_Data
);
    logic queue_DB, pop_DB;
    logic [511:0] n_DB;
    logic [511:0] c_DB;

    logic [7:0] new_byte;
    logic bo_flag;

    logic [7:0] n_TX_Packet_Data, n_RX_Data;

    logic flush_clear;

    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            c_DB <= 512'b0;
            TX_Packet_Data <= 8'b0;
            RX_Data <= 8'b0;
        end
        else begin
            c_DB <= n_DB;
            TX_Packet_Data <= n_TX_Packet_Data;
            RX_Data <= n_RX_Data;
        end
    end

    always_comb begin // n_DB
        n_DB = c_DB;
        new_byte = 8'b0;
        queue_DB = 1'b0;
        flush_clear = 1'b0;

        if(flush || clear) begin
            n_DB = 512'b0;
            flush_clear = 1'b1;
        end

        if(pop_DB) begin
            n_DB[503:0] = c_DB[511:8];
        end
        
        if(Store_TX_Data || Store_RX_Packet_Data) begin
            if(Store_TX_Data) begin
                new_byte = TX_Data;
                queue_DB = 1'b1;
            end
            else if(Store_RX_Packet_Data) begin
                new_byte = RX_Packet_Data;
                queue_DB = 1'b1;
            end

            case(Buffer_Occupancy) 
                7'd0: begin
                    n_DB[7:0] = new_byte;
                end
                7'd1: begin
                    n_DB[15:8] = new_byte;
                end
                7'd2: begin
                    n_DB[23:16] = new_byte;
                end
                7'd3: begin
                    n_DB[31:24] = new_byte;
                end
                7'd4: begin
                    n_DB[39:32] = new_byte;
                end
                7'd5: begin
                    n_DB[47:40] = new_byte;
                end
                7'd6: begin
                    n_DB[55:48] = new_byte;
                end
                7'd7: begin
                    n_DB[63:56] = new_byte;
                end
                7'd8: begin
                    n_DB[71:64] = new_byte;
                end
                7'd9: begin
                    n_DB[79:72] = new_byte;
                end
                7'd10: begin
                    n_DB[87:80] = new_byte;
                end
                7'd11: begin
                    n_DB[95:88] = new_byte;
                end
                7'd12: begin
                    n_DB[103:96] = new_byte;
                end
                7'd13: begin
                    n_DB[111:104] = new_byte;
                end
                7'd14: begin
                    n_DB[119:112] = new_byte;
                end
                7'd15: begin
                    n_DB[127:120] = new_byte;
                end
                7'd16: begin
                    n_DB[135:128] = new_byte;
                end
                7'd17: begin
                    n_DB[143:136] = new_byte;
                end
                7'd18: begin
                    n_DB[151:144] = new_byte;
                end
                7'd19: begin
                    n_DB[159:152] = new_byte;
                end
                7'd20: begin
                    n_DB[167:160] = new_byte;
                end
                7'd21: begin
                    n_DB[175:168] = new_byte;
                end
                7'd22: begin
                    n_DB[183:176] = new_byte;
                end
                7'd23: begin
                    n_DB[191:184] = new_byte;
                end
                7'd24: begin
                    n_DB[199:192] = new_byte;
                end
                7'd25: begin
                    n_DB[207:200] = new_byte;
                end
                7'd26: begin
                    n_DB[215:208] = new_byte;
                end
                7'd27: begin
                    n_DB[223:216] = new_byte;
                end
                7'd28: begin
                    n_DB[231:224] = new_byte;
                end
                7'd29: begin
                    n_DB[239:232] = new_byte;
                end
                7'd30: begin
                    n_DB[247:240] = new_byte;
                end
                7'd31: begin
                    n_DB[255:248] = new_byte;
                end
                7'd32: begin
                    n_DB[263:256] = new_byte;
                end
                7'd33: begin
                    n_DB[271:264] = new_byte;
                end
                7'd34: begin
                    n_DB[279:272] = new_byte;
                end
                7'd35: begin
                    n_DB[287:280] = new_byte;
                end
                7'd36: begin
                    n_DB[295:288] = new_byte;
                end
                7'd37: begin
                    n_DB[303:296] = new_byte;
                end
                7'd38: begin
                    n_DB[311:304] = new_byte;
                end
                7'd39: begin
                    n_DB[319:312] = new_byte;
                end
                7'd40: begin
                    n_DB[327:320] = new_byte;
                end
                7'd41: begin
                    n_DB[335:328] = new_byte;
                end
                7'd42: begin
                    n_DB[343:336] = new_byte;
                end
                7'd43: begin
                    n_DB[351:344] = new_byte;
                end
                7'd44: begin
                    n_DB[359:352] = new_byte;
                end
                7'd45: begin
                    n_DB[367:360] = new_byte;
                end
                7'd46: begin
                    n_DB[375:368] = new_byte;
                end
                7'd47: begin
                    n_DB[383:376] = new_byte;
                end
                7'd48: begin
                    n_DB[391:384] = new_byte;
                end
                7'd49: begin
                    n_DB[399:392] = new_byte;
                end
                7'd50: begin
                    n_DB[407:400] = new_byte;
                end
                7'd51: begin
                    n_DB[415:408] = new_byte;
                end
                7'd52: begin
                    n_DB[423:416] = new_byte;
                end
                7'd53: begin
                    n_DB[431:424] = new_byte;
                end
                7'd54: begin
                    n_DB[439:432] = new_byte;
                end
                7'd55: begin
                    n_DB[447:440] = new_byte;
                end
                7'd56: begin
                    n_DB[455:448] = new_byte;
                end
                7'd57: begin
                    n_DB[463:456] = new_byte;
                end
                7'd58: begin
                    n_DB[471:464] = new_byte;
                end
                7'd59: begin
                    n_DB[479:472] = new_byte;
                end
                7'd60: begin
                    n_DB[487:480] = new_byte;
                end
                7'd61: begin
                    n_DB[495:488] = new_byte;
                end
                7'd62: begin
                    n_DB[503:496] = new_byte;
                end
                7'd63: begin
                    n_DB[511:504] = new_byte;
                end
                
            endcase
        end
        
    end

    always_comb begin // Output
        n_TX_Packet_Data = 8'b0;
        n_RX_Data = 8'b0;
        pop_DB = 1'b0;
        if(Get_TX_Packet_Data) begin
            n_TX_Packet_Data = c_DB[7:0];
            pop_DB = 1'b1;
        end
        else if(Get_RX_Data) begin
            n_RX_Data = c_DB[7:0];
            pop_DB = 1'b1;
        end
    end

    USB_Buffer_Counter BUFF_OCCU ( 
        .clk(clk), .n_rst(n_rst), .clear(flush_clear), 
        .countUP_enable((queue_DB) && (Buffer_Occupancy != 7'd64)), .countDOWN_enable((pop_DB) && (Buffer_Occupancy)), .rollover_val(7'd65),
        .count_out(Buffer_Occupancy), .rollover_flag(bo_flag)
    );

endmodule