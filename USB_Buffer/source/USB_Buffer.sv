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

            if(Buffer_Occupancy == 7'd0) begin
                n_DB[7:0] = new_byte;
            end
            else if(Buffer_Occupancy == 7'd1) begin
                n_DB[15:8] = new_byte;
            end
            else if(Buffer_Occupancy == 7'd2) begin
                n_DB[23:16] = new_byte;
            end
            else if(Buffer_Occupancy == 7'd3) begin
                n_DB[31:24] = new_byte;
            end
            else if(Buffer_Occupancy == 7'd4) begin
                n_DB[39:32] = new_byte;
            end
            else if(Buffer_Occupancy == 7'd5) begin
                n_DB[47:40] = new_byte;
            end
            else if(Buffer_Occupancy == 7'd6) begin
                n_DB[55:48] = new_byte;
            end
            else if(Buffer_Occupancy == 7'd7) begin
                n_DB[63:56] = new_byte;
            end
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
        .countUP_enable(queue_DB), .countDOWN_enable(pop_DB), .rollover_val(7'd64),
        .count_out(Buffer_Occupancy), .rollover_flag(bo_flag)
    );

endmodule